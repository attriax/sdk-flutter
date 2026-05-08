class AttriaxQueueDiagnostics {
  const AttriaxQueueDiagnostics({
    this.corruptedPayloadCount = 0,
    this.lastCorruptionAt,
    this.lastCorruptionReason,
    this.lastCorruptedEntryCount = 0,
    this.evictedRequestCount = 0,
    this.lastEvictedAt,
    this.lastEvictedRequestKinds = const <String>[],
    this.droppedRequestCount = 0,
    this.lastDroppedAt,
    this.lastDroppedReason,
    this.lastDroppedRequestKinds = const <String>[],
  });

  factory AttriaxQueueDiagnostics.fromJson(Map<String, Object?> json) {
    return AttriaxQueueDiagnostics(
      corruptedPayloadCount: _readInt(json['corruptedPayloadCount']) ?? 0,
      lastCorruptionAt: _readDateTime(json['lastCorruptionAt']),
      lastCorruptionReason: _readString(json['lastCorruptionReason']),
      lastCorruptedEntryCount: _readInt(json['lastCorruptedEntryCount']) ?? 0,
      evictedRequestCount: _readInt(json['evictedRequestCount']) ?? 0,
      lastEvictedAt: _readDateTime(json['lastEvictedAt']),
      lastEvictedRequestKinds: _readStringList(json['lastEvictedRequestKinds']),
      droppedRequestCount: _readInt(json['droppedRequestCount']) ?? 0,
      lastDroppedAt: _readDateTime(json['lastDroppedAt']),
      lastDroppedReason: _readString(json['lastDroppedReason']),
      lastDroppedRequestKinds: _readStringList(json['lastDroppedRequestKinds']),
    );
  }

  static const Object _unset = Object();

  final int corruptedPayloadCount;
  final DateTime? lastCorruptionAt;
  final String? lastCorruptionReason;
  final int lastCorruptedEntryCount;
  final int evictedRequestCount;
  final DateTime? lastEvictedAt;
  final List<String> lastEvictedRequestKinds;
  final int droppedRequestCount;
  final DateTime? lastDroppedAt;
  final String? lastDroppedReason;
  final List<String> lastDroppedRequestKinds;

  bool get hasIssues =>
      corruptedPayloadCount > 0 ||
      evictedRequestCount > 0 ||
      droppedRequestCount > 0;

  AttriaxQueueDiagnostics copyWith({
    int? corruptedPayloadCount,
    Object? lastCorruptionAt = _unset,
    Object? lastCorruptionReason = _unset,
    int? lastCorruptedEntryCount,
    int? evictedRequestCount,
    Object? lastEvictedAt = _unset,
    Object? lastEvictedRequestKinds = _unset,
    int? droppedRequestCount,
    Object? lastDroppedAt = _unset,
    Object? lastDroppedReason = _unset,
    Object? lastDroppedRequestKinds = _unset,
  }) {
    return AttriaxQueueDiagnostics(
      corruptedPayloadCount:
          corruptedPayloadCount ?? this.corruptedPayloadCount,
      lastCorruptionAt: identical(lastCorruptionAt, _unset)
          ? this.lastCorruptionAt
          : lastCorruptionAt as DateTime?,
      lastCorruptionReason: identical(lastCorruptionReason, _unset)
          ? this.lastCorruptionReason
          : lastCorruptionReason as String?,
      lastCorruptedEntryCount:
          lastCorruptedEntryCount ?? this.lastCorruptedEntryCount,
      evictedRequestCount: evictedRequestCount ?? this.evictedRequestCount,
      lastEvictedAt: identical(lastEvictedAt, _unset)
          ? this.lastEvictedAt
          : lastEvictedAt as DateTime?,
      lastEvictedRequestKinds: identical(lastEvictedRequestKinds, _unset)
          ? this.lastEvictedRequestKinds
          : List<String>.unmodifiable(
              (lastEvictedRequestKinds as List<String>?) ?? const <String>[],
            ),
      droppedRequestCount: droppedRequestCount ?? this.droppedRequestCount,
      lastDroppedAt: identical(lastDroppedAt, _unset)
          ? this.lastDroppedAt
          : lastDroppedAt as DateTime?,
      lastDroppedReason: identical(lastDroppedReason, _unset)
          ? this.lastDroppedReason
          : lastDroppedReason as String?,
      lastDroppedRequestKinds: identical(lastDroppedRequestKinds, _unset)
          ? this.lastDroppedRequestKinds
          : List<String>.unmodifiable(
              (lastDroppedRequestKinds as List<String>?) ?? const <String>[],
            ),
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'corruptedPayloadCount': corruptedPayloadCount,
      if (lastCorruptionAt != null)
        'lastCorruptionAt': lastCorruptionAt!.toIso8601String(),
      if (lastCorruptionReason != null)
        'lastCorruptionReason': lastCorruptionReason,
      'lastCorruptedEntryCount': lastCorruptedEntryCount,
      'evictedRequestCount': evictedRequestCount,
      if (lastEvictedAt != null)
        'lastEvictedAt': lastEvictedAt!.toIso8601String(),
      if (lastEvictedRequestKinds.isNotEmpty)
        'lastEvictedRequestKinds': lastEvictedRequestKinds,
      'droppedRequestCount': droppedRequestCount,
      if (lastDroppedAt != null)
        'lastDroppedAt': lastDroppedAt!.toIso8601String(),
      if (lastDroppedReason != null) 'lastDroppedReason': lastDroppedReason,
      if (lastDroppedRequestKinds.isNotEmpty)
        'lastDroppedRequestKinds': lastDroppedRequestKinds,
    };
  }
}

class AttriaxQueueStatus {
  const AttriaxQueueStatus({
    required this.pendingRequestCount,
    required this.diagnostics,
    this.oldestQueuedAt,
    this.nextRetryAt,
  });

  const AttriaxQueueStatus.empty()
    : pendingRequestCount = 0,
      diagnostics = const AttriaxQueueDiagnostics(),
      oldestQueuedAt = null,
      nextRetryAt = null;

  final int pendingRequestCount;
  final AttriaxQueueDiagnostics diagnostics;
  final DateTime? oldestQueuedAt;
  final DateTime? nextRetryAt;

  bool get hasPendingRequests => pendingRequestCount > 0;
  bool get hasDeferredRetry => nextRetryAt != null;
}

DateTime? _readDateTime(Object? value) =>
    value is String ? DateTime.tryParse(value) : null;

int? _readInt(Object? value) {
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

String? _readString(Object? value) {
  if (value is! String) {
    return null;
  }

  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

List<String> _readStringList(Object? value) {
  if (value is! List) {
    return const <String>[];
  }

  return List<String>.unmodifiable(
    value.map(_readString).whereType<String>().toList(growable: false),
  );
}
