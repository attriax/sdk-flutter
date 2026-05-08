import 'dart:async';
import 'dart:convert';

import 'attriax_api_models.dart';
import 'attriax_json_utils.dart';
import 'attriax_preferences_store.dart';
import 'attriax_queue_status.dart';

/// A single SDK request waiting to be delivered to the Attriax backend.
class AttriaxQueuedRequest {
  const AttriaxQueuedRequest({
    required this.id,
    required this.request,
    required this.createdAt,
    this.attemptCount = 0,
    this.lastAttemptAt,
    this.lastErrorClass,
    this.lastHttpStatusCode,
    this.nextRetryAt,
  });

  static const Object _unset = Object();

  factory AttriaxQueuedRequest.fromJson(Map<String, Object?> json) =>
      AttriaxQueuedRequest(
        id: attriaxRequireString(json, 'id'),
        request: attriaxApiRequestFromJson(
          attriaxRequireString(json, 'kind'),
          attriaxObjectMapOrEmpty(json['body']),
        ),
        createdAt:
            attriaxDateTimeValue(json['createdAt']) ?? DateTime.now().toUtc(),
        attemptCount: _attriaxIntValue(json['attemptCount']) ?? 0,
        lastAttemptAt: attriaxDateTimeValue(json['lastAttemptAt']),
        lastErrorClass: attriaxStringValue(json['lastErrorClass']),
        lastHttpStatusCode: _attriaxIntValue(json['lastHttpStatusCode']),
        nextRetryAt: attriaxDateTimeValue(json['nextRetryAt']),
      );

  final String id;
  final AttriaxApiRequest request;
  final DateTime createdAt;
  final int attemptCount;
  final DateTime? lastAttemptAt;
  final String? lastErrorClass;
  final int? lastHttpStatusCode;
  final DateTime? nextRetryAt;

  AttriaxQueuedRequest copyWith({
    String? id,
    AttriaxApiRequest? request,
    DateTime? createdAt,
    int? attemptCount,
    Object? lastAttemptAt = _unset,
    Object? lastErrorClass = _unset,
    Object? lastHttpStatusCode = _unset,
    Object? nextRetryAt = _unset,
  }) {
    return AttriaxQueuedRequest(
      id: id ?? this.id,
      request: request ?? this.request,
      createdAt: createdAt ?? this.createdAt,
      attemptCount: attemptCount ?? this.attemptCount,
      lastAttemptAt: identical(lastAttemptAt, _unset)
          ? this.lastAttemptAt
          : lastAttemptAt as DateTime?,
      lastErrorClass: identical(lastErrorClass, _unset)
          ? this.lastErrorClass
          : lastErrorClass as String?,
      lastHttpStatusCode: identical(lastHttpStatusCode, _unset)
          ? this.lastHttpStatusCode
          : lastHttpStatusCode as int?,
      nextRetryAt: identical(nextRetryAt, _unset)
          ? this.nextRetryAt
          : nextRetryAt as DateTime?,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'kind': request.kindName,
    'body': attriaxNormalizeJsonMap(request.toQueueBody()),
    'createdAt': createdAt.toIso8601String(),
    'attemptCount': attemptCount,
    if (lastAttemptAt != null)
      'lastAttemptAt': lastAttemptAt!.toIso8601String(),
    if (lastErrorClass != null) 'lastErrorClass': lastErrorClass,
    if (lastHttpStatusCode != null) 'lastHttpStatusCode': lastHttpStatusCode,
    if (nextRetryAt != null) 'nextRetryAt': nextRetryAt!.toIso8601String(),
  };
}

/// Persists the outbound request queue to [SharedPreferences].
class AttriaxQueueManager {
  AttriaxQueueManager({
    required AttriaxPreferencesStore preferencesStore,
    required int maxQueueSize,
  }) : _preferencesStore = preferencesStore,
       _maxQueueSize = maxQueueSize;

  final AttriaxPreferencesStore _preferencesStore;
  final int _maxQueueSize;
  Future<void> _operationLock = Future<void>.value();

  Future<void> enqueue(AttriaxQueuedRequest request) async {
    await _withLock(() async {
      final queue = await _readAllUnlocked();
      queue.add(request);
      if (queue.length > _maxQueueSize) {
        final overflowCount = queue.length - _maxQueueSize;
        final evictedRequests = List<AttriaxQueuedRequest>.from(
          queue.take(overflowCount),
        );
        queue.removeRange(0, overflowCount);
        await _recordEvictionUnlocked(evictedRequests);
      }
      await _writeAllUnlocked(queue);
    });
  }

  Future<List<AttriaxQueuedRequest>> readAll() => _withLock(_readAllUnlocked);

  Future<List<AttriaxQueuedRequest>> _readAllUnlocked() async {
    final raw = await _preferencesStore.readQueuePayload();
    if (raw == null || raw.isEmpty) {
      return <AttriaxQueuedRequest>[];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        await _recordCorruptionUnlocked(reason: 'invalid_queue_payload');
        await _preferencesStore.writeQueuePayload(null);
        return <AttriaxQueuedRequest>[];
      }

      final queue = <AttriaxQueuedRequest>[];
      var invalidEntryCount = 0;
      for (final value in decoded) {
        final json = attriaxObjectMap(value);
        if (json == null) {
          invalidEntryCount += 1;
          continue;
        }

        try {
          queue.add(AttriaxQueuedRequest.fromJson(json));
        } on FormatException {
          invalidEntryCount += 1;
        }
      }

      if (invalidEntryCount > 0) {
        await _recordCorruptionUnlocked(
          reason: 'invalid_queue_entry',
          affectedEntryCount: invalidEntryCount,
        );
        await _writeAllUnlocked(queue);
      }
      return queue;
    } catch (_) {
      await _recordCorruptionUnlocked(reason: 'invalid_queue_payload');
      await _preferencesStore.writeQueuePayload(null);
      return <AttriaxQueuedRequest>[];
    }
  }

