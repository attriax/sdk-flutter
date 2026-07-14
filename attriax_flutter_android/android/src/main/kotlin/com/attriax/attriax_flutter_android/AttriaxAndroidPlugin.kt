package com.attriax.attriax_flutter_android

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Handler
import android.os.Looper
import com.attriax.sdk.Attriax
import com.attriax.sdk.AttriaxAttStatus
import com.attriax.sdk.AttriaxConfig
import com.attriax.sdk.AttriaxDeepLinkEvent
import com.attriax.sdk.AttriaxDeepLinkListener
import com.attriax.sdk.AttriaxDispatchResult
import com.attriax.sdk.AttriaxDispatcher
import com.attriax.sdk.AttriaxRawDeepLinkEvent
import com.attriax.sdk.AttriaxRawDeepLinkListener
import com.attriax.sdk.AttriaxSdk
import com.attriax.sdk.AttriaxSynchronizationState
import com.attriax.sdk.AttriaxSynchronizationStateListener
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.concurrent.Executors

/**
 * Android implementation of the Attriax Flutter plugin (Phase 2 re-wrap).
 *
 * The engine lives in the KMP core (shipped as the `com.attriax:core` Android AAR).
 * This plugin is a THIN shim: it holds the KMP [Attriax] engine — built via
 * [AttriaxSdk] — and forwards the platform-interface command surface to the core's
 * canonical [AttriaxDispatcher.execute] OFF the platform thread, mapping its
 * [AttriaxDispatchResult] onto the method-channel reply. Engine construction
 * (`initialize`) and teardown (`dispose`), the handful of commands whose Dart wire
 * shape has no faithful single dispatch mapping, and the Android-only browser open
 * stay hand-wired; the engine's synchronization-state + deep-link events are bridged
 * to their [EventChannel]s. The old native signal-provider code (device context,
 * install-referrer, crash reporting, UA) is superseded by the KMP androidMain
 * adapters; only genuinely wrapper-side Android concerns remain — the Play-Services
 * advertising-id supplier and the in-app browser Activity.
 *
 * This mirrors the iOS binding (`AttriaxIosPlugin.swift`) method-for-method.
 */
class AttriaxAndroidPlugin : FlutterPlugin, MethodCallHandler {

    private var channel: MethodChannel? = null
    private var appContext: Context? = null

    private var engine: Attriax? = null
    private val worker = Executors.newSingleThreadExecutor { runnable ->
        Thread(runnable, "attriax-plugin").apply { isDaemon = true }
    }
    private val mainHandler = Handler(Looper.getMainLooper())

    private val syncStream = AttriaxEventStream(mainHandler)
    private val deepLinkStream = AttriaxEventStream(mainHandler)
    private val rawDeepLinkStream = AttriaxEventStream(mainHandler)
    private val initialDeepLinkStream = AttriaxEventStream(mainHandler)

    private var syncListener: AttriaxSynchronizationStateListener? = null
    private var deepLinkListener: AttriaxDeepLinkListener? = null
    private var rawDeepLinkListener: AttriaxRawDeepLinkListener? = null

    // ---------------------------------------------------------------------------
    // Plugin lifecycle.
    // ---------------------------------------------------------------------------

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        appContext = binding.applicationContext
        val messenger = binding.binaryMessenger

        channel = MethodChannel(messenger, "attriax").apply { setMethodCallHandler(this@AttriaxAndroidPlugin) }

