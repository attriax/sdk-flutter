part of 'types.dart';

class AttriaxUtmParameters {
  const AttriaxUtmParameters({
    this.source,
    this.medium,
    this.campaign,
    this.term,
    this.content,
  });

  factory AttriaxUtmParameters.fromJson(Map<String, Object?> json) =>
      AttriaxUtmParameters(
        source: _jsonString(json['source']),
        medium: _jsonString(json['medium']),
        campaign: _jsonString(json['campaign']),
        term: _jsonString(json['term']),
        content: _jsonString(json['content']),
      );

  final String? source;
  final String? medium;
  final String? campaign;
  final String? term;
  final String? content;

  bool get isEmpty =>
      source == null &&
      medium == null &&
      campaign == null &&
      term == null &&
      content == null;

  Map<String, Object?> toJson() => <String, Object?>{
    if (source != null) 'source': source,
    if (medium != null) 'medium': medium,
    if (campaign != null) 'campaign': campaign,
    if (term != null) 'term': term,
    if (content != null) 'content': content,
  };
}

class AttriaxDeepLink {
  const AttriaxDeepLink({required this.path, this.data, this.uri, this.utm});

  factory AttriaxDeepLink.fromJson(Map<String, Object?> json) {
    final utmJson = _jsonObject(json['utm']);

    return AttriaxDeepLink(
      path: _requireJsonString(json, 'path'),
      data: _jsonObject(json['data']),
      uri: _jsonUri(json['uri']),
      utm: utmJson == null ? null : AttriaxUtmParameters.fromJson(utmJson),
    );
  }

  final String path;
  final Map<String, Object?>? data;
  final Uri? uri;
  final AttriaxUtmParameters? utm;

  Map<String, Object?> toJson() => <String, Object?>{
    'path': path,
    if (data != null && data!.isNotEmpty) 'data': _normalizeJsonMap(data!),
    if (uri != null) 'uri': uri.toString(),
    if (utm != null && !utm!.isEmpty) 'utm': utm!.toJson(),
  };
}

class AttriaxResolvedUrlAction {
  const AttriaxResolvedUrlAction({required this.uri, required this.openMode});

  factory AttriaxResolvedUrlAction.fromJson(Map<String, Object?> json) {
    final uri = _jsonUri(json['url'] ?? json['uri']);
    if (uri == null) {
      throw const FormatException('Missing or invalid "url".');
    }

    return AttriaxResolvedUrlAction(
      uri: uri,
      openMode: _parseResolvedUrlOpenMode(_jsonString(json['openMode'])),
    );
  }

  final Uri uri;
  final AttriaxResolvedUrlOpenMode openMode;

  Map<String, Object?> toJson() => <String, Object?>{
    'url': uri.toString(),
    'openMode': openMode.name,
  };
}

/// Structured install-referrer details resolved by Attriax.
class AttriaxInstallReferrerDetails {
  const AttriaxInstallReferrerDetails({
    required this.attributionType,
    required this.precision,
    this.rawPlatformInstallReferrer,
    this.source,
    this.medium,
    this.campaign,
    this.term,
    this.content,
    this.adNetwork,
    this.adClickId,
    this.deepLinkUrl,
    this.deepLinkUri,
    this.deepLinkData,
    this.registeredAt,
    this.installBeginTimestampSeconds,
    this.referrerClickTimestampSeconds,
    this.googlePlayInstantParam,
  });

  factory AttriaxInstallReferrerDetails.fromJson(Map<String, Object?> json) {
    final deepLinkDataJson = _jsonStringMap(json['deepLinkData']);

    return AttriaxInstallReferrerDetails(
      rawPlatformInstallReferrer: _jsonString(
        json['rawPlatformInstallReferrer'],
      ),
      source: _jsonString(json['source']),
      medium: _jsonString(json['medium']),
      campaign: _jsonString(json['campaign']),
      term: _jsonString(json['term']),
      content: _jsonString(json['content']),
      adNetwork: _jsonString(json['adNetwork']),
      adClickId: _jsonString(json['adClickId']),
      attributionType: _parseAttributionType(
        _jsonString(json['attributionType']),
      ),
      deepLinkUrl: _jsonString(json['deepLinkUrl']),
      deepLinkUri:
          _jsonUri(json['deepLinkUri']) ?? _jsonUri(json['deepLinkUrl']),
      deepLinkData: deepLinkDataJson,
      registeredAt: _jsonDateTime(json['registeredAt']),
      installBeginTimestampSeconds: _jsonInt(
        json['installBeginTimestampSeconds'],
      ),
      referrerClickTimestampSeconds: _jsonInt(
        json['referrerClickTimestampSeconds'],
      ),
      googlePlayInstantParam: _jsonBool(json['googlePlayInstantParam']),
      precision: _jsonDouble(json['precision']) ?? 0,
    );
  }

