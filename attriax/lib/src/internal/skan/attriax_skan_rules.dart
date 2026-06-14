import 'package:attriax_flutter_platform_interface/attriax_runtime_types.dart';

const int skanFineValueBitCount = 6;
const int skanWindow1MaxDay = 2;
const int skanWindow2MaxDay = 7;
const int skanWindow3MaxDay = 35;

/// Whether SKAdNetwork is supported on [platformType].
///
/// SKAN is iOS-only; macOS and every other platform are excluded. Both the
/// manager and the conversion updater gate on this single predicate so the
/// exclusion can never drift between the two.
bool attriaxPlatformSupportsSkan(AttriaxPlatformType platformType) =>
    platformType == AttriaxPlatformType.ios;

enum SkanActiveWindow { window1, window2, window3 }

class SkanWindow1Match {
  const SkanWindow1Match({required this.rank, required this.event});

  final int rank;
  final AttriaxSkanEvent event;
}

SkanActiveWindow? activeSkanWindowForDay(int day) {
  if (day < 0) {
    return null;
  }
  if (day <= skanWindow1MaxDay) {
    return SkanActiveWindow.window1;
  }
  if (day <= skanWindow2MaxDay) {
    return SkanActiveWindow.window2;
  }
  if (day <= skanWindow3MaxDay) {
    return SkanActiveWindow.window3;
  }

  return null;
}

int skanRetentionDay(DateTime installAnchorAt, DateTime now) {
  final normalizedInstallDay = DateTime.utc(
    installAnchorAt.year,
    installAnchorAt.month,
    installAnchorAt.day,
  );
  final normalizedCurrentDay = DateTime.utc(now.year, now.month, now.day);
  final difference = normalizedCurrentDay
      .difference(normalizedInstallDay)
      .inDays;
  return difference < 0 ? 0 : difference;
}

AttriaxSkanCoarseValue deriveSkanCoarseValue(int fineValue) {
  if (fineValue >= 40) {
    return AttriaxSkanCoarseValue.high;
  }
  if (fineValue >= 20) {
    return AttriaxSkanCoarseValue.medium;
  }

  return AttriaxSkanCoarseValue.low;
}

AttriaxSkanCoarseValue? maxSkanCoarseValue(
  AttriaxSkanCoarseValue? current,
  AttriaxSkanCoarseValue? next,
) {
  if (current == null) {
    return next;
  }
  if (next == null) {
    return current;
  }

  return current.index >= next.index ? current : next;
}

bool isValidSkanBitRange(int startBit, int bitCount) =>
    startBit >= 0 &&
    bitCount > 0 &&
    startBit + bitCount <= skanFineValueBitCount;

int extractSkanBitRangeValue(
  int fineValue, {
  required int startBit,
  required int bitCount,
}) {
  final mask = (1 << bitCount) - 1;
  return (fineValue >> startBit) & mask;
}

int replaceSkanBitRangeValue(
  int fineValue, {
  required int startBit,
  required int bitCount,
  required int value,
}) {
  final maxValue = (1 << bitCount) - 1;
  final clampedValue = value < 0 ? 0 : (value > maxValue ? maxValue : value);
  final mask = maxValue << startBit;
  return (fineValue & ~mask) | ((clampedValue << startBit) & mask);
}

bool matchesSkanConditions(
  List<AttriaxSkanCondition> conditions,
  Map<String, Object?> eventData,
) {
  if (conditions.isEmpty) {
    return true;
  }

  for (final condition in conditions) {
    final hasValue = eventData.containsKey(condition.paramKey);
    final actualValue = hasValue ? eventData[condition.paramKey] : null;

    if (!skanConditionMatches(
      condition: condition,
      actualValue: actualValue,
      hasValue: hasValue,
    )) {
      return false;
    }
  }

  return true;
}

bool skanConditionMatches({
  required AttriaxSkanCondition condition,
  required Object? actualValue,
  required bool hasValue,
}) {
  switch (condition.operator) {
    case AttriaxSkanRuleOperator.exists:
      return hasValue && actualValue != null;
    case AttriaxSkanRuleOperator.eq:
      return hasValue && skanValuesEqual(actualValue, condition.value);
    case AttriaxSkanRuleOperator.notEq:
      return hasValue && !skanValuesEqual(actualValue, condition.value);
    case AttriaxSkanRuleOperator.gt:
    case AttriaxSkanRuleOperator.gte:
    case AttriaxSkanRuleOperator.lt:
    case AttriaxSkanRuleOperator.lte:
      final actualNumber = coerceSkanNumber(actualValue);
      final expectedNumber = coerceSkanNumber(condition.value);
      if (!hasValue || actualNumber == null || expectedNumber == null) {
        return false;
      }

      return switch (condition.operator) {
        AttriaxSkanRuleOperator.gt => actualNumber > expectedNumber,
        AttriaxSkanRuleOperator.gte => actualNumber >= expectedNumber,
        AttriaxSkanRuleOperator.lt => actualNumber < expectedNumber,
        AttriaxSkanRuleOperator.lte => actualNumber <= expectedNumber,
        _ => false,
      };
    case AttriaxSkanRuleOperator.contains:
      if (!hasValue || actualValue == null || condition.value == null) {
        return false;
      }

      final expectedValue = condition.value;
      if (actualValue is String && expectedValue is String) {
        return actualValue.toLowerCase().contains(expectedValue.toLowerCase());
      }

      if (actualValue is List) {
        return actualValue.any(
          (value) => skanValuesEqual(value, condition.value),
        );
      }

      return false;
  }
}

bool skanValuesEqual(Object? left, Object? right) {
  final leftNumber = coerceSkanNumber(left);
  final rightNumber = coerceSkanNumber(right);
  if (leftNumber != null && rightNumber != null) {
    return leftNumber == rightNumber;
  }

  return left?.toString() == right?.toString();
}

double? coerceSkanNumber(Object? value) {
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value.trim());
  }

  return null;
}
