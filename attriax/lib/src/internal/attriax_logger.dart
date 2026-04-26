import 'package:flutter/foundation.dart';

class AttriaxLogger {
  AttriaxLogger({required bool enableDebugLogs})
    : _enableDebugLogs = enableDebugLogs;

  bool _enableDebugLogs;

  bool get enableDebugLogs => _enableDebugLogs;

  void setDebugLogsEnabled({required bool enabled}) {
    _enableDebugLogs = enabled;
    verbose('Debug logging ${enabled ? 'enabled' : 'disabled'}.');
  }

  void verbose(String message) {
    if (!_enableDebugLogs) {
      return;
    }
    _write('VERBOSE', message);
  }

  void warning(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    _write('WARNING', message, error: error, stackTrace: stackTrace);
  }

  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    _write('ERROR', message, error: error, stackTrace: stackTrace);
  }

  void _write(
    String level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    debugPrint('[Attriax][$level] $message');
    if (error != null) {
      debugPrint('[Attriax][$level] $error');
    }
    if (stackTrace != null && (_enableDebugLogs || level == 'ERROR')) {
      debugPrintStack(
        label: '[Attriax][$level] stackTrace',
        stackTrace: stackTrace,
      );
    }
  }
}