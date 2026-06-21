part of 'types.dart';

class AttriaxRawDeepLinkEvent {
  const AttriaxRawDeepLinkEvent({
    required this.uri,
    required this.receivedAt,
    required this.isInitial,
  });

  factory AttriaxRawDeepLinkEvent.fromJson(
    Map<String, Object?> json,
  ) => AttriaxRawDeepLinkEvent(
    uri: _jsonUri(json['uri']) ?? Uri(path: _jsonString(json['path']) ?? '/'),
    receivedAt: _requireJsonDateTime(json, 'receivedAt'),
    isInitial: _jsonBool(json['isInitial']) ?? false,
  );

  final Uri uri;
  final DateTime receivedAt;
  final bool isInitial;

  Map<String, Object?> toJson() => <String, Object?>{
    'uri': uri.toString(),
    'receivedAt': receivedAt.toIso8601String(),
    'isInitial': isInitial,
  };
}

class AttriaxDeepLinkReferrerDetails {
  const AttriaxDeepLinkReferrerDetails({
    required this.uri,
    required this.receivedAt,
    required this.clickedAt,
    required this.consumedAt,
    required this.trigger,
    required this.isAttriaxDomain,
    required this.found,
    this.data,
    this.utm,
    this.browserAction,
    this.handledBySdk = false,
  });

  final Uri uri;
  final DateTime receivedAt;
  final DateTime clickedAt;
  final DateTime consumedAt;
  final AttriaxDeepLinkTrigger trigger;
  final bool isAttriaxDomain;
  final bool found;
  final Map<String, String>? data;
  final AttriaxUtmParameters? utm;
  final AttriaxResolvedUrlAction? browserAction;
  final bool handledBySdk;

  Map<String, Object?> toJson() => <String, Object?>{
    'uri': uri.toString(),
    'receivedAt': receivedAt.toIso8601String(),
    'clickedAt': clickedAt.toIso8601String(),
    'consumedAt': consumedAt.toIso8601String(),
    'trigger': trigger.name,
    'isAttriaxDomain': isAttriaxDomain,
    'found': found,
    if (data != null && data!.isNotEmpty)
      'data': Map<String, String>.from(data!),
    if (utm != null && !utm!.isEmpty) 'utm': utm!.toJson(),
    if (browserAction != null) 'browserAction': browserAction!.toJson(),
    'handledBySdk': handledBySdk,
  };
}

class AttriaxDeepLinkEvent {
  const AttriaxDeepLinkEvent({
    required this.uri,
    required this.clickedAt,
    required this.consumedAt,
    required this.found,
    required this.trigger,
    required this.isAttriaxSubDomain,
    this.rawEvent,
    this.data,
    this.utm,
    this.browserAction,
    this.handledBySdk = false,
  });

  factory AttriaxDeepLinkEvent.fromJson(Map<String, Object?> json) {
    final utmJson = _jsonObject(json['utm']);
    final browserActionJson = _jsonObject(json['browserAction']);
    final rawEventJson = _jsonObject(json['rawEvent']);

    return AttriaxDeepLinkEvent(
      uri: _jsonUri(json['uri']) ?? Uri(path: _jsonString(json['path']) ?? '/'),
      clickedAt: _requireJsonDateTime(json, 'clickedAt'),
      consumedAt: _requireJsonDateTime(json, 'consumedAt'),
      found: _jsonBool(json['found']) ?? false,
      trigger: _parseDeepLinkTrigger(_jsonString(json['trigger'])),
      isAttriaxSubDomain:
          _jsonBool(json['isAttriaxSubDomain']) ??
          _jsonBool(json['isAttriaxDomain']) ??
          false,
      rawEvent: rawEventJson == null
          ? null
          : AttriaxRawDeepLinkEvent.fromJson(rawEventJson),
      data: _jsonStringMap(json['data']),
      utm: utmJson == null ? null : AttriaxUtmParameters.fromJson(utmJson),
      browserAction: browserActionJson == null
          ? null
          : AttriaxResolvedUrlAction.fromJson(browserActionJson),
      handledBySdk: _jsonBool(json['handledBySdk']) ?? false,
    );
  }

  final Uri uri;
  final DateTime clickedAt;
  final DateTime consumedAt;
  final bool found;
  final AttriaxDeepLinkTrigger trigger;
  final bool isAttriaxSubDomain;
  final AttriaxRawDeepLinkEvent? rawEvent;
  final Map<String, String>? data;
  final AttriaxUtmParameters? utm;
  final AttriaxResolvedUrlAction? browserAction;
  final bool handledBySdk;

  bool get isDeferred => trigger == AttriaxDeepLinkTrigger.deferred;

  bool get isColdStart => trigger == AttriaxDeepLinkTrigger.coldStart;

  bool get isForeground => trigger == AttriaxDeepLinkTrigger.foreground;

  Map<String, Object?> toJson() => <String, Object?>{
    'uri': uri.toString(),
    'clickedAt': clickedAt.toIso8601String(),
    'consumedAt': consumedAt.toIso8601String(),
    'found': found,
    'trigger': trigger.name,
    'isAttriaxSubDomain': isAttriaxSubDomain,
    if (rawEvent != null) 'rawEvent': rawEvent!.toJson(),
    if (data != null && data!.isNotEmpty)
      'data': Map<String, String>.from(data!),
    if (utm != null && !utm!.isEmpty) 'utm': utm!.toJson(),
    if (browserAction != null) 'browserAction': browserAction!.toJson(),
    'handledBySdk': handledBySdk,
  };
}