        EventChannel(messenger, "attriax/events/synchronization").setStreamHandler(syncStream)
        EventChannel(messenger, "attriax/events/deep_links").setStreamHandler(deepLinkStream)
        EventChannel(messenger, "attriax/events/raw_deep_links").setStreamHandler(rawDeepLinkStream)
        EventChannel(messenger, "attriax/events/initial_deep_link").setStreamHandler(initialDeepLinkStream)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
        engine?.let { detachListeners(it) }
        worker.shutdown()
    }

    // ---------------------------------------------------------------------------
    // Method channel.
    // ---------------------------------------------------------------------------

    override fun onMethodCall(call: MethodCall, result: Result) {
        @Suppress("UNCHECKED_CAST")
        val a = (call.arguments as? Map<String, Any?>) ?: emptyMap()

        when (call.method) {
            // ---- lifecycle: engine construction / teardown stay plugin-side ----
            // `execute` operates on an already-built engine, so it can neither create
            // (initialize) nor tear down (dispose) it.
            "initialize" -> initialize(a, result)
            "dispose" -> run(result) {
                detachListeners(it)
                it.dispose()
                engine = null
                null
            }

            // ---- Dart command names that ARE the canonical dispatch key ----
            // The arg Map flows straight through and the canonical `Ok.value` shape is
            // exactly what the Dart parsers already consume (snapshot / skan-state /
            // skan-update maps are byte-identical to the removed serializers).
            "flush", "reset",
            "getDeviceId", "getIsInitialized", "getIsFirstLaunch",
            "getAnonymousTracking", "setAnonymousTracking",
            "getIsSynchronized", "getIsWaitingForGdprConsent",
            "getSdkSnapshot", "getSkanState",
            "recordEvent", "recordPageView", "recordPurchase", "recordRefund",
            "recordAdRevenue", "recordNotification", "recordError",
            "setUser", "setUserProperty", "setUserProperties", "clearUserProperties",
            "setGdprConsent", "setGdprConsentNotRequired", "resetGdprConsent",
            "requestGdprDataErasure",
            "updateSkanConversionValue", "handleIncomingLink", "submitAsaToken",
            // Paired CCPA setter now has a dispatch key (execute() calls ccpa.set with
            // the same clear-omitted semantics), so it forwards like the rest.
            "setCcpaConsent" ->
                forward(result, call.method, a)

            // ---- Dart command names that differ from the dispatch key ----
            "getSdkEnabled" -> forward(result, "getEnabled", a)
            "setSdkEnabled" -> forward(result, "setEnabled", a)
            // The platform-interface sends the resolved reserved event name under
            // `eventName`; the dispatch table reads it under `type` (it resolves the
            // enum by name OR eventName), so alias it across before forwarding.
            "recordAdEvent" -> forward(result, "recordAdEvent", a + ("type" to a["eventName"]))
            // One Dart command → the provider-split registration dispatch keys.
            "registerPushToken" -> forward(
                result,
                if (str(a, "provider") == "apns") "registerApplePushToken" else "registerFirebaseMessagingToken",
                a,
            )

            // ---- kept engine-direct: genuinely wrapper-specific, not duplication ----
            // `tracking.enabled` has no dispatch key.
            "getEventTrackingEnabled" -> run(result) { it.tracking.enabled }
            // ATT stays direct on purpose: the Dart `AttriaxTrackingAuthorizationStatus`
            // is a RICHER enum (8 values incl. notSupported / disabled / timedOut) than
            // the engine's canonical 5-value `AttriaxAttStatus`, and snake_cased
            // (`not_determined`) vs the engine wireValue (`notDetermined`). The wrapper's
            // tolerant mapper normalizes 8→5; forwarding would relocate wrapper-only logic.
            "setTrackingAuthorizationStatus" -> run(result) {
                it.consent.att.setStatus(attStatus(str(a, "status")))
                null
            }

            // ---- Android-specific: in-app / external browser open ----
            // Kept as a genuine wrapper-side concern: the engine's browser opener only
            // fires an external ACTION_VIEW; the in-app WebView Activity is Android UX
            // the engine cannot own. Does not require the engine to be initialized.
            "openBrowserUrl" -> openBrowserUrl(a, result)

            else -> result.notImplemented()
        }
    }

    // ---------------------------------------------------------------------------
    // initialize.
    // ---------------------------------------------------------------------------

    private fun initialize(a: Map<*, *>, result: Result) {
        val configMap = a["config"] as? Map<*, *>
        if (configMap == null) {
            reply { result.error("bad_args", "initialize requires a config map", null) }
            return
        }
        val context = appContext
        if (context == null) {
            reply { result.error("no_context", "Attriax plugin is not attached to a context.", null) }
            return
        }
        worker.execute {
            try {
                val config = buildConfig(configMap)
                // No synthetic User-Agent: the KMP androidMain factory resolves + stamps
                // the real Android UA on its OkHttp transport. The advertising-id supplier
                // runs off the platform thread here (it binds the Play-Services AIDL).
                val created = AttriaxSdk.create(
                    context = context,
                    config = config,
                    advertisingIdSupplier = { AdvertisingIdProvider.fetch(context) },
                )
                created.init()
                engine = created
                attachListeners(created)
                reply { result.success(null) }
            } catch (t: Throwable) {
                reply { result.error("init_failed", t.message, null) }
            }
        }
    }

    private fun buildConfig(m: Map<*, *>): AttriaxConfig = AttriaxConfig(
        projectToken = str(m, "projectToken") ?: "",
        apiBaseUrl = str(m, "apiBaseUrl") ?: AttriaxConfig.DEFAULT_API_BASE_URL,
        appVersion = str(m, "appVersion"),
        appBuildNumber = str(m, "appBuildNumber"),
        appPackageName = str(m, "appPackageName"),
        sdkMetadata = map(m, "sdkMetadata"),
        // deviceContext: null — the androidMain factory auto-captures the non-sensitive
        // device fields; the wrapper has nothing extra Android cannot self-collect.
        deviceContext = null,
        enableDebugLogs = bool(m, "enableDebugLogs", false),
        requestTimeoutMs = long(m, "requestTimeoutMs", 12_000L),
        maxQueueSize = int(m, "maxQueueSize", 500),
        eventFlushIntervalMs = long(m, "eventFlushIntervalMs", 60_000L),
        flushEventsImmediatelyOnFirstLaunch = bool(m, "flushEventsImmediatelyOnFirstLaunch", true),
        collectAdvertisingId = bool(m, "collectAdvertisingId", true),
        automaticCrashReportingEnabled = bool(m, "automaticCrashReportingEnabled", true),
        gdprEnabled = bool(m, "gdprEnabled", false),
        anonymousTracking = bool(m, "anonymousTracking", true),
        sessionTrackingEnabled = bool(m, "sessionTrackingEnabled", true),
        sessionHeartbeatIntervalMs = long(m, "sessionHeartbeatIntervalMs", 300_000L),
        firstLaunchSessionHeartbeatIntervalMs = long(m, "firstLaunchSessionHeartbeatIntervalMs", 30_000L),
        // installReferrerEnabled / asaTokenCaptureEnabled are not in the Dart config
        // JSON; default them on (matching the KMP + Flutter defaults).
        installReferrerEnabled = bool(m, "installReferrerEnabled", true),
        attestationEnabled = bool(m, "attestationEnabled", false),
        // attestationProvider: left null. Play Integrity is opt-in and requires the
        // app to add `com.google.android.play:integrity`; wire it explicitly later.
        pinnedCertificateSha256Fingerprints = strList(m, "pinnedCertificateSha256Fingerprints") ?: emptyList(),
        automaticBrowserHandling = bool(m, "automaticBrowserHandling", true),
        requestTrackingAuthorizationOnInit = bool(m, "requestTrackingAuthorizationOnInit", false),
        trackingAuthorizationStatusTimeoutMs = long(m, "trackingAuthorizationStatusTimeoutMs", 60_000L),
        asaTokenCaptureEnabled = bool(m, "asaTokenCaptureEnabled", true),
        doNotSell = kbool(m, "doNotSell"),
        usPrivacy = str(m, "usPrivacy"),
    )

    // ---------------------------------------------------------------------------
    // Android-specific browser open.
    // ---------------------------------------------------------------------------

    private fun openBrowserUrl(a: Map<*, *>, result: Result) {
        val url = str(a, "url")
        if (url.isNullOrBlank()) {
            reply { result.success(false) }
            return
        }
        val context = appContext
        if (context == null) {
            reply { result.success(false) }
            return
        }
        reply {
            val opened = try {
                val intent = if (str(a, "openMode") == "external") {
                    Intent(Intent.ACTION_VIEW, Uri.parse(url)).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                } else {
                    Intent(context, AttriaxInAppBrowserActivity::class.java)
                        .putExtra(AttriaxInAppBrowserActivity.EXTRA_URL, url)
                        .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                context.startActivity(intent)
                true
            } catch (t: Throwable) {
                false
            }
            result.success(opened)
        }
    }

    // ---------------------------------------------------------------------------
    // Engine event listeners.
    // ---------------------------------------------------------------------------

    private fun attachListeners(engine: Attriax) {
        val sync = AttriaxSynchronizationStateListener { state -> syncStream.emit(state.name) }
        engine.synchronization.addStateListener(sync)
        syncListener = sync

        val deep = AttriaxDeepLinkListener { event -> deepLinkStream.emit(serializeDeepLinkEvent(event)) }
        engine.deepLinks.addListener(deep)
        deepLinkListener = deep

        val raw = AttriaxRawDeepLinkListener { event ->
            rawDeepLinkStream.emit(mapOf("uri" to event.uri.raw, "receivedAtMs" to event.receivedAtMs))
        }
        engine.deepLinks.addRawListener(raw)
        rawDeepLinkListener = raw
    }

    private fun detachListeners(engine: Attriax) {
        syncListener?.let { engine.synchronization.removeStateListener(it) }
        deepLinkListener?.let { engine.deepLinks.removeListener(it) }
        rawDeepLinkListener?.let { engine.deepLinks.removeRawListener(it) }
        syncListener = null
        deepLinkListener = null
        rawDeepLinkListener = null
    }

    // ---------------------------------------------------------------------------
    // Deep-link event serialization for the EventChannel. (Command-result shaping —
    // snapshot / skan-state / skan-update — now lives inside AttriaxDispatcher.)
    // ---------------------------------------------------------------------------

    private fun serializeDeepLinkEvent(e: AttriaxDeepLinkEvent): Map<String, Any?> = mapOf(
        "uri" to e.uri.raw,
        "status" to e.status.name,
        "trigger" to e.trigger.name,
        "found" to e.found,
        "handledBySdk" to e.handledBySdk,
        "isDeferred" to e.isDeferred,
        "isColdStart" to e.isColdStart,
        "isForeground" to e.isForeground,
        "data" to e.data,
    )

    // ---------------------------------------------------------------------------
    // Helpers.
    // ---------------------------------------------------------------------------

    private fun run(result: Result, block: (Attriax) -> Any?) {
        worker.execute {
            val e = engine
            if (e == null) {
                reply { result.error("not_initialized", "Attriax is not initialized", null) }
                return@execute
            }
            try {
                val value = block(e)
                reply { result.success(value) }
            } catch (t: Throwable) {
                reply { result.error("error", t.message, null) }
            }
        }
    }

    /**
     * Forward a command to the KMP core's canonical [AttriaxDispatcher.execute] off the
     * platform thread and map its [AttriaxDispatchResult] onto the reply. `execute` does
     * NOT catch engine exceptions, so — like the old hand-written dispatch — we wrap it
     * and convert a throw into the same `error` reply.
     */
    private fun forward(result: Result, method: String, args: Map<String, Any?>) {
        worker.execute {
            val e = engine
            if (e == null) {
                reply { result.error("not_initialized", "Attriax is not initialized", null) }
                return@execute
            }
            try {
                when (val outcome = AttriaxDispatcher.execute(e, method, args)) {
                    is AttriaxDispatchResult.Ok -> reply { result.success(outcome.value) }
                    is AttriaxDispatchResult.Err -> reply { result.error("error", outcome.message, null) }
                    is AttriaxDispatchResult.Unimplemented -> reply { result.notImplemented() }
                }
            } catch (t: Throwable) {
                reply { result.error("error", t.message, null) }
            }
        }
    }

    private fun reply(action: () -> Unit) = mainHandler.post(action)

    private fun str(m: Map<*, *>, key: String): String? = m[key] as? String

    private fun bool(m: Map<*, *>, key: String, default: Boolean): Boolean = m[key] as? Boolean ?: default

    private fun kbool(m: Map<*, *>, key: String): Boolean? = m[key] as? Boolean

    private fun int(m: Map<*, *>, key: String, default: Int): Int = (m[key] as? Number)?.toInt() ?: default

    private fun long(m: Map<*, *>, key: String, default: Long): Long = (m[key] as? Number)?.toLong() ?: default

    @Suppress("UNCHECKED_CAST")
    private fun map(m: Map<*, *>, key: String): Map<String, Any?>? = m[key] as? Map<String, Any?>

    private fun strList(m: Map<*, *>, key: String): List<String>? =
        (m[key] as? List<*>)?.mapNotNull { it as? String }

    private fun attStatus(wire: String?): AttriaxAttStatus = when (wire) {
        "authorized" -> AttriaxAttStatus.AUTHORIZED
        "denied" -> AttriaxAttStatus.DENIED
        "restricted" -> AttriaxAttStatus.RESTRICTED
        "not_determined", "notDetermined" -> AttriaxAttStatus.NOT_DETERMINED
        else -> AttriaxAttStatus.UNKNOWN
    }

    /**
     * A reusable [EventChannel.StreamHandler] that forwards values to the sink on the
     * main thread (Flutter requires event-sink calls on the platform thread).
     */
    private class AttriaxEventStream(private val mainHandler: Handler) : EventChannel.StreamHandler {
        @Volatile private var sink: EventChannel.EventSink? = null

        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
            sink = events
        }

        override fun onCancel(arguments: Any?) {
            sink = null
        }

        fun emit(value: Any?) {
            mainHandler.post { sink?.success(value) }
        }
    }
}
