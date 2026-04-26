package com.attriax.attriax_android;

import android.content.pm.PackageManager;
import android.content.Context;
import android.content.Intent;
import android.content.pm.InstallSourceInfo;
import android.os.Build;
import android.provider.Settings;
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
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import java.util.TimeZone;
import java.util.concurrent.atomic.AtomicBoolean;

public class AttriaxAndroidPlugin implements
    FlutterPlugin,
    MethodCallHandler,
    EventChannel.StreamHandler,
    ActivityAware,
    NewIntentListener {
    private static final String CHANNEL_NAME = "attriax";
    private static final String DEEP_LINK_EVENTS_CHANNEL = "attriax/deep_links/events";

    private MethodChannel channel;
    private EventChannel deepLinkEventChannel;
    private EventChannel.EventSink deepLinkEventSink;
    private Context context;
    private ActivityPluginBinding activityBinding;
    private String initialLink;
    private boolean initialLinkSent = false;
    private String latestLink;

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
        deepLinkEventSink = null;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "collectNativeContext":
                collectNativeContext(result);
                break;
            case "collectInstallReferrer":
                collectInstallReferrer(result);
                break;
            case "getInitialLink":
                result.success(initialLink);
                break;
            case "getLatestLink":
                result.success(latestLink);
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
        deepLinkEventSink = events;

        if (!initialLinkSent && initialLink != null) {
            initialLinkSent = true;
            events.success(initialLink);
        }
    }

    @Override
    public void onCancel(Object arguments) {
        deepLinkEventSink = null;
    }

    @Override
    public boolean onNewIntent(@NonNull Intent intent) {
        return handleIntent(intent);
    }

    private void collectNativeContext(@NonNull Result result) {
        Map<String, Object> payload = new HashMap<>();
        Map<String, Object> metadata = new HashMap<>();

        payload.put("androidId", Settings.Secure.getString(
            context.getContentResolver(),
            Settings.Secure.ANDROID_ID
        ));
        metadata.put("source", "android_native");
        metadata.put("timezone", TimeZone.getDefault().getID());
        metadata.put("locale", Locale.getDefault().toLanguageTag());

        try {
            PackageManager packageManager = context.getPackageManager();
            String installerPackageName;
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                InstallSourceInfo installSourceInfo = packageManager.getInstallSourceInfo(
                    context.getPackageName()
                );
                installerPackageName = installSourceInfo.getInstallingPackageName();
            } else {
                installerPackageName = packageManager.getInstallerPackageName(
                    context.getPackageName()
                );
            }
            metadata.put(
                "installerPackageName",
                installerPackageName
            );
        } catch (Exception exception) {
            metadata.put("installerPackageNameError", exception.getMessage());
        }

        payload.put("metadata", metadata);
        result.success(payload);
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
    }

    private Map<String, Object> createInstallReferrerMetadata() {
        Map<String, Object> metadata = new HashMap<>();
        metadata.put("source", "android_install_referrer");
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

        if (initialLink == null) {
            initialLink = link;
        }

        latestLink = link;

        if (deepLinkEventSink != null) {
            initialLinkSent = true;
            deepLinkEventSink.success(link);
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
