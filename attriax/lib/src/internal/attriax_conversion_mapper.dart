import 'package:attriax_platform_interface/attriax_platform_interface.dart';

class AttriaxConversionMapper {
  const AttriaxConversionMapper();

  AttriaxDeepLinkConversionEvent? buildEvent(
    AttriaxDeepLinkResolutionResult result, {
    required AttriaxRawDeepLinkEvent? rawEvent,
    required bool isDeferred,
  }) {
    final deepLink = result.deepLink;
    if (!result.matched || deepLink == null) {
      return null;
    }

    return AttriaxDeepLinkConversionEvent(
      deepLink: deepLink,
      rawEvent: rawEvent,
      isFirstLaunch: result.isFirstLaunch,
      isDeferred: isDeferred,
      requestVersion: result.requestVersion,
      occurredAt: result.acceptedAt ?? DateTime.now().toUtc(),
    );
  }

  AttriaxDeepLinkConversionFailure buildFailure(
    AttriaxDeepLinkResolutionResult result, {
    required AttriaxRawDeepLinkEvent? rawEvent,
  }) => AttriaxDeepLinkConversionFailure(
    reason: result.reason ?? result.status.name,
    rawEvent: rawEvent,
    isFirstLaunch: result.isFirstLaunch,
    occurredAt: result.acceptedAt ?? DateTime.now().toUtc(),
  );
}
