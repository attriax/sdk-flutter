// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_session_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SdkSessionDto extends SdkSessionDto {
  @override
  final String? appBuildNumber;
  @override
  final String? appPackageName;
  @override
  final String appToken;
  @override
  final String? appVersion;
  @override
  final DateTime? clientOccurredAt;
  @override
  final String deviceId;
  @override
  final String? deviceIdSource;
  @override
  final bool? isFirstLaunch;
  @override
  final SdkSessionLifecycleKind kind;
  @override
  final String? locale;
  @override
  final BuiltMap<String, JsonObject?>? metadata;
  @override
  final Platform? platform;
  @override
  final String? sdkApiVersion;
  @override
  final String? sdkPackageVersion;
  @override
  final String sessionId;
  @override
  final num? sessionRelativeTimeMs;

  factory _$SdkSessionDto([void Function(SdkSessionDtoBuilder)? updates]) =>
      (SdkSessionDtoBuilder()..update(updates))._build();

  _$SdkSessionDto._({
    this.appBuildNumber,
    this.appPackageName,
    required this.appToken,
    this.appVersion,
    this.clientOccurredAt,
    required this.deviceId,
    this.deviceIdSource,
    this.isFirstLaunch,
    required this.kind,
    this.locale,
    this.metadata,
    this.platform,
    this.sdkApiVersion,
    this.sdkPackageVersion,
    required this.sessionId,
    this.sessionRelativeTimeMs,
  }) : super._();
  @override
  SdkSessionDto rebuild(void Function(SdkSessionDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SdkSessionDtoBuilder toBuilder() => SdkSessionDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SdkSessionDto &&
        appBuildNumber == other.appBuildNumber &&
        appPackageName == other.appPackageName &&
        appToken == other.appToken &&
        appVersion == other.appVersion &&
        clientOccurredAt == other.clientOccurredAt &&
        deviceId == other.deviceId &&
        deviceIdSource == other.deviceIdSource &&
        isFirstLaunch == other.isFirstLaunch &&
        kind == other.kind &&
        locale == other.locale &&
        metadata == other.metadata &&
        platform == other.platform &&
        sdkApiVersion == other.sdkApiVersion &&
        sdkPackageVersion == other.sdkPackageVersion &&
        sessionId == other.sessionId &&
        sessionRelativeTimeMs == other.sessionRelativeTimeMs;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, appBuildNumber.hashCode);
    _$hash = $jc(_$hash, appPackageName.hashCode);
    _$hash = $jc(_$hash, appToken.hashCode);
    _$hash = $jc(_$hash, appVersion.hashCode);
    _$hash = $jc(_$hash, clientOccurredAt.hashCode);
    _$hash = $jc(_$hash, deviceId.hashCode);
    _$hash = $jc(_$hash, deviceIdSource.hashCode);
    _$hash = $jc(_$hash, isFirstLaunch.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, locale.hashCode);
    _$hash = $jc(_$hash, metadata.hashCode);
    _$hash = $jc(_$hash, platform.hashCode);
    _$hash = $jc(_$hash, sdkApiVersion.hashCode);
    _$hash = $jc(_$hash, sdkPackageVersion.hashCode);
    _$hash = $jc(_$hash, sessionId.hashCode);
    _$hash = $jc(_$hash, sessionRelativeTimeMs.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SdkSessionDto')
          ..add('appBuildNumber', appBuildNumber)
          ..add('appPackageName', appPackageName)
          ..add('appToken', appToken)
          ..add('appVersion', appVersion)
          ..add('clientOccurredAt', clientOccurredAt)
          ..add('deviceId', deviceId)
          ..add('deviceIdSource', deviceIdSource)
          ..add('isFirstLaunch', isFirstLaunch)
          ..add('kind', kind)
          ..add('locale', locale)
          ..add('metadata', metadata)
          ..add('platform', platform)
          ..add('sdkApiVersion', sdkApiVersion)
          ..add('sdkPackageVersion', sdkPackageVersion)
          ..add('sessionId', sessionId)
          ..add('sessionRelativeTimeMs', sessionRelativeTimeMs))
        .toString();
  }
}

