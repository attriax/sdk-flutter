import 'package:attriax_platform_interface/attriax_platform_interface.dart';

class AttriaxConversionMapper {
  const AttriaxConversionMapper();

  AttriaxDeepLinkResolution? buildEvent(
    AttriaxDeepLinkResolutionResult result, {
    required AttriaxRawDeepLinkEvent? rawEvent,
    required bool isDeferred,
  }) {
    final deepLink = result.deepLink;
    if (!result.matched || deepLink == null) {
      return null;
    }

    return AttriaxDeepLinkResolution(
      deepLink: deepLink,
      rawEvent: rawEvent,
      isFirstLaunch: result.isFirstLaunch,
      isDeferred: isDeferred,
      consumedAt: result.consumedAt,
      occurredAt: result.acceptedAt ?? DateTime.now().toUtc(),
    );
  }

  AttriaxDeepLinkResolutionFailure buildFailure(
    AttriaxDeepLinkResolutionResult result, {
    required AttriaxRawDeepLinkEvent? rawEvent,
  }) => AttriaxDeepLinkResolutionFailure(
    reason: result.reason ?? result.status.name,
    rawEvent: rawEvent,
    isFirstLaunch: result.isFirstLaunch,
    status: result.status,
    requestVersion: result.requestVersion,
    acceptedAt: result.acceptedAt,
    occurredAt: result.acceptedAt ?? DateTime.now().toUtc(),
  );
}
