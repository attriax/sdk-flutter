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

  void warning(String message, {Object? error, StackTrace? stackTrace}) {
    _write('WARNING', message, error: error, stackTrace: stackTrace);
  }

  void error(String message, {Object? error, StackTrace? stackTrace}) {
    _write('ERROR', message, error: error, stackTrace: stackTrace);
  }

  void _write(
    String level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    _emitLine('[Attriax][$level] $message');
    if (error != null) {
      _emitLine('[Attriax][$level] $error');
    }
    if (stackTrace != null && (_enableDebugLogs || level == 'ERROR')) {
      if (kDebugMode) {
        debugPrintStack(
          label: '[Attriax][$level] stackTrace',
          stackTrace: stackTrace,
        );
      } else {
        _emitLine('[Attriax][$level] stackTrace');
        _emitLine('$stackTrace');
      }
    }
  }

  void _emitLine(String line) {
    debugPrint(line);
  }
}
