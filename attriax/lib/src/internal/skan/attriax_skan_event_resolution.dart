import 'package:attriax_flutter_platform_interface/attriax_runtime_types.dart';

import 'attriax_skan_rules.dart';

class AttriaxSkanResolvedUpdate {
  const AttriaxSkanResolvedUpdate({
    required this.fineValue,
    required this.coarseValue,
    required this.lockWindow,
  });

  final int fineValue;
  final AttriaxSkanCoarseValue? coarseValue;
  final bool lockWindow;
}

AttriaxSkanResolvedUpdate? resolveWindow1SkanUpdate({
  required AttriaxSkanState currentState,
  required String eventName,
  required Map<String, Object?> eventData,
  required List<AttriaxSkanWindow1Group> groups,
}) {
  if (groups.isEmpty) {
    return null;
  }

  var nextFineValue = currentState.fineValue ?? 0;
  var nextCoarseValue = currentState.coarseValue;
  var nextLockWindow = currentState.lockWindow;
  var matchedAnyGroup = false;

  for (final group in groups) {
    if (!isValidSkanBitRange(group.startBit, group.bitCount)) {
      continue;
    }

    final match = _matchedWindow1Event(
      group: group,
      eventName: eventName,
      eventData: eventData,
    );
    if (match == null) {
      continue;
    }

    matchedAnyGroup = true;
    final currentSegmentValue = extractSkanBitRangeValue(
      nextFineValue,
      startBit: group.startBit,
      bitCount: group.bitCount,
    );
    final nextSegmentValue = match.rank > currentSegmentValue
        ? match.rank
        : currentSegmentValue;
    nextFineValue = replaceSkanBitRangeValue(
      nextFineValue,
      startBit: group.startBit,
      bitCount: group.bitCount,
      value: nextSegmentValue,
    );
    nextCoarseValue = maxSkanCoarseValue(
      nextCoarseValue,
      match.event.coarseValue,
    );
    nextLockWindow = nextLockWindow || match.event.lockWindow;
  }

  return matchedAnyGroup
      ? AttriaxSkanResolvedUpdate(
          fineValue: nextFineValue,
          coarseValue: nextCoarseValue,
          lockWindow: nextLockWindow,
        )
      : null;
}

AttriaxSkanResolvedUpdate? resolveCoarseWindowSkanUpdate({
  required AttriaxSkanState currentState,
  required String eventName,
  required Map<String, Object?> eventData,
  required List<AttriaxSkanCoarseWindowEvent> events,
}) {
  if (events.isEmpty) {
    return null;
  }

  var nextCoarseValue = currentState.coarseValue;
  var nextLockWindow = currentState.lockWindow;
  var matchedAnyEvent = false;

  for (final event in events) {
    if (event.eventName != eventName ||
        !matchesSkanConditions(event.conditions, eventData)) {
      continue;
    }

    matchedAnyEvent = true;
    nextCoarseValue = maxSkanCoarseValue(nextCoarseValue, event.coarseValue);
    nextLockWindow = nextLockWindow || event.lockWindow;
  }

  return matchedAnyEvent
      ? AttriaxSkanResolvedUpdate(
          fineValue: currentState.fineValue ?? 0,
          coarseValue: nextCoarseValue,
          lockWindow: nextLockWindow,
        )
      : null;
}

SkanWindow1Match? _matchedWindow1Event({
  required AttriaxSkanWindow1Group group,
  required String eventName,
  required Map<String, Object?> eventData,
}) {
  SkanWindow1Match? match;

  for (var index = 0; index < group.events.length; index += 1) {
    final event = group.events[index];
    if (event.eventName != eventName ||
        !matchesSkanConditions(event.conditions, eventData)) {
      continue;
    }

    match = SkanWindow1Match(rank: index + 1, event: event);
  }

  return match;
}
