import 'package:attriax_flutter_platform_interface/attriax_runtime_types.dart';

/// Shared app-open lifecycle contract for runtime collaborators.
///
/// App-open (attribution) delivery is best-effort: it no longer gates other
/// queued requests. Collaborators only observe its eventual result.
// ignore: one_member_abstracts
abstract interface class AttriaxAppOpenMonitor {
  Future<AttriaxAppOpenResult?> waitForTrackedResult();
}
