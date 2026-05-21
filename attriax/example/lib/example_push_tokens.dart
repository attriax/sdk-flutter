import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'example_firebase.dart';
import 'package:attriax_flutter/attriax_flutter.dart';

enum ExamplePushTokenPhase {
  idle,
  checking,
  needsPermission,
  ready,
  unavailable,
  error,
}

class ExamplePushTokenSnapshot {
  const ExamplePushTokenSnapshot({
    required this.phase,
    required this.summary,
    required this.permissionStatus,
    required this.setupHint,
    this.fcmToken,
    this.apnsToken,
    this.lastUpdatedAt,
    this.errorMessage,
    this.firebaseConfigured = false,
    this.listeningForRefresh = false,
  });

  const ExamplePushTokenSnapshot.idle()
    : this(
        phase: ExamplePushTokenPhase.idle,
        summary: 'Firebase token sync has not run yet.',
        permissionStatus: 'Unknown',
        setupHint:
            'Add your Firebase app configuration, then request permission and sync tokens from this page.',
      );

  final ExamplePushTokenPhase phase;
  final String summary;
  final String permissionStatus;
  final String setupHint;
  final String? fcmToken;
  final String? apnsToken;
  final DateTime? lastUpdatedAt;
  final String? errorMessage;
  final bool firebaseConfigured;
  final bool listeningForRefresh;

  bool get supportsApns =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);
}

abstract class ExamplePushTokenService {
  ExamplePushTokenSnapshot get snapshot;
  Stream<ExamplePushTokenSnapshot> get snapshots;

  Future<void> refresh({bool requestPermission = false});
  Future<void> dispose();
}

class LiveExamplePushTokenService implements ExamplePushTokenService {
  LiveExamplePushTokenService({required Attriax sdk}) : _sdk = sdk;

  final Attriax _sdk;
  final StreamController<ExamplePushTokenSnapshot> _snapshotsController =
      StreamController<ExamplePushTokenSnapshot>.broadcast();

  StreamSubscription<String>? _tokenRefreshSubscription;
  ExamplePushTokenSnapshot _snapshot = const ExamplePushTokenSnapshot.idle();

  @override
  ExamplePushTokenSnapshot get snapshot => _snapshot;

  @override
  Stream<ExamplePushTokenSnapshot> get snapshots => _snapshotsController.stream;