  final String? rawPlatformInstallReferrer;
  final String? source;
  final String? medium;
  final String? campaign;
  final String? term;
  final String? content;
  final String? adNetwork;
  final String? adClickId;
  final AttributionType attributionType;

  @Deprecated('Use deepLinkUri instead.')
  final String? deepLinkUrl;

  final Uri? deepLinkUri;
  final Map<String, String>? deepLinkData;
  final DateTime? registeredAt;
  final int? installBeginTimestampSeconds;
  final int? referrerClickTimestampSeconds;
  final bool? googlePlayInstantParam;

  AttriaxUtmParameters? get utm {
    final value = AttriaxUtmParameters(
      source: source,
      medium: medium,
      campaign: campaign,
      term: term,
      content: content,
    );
    return value.isEmpty ? null : value;
  }

  final double precision;

  Map<String, Object?> toJson() => <String, Object?>{
    if (rawPlatformInstallReferrer != null)
      'rawPlatformInstallReferrer': rawPlatformInstallReferrer,
    if (source != null) 'source': source,
    if (medium != null) 'medium': medium,
    if (campaign != null) 'campaign': campaign,
    if (term != null) 'term': term,
    if (content != null) 'content': content,
    if (adNetwork != null) 'adNetwork': adNetwork,
    if (adClickId != null) 'adClickId': adClickId,
    'attributionType': attributionType.name,
    if (deepLinkUri != null) 'deepLinkUri': deepLinkUri.toString(),
    if (deepLinkUrl != null) 'deepLinkUrl': deepLinkUrl,
    if (deepLinkData != null && deepLinkData!.isNotEmpty)
      'deepLinkData': Map<String, String>.from(deepLinkData!),
    if (registeredAt != null) 'registeredAt': registeredAt!.toIso8601String(),
    if (installBeginTimestampSeconds != null)
      'installBeginTimestampSeconds': installBeginTimestampSeconds,
    if (referrerClickTimestampSeconds != null)
      'referrerClickTimestampSeconds': referrerClickTimestampSeconds,
    if (googlePlayInstantParam != null)
      'googlePlayInstantParam': googlePlayInstantParam,
    'precision': precision,
  };
}

class AttriaxDynamicLinkRecord {
  const AttriaxDynamicLinkRecord({
    required this.id,
    required this.path,
    required this.shortUrl,
    this.name,
    this.destinationUrl,
    this.group,
    this.prefix,
    this.data,
    this.previewTitle,
    this.previewDescription,
    this.previewImagePath,
    this.iosRedirect,
    this.androidRedirect,
    this.utmSource,
    this.utmMedium,
    this.utmCampaign,
    this.utmTerm,
    this.utmContent,
    this.createdAt,
  });

  factory AttriaxDynamicLinkRecord.fromJson(Map<String, Object?> json) =>
      AttriaxDynamicLinkRecord(
        id: _requireJsonString(json, 'id'),
        path: _requireJsonString(json, 'path'),
        shortUrl: _requireJsonString(json, 'shortUrl'),
        name: _jsonString(json['name']),
        destinationUrl: _jsonString(json['destinationUrl']),
        group: _jsonString(json['group']),
        prefix: _jsonString(json['prefix']),
        data: _jsonObject(json['data']),
        previewTitle: _jsonString(json['previewTitle']),
        previewDescription: _jsonString(json['previewDescription']),
        previewImagePath: _jsonString(json['previewImagePath']),
        iosRedirect: _jsonBool(json['iosRedirect']),
        androidRedirect: _jsonBool(json['androidRedirect']),
        utmSource: _jsonString(json['utmSource']),
        utmMedium: _jsonString(json['utmMedium']),
        utmCampaign: _jsonString(json['utmCampaign']),
        utmTerm: _jsonString(json['utmTerm']),
        utmContent: _jsonString(json['utmContent']),
        createdAt: _jsonDateTime(json['createdAt']),
      );