class SdkSessionDtoBuilder
    implements Builder<SdkSessionDto, SdkSessionDtoBuilder> {
  _$SdkSessionDto? _$v;

  String? _appBuildNumber;
  String? get appBuildNumber => _$this._appBuildNumber;
  set appBuildNumber(String? appBuildNumber) =>
      _$this._appBuildNumber = appBuildNumber;

  String? _appPackageName;
  String? get appPackageName => _$this._appPackageName;
  set appPackageName(String? appPackageName) =>
      _$this._appPackageName = appPackageName;

  String? _appToken;
  String? get appToken => _$this._appToken;
  set appToken(String? appToken) => _$this._appToken = appToken;

  String? _appVersion;
  String? get appVersion => _$this._appVersion;
  set appVersion(String? appVersion) => _$this._appVersion = appVersion;

  DateTime? _clientOccurredAt;
  DateTime? get clientOccurredAt => _$this._clientOccurredAt;
  set clientOccurredAt(DateTime? clientOccurredAt) =>
      _$this._clientOccurredAt = clientOccurredAt;

  String? _deviceId;
  String? get deviceId => _$this._deviceId;
  set deviceId(String? deviceId) => _$this._deviceId = deviceId;

  String? _deviceIdSource;
  String? get deviceIdSource => _$this._deviceIdSource;
  set deviceIdSource(String? deviceIdSource) =>
      _$this._deviceIdSource = deviceIdSource;

  bool? _isFirstLaunch;
  bool? get isFirstLaunch => _$this._isFirstLaunch;
  set isFirstLaunch(bool? isFirstLaunch) =>
      _$this._isFirstLaunch = isFirstLaunch;

  SdkSessionLifecycleKind? _kind;
  SdkSessionLifecycleKind? get kind => _$this._kind;
  set kind(SdkSessionLifecycleKind? kind) => _$this._kind = kind;

  String? _locale;
  String? get locale => _$this._locale;
  set locale(String? locale) => _$this._locale = locale;

  MapBuilder<String, JsonObject?>? _metadata;
  MapBuilder<String, JsonObject?> get metadata =>
      _$this._metadata ??= MapBuilder<String, JsonObject?>();
  set metadata(MapBuilder<String, JsonObject?>? metadata) =>
      _$this._metadata = metadata;

  Platform? _platform;
  Platform? get platform => _$this._platform;
  set platform(Platform? platform) => _$this._platform = platform;

  String? _sdkApiVersion;
  String? get sdkApiVersion => _$this._sdkApiVersion;
  set sdkApiVersion(String? sdkApiVersion) =>
      _$this._sdkApiVersion = sdkApiVersion;

  String? _sdkPackageVersion;
  String? get sdkPackageVersion => _$this._sdkPackageVersion;
  set sdkPackageVersion(String? sdkPackageVersion) =>
      _$this._sdkPackageVersion = sdkPackageVersion;

  String? _sessionId;
  String? get sessionId => _$this._sessionId;
  set sessionId(String? sessionId) => _$this._sessionId = sessionId;

  num? _sessionRelativeTimeMs;
  num? get sessionRelativeTimeMs => _$this._sessionRelativeTimeMs;
  set sessionRelativeTimeMs(num? sessionRelativeTimeMs) =>
      _$this._sessionRelativeTimeMs = sessionRelativeTimeMs;

  SdkSessionDtoBuilder() {
    SdkSessionDto._defaults(this);
  }

  SdkSessionDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _appBuildNumber = $v.appBuildNumber;
      _appPackageName = $v.appPackageName;
      _appToken = $v.appToken;
      _appVersion = $v.appVersion;
      _clientOccurredAt = $v.clientOccurredAt;
      _deviceId = $v.deviceId;
      _deviceIdSource = $v.deviceIdSource;
      _isFirstLaunch = $v.isFirstLaunch;
      _kind = $v.kind;
      _locale = $v.locale;
      _metadata = $v.metadata?.toBuilder();
      _platform = $v.platform;
      _sdkApiVersion = $v.sdkApiVersion;
      _sdkPackageVersion = $v.sdkPackageVersion;
      _sessionId = $v.sessionId;
      _sessionRelativeTimeMs = $v.sessionRelativeTimeMs;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SdkSessionDto other) {
    _$v = other as _$SdkSessionDto;
  }

  @override
  void update(void Function(SdkSessionDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SdkSessionDto build() => _build();

  _$SdkSessionDto _build() {
    _$SdkSessionDto _$result;
    try {
      _$result =
          _$v ??
          _$SdkSessionDto._(
            appBuildNumber: appBuildNumber,
            appPackageName: appPackageName,
            appToken: BuiltValueNullFieldError.checkNotNull(
              appToken,
              r'SdkSessionDto',
              'appToken',
            ),
            appVersion: appVersion,
            clientOccurredAt: clientOccurredAt,
            deviceId: BuiltValueNullFieldError.checkNotNull(
              deviceId,
              r'SdkSessionDto',
              'deviceId',
            ),
            deviceIdSource: deviceIdSource,
            isFirstLaunch: isFirstLaunch,
            kind: BuiltValueNullFieldError.checkNotNull(
              kind,
              r'SdkSessionDto',
              'kind',
            ),
            locale: locale,
            metadata: _metadata?.build(),
            platform: platform,
            sdkApiVersion: sdkApiVersion,
            sdkPackageVersion: sdkPackageVersion,
            sessionId: BuiltValueNullFieldError.checkNotNull(
              sessionId,
              r'SdkSessionDto',
              'sessionId',
            ),
            sessionRelativeTimeMs: sessionRelativeTimeMs,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'metadata';
        _metadata?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'SdkSessionDto',
          _$failedField,
          e.toString(),
        );
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
