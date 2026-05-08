class AttriaxWebEnvironmentSnapshot {
  const AttriaxWebEnvironmentSnapshot({
    this.assetBaseUrl,
    this.documentBaseUrl,
    this.locationBaseUrl,
    this.appName,
    this.browserName,
    this.userAgent,
    this.platform,
    this.vendor,
    this.title,
    this.referrer,
  });

  final String? assetBaseUrl;
  final String? documentBaseUrl;
  final String? locationBaseUrl;
  final String? appName;
  final String? browserName;
  final String? userAgent;
  final String? platform;
  final String? vendor;
  final String? title;
  final String? referrer;
}

AttriaxWebEnvironmentSnapshot currentAttriaxWebEnvironment() =>
    const AttriaxWebEnvironmentSnapshot();
