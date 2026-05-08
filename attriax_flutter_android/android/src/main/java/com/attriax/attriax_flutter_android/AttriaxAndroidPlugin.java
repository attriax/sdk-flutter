package com.attriax.attriax_flutter_android;

import android.content.pm.PackageManager;
import android.content.pm.PackageInfo;
import android.content.pm.Signature;
import android.content.Context;
import android.content.Intent;
import android.content.pm.InstallSourceInfo;
import android.content.pm.verify.domain.DomainVerificationManager;
import android.content.pm.verify.domain.DomainVerificationUserState;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.provider.Settings;
import android.util.Log;
import androidx.annotation.NonNull;
import com.android.installreferrer.api.InstallReferrerClient;
import com.android.installreferrer.api.InstallReferrerStateListener;
import com.android.installreferrer.api.ReferrerDetails;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.NewIntentListener;
import java.security.MessageDigest;
import java.text.SimpleDateFormat;
import java.util.HashMap;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.Map.Entry;
import java.util.Map;
import java.util.TimeZone;
import java.util.concurrent.atomic.AtomicBoolean;
import android.content.SharedPreferences;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class AttriaxAndroidPlugin implements
    FlutterPlugin,
    MethodCallHandler,
    EventChannel.StreamHandler,
    ActivityAware,
    NewIntentListener {
    private static final String CHANNEL_NAME = "attriax";
    private static final String DEEP_LINK_EVENTS_CHANNEL = "attriax/deep_links/events";
    private static final String CRASH_PREFERENCES_NAME = "attriax.crashes";
    private static final String PENDING_CRASH_KEY = "attriax.pending_crash";

    private MethodChannel channel;
    private EventChannel deepLinkEventChannel;
    private EventChannel.EventSink deepLinkEventSink;
    private final Object deepLinkStateLock = new Object();
    private Context context;
    private ActivityPluginBinding activityBinding;
    private String initialLink;
    private boolean initialLinkSent = false;
    private String latestLink;
    private Thread.UncaughtExceptionHandler previousUncaughtExceptionHandler;
    private Thread.UncaughtExceptionHandler attriaxUncaughtExceptionHandler;
    private final AtomicBoolean crashHandlerInstalled = new AtomicBoolean(false);

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
        channel.setMethodCallHandler(this);
        deepLinkEventChannel = new EventChannel(
            binding.getBinaryMessenger(),
            DEEP_LINK_EVENTS_CHANNEL
        );
        deepLinkEventChannel.setStreamHandler(this);
        context = binding.getApplicationContext();
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        if (channel != null) {
            channel.setMethodCallHandler(null);
        }
        if (deepLinkEventChannel != null) {
            deepLinkEventChannel.setStreamHandler(null);
        }
        synchronized (deepLinkStateLock) {
            deepLinkEventSink = null;
        }
        restoreCrashReporter();
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "collectNativeContext":
                collectNativeContext(call, result);
                break;
            case "collectInstallReferrer":
                collectInstallReferrer(result);
                break;
            case "setAutomaticCrashReportingEnabled":
                setAutomaticCrashReportingEnabled(call, result);
                break;
            case "getTrackingAuthorizationStatus":
                result.success("not_supported");
                break;
            case "requestTrackingAuthorization":
                result.success("not_supported");
                break;
            case "consumePendingCrashReport":
                consumePendingCrashReport(result);
                break;
            case "getInitialLink":
                synchronized (deepLinkStateLock) {
                    result.success(initialLink);
                }
                break;
            case "getLatestLink":
                synchronized (deepLinkStateLock) {
                    result.success(latestLink);
                }
                break;
            default:
                result.notImplemented();
        }
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activityBinding = binding;
        binding.addOnNewIntentListener(this);
        handleIntent(binding.getActivity().getIntent());
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        onAttachedToActivity(binding);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity();
    }

    @Override
    public void onDetachedFromActivity() {
        if (activityBinding != null) {
            activityBinding.removeOnNewIntentListener(this);
        }
        activityBinding = null;
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        String initialLinkToEmit = null;
        synchronized (deepLinkStateLock) {
            deepLinkEventSink = events;

            if (!initialLinkSent && initialLink != null) {
                initialLinkSent = true;
                initialLinkToEmit = initialLink;
            }
        }

        if (initialLinkToEmit != null) {
            events.success(initialLinkToEmit);
        }
    }

    @Override
    public void onCancel(Object arguments) {
        synchronized (deepLinkStateLock) {
            deepLinkEventSink = null;
        }
    }

    @Override
    public boolean onNewIntent(@NonNull Intent intent) {
        return handleIntent(intent);
    }

    private void collectNativeContext(@NonNull MethodCall call, @NonNull Result result) {
        Map<String, Object> payload = new HashMap<>();
        Map<String, Object> metadata = new HashMap<>();
        boolean collectAdvertisingId = true;
        Object collectAdvertisingIdArgument = call.argument("collectAdvertisingId");
        if (collectAdvertisingIdArgument instanceof Boolean) {
            collectAdvertisingId = (Boolean) collectAdvertisingIdArgument;
        }

        // ANDROID_ID is shipped to the Attriax backend raw because the
        // backend now performs deterministic matching against click-time
        // values (which are also raw). Hashing here would defeat that
        // matching path. The value is treated as PII server-side: it is
        // never logged and never returned in analytics responses. See
        // GDPR notes on `app_users.androidId`.
        String rawAndroidId = Settings.Secure.getString(
            context.getContentResolver(),
            Settings.Secure.ANDROID_ID
        );
        if (rawAndroidId != null && !rawAndroidId.isEmpty()
                && !"9774d56d682e549c".equals(rawAndroidId)) {
            // 9774d56d682e549c is a known buggy value historically returned by
            // some Android 2.x devices and on factory-reset devices; treat
            // it as missing rather than persisting it as a duplicate id.
            payload.put("androidId", rawAndroidId);
        }

        if (collectAdvertisingId) {
            String advertisingId = AdvertisingIdProvider.fetch(context);
            if (advertisingId != null) {
                payload.put("advertisingId", advertisingId);
            }
        }
        metadata.put("source", "android_native");
        metadata.put("timezone", TimeZone.getDefault().getID());
        metadata.put("locale", Locale.getDefault().toLanguageTag());
        metadata.put("appVersion", readAppVersion());
        metadata.put("appBuildNumber", readAppBuildNumber());
        metadata.put("packageName", context.getPackageName());
        metadata.put("model", Build.MODEL);
        metadata.put("device", Build.DEVICE);
        metadata.put("product", Build.PRODUCT);
        metadata.put("brand", Build.BRAND);
        metadata.put("manufacturer", Build.MANUFACTURER);
        metadata.put("hardware", Build.HARDWARE);
        metadata.put("osVersion", Build.VERSION.RELEASE);
        metadata.put("isPhysicalDevice", !isProbablyEmulator());
        metadata.put("supportedAbis", Arrays.asList(Build.SUPPORTED_ABIS));
        metadata.put("supported32BitAbis", Arrays.asList(Build.SUPPORTED_32_BIT_ABIS));
        metadata.put("supported64BitAbis", Arrays.asList(Build.SUPPORTED_64_BIT_ABIS));

        try {
            PackageManager packageManager = context.getPackageManager();
            String installerPackageName = getInstallingPackageNameCompat(packageManager);
            metadata.put(
                "installerPackageName",
                installerPackageName
            );
        } catch (Exception exception) {
            metadata.put("installerPackageNameError", exception.getMessage());
        }

        appendSigningFingerprints(metadata);
        appendDomainVerificationState(metadata);

        payload.put("metadata", metadata);
        result.success(payload);
    }

    @SuppressWarnings("deprecation")
    private void appendSigningFingerprints(Map<String, Object> metadata) {
        try {
            PackageInfo packageInfo;

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                packageInfo = getPackageInfoCompat(
                    PackageManager.GET_SIGNING_CERTIFICATES
                );
            } else {
                packageInfo = getPackageInfoCompat(PackageManager.GET_SIGNATURES);
            }

            List<String> fingerprints = new ArrayList<>();

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P && packageInfo.signingInfo != null) {
                Signature[] signatures = packageInfo.signingInfo.hasMultipleSigners()
                    ? packageInfo.signingInfo.getApkContentsSigners()
                    : packageInfo.signingInfo.getSigningCertificateHistory();

                if (signatures != null) {
                    for (Signature signature : signatures) {
                        String fingerprint = toSha256Fingerprint(signature.toByteArray());
                        if (fingerprint != null && !fingerprints.contains(fingerprint)) {
                            fingerprints.add(fingerprint);
                        }
                    }
                }
            } else if (packageInfo.signatures != null) {
                for (Signature signature : packageInfo.signatures) {
                    String fingerprint = toSha256Fingerprint(signature.toByteArray());
                    if (fingerprint != null && !fingerprints.contains(fingerprint)) {
                        fingerprints.add(fingerprint);
                    }
                }
            }

            metadata.put("signingSha256Fingerprints", fingerprints);
        } catch (Exception exception) {
            metadata.put("signingSha256FingerprintError", exception.getMessage());
        }
    }

    private PackageInfo getPackageInfoCompat(long flags)
        throws PackageManager.NameNotFoundException {
        PackageManager packageManager = context.getPackageManager();
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            return packageManager.getPackageInfo(
                context.getPackageName(),
                PackageManager.PackageInfoFlags.of(flags)
            );
        }

        @SuppressWarnings("deprecation")
        PackageInfo packageInfo = packageManager.getPackageInfo(
            context.getPackageName(),
            (int) flags
        );
        return packageInfo;
    }

    private String getInstallingPackageNameCompat(PackageManager packageManager)
        throws PackageManager.NameNotFoundException {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            InstallSourceInfo installSourceInfo = packageManager.getInstallSourceInfo(
                context.getPackageName()
            );
            return installSourceInfo.getInstallingPackageName();
        }

        @SuppressWarnings("deprecation")
        String installerPackageName = packageManager.getInstallerPackageName(
            context.getPackageName()
        );
        return installerPackageName;
    }

    private long getPackageVersionCodeCompat(PackageInfo packageInfo) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            return packageInfo.getLongVersionCode();
        }

        try {
            Object versionCode = PackageInfo.class.getField("versionCode").get(packageInfo);
            if (versionCode instanceof Number) {
                return ((Number) versionCode).longValue();
            }
        } catch (NoSuchFieldException | IllegalAccessException ignored) {
        }

        return 0L;
    }

    private String readAppVersion() {
        try {
            PackageInfo packageInfo = getPackageInfoCompat(0);
            return packageInfo.versionName;
        } catch (Exception exception) {
            return null;
        }
    }

    private String readAppBuildNumber() {
        try {
            PackageInfo packageInfo = getPackageInfoCompat(0);
            long versionCode = getPackageVersionCodeCompat(packageInfo);
            return Long.toString(versionCode);
        } catch (Exception exception) {
            return null;
        }
    }

    private boolean isProbablyEmulator() {
        return Build.FINGERPRINT.startsWith("generic")
            || Build.FINGERPRINT.startsWith("unknown")
            || Build.MODEL.contains("google_sdk")
            || Build.MODEL.contains("Emulator")
            || Build.MODEL.contains("Android SDK built for x86")
            || Build.MANUFACTURER.contains("Genymotion")
            || Build.BRAND.startsWith("generic") && Build.DEVICE.startsWith("generic")
            || "google_sdk".equals(Build.PRODUCT);
    }

    private void appendDomainVerificationState(Map<String, Object> metadata) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
            return;
        }

        try {
            DomainVerificationManager manager = context.getSystemService(
                DomainVerificationManager.class
            );

            if (manager == null) {
                return;
            }

            DomainVerificationUserState userState = manager.getDomainVerificationUserState(
                context.getPackageName()
            );

            if (userState == null) {
                return;
            }

            Map<String, Object> domainVerification = new HashMap<>();
            Map<String, String> hostStates = new HashMap<>();

            for (Entry<String, Integer> entry : userState.getHostToStateMap().entrySet()) {
                hostStates.put(entry.getKey(), domainStateToString(entry.getValue()));
            }

            domainVerification.put("hostStates", hostStates);
            domainVerification.put("linkHandlingAllowed", userState.isLinkHandlingAllowed());
            metadata.put("domainVerification", domainVerification);
        } catch (Exception exception) {
            metadata.put("domainVerificationError", exception.getMessage());
        }
    }

    private String toSha256Fingerprint(byte[] certificateBytes) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(certificateBytes);
            StringBuilder builder = new StringBuilder();

            for (int index = 0; index < hash.length; index++) {
                if (index > 0) {
                    builder.append(':');
                }
                builder.append(String.format(Locale.US, "%02X", hash[index]));
            }

            return builder.toString();
        } catch (Exception exception) {
            return null;
        }
    }

    /**
     * @deprecated Kept around to keep the existing unit test compiling
     * while the new raw-id flow lands. Will be removed in a follow-up
     * release once the backend rollout has soaked. New callers must
     * use raw `Settings.Secure.ANDROID_ID` and let the backend handle
     * matching directly.
     */
    @Deprecated
    private String hashAndroidId(String rawAndroidId, String packageName) {
        if (rawAndroidId == null || rawAndroidId.isEmpty()) {
            return null;
        }
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            String salted = (packageName == null ? "" : packageName) + ":" + rawAndroidId;
            byte[] hash = digest.digest(salted.getBytes("UTF-8"));
            StringBuilder builder = new StringBuilder(hash.length * 2);
            for (int index = 0; index < hash.length; index++) {
                builder.append(String.format(Locale.US, "%02x", hash[index]));
            }
            return builder.toString();
        } catch (Exception exception) {
            return null;
        }
    }

    private String domainStateToString(int state) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
            return "unsupported";
        }

        switch (state) {
            case DomainVerificationUserState.DOMAIN_STATE_NONE:
                return "none";
            case DomainVerificationUserState.DOMAIN_STATE_SELECTED:
                return "selected";
            case DomainVerificationUserState.DOMAIN_STATE_VERIFIED:
                return "verified";
            default:
                return "unknown_" + state;
        }
    }

    private void installCrashReporter() {
        if (context == null || !crashHandlerInstalled.compareAndSet(false, true)) {
            return;
        }

        previousUncaughtExceptionHandler = Thread.getDefaultUncaughtExceptionHandler();
        attriaxUncaughtExceptionHandler = (thread, throwable) -> {
            try {
                persistPendingCrashReport(thread, throwable);
            } catch (Exception ignored) {
            }

            if (previousUncaughtExceptionHandler != null
                    && previousUncaughtExceptionHandler != attriaxUncaughtExceptionHandler) {
                previousUncaughtExceptionHandler.uncaughtException(thread, throwable);
            } else {
                android.os.Process.killProcess(android.os.Process.myPid());
                System.exit(10);
            }
        };
        Thread.setDefaultUncaughtExceptionHandler(attriaxUncaughtExceptionHandler);
    }

    private void setAutomaticCrashReportingEnabled(
        @NonNull MethodCall call,
        @NonNull Result result
    ) {
        Object enabledArgument = call.argument("enabled");
        boolean enabled = enabledArgument instanceof Boolean && (Boolean) enabledArgument;
        if (enabled) {
            installCrashReporter();
        } else {
            restoreCrashReporter();
        }
        result.success(null);
    }

    private void restoreCrashReporter() {
        if (!crashHandlerInstalled.compareAndSet(true, false)) {
            return;
        }

        if (Thread.getDefaultUncaughtExceptionHandler() == attriaxUncaughtExceptionHandler) {
            Thread.setDefaultUncaughtExceptionHandler(previousUncaughtExceptionHandler);
        }
        attriaxUncaughtExceptionHandler = null;
        previousUncaughtExceptionHandler = null;
    }

    private void persistPendingCrashReport(Thread thread, Throwable throwable) {
        if (context == null) {
            return;
        }

        Map<String, Object> metadata = new HashMap<>();
        metadata.put("threadName", thread.getName());
        metadata.put("threadId", thread.getId());
        metadata.put("androidApiLevel", Build.VERSION.SDK_INT);
        metadata.put("deviceModel", Build.MODEL);
        metadata.put("deviceManufacturer", Build.MANUFACTURER);

        Map<String, Object> payload = new HashMap<>();
        payload.put("source", "android_uncaught_exception");
        payload.put("isFatal", true);
        payload.put("exceptionType", throwable.getClass().getName());
        payload.put(
            "message",
            throwable.getMessage() == null ? throwable.toString() : throwable.getMessage()
        );
        payload.put("stackTrace", Log.getStackTraceString(throwable));
        payload.put("occurredAt", isoTimestamp(System.currentTimeMillis()));
        payload.put("reason", "Uncaught exception on thread " + thread.getName());
        payload.put("metadata", metadata);

        boolean persisted = crashPreferences()
            .edit()
            .putString(PENDING_CRASH_KEY, new JSONObject(payload).toString())
            .commit();
        if (!persisted) {
            Log.w("Attriax", "Failed to persist pending crash report.");
        }
    }

    private void consumePendingCrashReport(@NonNull Result result) {
        String raw = crashPreferences().getString(PENDING_CRASH_KEY, null);
        if (raw == null || raw.isEmpty()) {
            result.success(null);
            return;
        }

        crashPreferences().edit().remove(PENDING_CRASH_KEY).commit();
        try {
            result.success(jsonObjectToMap(new JSONObject(raw)));
        } catch (JSONException exception) {
            result.success(null);
        }
    }

    private SharedPreferences crashPreferences() {
        return context.getSharedPreferences(CRASH_PREFERENCES_NAME, Context.MODE_PRIVATE);
    }

    private String isoTimestamp(long millis) {
        SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US);
        formatter.setTimeZone(TimeZone.getTimeZone("UTC"));
        return formatter.format(new Date(millis));
    }

    private Map<String, Object> jsonObjectToMap(JSONObject object) throws JSONException {
        Map<String, Object> map = new HashMap<>();
        JSONArray names = object.names();
        if (names == null) {
            return map;
        }

        for (int index = 0; index < names.length(); index += 1) {
            String key = names.getString(index);
            Object value = object.get(key);
            if (value instanceof JSONObject) {
                map.put(key, jsonObjectToMap((JSONObject) value));
            } else if (value instanceof JSONArray) {
                map.put(key, jsonArrayToList((JSONArray) value));
            } else if (value == JSONObject.NULL) {
                map.put(key, null);
            } else {
                map.put(key, value);
            }
        }

        return map;
    }

    private List<Object> jsonArrayToList(JSONArray array) throws JSONException {
        List<Object> values = new ArrayList<>();
        for (int index = 0; index < array.length(); index += 1) {
            Object value = array.get(index);
            if (value instanceof JSONObject) {
                values.add(jsonObjectToMap((JSONObject) value));
            } else if (value instanceof JSONArray) {
                values.add(jsonArrayToList((JSONArray) value));
            } else if (value == JSONObject.NULL) {
                values.add(null);
            } else {
                values.add(value);
            }
        }

        return values;
    }

    private void collectInstallReferrer(@NonNull Result result) {
        AtomicBoolean completed = new AtomicBoolean(false);

        final InstallReferrerClient referrerClient;
        try {
            referrerClient = InstallReferrerClient.newBuilder(context).build();
        } catch (Exception exception) {
            Map<String, Object> metadata = createInstallReferrerMetadata();
            metadata.put("installReferrerError", exception.getMessage());
            if (!completed.compareAndSet(false, true)) {
                return;
            }
            result.success(createInstallReferrerPayload(null, metadata));
            return;
        }

        Handler timeoutHandler = new Handler(Looper.getMainLooper());
        timeoutHandler.postDelayed(() -> {
            Map<String, Object> metadata = createInstallReferrerMetadata();
            metadata.put("installReferrerStatus", "timeout");
            finishCollectInstallReferrer(
                result,
                referrerClient,
                completed,
                createInstallReferrerPayload(null, metadata)
            );
        }, 30000);

        try {
            referrerClient.startConnection(new InstallReferrerStateListener() {
            @Override
            public void onInstallReferrerSetupFinished(int responseCode) {
                Map<String, Object> metadata = createInstallReferrerMetadata();
                String installReferrer = null;

                try {
                    switch (responseCode) {
                        case InstallReferrerClient.InstallReferrerResponse.OK:
                            ReferrerDetails details = referrerClient.getInstallReferrer();
                            metadata.put("installReferrerStatus", "ok");
                            installReferrer = details.getInstallReferrer();
                            metadata.put("referrerClickTimestampSeconds", details.getReferrerClickTimestampSeconds());
                            metadata.put("installBeginTimestampSeconds", details.getInstallBeginTimestampSeconds());
                            metadata.put("googlePlayInstantParam", details.getGooglePlayInstantParam());
                            break;
                        case InstallReferrerClient.InstallReferrerResponse.FEATURE_NOT_SUPPORTED:
                            metadata.put("installReferrerStatus", "feature_not_supported");
                            break;
                        case InstallReferrerClient.InstallReferrerResponse.SERVICE_UNAVAILABLE:
                            metadata.put("installReferrerStatus", "service_unavailable");
                            break;
                        case InstallReferrerClient.InstallReferrerResponse.DEVELOPER_ERROR:
                            metadata.put("installReferrerStatus", "developer_error");
                            break;
                        case InstallReferrerClient.InstallReferrerResponse.SERVICE_DISCONNECTED:
                            metadata.put("installReferrerStatus", "service_disconnected");
                            break;
                        case InstallReferrerClient.InstallReferrerResponse.PERMISSION_ERROR:
                            metadata.put("installReferrerStatus", "permission_error");
                            break;
                        default:
                            metadata.put("installReferrerStatus", "unknown_response");
                            metadata.put("installReferrerCode", responseCode);
                            break;
                    }
                } catch (Exception exception) {
                    metadata.put("installReferrerError", exception.getMessage());
                } finally {
                    finishCollectInstallReferrer(
                        result,
                        referrerClient,
                        completed,
                        createInstallReferrerPayload(installReferrer, metadata)
                    );
                }
            }

            @Override
            public void onInstallReferrerServiceDisconnected() {
                Map<String, Object> metadata = createInstallReferrerMetadata();
                metadata.put("installReferrerStatus", "service_disconnected");
                finishCollectInstallReferrer(
                    result,
                    referrerClient,
                    completed,
                    createInstallReferrerPayload(null, metadata)
                );
            }
            });
        } catch (Exception exception) {
            Map<String, Object> metadata = createInstallReferrerMetadata();
            metadata.put("installReferrerError", exception.getMessage());
            finishCollectInstallReferrer(
                result,
                referrerClient,
                completed,
                createInstallReferrerPayload(null, metadata)
            );
        }
    }

    private Map<String, Object> createInstallReferrerMetadata() {
        Map<String, Object> metadata = new HashMap<>();
        metadata.put("source", "android_install_referrer");
        metadata.put("packageName", context.getPackageName());
        return metadata;
    }

    private Map<String, Object> createInstallReferrerPayload(
        String installReferrer,
        Map<String, Object> metadata
    ) {
        Map<String, Object> payload = new HashMap<>();
        if (installReferrer != null) {
            payload.put("installReferrer", installReferrer);
        }
        payload.put("metadata", new HashMap<>(metadata));
        return payload;
    }

    private void finishCollectInstallReferrer(
        @NonNull Result result,
        @NonNull InstallReferrerClient referrerClient,
        @NonNull AtomicBoolean completed,
        @NonNull Map<String, Object> payload
    ) {
        if (!completed.compareAndSet(false, true)) {
            return;
        }

        result.success(payload);

        try {
            referrerClient.endConnection();
        } catch (Exception ignored) {
        }
    }

    private boolean handleIntent(Intent intent) {
        if (intent == null) {
            return false;
        }

        final int historyFlag = Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY;
        if ((intent.getFlags() & historyFlag) == historyFlag) {
            return false;
        }

        String link = getDeepLinkFromIntent(intent);
        if (link == null) {
            return false;
        }

        EventChannel.EventSink eventSink = null;
        synchronized (deepLinkStateLock) {
            if (initialLink == null) {
                initialLink = link;
            }

            latestLink = link;

            if (deepLinkEventSink != null) {
                initialLinkSent = true;
                eventSink = deepLinkEventSink;
            }
        }

        if (eventSink != null) {
            eventSink.success(link);
        }

        return true;
    }

    private String getDeepLinkFromIntent(@NonNull Intent intent) {
        String action = intent.getAction();
        if (Intent.ACTION_SEND.equals(action)
            || Intent.ACTION_SEND_MULTIPLE.equals(action)
            || Intent.ACTION_SENDTO.equals(action)) {
            return null;
        }

        return intent.getDataString();
    }
}
