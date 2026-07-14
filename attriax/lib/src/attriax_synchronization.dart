import 'package:attriax_flutter_platform_interface/attriax_platform_types.dart';

import 'internal/attriax_runtime_interface.dart';

/// Synchronization state exposed from the public Attriax SDK.
class AttriaxSynchronization {
  const AttriaxSynchronization(this._runtime);

  final AttriaxRuntimeInterface _runtime;

  /// Whether every queued SDK request has been delivered successfully.
  bool get isSynchronized => _runtime.isSynchronized;

  /// Current runtime synchronization state.
  AttriaxSynchronizationState get state => _runtime.synchronizationState;

  /// Broadcast synchronization state stream with no buffering.
  Stream<AttriaxSynchronizationState> get states =>
      _runtime.synchronizationStates;
}
