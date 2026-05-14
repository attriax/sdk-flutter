import 'package:attriax_flutter_platform_interface/attriax_flutter_platform_interface.dart';

/// Shared app-open lifecycle contract for runtime collaborators.
abstract interface class AttriaxAppOpenMonitor {
  bool get hasSuccessfulResult;

  Future<AttriaxAppOpenResult?> waitForTrackedResult();
}
