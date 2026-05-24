import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;

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

  static const Object _unset = Object();

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
  }) => AttriaxQueuedRequest(
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
    required AttriaxQueueStore preferencesStore,
    required int maxQueueSize,
  }) : _preferencesStore = preferencesStore,
       _maxQueueSize = maxQueueSize;

  final AttriaxQueueStore _preferencesStore;
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
    final inspection = _inspectQueuePayload(
      await _preferencesStore.readQueuePayload(),
    );
    if (!inspection.hasCorruption) {
      return List<AttriaxQueuedRequest>.from(inspection.queue);
    }

    await _recordCorruptionUnlocked(
      reason: inspection.corruptionReason!,
      affectedEntryCount: inspection.invalidEntryCount,
      rawPayload: inspection.rawPayload,
    );
    if (inspection.shouldClearQueue) {
      await _preferencesStore.writeQueuePayload(null);
      return <AttriaxQueuedRequest>[];
    }

    await _writeAllUnlocked(inspection.queue);
    return List<AttriaxQueuedRequest>.from(inspection.queue);
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
        return _recordDiagnosticsCorruptionUnlocked(raw);
      }

      return AttriaxQueueDiagnostics.fromJson(json);
    } catch (_) {
      return _recordDiagnosticsCorruptionUnlocked(raw);
    }
  }

  Future<AttriaxQueueStatus> readStatus() => _withLock(() async {
    final queue = _inspectQueuePayload(
      await _preferencesStore.readQueuePayload(),
    ).queue;
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
    String? rawPayload,
  }) async {
    final diagnostics = await _readDiagnosticsUnlocked();
    await _writeDiagnosticsUnlocked(
      diagnostics.copyWith(
        corruptedPayloadCount: diagnostics.corruptedPayloadCount + 1,
        lastCorruptionAt: DateTime.now().toUtc(),
        lastCorruptionReason: reason,
        lastCorruptedEntryCount: affectedEntryCount,
        lastCorruptQueuePayload: rawPayload,
      ),
    );
  }

  Future<AttriaxQueueDiagnostics> _recordDiagnosticsCorruptionUnlocked(
    String rawPayload,
  ) async {
    final diagnostics = AttriaxQueueDiagnostics(
      corruptedDiagnosticsPayloadCount: 1,
      lastDiagnosticsCorruptionAt: DateTime.now().toUtc(),
      lastCorruptDiagnosticsPayload: rawPayload,
    );
    await _writeDiagnosticsUnlocked(diagnostics);
    return diagnostics;
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

  _QueueInspectionResult _inspectQueuePayload(String? rawPayload) {
    if (rawPayload == null || rawPayload.isEmpty) {
      return const _QueueInspectionResult(queue: <AttriaxQueuedRequest>[]);
    }

    try {
      final decoded = jsonDecode(rawPayload);
      if (decoded is! List) {
        return _QueueInspectionResult(
          queue: const <AttriaxQueuedRequest>[],
          corruptionReason: 'invalid_queue_payload',
          rawPayload: rawPayload,
        );
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
        return _QueueInspectionResult(
          queue: queue,
          corruptionReason: 'invalid_queue_entry',
          invalidEntryCount: invalidEntryCount,
          rawPayload: rawPayload,
        );
      }

      return _QueueInspectionResult(queue: queue);
    } catch (_) {
      return _QueueInspectionResult(
        queue: const <AttriaxQueuedRequest>[],
        corruptionReason: 'invalid_queue_payload',
        rawPayload: rawPayload,
      );
    }
  }
}

final class _QueueInspectionResult {
  const _QueueInspectionResult({
    required this.queue,
    this.corruptionReason,
    this.invalidEntryCount = 0,
    this.rawPayload,
  });

  final List<AttriaxQueuedRequest> queue;
  final String? corruptionReason;
  final int invalidEntryCount;
  final String? rawPayload;

  bool get hasCorruption => corruptionReason != null;

  bool get shouldClearQueue => corruptionReason == 'invalid_queue_payload';
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
