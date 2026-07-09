package com.attriax.attriax_flutter_android

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Handler
import android.os.Looper
import com.attriax.sdk.Attriax
import com.attriax.sdk.AttriaxAdEventType
import com.attriax.sdk.AttriaxAttStatus
import com.attriax.sdk.AttriaxConfig
import com.attriax.sdk.AttriaxDeepLinkEvent
import com.attriax.sdk.AttriaxDeepLinkListener
import com.attriax.sdk.AttriaxNotificationEventSource
import com.attriax.sdk.AttriaxNotificationEventType
import com.attriax.sdk.AttriaxRawDeepLinkEvent
import com.attriax.sdk.AttriaxRawDeepLinkListener
import com.attriax.sdk.AttriaxSdk
import com.attriax.sdk.AttriaxSdkSnapshot
import com.attriax.sdk.AttriaxSkanCoarseValue
import com.attriax.sdk.AttriaxSkanState
import com.attriax.sdk.AttriaxSkanUpdateResult
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
 * [AttriaxSdk] — and implements the expanded platform-interface command surface by
 * delegating to the engine (and its `tracking` / `consent` / `skan` / `deepLinks`
 * sub-surfaces) OFF the platform thread, bridging the engine's synchronization-state
 * + deep-link events to their [EventChannel]s. The old native signal-provider code
 * (device context, install-referrer, crash reporting, UA) is superseded by the KMP
 * androidMain adapters; only genuinely wrapper-side Android concerns remain — the
 * Play-Services advertising-id supplier and the in-app browser Activity.
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
        val a = call.arguments as? Map<*, *> ?: emptyMap<String, Any?>()

        when (call.method) {
            // ---- lifecycle ----
            "initialize" -> initialize(a, result)
            "flush" -> run(result) { it.flush(); null }
            "reset" -> run(result) { it.reset(); null }
            "dispose" -> run(result) {
                detachListeners(it)
                it.dispose()
                engine = null
                null
            }
            "submitAsaToken" -> run(result) { it.submitAsaToken(str(a, "token") ?: ""); null }

            // ---- primitive getters / setters ----
            "getDeviceId" -> run(result) { it.deviceId }
            "getIsInitialized" -> run(result) { it.isInitialized }
            "getIsFirstLaunch" -> run(result) { it.isFirstLaunch }
            "getSdkEnabled" -> run(result) { it.enabled }
            "setSdkEnabled" -> run(result) { it.enabled = bool(a, "enabled", true); null }
            "getAnonymousTracking" -> run(result) { it.anonymousTrackingEnabled }
            "setAnonymousTracking" -> run(result) { it.anonymousTrackingEnabled = bool(a, "enabled", true); null }
            "getEventTrackingEnabled" -> run(result) { it.tracking.enabled }
            "getIsSynchronized" -> run(result) { it.synchronization.isSynchronized }
            "getIsWaitingForGdprConsent" -> run(result) { it.consent.gdpr.isWaitingForConsent }
            "getSdkSnapshot" -> run(result) { serializeSnapshot(it.sdkSnapshot) }
            "getSkanState" -> run(result) { serializeSkanState(it.skan.state) }

            // ---- tracking ----
            "recordEvent" -> run(result) {
                it.recordEvent(
                    name = str(a, "name") ?: "",
                    eventData = map(a, "eventData"),
                    flushImmediately = bool(a, "flushImmediately", false),
                )
                null
            }
            "recordPageView" -> run(result) {
                it.tracking.recordPageView(
                    pageName = str(a, "pageName") ?: "",
                    pageClass = str(a, "pageClass"),
                    pageTitle = str(a, "pageTitle"),
                    previousPageName = str(a, "previousPageName"),
                    parameters = map(a, "parameters"),
                    source = str(a, "source") ?: "manual",
                    flushImmediately = bool(a, "flushImmediately", false),
                )
                null
            }
            "recordPurchase" -> run(result) {
                it.tracking.recordPurchase(
                    revenue = double(a, "revenue", 0.0),
                    currency = str(a, "currency") ?: "USD",
                    revenueInMicros = bool(a, "revenueInMicros", false),
                    purchaseType = str(a, "purchaseType"),
                    productId = str(a, "productId"),
                    transactionId = str(a, "transactionId"),
                    originalTransactionId = str(a, "originalTransactionId"),
                    validationProvider = str(a, "validationProvider"),
                    validationEnvironment = str(a, "validationEnvironment"),
                    purchaseToken = str(a, "purchaseToken"),
                    receiptData = str(a, "receiptData"),
                    signedPayload = str(a, "signedPayload"),
                    receiptSignature = str(a, "receiptSignature"),
                    isRenewal = kbool(a, "isRenewal"),
                    quantity = int(a, "quantity", 1),
                    store = str(a, "store"),
                    packageName = str(a, "packageName"),
                    voided = kbool(a, "voided"),
                    test = kbool(a, "test"),
                    validationId = str(a, "validationId"),
                    metadata = map(a, "metadata"),
                    flushImmediately = bool(a, "flushImmediately", true),
                )
                null
            }
            "recordRefund" -> run(result) {
                it.tracking.recordRefund(
                    revenue = double(a, "revenue", 0.0),
                    currency = str(a, "currency") ?: "USD",
                    revenueInMicros = bool(a, "revenueInMicros", false),
                    purchaseType = str(a, "purchaseType"),
                    productId = str(a, "productId"),
                    transactionId = str(a, "transactionId"),
                    originalTransactionId = str(a, "originalTransactionId"),
                    quantity = int(a, "quantity", 1),
                    store = str(a, "store"),
                    packageName = str(a, "packageName"),
                    voided = kbool(a, "voided"),
                    test = kbool(a, "test"),
                    reason = str(a, "reason"),
                    metadata = map(a, "metadata"),
                    flushImmediately = bool(a, "flushImmediately", true),
                )
                null
            }
            "recordAdRevenue" -> run(result) {
                it.tracking.recordAdRevenue(
                    revenue = double(a, "revenue", 0.0),
                    currency = str(a, "currency") ?: "USD",
                    revenueInMicros = bool(a, "revenueInMicros", false),
                    adNetwork = str(a, "adNetwork"),
                    adFormat = str(a, "adFormat"),
                    adType = str(a, "adType"),
                    adPlacement = str(a, "adPlacement"),
                    test = kbool(a, "test"),
                    metadata = map(a, "metadata"),
                    flushImmediately = bool(a, "flushImmediately", true),
                )
                null
            }
            "recordAdEvent" -> run(result) {
                // The platform-interface sends the resolved reserved event name
                // (`eventName`, e.g. "ad_show_failed"); resolve it back to the enum
                // whose `eventName` matches so the engine's field->eventData lowering
                // runs. Unknown names fall back to REQUEST.
                it.tracking.recordAdEvent(
                    type = adEventType(str(a, "eventName")),
                    adNetwork = str(a, "adNetwork"),
                    mediationNetwork = str(a, "mediationNetwork"),
                    adUnitId = str(a, "adUnitId"),
                    adPlacement = str(a, "adPlacement"),
                    adFormat = str(a, "adFormat"),
                    adType = str(a, "adType"),
                    failureReason = str(a, "failureReason"),
                    loadLatencyMs = kdouble(a, "loadLatencyMs"),
                    rewardType = str(a, "rewardType"),
                    rewardAmount = kdouble(a, "rewardAmount"),
                    test = kbool(a, "test"),
                    metadata = map(a, "metadata"),
                    flushImmediately = bool(a, "flushImmediately", true),
                )
                null
            }
            "recordNotification" -> run(result) {
                it.tracking.recordNotification(
                    type = notificationType(str(a, "type")),
                    notificationId = str(a, "notificationId") ?: "",
                    linkId = str(a, "linkId"),
                    campaignId = str(a, "campaignId"),
                    title = str(a, "title"),
                    source = notificationSource(str(a, "source")),
                    payload = map(a, "payload"),
                    metadata = map(a, "metadata"),
                    flushImmediately = bool(a, "flushImmediately", false),
                )
                null
            }
            "recordError" -> run(result) {
                it.tracking.recordError(
                    error = Throwable(str(a, "message") ?: str(a, "error") ?: "error"),
                    stackTrace = str(a, "stackTrace"),
                    fatal = bool(a, "fatal", false),
                    source = str(a, "source") ?: "manual",
                    reason = str(a, "reason"),
                    metadata = map(a, "metadata"),
                )
                null
            }
            "setUser" -> run(result) {
                it.tracking.setUser(userId = str(a, "userId"), userName = str(a, "userName"))
                null
            }
            "setUserProperty" -> run(result) {
                it.tracking.setUserProperty(str(a, "name") ?: "", a["value"])
                null
            }
            "setUserProperties" -> run(result) {
                it.tracking.setUserProperties(map(a, "properties") ?: emptyMap())
                null
            }
            "clearUserProperties" -> run(result) {
                it.tracking.clearUserProperties(strList(a, "propertyNames"))
                null
            }
            "registerPushToken" -> run(result) {
                val token = str(a, "token")
                val metadata = map(a, "metadata")
                if (str(a, "provider") == "apns") {
                    it.tracking.registerApplePushToken(token, metadata)
                } else {
                    it.tracking.registerFirebaseMessagingToken(token, metadata)
                }
                null
            }

            // ---- consent (GDPR / CCPA / ATT) ----
            "setGdprConsent" -> run(result) {
                it.consent.gdpr.setConsent(
                    analytics = bool(a, "analytics", false),
                    attribution = bool(a, "attribution", false),
                    adEvents = bool(a, "adEvents", false),
                )
                null
            }
            "setGdprConsentNotRequired" -> run(result) { it.consent.gdpr.setNotRequired(); null }
            "resetGdprConsent" -> run(result) { it.consent.gdpr.reset(); null }
            "requestGdprDataErasure" -> run(result) { it.consent.gdpr.requestDataErasure(); null }
            "setCcpaConsent" -> run(result) {
                it.consent.ccpa.set(doNotSell = kbool(a, "doNotSell"), usPrivacy = str(a, "usPrivacy"))
                null
            }
            "setTrackingAuthorizationStatus" -> run(result) {
                it.consent.att.setStatus(attStatus(str(a, "status")))
                null
            }

            // ---- SKAN ----
            "updateSkanConversionValue" -> run(result) {
                serializeSkanResult(
                    it.skan.updateConversionValue(
                        fineValue = int(a, "fineValue", 0),
                        coarseValue = coarse(str(a, "coarseValue")),
                        lockWindow = bool(a, "lockWindow", false),
                    ),
                )
            }

            // ---- deep links ----
            "handleIncomingLink" -> run(result) {
                it.deepLinks.handleUri(
                    rawUri = str(a, "uri") ?: "",
                    isInitialLink = bool(a, "isInitialLink", false),
                )
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
    // Serialization (best-effort; validated against the Dart parsers when the facade
    // rewire activates the native runtime path — mirrors the iOS binding).
    // ---------------------------------------------------------------------------

    private fun serializeSkanResult(r: AttriaxSkanUpdateResult): Map<String, Any?> = mapOf(
        "status" to r.status.wireValue,
        "message" to r.message,
        "fineValue" to r.fineValue,
        "coarseValue" to r.coarseValue?.wireValue,
        "lockWindow" to r.lockWindow,
    )

    private fun serializeSkanState(s: AttriaxSkanState?): Map<String, Any?>? {
        if (s == null) return null
        return mapOf(
            "enabled" to s.enabled,
            "fineValue" to s.fineValue,
            "coarseValue" to s.coarseValue?.wireValue,
            "lockWindow" to s.lockWindow,
        )
    }

    private fun serializeSnapshot(s: AttriaxSdkSnapshot): Map<String, Any?> = mapOf(
        "apiVersion" to s.apiVersion,
        "packageVersion" to s.packageVersion,
        "metadata" to s.metadata,
    )

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

    private fun reply(action: () -> Unit) = mainHandler.post(action)

    private fun str(m: Map<*, *>, key: String): String? = m[key] as? String

    private fun bool(m: Map<*, *>, key: String, default: Boolean): Boolean = m[key] as? Boolean ?: default

    private fun kbool(m: Map<*, *>, key: String): Boolean? = m[key] as? Boolean

    private fun int(m: Map<*, *>, key: String, default: Int): Int = (m[key] as? Number)?.toInt() ?: default

    private fun long(m: Map<*, *>, key: String, default: Long): Long = (m[key] as? Number)?.toLong() ?: default

    private fun double(m: Map<*, *>, key: String, default: Double): Double =
        (m[key] as? Number)?.toDouble() ?: default

    private fun kdouble(m: Map<*, *>, key: String): Double? = (m[key] as? Number)?.toDouble()

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

    private fun coarse(wire: String?): AttriaxSkanCoarseValue? {
        val normalized = wire?.lowercase() ?: return null
        return AttriaxSkanCoarseValue.entries.firstOrNull { it.wireValue == normalized }
    }

    private fun adEventType(eventName: String?): AttriaxAdEventType =
        AttriaxAdEventType.entries.firstOrNull { it.eventName == eventName } ?: AttriaxAdEventType.REQUEST

    private fun notificationType(wire: String?): AttriaxNotificationEventType =
        AttriaxNotificationEventType.entries.firstOrNull { it.wireValue == wire }
            ?: AttriaxNotificationEventType.RECEIVED

    private fun notificationSource(wire: String?): AttriaxNotificationEventSource? {
        if (wire == null) return null
        return AttriaxNotificationEventSource.entries.firstOrNull { it.wireValue == wire }
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
