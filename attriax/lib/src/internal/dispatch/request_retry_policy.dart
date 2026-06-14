import 'dart:async';
import 'dart:math' as math;

import 'package:dio/dio.dart';

import '../attriax_api_models.dart';
import '../attriax_generated_transport.dart';
import '../attriax_queue.dart';

const int attriaxMaxRetryAttempts = 8;
const Duration attriaxMaxRetryAge = Duration(days: 7);

/// Base delay for the first retry when the server does not send `Retry-After`.
const Duration attriaxRetryBaseBackoff = Duration(seconds: 2);

/// Upper bound for a single backoff delay.
const Duration attriaxRetryMaxBackoff = Duration(minutes: 5);

/// Whether an HTTP status code should be retried rather than dropped.
///
/// Covers rate-limiting (429), all 5xx server errors, plus the two 4xx codes
/// that are explicitly transient: 408 (Request Timeout) and 425 (Too Early).
/// Every other 4xx is a client error and is dropped.
bool attriaxIsRetryableHttpStatus(int statusCode) =>
    statusCode == 408 ||
    statusCode == 425 ||
    statusCode == 429 ||
    statusCode >= 500;

bool attriaxIsRetryableRequestError(Object error) => switch (error) {
  AttriaxTransportHttpException(statusCode: final statusCode) =>
    attriaxIsRetryableHttpStatus(statusCode),
  TimeoutException() => true,
  DioException() => true,
  _ => false,
};

AttriaxQueuedRequest attriaxMarkRequestForRetry(
  AttriaxQueuedRequest queuedRequest,
  Object error,
  DateTime attemptedAt,
) {
  final nextAttemptCount = queuedRequest.attemptCount + 1;
  return queuedRequest.copyWith(
    attemptCount: nextAttemptCount,
    lastAttemptAt: attemptedAt,
    lastErrorClass: attriaxRetryErrorClass(error),
    lastHttpStatusCode: attriaxHttpStatusCode(error),
    // A server-provided `Retry-After` always wins. Otherwise fall back to a
    // jittered exponential backoff so transient failures (network errors,
    // timeouts, header-less 5xx/429) are re-attempted with increasing spacing
    // instead of either spinning or never being re-flushed.
    nextRetryAt:
        attriaxRetryAfterAt(error, attemptedAt) ??
        attriaxBackoffRetryAt(attemptedAt, nextAttemptCount),
  );
}

/// Computes the next retry time using a capped exponential backoff.
///
/// [attemptCount] is the post-increment attempt number (1 after the first
/// failure). The delay doubles each attempt from [attriaxRetryBaseBackoff] up to
/// [attriaxRetryMaxBackoff]. A small deterministic jitter derived from
/// [attemptedAt] spreads retries across devices without depending on a random
/// source, keeping the result reproducible in tests.
DateTime attriaxBackoffRetryAt(DateTime attemptedAt, int attemptCount) {
  final exponent = (attemptCount - 1).clamp(0, 20);
  final scaledMs = attriaxRetryBaseBackoff.inMilliseconds * (1 << exponent);
  final cappedMs = math.min(attriaxRetryMaxBackoff.inMilliseconds, scaledMs);
  final jitterRange = (cappedMs * 0.2).floor();
  final jitterMs = jitterRange == 0
      ? 0
      : attemptedAt.microsecondsSinceEpoch.abs() % (jitterRange + 1);
  return attemptedAt.add(Duration(milliseconds: cappedMs + jitterMs));
}

String attriaxRetryErrorClass(Object error) => switch (error) {
  AttriaxTransportHttpException(statusCode: final statusCode) =>
    'http_$statusCode',
  TimeoutException() => 'timeout',
  DioException() => 'transport',
  _ => error.runtimeType.toString(),
};

int? attriaxHttpStatusCode(Object error) => switch (error) {
  AttriaxTransportHttpException(statusCode: final statusCode) => statusCode,
  _ => null,
};

String? attriaxTerminalDropReason(
  AttriaxQueuedRequest queuedRequest, {
  DateTime? now,
}) {
  if (!attriaxShouldApplyTerminalRetryPolicy(queuedRequest.request)) {
    return null;
  }

  if (queuedRequest.attemptCount >= attriaxMaxRetryAttempts) {
    return 'max_attempts_exceeded';
  }

  final currentTime = now ?? DateTime.now().toUtc();
  final age = currentTime.difference(queuedRequest.createdAt);
  if (age > attriaxMaxRetryAge) {
    return 'max_age_exceeded';
  }

  return null;
}

bool attriaxShouldApplyTerminalRetryPolicy(AttriaxApiRequest request) =>
    request is! AttriaxResolveDeepLinkRequest;

DateTime? attriaxRetryAfterAt(Object error, DateTime attemptedAt) {
  switch (error) {
    case AttriaxTransportHttpException():
      final retryAfterValue = error.headerValue('retry-after');
      if (retryAfterValue == null) {
        return null;
      }

      final trimmed = retryAfterValue.trim();
      if (trimmed.isEmpty) {
        return null;
      }

      final retryAfterSeconds = int.tryParse(trimmed);
      if (retryAfterSeconds != null) {
        // A non-positive delay ("0" or negative) means the server gave no
        // useful spacing. Fall back to the jittered exponential backoff rather
        // than retrying immediately, which would spin against a server that is
        // already failing or rate-limiting.
        if (retryAfterSeconds <= 0) {
          return null;
        }
        return attemptedAt.add(Duration(seconds: retryAfterSeconds));
      }

      final retryAfterDate = DateTime.tryParse(trimmed)?.toUtc();
      final httpRetryAfterDate = attriaxParseHttpRetryAfterDate(trimmed);
      final parsedRetryAfterDate = httpRetryAfterDate ?? retryAfterDate;
      if (parsedRetryAfterDate == null ||
          !parsedRetryAfterDate.isAfter(attemptedAt)) {
        return null;
      }

      return parsedRetryAfterDate;
    default:
      return null;
  }
}

DateTime? attriaxParseHttpRetryAfterDate(String value) {
  final match = _httpRetryAfterPattern.firstMatch(value);
  if (match == null) {
    return null;
  }

  final month = _httpRetryAfterMonths[match.group(2)!];
  if (month == null) {
    return null;
  }

  try {
    return DateTime.utc(
      int.parse(match.group(3)!),
      month,
      int.parse(match.group(1)!),
      int.parse(match.group(4)!),
      int.parse(match.group(5)!),
      int.parse(match.group(6)!),
    );
  } on FormatException {
    return null;
  }
}

final RegExp _httpRetryAfterPattern = RegExp(
  r'^[A-Za-z]{3}, (\d{2}) ([A-Za-z]{3}) (\d{4}) (\d{2}):(\d{2}):(\d{2}) GMT$',
);

const Map<String, int> _httpRetryAfterMonths = <String, int>{
  'Jan': 1,
  'Feb': 2,
  'Mar': 3,
  'Apr': 4,
  'May': 5,
  'Jun': 6,
  'Jul': 7,
  'Aug': 8,
  'Sep': 9,
  'Oct': 10,
  'Nov': 11,
  'Dec': 12,
};
