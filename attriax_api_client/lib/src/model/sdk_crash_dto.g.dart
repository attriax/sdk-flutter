// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_crash_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SdkCrashDto extends SdkCrashDto {
  @override
  final String? appBuildNumber;
  @override
  final String? appPackageName;
  @override
  final String appToken;
  @override
  final String? appVersion;
  @override
  final DateTime clientOccurredAt;
  @override
  final String deviceId;
  @override
  final String deviceIdSource;
  @override
  final String exceptionType;
  @override
  final bool isFatal;
  @override
  final bool isFirstLaunch;
  @override
  final String? locale;
  @override
  final String message;
  @override
  final BuiltMap<String, JsonObject?>? metadata;
  @override
  final Platform platform;
  @override
  final String? reason;
  @override
  final String? sdkApiVersion;
  @override
  final String? sdkPackageVersion;
  @override
  final String? sessionId;
  @override
  final num? sessionRelativeTimeMs;
  @override
  final String source_;
  @override
  final String stackTrace;

  factory _$SdkCrashDto([void Function(SdkCrashDtoBuilder)? updates]) =>
      (SdkCrashDtoBuilder()..update(updates))._build();

  _$SdkCrashDto._({
    this.appBuildNumber,
    this.appPackageName,
    required this.appToken,
    this.appVersion,
    required this.clientOccurredAt,
    required this.deviceId,
    required this.deviceIdSource,
    required this.exceptionType,
    required this.isFatal,
    required this.isFirstLaunch,
    this.locale,
    required this.message,
    this.metadata,
    required this.platform,
    this.reason,
    this.sdkApiVersion,
    this.sdkPackageVersion,
    this.sessionId,
    this.sessionRelativeTimeMs,
    required this.source_,
    required this.stackTrace,
  }) : super._();
  @override
  SdkCrashDto rebuild(void Function(SdkCrashDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SdkCrashDtoBuilder toBuilder() => SdkCrashDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SdkCrashDto &&
        appBuildNumber == other.appBuildNumber &&
        appPackageName == other.appPackageName &&
        appToken == other.appToken &&
        appVersion == other.appVersion &&
        clientOccurredAt == other.clientOccurredAt &&
        deviceId == other.deviceId &&
        deviceIdSource == other.deviceIdSource &&
        exceptionType == other.exceptionType &&
        isFatal == other.isFatal &&
        isFirstLaunch == other.isFirstLaunch &&
        locale == other.locale &&
        message == other.message &&
        metadata == other.metadata &&
        platform == other.platform &&
        reason == other.reason &&
        sdkApiVersion == other.sdkApiVersion &&
        sdkPackageVersion == other.sdkPackageVersion &&
        sessionId == other.sessionId &&
        sessionRelativeTimeMs == other.sessionRelativeTimeMs &&
        source_ == other.source_ &&
        stackTrace == other.stackTrace;
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
    _$hash = $jc(_$hash, exceptionType.hashCode);
    _$hash = $jc(_$hash, isFatal.hashCode);
    _$hash = $jc(_$hash, isFirstLaunch.hashCode);
    _$hash = $jc(_$hash, locale.hashCode);
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jc(_$hash, metadata.hashCode);
    _$hash = $jc(_$hash, platform.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jc(_$hash, sdkApiVersion.hashCode);
    _$hash = $jc(_$hash, sdkPackageVersion.hashCode);
    _$hash = $jc(_$hash, sessionId.hashCode);
    _$hash = $jc(_$hash, sessionRelativeTimeMs.hashCode);
    _$hash = $jc(_$hash, source_.hashCode);
    _$hash = $jc(_$hash, stackTrace.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SdkCrashDto')
          ..add('appBuildNumber', appBuildNumber)
          ..add('appPackageName', appPackageName)
          ..add('appToken', appToken)
          ..add('appVersion', appVersion)
          ..add('clientOccurredAt', clientOccurredAt)
          ..add('deviceId', deviceId)
          ..add('deviceIdSource', deviceIdSource)
          ..add('exceptionType', exceptionType)
          ..add('isFatal', isFatal)
          ..add('isFirstLaunch', isFirstLaunch)
          ..add('locale', locale)
          ..add('message', message)
          ..add('metadata', metadata)
          ..add('platform', platform)
          ..add('reason', reason)
          ..add('sdkApiVersion', sdkApiVersion)
          ..add('sdkPackageVersion', sdkPackageVersion)
          ..add('sessionId', sessionId)
          ..add('sessionRelativeTimeMs', sessionRelativeTimeMs)
          ..add('source_', source_)
          ..add('stackTrace', stackTrace))
        .toString();
  }
}

class SdkCrashDtoBuilder implements Builder<SdkCrashDto, SdkCrashDtoBuilder> {
  _$SdkCrashDto? _$v;

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

  String? _exceptionType;
  String? get exceptionType => _$this._exceptionType;
  set exceptionType(String? exceptionType) =>
      _$this._exceptionType = exceptionType;

  bool? _isFatal;
  bool? get isFatal => _$this._isFatal;
  set isFatal(bool? isFatal) => _$this._isFatal = isFatal;

  bool? _isFirstLaunch;
  bool? get isFirstLaunch => _$this._isFirstLaunch;
  set isFirstLaunch(bool? isFirstLaunch) =>
      _$this._isFirstLaunch = isFirstLaunch;

  String? _locale;
  String? get locale => _$this._locale;
  set locale(String? locale) => _$this._locale = locale;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  MapBuilder<String, JsonObject?>? _metadata;
  MapBuilder<String, JsonObject?> get metadata =>
      _$this._metadata ??= MapBuilder<String, JsonObject?>();
  set metadata(MapBuilder<String, JsonObject?>? metadata) =>
      _$this._metadata = metadata;

  Platform? _platform;
  Platform? get platform => _$this._platform;
  set platform(Platform? platform) => _$this._platform = platform;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

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

  String? _source_;
  String? get source_ => _$this._source_;
  set source_(String? source_) => _$this._source_ = source_;

  String? _stackTrace;
  String? get stackTrace => _$this._stackTrace;
  set stackTrace(String? stackTrace) => _$this._stackTrace = stackTrace;

  SdkCrashDtoBuilder() {
    SdkCrashDto._defaults(this);
  }

  SdkCrashDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _appBuildNumber = $v.appBuildNumber;
      _appPackageName = $v.appPackageName;
      _appToken = $v.appToken;
      _appVersion = $v.appVersion;
      _clientOccurredAt = $v.clientOccurredAt;
      _deviceId = $v.deviceId;
      _deviceIdSource = $v.deviceIdSource;
      _exceptionType = $v.exceptionType;
      _isFatal = $v.isFatal;
      _isFirstLaunch = $v.isFirstLaunch;
      _locale = $v.locale;
      _message = $v.message;
      _metadata = $v.metadata?.toBuilder();
      _platform = $v.platform;
      _reason = $v.reason;
      _sdkApiVersion = $v.sdkApiVersion;
      _sdkPackageVersion = $v.sdkPackageVersion;
      _sessionId = $v.sessionId;
      _sessionRelativeTimeMs = $v.sessionRelativeTimeMs;
      _source_ = $v.source_;
      _stackTrace = $v.stackTrace;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SdkCrashDto other) {
    _$v = other as _$SdkCrashDto;
  }

  @override
  void update(void Function(SdkCrashDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SdkCrashDto build() => _build();

  _$SdkCrashDto _build() {
    _$SdkCrashDto _$result;
    try {
      _$result =
          _$v ??
          _$SdkCrashDto._(
            appBuildNumber: appBuildNumber,
            appPackageName: appPackageName,
            appToken: BuiltValueNullFieldError.checkNotNull(
              appToken,
              r'SdkCrashDto',
              'appToken',
            ),
            appVersion: appVersion,
            clientOccurredAt: BuiltValueNullFieldError.checkNotNull(
              clientOccurredAt,
              r'SdkCrashDto',
              'clientOccurredAt',
            ),
            deviceId: BuiltValueNullFieldError.checkNotNull(
              deviceId,
              r'SdkCrashDto',
              'deviceId',
            ),
            deviceIdSource: BuiltValueNullFieldError.checkNotNull(
              deviceIdSource,
              r'SdkCrashDto',
              'deviceIdSource',
            ),
            exceptionType: BuiltValueNullFieldError.checkNotNull(
              exceptionType,
              r'SdkCrashDto',
              'exceptionType',
            ),
            isFatal: BuiltValueNullFieldError.checkNotNull(
              isFatal,
              r'SdkCrashDto',
              'isFatal',
            ),
            isFirstLaunch: BuiltValueNullFieldError.checkNotNull(
              isFirstLaunch,
              r'SdkCrashDto',
              'isFirstLaunch',
            ),
            locale: locale,
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'SdkCrashDto',
              'message',
            ),
            metadata: _metadata?.build(),
            platform: BuiltValueNullFieldError.checkNotNull(
              platform,
              r'SdkCrashDto',
              'platform',
            ),
            reason: reason,
            sdkApiVersion: sdkApiVersion,
            sdkPackageVersion: sdkPackageVersion,
            sessionId: sessionId,
            sessionRelativeTimeMs: sessionRelativeTimeMs,
            source_: BuiltValueNullFieldError.checkNotNull(
              source_,
              r'SdkCrashDto',
              'source_',
            ),
            stackTrace: BuiltValueNullFieldError.checkNotNull(
              stackTrace,
              r'SdkCrashDto',
              'stackTrace',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'metadata';
        _metadata?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'SdkCrashDto',
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