  @override
  Future<void> refresh({bool requestPermission = false}) async {
    if (!exampleSupportsFirebaseMessaging) {
      _emit(
        ExamplePushTokenSnapshot(
          phase: ExamplePushTokenPhase.unavailable,
          summary:
              'Firebase Messaging is not available on $exampleCurrentPlatformLabel.',
          permissionStatus: 'Not supported',
          setupHint: _setupHintForCurrentPlatform(),
          lastUpdatedAt: DateTime.now(),
          firebaseConfigured: Firebase.apps.isNotEmpty,
          listeningForRefresh: false,
        ),
      );
      return;
    }

    _emit(
      ExamplePushTokenSnapshot(
        phase: ExamplePushTokenPhase.checking,
        summary: requestPermission
            ? 'Requesting notification permission and syncing tokens...'
            : 'Checking Firebase token status...',
        permissionStatus: _snapshot.permissionStatus,
        setupHint: _snapshot.setupHint,
        fcmToken: _snapshot.fcmToken,
        apnsToken: _snapshot.apnsToken,
        firebaseConfigured: _snapshot.firebaseConfigured,
        listeningForRefresh: _snapshot.listeningForRefresh,
      ),
    );

    try {
      await _ensureFirebaseInitialized();

      final messaging = FirebaseMessaging.instance;
      final settings = requestPermission
          ? await messaging.requestPermission(provisional: true)
          : await messaging.getNotificationSettings();

      final permissionStatus = _describeAuthorizationStatus(
        settings.authorizationStatus,
      );

      String? fcmToken;
      String? apnsToken;

      if (_shouldAttemptFcmToken(settings.authorizationStatus)) {
        fcmToken = await messaging.getToken();
        if (fcmToken != null) {
          await _sdk.registerFirebaseMessagingToken(
            fcmToken,
            metadata: const <String, Object?>{
              'source': 'firebase_messaging_example',
            },
          );
        }
      }

      if (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS)) {
        apnsToken = await messaging.getAPNSToken();
        if (apnsToken != null) {
          await _sdk.registerApplePushToken(
            apnsToken,
            metadata: const <String, Object?>{
              'source': 'firebase_messaging_example_apns',
            },
          );
        }
      }

      _ensureTokenRefreshSubscription();

      final phase = _needsPermission(settings.authorizationStatus)
          ? ExamplePushTokenPhase.needsPermission
          : ExamplePushTokenPhase.ready;
      final summary = fcmToken == null
          ? _summaryWithoutToken(settings.authorizationStatus)
          : 'FCM token synced with Attriax.';

      _emit(
        ExamplePushTokenSnapshot(
          phase: phase,
          summary: summary,
          permissionStatus: permissionStatus,
          setupHint: _setupHintForCurrentPlatform(),
          fcmToken: fcmToken,
          apnsToken: apnsToken,
          lastUpdatedAt: DateTime.now(),
          firebaseConfigured: true,
          listeningForRefresh: _tokenRefreshSubscription != null,
        ),
      );
    } catch (error) {
      final pluginUnavailable = error is MissingPluginException;
      _emit(
        ExamplePushTokenSnapshot(
          phase: error is UnsupportedError || pluginUnavailable
              ? ExamplePushTokenPhase.unavailable
              : ExamplePushTokenPhase.error,
          summary: error is UnsupportedError || pluginUnavailable
              ? 'Firebase token sync is unavailable on this platform.'
              : 'Firebase token sync is not available yet.',
          permissionStatus: _snapshot.permissionStatus,
          setupHint: _setupHintFromError(error),
          fcmToken: _snapshot.fcmToken,
          apnsToken: _snapshot.apnsToken,
          lastUpdatedAt: DateTime.now(),
          errorMessage: error.toString(),
          firebaseConfigured: false,
          listeningForRefresh: _tokenRefreshSubscription != null,
        ),
      );
    }
  }

  @override
  Future<void> dispose() async {
    await _tokenRefreshSubscription?.cancel();
    await _snapshotsController.close();
  }

  Future<void> _ensureFirebaseInitialized() async {
    await ensureExampleFirebaseInitialized();
  }

  void _ensureTokenRefreshSubscription() {
    if (_tokenRefreshSubscription != null) {
      return;
    }

    _tokenRefreshSubscription = FirebaseMessaging.instance.onTokenRefresh
        .listen((token) {
          unawaited(_handleTokenRefresh(token));
        });
  }

  Future<void> _handleTokenRefresh(String token) async {
    try {
      await _sdk.registerFirebaseMessagingToken(
        token,
        metadata: const <String, Object?>{
          'source': 'firebase_messaging_refresh_example',
        },
      );
      _emit(
        ExamplePushTokenSnapshot(
          phase: ExamplePushTokenPhase.ready,
          summary: 'Firebase rotated the token and Attriax was updated.',
          permissionStatus: _snapshot.permissionStatus,
          setupHint: _snapshot.setupHint,
          fcmToken: token,
          apnsToken: _snapshot.apnsToken,
          lastUpdatedAt: DateTime.now(),
          firebaseConfigured: true,
          listeningForRefresh: true,
        ),
      );
    } catch (error) {
      _emit(
        ExamplePushTokenSnapshot(
          phase: ExamplePushTokenPhase.error,
          summary:
              'Token rotation was detected, but Attriax registration failed.',
          permissionStatus: _snapshot.permissionStatus,
          setupHint: _snapshot.setupHint,
          fcmToken: token,
          apnsToken: _snapshot.apnsToken,
          lastUpdatedAt: DateTime.now(),
          errorMessage: error.toString(),
          firebaseConfigured: true,
          listeningForRefresh: true,
        ),
      );
    }
  }

  void _emit(ExamplePushTokenSnapshot next) {
    _snapshot = next;
    if (!_snapshotsController.isClosed) {
      _snapshotsController.add(next);
    }
  }

  bool _needsPermission(AuthorizationStatus status) {
    if (defaultTargetPlatform == TargetPlatform.android && !kIsWeb) {
      return status == AuthorizationStatus.denied ||
          status == AuthorizationStatus.notDetermined;
    }
    return !_isAuthorized(status);
  }

  bool _shouldAttemptFcmToken(AuthorizationStatus status) {
    if (kIsWeb || defaultTargetPlatform == TargetPlatform.android) {
      return true;
    }
    return _isAuthorized(status);
  }

  bool _isAuthorized(AuthorizationStatus status) {
    return status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional;
  }

  String _describeAuthorizationStatus(AuthorizationStatus status) {
    switch (status) {
      case AuthorizationStatus.authorized:
        return 'Authorized';
      case AuthorizationStatus.denied:
        return 'Denied';
      case AuthorizationStatus.notDetermined:
        return 'Not determined';
      case AuthorizationStatus.provisional:
        return 'Provisional';
    }
  }

  String _summaryWithoutToken(AuthorizationStatus status) {
    if (_needsPermission(status)) {
      return 'Permission is still needed before the app can rely on push delivery.';
    }
    return 'Firebase is configured, but no token is available yet.';
  }

  String _setupHintForCurrentPlatform() {
    if (kIsWeb) {
      return 'Web push requires Firebase web configuration, a service worker, and a VAPID key before Firebase can return a token.';
    }
    if (defaultTargetPlatform == TargetPlatform.windows) {
      return 'Firebase Messaging is not supported on Windows in this example. Use Android, Apple platforms, or web for live push-token registration.';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'Add google-services.json for this example app to receive a live FCM token.';
    }
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return 'Add GoogleService-Info.plist and enable push notifications so Firebase can expose both FCM and APNs tokens.';
    }
    return 'Push token registration is meaningful only on Android, Apple platforms, or web builds backed by Firebase Messaging.';
  }

  String _setupHintFromError(Object error) {
    final message = error.toString();
    if (error is UnsupportedError) {
      return _setupHintForCurrentPlatform();
    }
    if (error is MissingPluginException &&
        defaultTargetPlatform == TargetPlatform.macOS) {
      return 'The macOS example only enables Firebase Messaging when the app is signed with a Team ID. Sign the app for macOS push testing, or use iOS or Android for live token registration.';
    }
    if (message.contains('Default FirebaseApp')) {
      return _setupHintForCurrentPlatform();
    }
    if (kIsWeb) {
      return 'Web FCM still needs the Firebase web app config, service worker, and VAPID key.';
    }
    return '${_setupHintForCurrentPlatform()} Error: $message';
  }
}
