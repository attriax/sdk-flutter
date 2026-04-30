import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'attriax_api_models.dart';
import 'attriax_json_utils.dart';

/// A single SDK request waiting to be delivered to the Attriax backend.
class AttriaxQueuedRequest {
  const AttriaxQueuedRequest({
    required this.id,
    required this.request,
    required this.createdAt,
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
      );

  final String id;
  final AttriaxApiRequest request;
  final DateTime createdAt;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'kind': request.kindName,
    'body': attriaxNormalizeJsonMap(request.toQueueBody()),
    'createdAt': createdAt.toIso8601String(),
  };
}

/// Persists the outbound request queue to [SharedPreferences].
class AttriaxQueueManager {
  AttriaxQueueManager({
    required SharedPreferences prefs,
    required int maxQueueSize,
  }) : _prefs = prefs,
       _maxQueueSize = maxQueueSize;

  static const String _storageKey = 'attriax.queue.v1';

  final SharedPreferences _prefs;
  final int _maxQueueSize;

  Future<void> enqueue(AttriaxQueuedRequest request) async {
    final queue = await readAll();
    queue.add(request);
    if (queue.length > _maxQueueSize) {
      queue.removeRange(0, queue.length - _maxQueueSize);
    }
    await writeAll(queue);
  }

  Future<List<AttriaxQueuedRequest>> readAll() async {
    final raw = _prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return <AttriaxQueuedRequest>[];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return <AttriaxQueuedRequest>[];
      }

      final queue = <AttriaxQueuedRequest>[];
      for (final value in decoded) {
        final json = attriaxObjectMap(value);
        if (json == null) {
          continue;
        }
        queue.add(AttriaxQueuedRequest.fromJson(json));
      }
      return queue;
    } catch (_) {
      return <AttriaxQueuedRequest>[];
    }
  }

  Future<void> writeAll(List<AttriaxQueuedRequest> queue) async {
    await _prefs.setString(
      _storageKey,
      jsonEncode(queue.map((r) => r.toJson()).toList(growable: false)),
    );
  }
}
