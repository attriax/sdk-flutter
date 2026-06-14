import 'package:attriax_flutter_platform_interface/attriax_runtime_types.dart';

import '../../attriax_analytics_keys.dart';
import '../attriax_logger.dart';
import 'attriax_skan_rules.dart';

const int _microsPerUnit = 1000000;

typedef AttriaxSkanUsdRevenueConverter =
    Future<int?> Function({
      required int amountMicros,
      required String currency,
      required DateTime clientOccurredAt,
    });

class AttriaxSkanEventAugmentation {
  const AttriaxSkanEventAugmentation({
    required this.state,
    required this.eventData,
    required this.stateChanged,
  });

  final AttriaxSkanState state;
  final Map<String, Object?> eventData;
  final bool stateChanged;
}

class AttriaxSkanEventAugmenter {
  const AttriaxSkanEventAugmenter({
    required AttriaxClock clock,
    required AttriaxLogger logger,
    AttriaxSkanUsdRevenueConverter? usdRevenueConverter,
  }) : _clock = clock,
       _logger = logger,
       _usdRevenueConverter = usdRevenueConverter;

  final AttriaxClock _clock;
  final AttriaxLogger _logger;
  final AttriaxSkanUsdRevenueConverter? _usdRevenueConverter;

  Future<AttriaxSkanEventAugmentation> augment({
    required String eventName,
    required Map<String, Object?> eventData,
    required AttriaxSkanState state,
  }) async {
    if (eventName == AttriaxAnalyticsEventKeys.purchase) {
      return _augmentPurchaseEventData(state, eventData);
    }

    if (eventName == AttriaxAnalyticsEventKeys.adShow) {
      return _augmentAdShowEventData(state, eventData);
    }

    return AttriaxSkanEventAugmentation(
      state: state,
      eventData: eventData,
      stateChanged: false,
    );
  }

  Future<AttriaxSkanEventAugmentation> _augmentPurchaseEventData(
    AttriaxSkanState currentState,
    Map<String, Object?> eventData,
  ) async {
    final usdMicros = await _resolvePurchaseUsdMicros(eventData);
    final nextRevenueUsdMicros =
        currentState.purchaseRevenueUsdMicros + (usdMicros ?? 0);
    final nextPurchaseCount = currentState.purchaseCount + 1;

    final nextState = currentState.copyWith(
      purchaseRevenueUsdMicros: nextRevenueUsdMicros,
      purchaseCount: nextPurchaseCount,
    );

    return AttriaxSkanEventAugmentation(
      state: nextState,
      eventData: <String, Object?>{
        ...eventData,
        AttriaxAnalyticsParamKeys.revenue:
            nextRevenueUsdMicros / _microsPerUnit,
        'count': nextPurchaseCount,
      },
      stateChanged: true,
    );
  }

  AttriaxSkanEventAugmentation _augmentAdShowEventData(
    AttriaxSkanState currentState,
    Map<String, Object?> eventData,
  ) {
    final nextAdShowCount = currentState.adShowCount + 1;

    return AttriaxSkanEventAugmentation(
      state: currentState.copyWith(adShowCount: nextAdShowCount),
      eventData: <String, Object?>{
        ...eventData,
        'shown': nextAdShowCount,
        'count': nextAdShowCount,
      },
      stateChanged: true,
    );
  }

  Future<int?> _resolvePurchaseUsdMicros(Map<String, Object?> eventData) async {
    final revenue = coerceSkanNumber(
      eventData[AttriaxAnalyticsParamKeys.revenue],
    );
    if (revenue == null) {
      return null;
    }

    final revenueInMicros =
        _readBool(eventData['revenueInMicros']) ??
        _readBool(eventData['revenue_in_micros']) ??
        false;
    final amountMicros = _toMicros(revenue, alreadyMicros: revenueInMicros);
    final currency =
        _readString(
          eventData[AttriaxAnalyticsParamKeys.currency],
        )?.toUpperCase() ??
        'USD';
    if (currency == 'USD') {
      return amountMicros;
    }

    final converter = _usdRevenueConverter;
    if (converter == null) {
      _logger.warning(
        'Skipping non-USD purchase revenue for SKAN because no USD conversion transport is available.',
      );
      return null;
    }

    try {
      return await converter(
        amountMicros: amountMicros,
        currency: currency,
        clientOccurredAt: _clock.now().toUtc(),
      );
    } catch (error) {
      _logger.warning(
        'Failed to convert purchase revenue to USD for SKAN.',
        error: error,
      );
      // Optimistically count failed conversions as $1 USD so SKAN value updates
      // are not missed when a transient FX lookup fails. The converter contract
      // is in micros, so $1 is one full unit of micros, not a single micro.
      return _microsPerUnit;
    }
  }

  String? _readString(Object? value) {
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }

    return null;
  }

  bool? _readBool(Object? value) {
    if (value is bool) {
      return value;
    }
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true') {
        return true;
      }
      if (normalized == 'false') {
        return false;
      }
    }

    return null;
  }

  int _toMicros(double value, {required bool alreadyMicros}) =>
      (alreadyMicros ? value : value * _microsPerUnit).round();
}