  final String id;
  final String path;
  final String shortUrl;
  final String? name;
  final String? destinationUrl;
  final String? group;
  final String? prefix;
  final Map<String, Object?>? data;
  final String? previewTitle;
  final String? previewDescription;
  final String? previewImagePath;
  final bool? iosRedirect;
  final bool? androidRedirect;
  final String? utmSource;
  final String? utmMedium;
  final String? utmCampaign;
  final String? utmTerm;
  final String? utmContent;
  final DateTime? createdAt;
}

class AttriaxDynamicLinkSocialPreview {
  const AttriaxDynamicLinkSocialPreview({
    this.title,
    this.description,
    this.imagePath,
  });

  final String? title;
  final String? description;
  final String? imagePath;
}

class AttriaxDynamicLinkRedirects {
  const AttriaxDynamicLinkRedirects({this.ios, this.android});

  final bool? ios;
  final bool? android;
}

class AttriaxDynamicLinkUtms {
  const AttriaxDynamicLinkUtms({
    this.source,
    this.medium,
    this.campaign,
    this.term,
    this.content,
  });

  final String? source;
  final String? medium;
  final String? campaign;
  final String? term;
  final String? content;
}

class AttriaxCreateDynamicLinkResult {
  const AttriaxCreateDynamicLinkResult({
    required this.link,
    this.requestVersion,
    this.acceptedAt,
  });

  factory AttriaxCreateDynamicLinkResult.fromJson(Map<String, Object?> json) {
    final linkJson = _jsonObject(json['link']);
    if (linkJson == null) {
      throw const FormatException('Missing or invalid "link".');
    }

    return AttriaxCreateDynamicLinkResult(
      link: AttriaxDynamicLinkRecord.fromJson(linkJson),
      requestVersion: _jsonString(json['requestVersion']),
      acceptedAt: _jsonDateTime(json['acceptedAt']),
    );
  }

  final AttriaxDynamicLinkRecord link;
  final String? requestVersion;
  final DateTime? acceptedAt;
}

class AttriaxRevenueReceiptValidationResult {
  const AttriaxRevenueReceiptValidationResult({
    required this.validationId,
    required this.status,
    required this.publicReceipt,
    this.requestVersion,
    this.acceptedAt,
    this.provider,
    this.environment,
    this.transactionId,
    this.originalTransactionId,
    this.productId,
    this.failureReason,
    this.expiresAt,
    this.providerResult,
  });

  factory AttriaxRevenueReceiptValidationResult.fromJson(
    Map<String, Object?> json,
  ) => AttriaxRevenueReceiptValidationResult(
    requestVersion: _jsonString(json['requestVersion']),
    acceptedAt: _jsonDateTime(json['acceptedAt']),
    validationId: _requireJsonString(json, 'validationId'),
    status: _parseRevenueReceiptValidationStatus(_jsonString(json['status'])),
    provider: _jsonString(json['provider']),
    environment: _jsonString(json['environment']),
    transactionId: _jsonString(json['transactionId']),
    originalTransactionId: _jsonString(json['originalTransactionId']),
    productId: _jsonString(json['productId']),
    failureReason: _jsonString(json['failureReason']),
    expiresAt: _jsonDateTime(json['expiresAt']),
    providerResult: _jsonObject(json['providerResult']),
    publicReceipt:
        _jsonObject(json['publicReceipt']) ?? const <String, Object?>{},
  );

  final String validationId;
  final AttriaxRevenueReceiptValidationStatus status;
  final String? requestVersion;
  final DateTime? acceptedAt;
  final String? provider;
  final String? environment;
  final String? transactionId;
  final String? originalTransactionId;
  final String? productId;
  final String? failureReason;
  final DateTime? expiresAt;
  final Map<String, Object?>? providerResult;
  final Map<String, Object?> publicReceipt;
}