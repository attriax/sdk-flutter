// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_v1_open_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SdkV1OpenDto extends SdkV1OpenDto {
  @override
  final AppVersionContextDto app;
  @override
  final String appToken;
  @override
  final DeviceContextDto device;
  @override
  final String deviceId;
  @override
  final String? deviceIdSource;
  @override
  final String? installReferrer;
  @override
  final bool? isFirstLaunch;
  @override
  final Platform platform;
  @override
  final SdkVersionContextDto sdk;

  factory _$SdkV1OpenDto([void Function(SdkV1OpenDtoBuilder)? updates]) =>
      (SdkV1OpenDtoBuilder()..update(updates))._build();

  _$SdkV1OpenDto._({
    required this.app,
    required this.appToken,
    required this.device,
    required this.deviceId,
    this.deviceIdSource,
    this.installReferrer,
    this.isFirstLaunch,
    required this.platform,
    required this.sdk,
  }) : super._();
  @override
  SdkV1OpenDto rebuild(void Function(SdkV1OpenDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SdkV1OpenDtoBuilder toBuilder() => SdkV1OpenDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SdkV1OpenDto &&
        app == other.app &&
        appToken == other.appToken &&
        device == other.device &&
        deviceId == other.deviceId &&
        deviceIdSource == other.deviceIdSource &&
        installReferrer == other.installReferrer &&
        isFirstLaunch == other.isFirstLaunch &&
        platform == other.platform &&
        sdk == other.sdk;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, app.hashCode);
    _$hash = $jc(_$hash, appToken.hashCode);
    _$hash = $jc(_$hash, device.hashCode);
    _$hash = $jc(_$hash, deviceId.hashCode);
    _$hash = $jc(_$hash, deviceIdSource.hashCode);
    _$hash = $jc(_$hash, installReferrer.hashCode);
    _$hash = $jc(_$hash, isFirstLaunch.hashCode);
    _$hash = $jc(_$hash, platform.hashCode);
    _$hash = $jc(_$hash, sdk.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SdkV1OpenDto')
          ..add('app', app)
          ..add('appToken', appToken)
          ..add('device', device)
          ..add('deviceId', deviceId)
          ..add('deviceIdSource', deviceIdSource)
          ..add('installReferrer', installReferrer)
          ..add('isFirstLaunch', isFirstLaunch)
          ..add('platform', platform)
          ..add('sdk', sdk))
        .toString();
  }
}

class SdkV1OpenDtoBuilder
    implements Builder<SdkV1OpenDto, SdkV1OpenDtoBuilder> {
  _$SdkV1OpenDto? _$v;

  AppVersionContextDtoBuilder? _app;
  AppVersionContextDtoBuilder get app =>
      _$this._app ??= AppVersionContextDtoBuilder();
  set app(AppVersionContextDtoBuilder? app) => _$this._app = app;

  String? _appToken;
  String? get appToken => _$this._appToken;
  set appToken(String? appToken) => _$this._appToken = appToken;

  DeviceContextDtoBuilder? _device;
  DeviceContextDtoBuilder get device =>
      _$this._device ??= DeviceContextDtoBuilder();
  set device(DeviceContextDtoBuilder? device) => _$this._device = device;

  String? _deviceId;
  String? get deviceId => _$this._deviceId;
  set deviceId(String? deviceId) => _$this._deviceId = deviceId;

  String? _deviceIdSource;
  String? get deviceIdSource => _$this._deviceIdSource;
  set deviceIdSource(String? deviceIdSource) =>
      _$this._deviceIdSource = deviceIdSource;

  String? _installReferrer;
  String? get installReferrer => _$this._installReferrer;
  set installReferrer(String? installReferrer) =>
      _$this._installReferrer = installReferrer;

  bool? _isFirstLaunch;
  bool? get isFirstLaunch => _$this._isFirstLaunch;
  set isFirstLaunch(bool? isFirstLaunch) =>
      _$this._isFirstLaunch = isFirstLaunch;

  Platform? _platform;
  Platform? get platform => _$this._platform;
  set platform(Platform? platform) => _$this._platform = platform;

  SdkVersionContextDtoBuilder? _sdk;
  SdkVersionContextDtoBuilder get sdk =>
      _$this._sdk ??= SdkVersionContextDtoBuilder();
  set sdk(SdkVersionContextDtoBuilder? sdk) => _$this._sdk = sdk;

  SdkV1OpenDtoBuilder() {
    SdkV1OpenDto._defaults(this);
  }

  SdkV1OpenDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _app = $v.app.toBuilder();
      _appToken = $v.appToken;
      _device = $v.device.toBuilder();
      _deviceId = $v.deviceId;
      _deviceIdSource = $v.deviceIdSource;
      _installReferrer = $v.installReferrer;
      _isFirstLaunch = $v.isFirstLaunch;
      _platform = $v.platform;
      _sdk = $v.sdk.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SdkV1OpenDto other) {
    _$v = other as _$SdkV1OpenDto;
  }

  @override
  void update(void Function(SdkV1OpenDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SdkV1OpenDto build() => _build();

  _$SdkV1OpenDto _build() {
    _$SdkV1OpenDto _$result;
    try {
      _$result =
          _$v ??
          _$SdkV1OpenDto._(
            app: app.build(),
            appToken: BuiltValueNullFieldError.checkNotNull(
              appToken,
              r'SdkV1OpenDto',
              'appToken',
            ),
            device: device.build(),
            deviceId: BuiltValueNullFieldError.checkNotNull(
              deviceId,
              r'SdkV1OpenDto',
              'deviceId',
            ),
            deviceIdSource: deviceIdSource,
            installReferrer: installReferrer,
            isFirstLaunch: isFirstLaunch,
            platform: BuiltValueNullFieldError.checkNotNull(
              platform,
              r'SdkV1OpenDto',
              'platform',
            ),
            sdk: sdk.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'app';
        app.build();

        _$failedField = 'device';
        device.build();

        _$failedField = 'sdk';
        sdk.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'SdkV1OpenDto',
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
