// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_register_uninstall_token_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SdkRegisterUninstallTokenDto extends SdkRegisterUninstallTokenDto {
  @override
  final String appToken;
  @override
  final String deviceId;
  @override
  final String? deviceIdSource;
  @override
  final BuiltMap<String, JsonObject?>? metadata;
  @override
  final Platform platform;
  @override
  final AppUserUninstallTokenProvider provider;
  @override
  final String token;

  factory _$SdkRegisterUninstallTokenDto([
    void Function(SdkRegisterUninstallTokenDtoBuilder)? updates,
  ]) => (SdkRegisterUninstallTokenDtoBuilder()..update(updates))._build();

  _$SdkRegisterUninstallTokenDto._({
    required this.appToken,
    required this.deviceId,
    this.deviceIdSource,
    this.metadata,
    required this.platform,
    required this.provider,
    required this.token,
  }) : super._();
  @override
  SdkRegisterUninstallTokenDto rebuild(
    void Function(SdkRegisterUninstallTokenDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SdkRegisterUninstallTokenDtoBuilder toBuilder() =>
      SdkRegisterUninstallTokenDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SdkRegisterUninstallTokenDto &&
        appToken == other.appToken &&
        deviceId == other.deviceId &&
        deviceIdSource == other.deviceIdSource &&
        metadata == other.metadata &&
        platform == other.platform &&
        provider == other.provider &&
        token == other.token;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, appToken.hashCode);
    _$hash = $jc(_$hash, deviceId.hashCode);
    _$hash = $jc(_$hash, deviceIdSource.hashCode);
    _$hash = $jc(_$hash, metadata.hashCode);
    _$hash = $jc(_$hash, platform.hashCode);
    _$hash = $jc(_$hash, provider.hashCode);
    _$hash = $jc(_$hash, token.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SdkRegisterUninstallTokenDto')
          ..add('appToken', appToken)
          ..add('deviceId', deviceId)
          ..add('deviceIdSource', deviceIdSource)
          ..add('metadata', metadata)
          ..add('platform', platform)
          ..add('provider', provider)
          ..add('token', token))
        .toString();
  }
}

class SdkRegisterUninstallTokenDtoBuilder
    implements
        Builder<
          SdkRegisterUninstallTokenDto,
          SdkRegisterUninstallTokenDtoBuilder
        > {
  _$SdkRegisterUninstallTokenDto? _$v;

  String? _appToken;
  String? get appToken => _$this._appToken;
  set appToken(String? appToken) => _$this._appToken = appToken;

  String? _deviceId;
  String? get deviceId => _$this._deviceId;
  set deviceId(String? deviceId) => _$this._deviceId = deviceId;

  String? _deviceIdSource;
  String? get deviceIdSource => _$this._deviceIdSource;
  set deviceIdSource(String? deviceIdSource) =>
      _$this._deviceIdSource = deviceIdSource;

  MapBuilder<String, JsonObject?>? _metadata;
  MapBuilder<String, JsonObject?> get metadata =>
      _$this._metadata ??= MapBuilder<String, JsonObject?>();
  set metadata(MapBuilder<String, JsonObject?>? metadata) =>
      _$this._metadata = metadata;

  Platform? _platform;
  Platform? get platform => _$this._platform;
  set platform(Platform? platform) => _$this._platform = platform;

  AppUserUninstallTokenProvider? _provider;
  AppUserUninstallTokenProvider? get provider => _$this._provider;
  set provider(AppUserUninstallTokenProvider? provider) =>
      _$this._provider = provider;

  String? _token;
  String? get token => _$this._token;
  set token(String? token) => _$this._token = token;

  SdkRegisterUninstallTokenDtoBuilder() {
    SdkRegisterUninstallTokenDto._defaults(this);
  }

  SdkRegisterUninstallTokenDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _appToken = $v.appToken;
      _deviceId = $v.deviceId;
      _deviceIdSource = $v.deviceIdSource;
      _metadata = $v.metadata?.toBuilder();
      _platform = $v.platform;
      _provider = $v.provider;
      _token = $v.token;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SdkRegisterUninstallTokenDto other) {
    _$v = other as _$SdkRegisterUninstallTokenDto;
  }

  @override
  void update(void Function(SdkRegisterUninstallTokenDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SdkRegisterUninstallTokenDto build() => _build();

  _$SdkRegisterUninstallTokenDto _build() {
    _$SdkRegisterUninstallTokenDto _$result;
    try {
      _$result =
          _$v ??
          _$SdkRegisterUninstallTokenDto._(
            appToken: BuiltValueNullFieldError.checkNotNull(
              appToken,
              r'SdkRegisterUninstallTokenDto',
              'appToken',
            ),
            deviceId: BuiltValueNullFieldError.checkNotNull(
              deviceId,
              r'SdkRegisterUninstallTokenDto',
              'deviceId',
            ),
            deviceIdSource: deviceIdSource,
            metadata: _metadata?.build(),
            platform: BuiltValueNullFieldError.checkNotNull(
              platform,
              r'SdkRegisterUninstallTokenDto',
              'platform',
            ),
            provider: BuiltValueNullFieldError.checkNotNull(
              provider,
              r'SdkRegisterUninstallTokenDto',
              'provider',
            ),
            token: BuiltValueNullFieldError.checkNotNull(
              token,
              r'SdkRegisterUninstallTokenDto',
              'token',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'metadata';
        _metadata?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'SdkRegisterUninstallTokenDto',
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