  Future<AttriaxQueueDiagnostics> readDiagnostics() =>
      _withLock(_readDiagnosticsUnlocked);

  Future<AttriaxQueueDiagnostics> _readDiagnosticsUnlocked() async {
    final raw = await _preferencesStore.readQueueDiagnosticsPayload();
    if (raw == null || raw.isEmpty) {
      return const AttriaxQueueDiagnostics();
    }

    try {
      final decoded = jsonDecode(raw);
      final json = attriaxObjectMap(decoded);
      if (json == null) {
        return const AttriaxQueueDiagnostics();
      }

      return AttriaxQueueDiagnostics.fromJson(json);
    } catch (_) {
      return const AttriaxQueueDiagnostics();
    }
  }

  Future<AttriaxQueueStatus> readStatus() => _withLock(() async {
    final queue = await _readAllUnlocked();
    final diagnostics = await _readDiagnosticsUnlocked();
    return AttriaxQueueStatus(
      pendingRequestCount: queue.length,
      diagnostics: diagnostics,
      oldestQueuedAt: _oldestQueuedAt(queue),
      nextRetryAt: _nextRetryAt(queue),
    );
  });

  Future<void> writeAll(List<AttriaxQueuedRequest> queue) =>
      _withLock(() => _writeAllUnlocked(queue));

  Future<void> recordTerminalDrop(
    List<AttriaxQueuedRequest> droppedRequests, {
    required String reason,
  }) => _withLock(
    () => _recordTerminalDropUnlocked(droppedRequests, reason: reason),
  );

  Future<void> _writeAllUnlocked(List<AttriaxQueuedRequest> queue) async {
    if (queue.isEmpty) {
      await _preferencesStore.writeQueuePayload(null);
      return;
    }

    await _preferencesStore.writeQueuePayload(
      jsonEncode(queue.map((r) => r.toJson()).toList(growable: false)),
    );
  }

  Future<void> _recordCorruptionUnlocked({
    required String reason,
    int affectedEntryCount = 0,
  }) async {
    final diagnostics = await _readDiagnosticsUnlocked();
    await _writeDiagnosticsUnlocked(
      diagnostics.copyWith(
        corruptedPayloadCount: diagnostics.corruptedPayloadCount + 1,
        lastCorruptionAt: DateTime.now().toUtc(),
        lastCorruptionReason: reason,
        lastCorruptedEntryCount: affectedEntryCount,
      ),
    );
  }

  Future<void> _recordEvictionUnlocked(
    List<AttriaxQueuedRequest> evictedRequests,
  ) async {
    if (evictedRequests.isEmpty) {
      return;
    }

    final diagnostics = await _readDiagnosticsUnlocked();
    await _writeDiagnosticsUnlocked(
      diagnostics.copyWith(
        evictedRequestCount:
            diagnostics.evictedRequestCount + evictedRequests.length,
        lastEvictedAt: DateTime.now().toUtc(),
        lastEvictedRequestKinds: evictedRequests
            .map((request) => request.request.kindName)
            .toList(growable: false),
      ),
    );
  }

  Future<void> _recordTerminalDropUnlocked(
    List<AttriaxQueuedRequest> droppedRequests, {
    required String reason,
  }) async {
    if (droppedRequests.isEmpty) {
      return;
    }

    final diagnostics = await _readDiagnosticsUnlocked();
    await _writeDiagnosticsUnlocked(
      diagnostics.copyWith(
        droppedRequestCount:
            diagnostics.droppedRequestCount + droppedRequests.length,
        lastDroppedAt: DateTime.now().toUtc(),
        lastDroppedReason: reason,
        lastDroppedRequestKinds: droppedRequests
            .map((request) => request.request.kindName)
            .toList(growable: false),
      ),
    );
  }

  Future<void> _writeDiagnosticsUnlocked(
    AttriaxQueueDiagnostics diagnostics,
  ) async {
    if (!diagnostics.hasIssues) {
      await _preferencesStore.writeQueueDiagnosticsPayload(null);
      return;
    }

    await _preferencesStore.writeQueueDiagnosticsPayload(
      jsonEncode(diagnostics.toJson()),
    );
  }

  Future<T> _withLock<T>(FutureOr<T> Function() action) {
    final completer = Completer<void>();
    final previous = _operationLock;
    _operationLock = completer.future;

    return previous.then((_) => Future<T>.sync(action)).whenComplete(() {
      if (!completer.isCompleted) {
        completer.complete();
      }
    });
  }

  DateTime? _oldestQueuedAt(List<AttriaxQueuedRequest> queue) {
    if (queue.isEmpty) {
      return null;
    }

    var oldest = queue.first.createdAt;
    for (final queuedRequest in queue.skip(1)) {
      if (queuedRequest.createdAt.isBefore(oldest)) {
        oldest = queuedRequest.createdAt;
      }
    }
    return oldest;
  }

  DateTime? _nextRetryAt(List<AttriaxQueuedRequest> queue) {
    DateTime? nextRetryAt;
    final now = DateTime.now().toUtc();
    for (final queuedRequest in queue) {
      final retryAt = queuedRequest.nextRetryAt;
      if (retryAt == null || !retryAt.isAfter(now)) {
        continue;
      }

      if (nextRetryAt == null || retryAt.isBefore(nextRetryAt)) {
        nextRetryAt = retryAt;
      }
    }
    return nextRetryAt;
  }
}

int? _attriaxIntValue(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value);
  }
  return null;
}
