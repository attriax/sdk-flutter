import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'firebase_options.dart';

bool get exampleSupportsFirebaseMessaging {
  if (kIsWeb) {
    return true;
  }

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      return true;
    case TargetPlatform.fuchsia:
    case TargetPlatform.linux:
    case TargetPlatform.windows:
      return false;
  }
}

String get exampleCurrentPlatformLabel {
  if (kIsWeb) {
    return 'web';
  }

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return 'Android';
    case TargetPlatform.iOS:
      return 'iOS';
    case TargetPlatform.macOS:
      return 'macOS';
    case TargetPlatform.windows:
      return 'Windows';
    case TargetPlatform.linux:
      return 'Linux';
    case TargetPlatform.fuchsia:
      return 'Fuchsia';
  }
}

Future<void> ensureExampleFirebaseInitialized() async {
  if (Firebase.apps.isNotEmpty) {
    return;
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}
