import 'dart:async';

import 'package:attriax_flutter/src/internal/attriax_api_models.dart';
import 'package:attriax_flutter/src/internal/attriax_generated_transport.dart';
import 'package:attriax_flutter/src/internal/attriax_queue.dart';
import 'package:attriax_flutter/src/internal/dispatch/request_retry_policy.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  AttriaxQueuedRequest buildQueuedRequest({int attemptCount = 0}) {
    return AttriaxQueuedRequest(
      id: 'req_1',
      request: attriaxBuildTrackEventRequest(
        appToken: 'ax_test_token',
        deviceId: 'device_1',
        deviceIdSource: 'android_ssaid',
        eventName: 'purchase',
        eventData: const <String, Object?>{'value': 42},
      ),
      createdAt: DateTime.utc(2026, 1, 1),
      attemptCount: attemptCount,
    );
  }

  group('attriaxIsRetryableHttpStatus', () {
    test('retries rate-limit, all 5xx, and transient 408/425', () {
      expect(attriaxIsRetryableHttpStatus(408), isTrue);
      expect(attriaxIsRetryableHttpStatus(425), isTrue);
      expect(attriaxIsRetryableHttpStatus(429), isTrue);
      expect(attriaxIsRetryableHttpStatus(500), isTrue);
      expect(attriaxIsRetryableHttpStatus(503), isTrue);
    });

    test('drops ordinary client errors', () {
      expect(attriaxIsRetryableHttpStatus(400), isFalse);
      expect(attriaxIsRetryableHttpStatus(401), isFalse);
      expect(attriaxIsRetryableHttpStatus(404), isFalse);
      expect(attriaxIsRetryableHttpStatus(422), isFalse);
    });
  });

  group('attriaxIsRetryableRequestError', () {
    test('classifies transport and timeout errors as retryable', () {
      expect(
        attriaxIsRetryableRequestError(TimeoutException('slow')),
        isTrue,
      );
      expect(
        attriaxIsRetryableRequestError(
          DioException(requestOptions: RequestOptions(path: '/')),
        ),
        isTrue,
      );
      expect(
        attriaxIsRetryableRequestError(
          const AttriaxTransportHttpException(statusCode: 408),
        ),
        isTrue,
      );
      expect(
        attriaxIsRetryableRequestError(
          const AttriaxTransportHttpException(statusCode: 400),
        ),
        isFalse,
      );
      expect(attriaxIsRetryableRequestError(StateError('nope')), isFalse);
    });
  });

  group('attriaxRetryAfterAt', () {
    final attemptedAt = DateTime.utc(2026, 6, 12, 10);

    AttriaxTransportHttpException httpWithRetryAfter(String value) {
      return AttriaxTransportHttpException(
        statusCode: 429,
        headers: Headers.fromMap(<String, List<String>>{
          'retry-after': <String>[value],
        }),
      );
    }

    test('uses a positive seconds delay', () {
      expect(
        attriaxRetryAfterAt(httpWithRetryAfter('30'), attemptedAt),
        attemptedAt.add(const Duration(seconds: 30)),
      );
    });

    test('falls back (null) for a zero or negative delay', () {
      expect(attriaxRetryAfterAt(httpWithRetryAfter('0'), attemptedAt), isNull);
      expect(
        attriaxRetryAfterAt(httpWithRetryAfter('-5'), attemptedAt),
        isNull,
      );
    });

    test('falls back (null) for an empty or non-HTTP error', () {
      expect(attriaxRetryAfterAt(httpWithRetryAfter('   '), attemptedAt), isNull);
      expect(attriaxRetryAfterAt(TimeoutException('x'), attemptedAt), isNull);
    });

    test('parses a future IMF-fixdate but ignores a past one', () {
      expect(
        attriaxRetryAfterAt(
          httpWithRetryAfter('Wed, 12 Jun 2026 10:00:30 GMT'),
          attemptedAt,
        ),
        DateTime.utc(2026, 6, 12, 10, 0, 30),
      );
      expect(
        attriaxRetryAfterAt(
          httpWithRetryAfter('Wed, 12 Jun 2026 09:59:30 GMT'),
          attemptedAt,
        ),
        isNull,
      );
    });
  });

  group('attriaxMarkRequestForRetry', () {
    final attemptedAt = DateTime.utc(2026, 6, 12, 10);

    test('always arms a retry time on the no-Retry-After path (backoff)', () {
      final marked = attriaxMarkRequestForRetry(
        buildQueuedRequest(),
        const AttriaxTransportHttpException(statusCode: 503),
        attemptedAt,
      );
      expect(marked.attemptCount, 1);
      expect(marked.nextRetryAt, isNotNull);
      expect(marked.nextRetryAt!.isAfter(attemptedAt), isTrue);
    });

    test('prefers a server-provided Retry-After over backoff', () {
      final marked = attriaxMarkRequestForRetry(
        buildQueuedRequest(),
        AttriaxTransportHttpException(
          statusCode: 429,
          headers: Headers.fromMap(<String, List<String>>{
            'retry-after': const <String>['120'],
          }),
        ),
        attemptedAt,
      );
      expect(marked.nextRetryAt, attemptedAt.add(const Duration(seconds: 120)));
    });
  });

  group('attriaxBackoffRetryAt', () {
    final attemptedAt = DateTime.utc(2026, 6, 12, 10);

    test('grows exponentially and stays within the configured cap', () {
      final first = attriaxBackoffRetryAt(attemptedAt, 1);
      final second = attriaxBackoffRetryAt(attemptedAt, 2);
      final far = attriaxBackoffRetryAt(attemptedAt, 30);

      expect(
        first.difference(attemptedAt),
        greaterThanOrEqualTo(attriaxRetryBaseBackoff),
      );
      expect(
        second.difference(attemptedAt),
        greaterThan(first.difference(attemptedAt)),
      );
      // Cap + 20% jitter is the maximum possible spacing.
      final maxWithJitter =
          attriaxRetryMaxBackoff +
          Duration(
            milliseconds: (attriaxRetryMaxBackoff.inMilliseconds * 0.2).ceil(),
          );
      expect(
        far.difference(attemptedAt),
        lessThanOrEqualTo(maxWithJitter),
      );
    });
  });
}