class AttriaxDeepLinkResolutionResult {
  const AttriaxDeepLinkResolutionResult({
    required this.matched,
    required this.status,
    required this.isFirstLaunch,
    this.reason,
    this.deepLink,
    this.browserAction,
    this.requestVersion,
    this.acceptedAt,
    this.consumedAt,
  });

  factory AttriaxDeepLinkResolutionResult.fromJson(Map<String, Object?> json) {
    final deepLinkJson = _jsonObject(json['deepLink']);
    final browserActionJson = _jsonObject(json['browserAction']);

    return AttriaxDeepLinkResolutionResult(
      matched: _jsonBool(json['matched']) ?? false,
      status: _parseResolutionStatus(_jsonString(json['status'])),
      isFirstLaunch: _jsonBool(json['isFirstLaunch']) ?? false,
      reason: _jsonString(json['reason']),
      deepLink: deepLinkJson != null
          ? AttriaxDeepLink.fromJson(deepLinkJson)
          : null,
      browserAction: browserActionJson != null
          ? AttriaxResolvedUrlAction.fromJson(browserActionJson)
          : null,
      requestVersion: _jsonString(json['requestVersion']),
      acceptedAt: _jsonDateTime(json['acceptedAt']),
      consumedAt: _jsonDateTime(json['consumedAt']),
    );
  }

  final bool matched;
  final AttriaxDeepLinkResolutionStatus status;
  final bool isFirstLaunch;
  final String? reason;
  final AttriaxDeepLink? deepLink;
  final AttriaxResolvedUrlAction? browserAction;
  final String? requestVersion;
  final DateTime? acceptedAt;
  final DateTime? consumedAt;
}

class AttriaxAppOpenResult {
  const AttriaxAppOpenResult({
    required this.userId,
    required this.isNewUser,
    required this.isFirstLaunch,
    this.installState = AttriaxInstallState.existing,
    this.requestVersion,
    this.acceptedAt,
    this.deepLink,
    this.deepLinkClickedAt,
    this.deepLinkConsumedAt,
    this.originalInstallReferrer,
    this.reinstallReferrer,
    this.installReferrer,
    this.skan,
  });

  factory AttriaxAppOpenResult.fromJson(Map<String, Object?> json) {
    final deepLinkJson = _jsonObject(json['deepLink']);
    final installReferrerJson = _jsonObject(json['installReferrer']);
    final originalInstallReferrerJson = _jsonObject(
      json['originalInstallReferrer'],
    );
    final reinstallReferrerJson = _jsonObject(json['reinstallReferrer']);
    final skanJson = _jsonObject(json['skan']);

    return AttriaxAppOpenResult(
      userId: _requireJsonString(json, 'userId'),
      isNewUser: _jsonBool(json['isNewUser']) ?? false,
      isFirstLaunch: _jsonBool(json['isFirstLaunch']) ?? false,
      installState: _parseInstallState(_jsonString(json['installState'])),
      requestVersion: _jsonString(json['requestVersion']),
      acceptedAt: _jsonDateTime(json['acceptedAt']),
      deepLink: deepLinkJson != null
          ? AttriaxDeepLink.fromJson(deepLinkJson)
          : null,
      deepLinkClickedAt: _jsonDateTime(json['deepLinkClickedAt']),
      deepLinkConsumedAt: _jsonDateTime(json['deepLinkConsumedAt']),
      originalInstallReferrer: originalInstallReferrerJson != null
          ? AttriaxInstallReferrerDetails.fromJson(originalInstallReferrerJson)
          : null,
      reinstallReferrer: reinstallReferrerJson != null
          ? AttriaxInstallReferrerDetails.fromJson(reinstallReferrerJson)
          : null,
      installReferrer: installReferrerJson != null
          ? AttriaxInstallReferrerDetails.fromJson(installReferrerJson)
          : null,
      skan: skanJson == null
          ? null
          : AttriaxSkanRuntimeConfiguration.fromJson(skanJson),
    );
  }

  final String userId;
  final bool isNewUser;
  final bool isFirstLaunch;
  final AttriaxInstallState installState;
  final String? requestVersion;
  final DateTime? acceptedAt;
  final AttriaxDeepLink? deepLink;
  final DateTime? deepLinkClickedAt;
  final DateTime? deepLinkConsumedAt;
  final AttriaxInstallReferrerDetails? originalInstallReferrer;
  final AttriaxInstallReferrerDetails? reinstallReferrer;
  final AttriaxInstallReferrerDetails? installReferrer;
  final AttriaxSkanRuntimeConfiguration? skan;
}

class AttriaxAppOpen {
  const AttriaxAppOpen({
    required this.isNewUser,
    required this.isFirstLaunch,
    this.deepLink,
  });

  final bool isNewUser;
  final bool isFirstLaunch;
  final AttriaxDeepLink? deepLink;
}

typedef AttriaxInitResult = AttriaxAppOpen;
