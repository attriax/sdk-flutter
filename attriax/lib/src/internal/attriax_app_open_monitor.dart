import 'package:attriax_flutter_platform_interface/attriax_runtime_types.dart';

/// Shared app-open lifecycle contract for runtime collaborators.
abstract interface class AttriaxAppOpenMonitor {
  bool get hasSuccessfulResult;
  bool get shouldGateRequestsOnSuccessfulAppOpen;

  Future<AttriaxAppOpenResult?> waitForTrackedResult();
}
