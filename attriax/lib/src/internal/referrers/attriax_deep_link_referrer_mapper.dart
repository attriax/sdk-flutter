import 'package:attriax_flutter_platform_interface/attriax_platform_types.dart';

AttriaxDeepLinkReferrerDetails attriaxDeepLinkReferrerDetailsFromEvent(
  AttriaxDeepLinkEvent event,
) => AttriaxDeepLinkReferrerDetails(
  uri: event.uri,
  receivedAt: event.rawEvent?.receivedAt ?? event.clickedAt,
  clickedAt: event.clickedAt,
  consumedAt: event.consumedAt,
  trigger: event.trigger,
  isAttriaxDomain: event.isAttriaxSubDomain,
  found: event.found,
  data: event.data,
  utm: event.utm,
  browserAction: event.browserAction,
  handledBySdk: event.handledBySdk,
);

bool attriaxIsSessionOpeningDeepLinkEvent(AttriaxDeepLinkEvent event) =>
    event.isColdStart || event.isDeferred;
