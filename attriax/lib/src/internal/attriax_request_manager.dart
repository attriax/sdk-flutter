import 'attriax_api_models.dart';
import 'attriax_synchronizer.dart';

class AttriaxRequestManager {
  AttriaxSynchronizer? synchronizer;

  bool get isBound => synchronizer != null;

  Future<void> enqueue(
    AttriaxApiRequest request, {
    void Function(AttriaxApiResponse response)? onSuccess,
    void Function(Object error, StackTrace? stackTrace)? onError,
    bool flushImmediately = true,
  }) {
    final synchronizer = this.synchronizer;
    if (synchronizer == null) {
      return Future<void>.error(
        StateError('Attriax request manager is not bound to a synchronizer.'),
      );
    }

    return synchronizer.enqueue(
      request,
      onSuccess: onSuccess,
      onError: onError,
      flushImmediately: flushImmediately,
    );
  }

  Future<void> flush() {
    final synchronizer = this.synchronizer;
    if (synchronizer == null) {
      return Future<void>.error(
        StateError('Attriax request manager is not bound to a synchronizer.'),
      );
    }

    return synchronizer.flush();
  }
}
