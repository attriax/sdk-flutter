// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_identify_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SdkIdentifyDto extends SdkIdentifyDto {
  @override
  final String appToken;
  @override
  final String deviceId;
  @override
  final String? deviceIdSource;
  @override
  final String? externalUserId;
  @override
  final String? externalUserName;

  factory _$SdkIdentifyDto([void Function(SdkIdentifyDtoBuilder)? updates]) =>
      (SdkIdentifyDtoBuilder()..update(updates))._build();

  _$SdkIdentifyDto._({
    required this.appToken,
    required this.deviceId,
    this.deviceIdSource,
    this.externalUserId,
    this.externalUserName,
  }) : super._();
  @override
  SdkIdentifyDto rebuild(void Function(SdkIdentifyDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SdkIdentifyDtoBuilder toBuilder() => SdkIdentifyDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SdkIdentifyDto &&
        appToken == other.appToken &&
        deviceId == other.deviceId &&
        deviceIdSource == other.deviceIdSource &&
        externalUserId == other.externalUserId &&
        externalUserName == other.externalUserName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, appToken.hashCode);
    _$hash = $jc(_$hash, deviceId.hashCode);
    _$hash = $jc(_$hash, deviceIdSource.hashCode);
    _$hash = $jc(_$hash, externalUserId.hashCode);
    _$hash = $jc(_$hash, externalUserName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SdkIdentifyDto')
          ..add('appToken', appToken)
          ..add('deviceId', deviceId)
          ..add('deviceIdSource', deviceIdSource)
          ..add('externalUserId', externalUserId)
          ..add('externalUserName', externalUserName))
        .toString();
  }
}

class SdkIdentifyDtoBuilder
    implements Builder<SdkIdentifyDto, SdkIdentifyDtoBuilder> {
  _$SdkIdentifyDto? _$v;

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

  String? _externalUserId;
  String? get externalUserId => _$this._externalUserId;
  set externalUserId(String? externalUserId) =>
      _$this._externalUserId = externalUserId;

  String? _externalUserName;
  String? get externalUserName => _$this._externalUserName;
  set externalUserName(String? externalUserName) =>
      _$this._externalUserName = externalUserName;

  SdkIdentifyDtoBuilder() {
    SdkIdentifyDto._defaults(this);
  }

  SdkIdentifyDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _appToken = $v.appToken;
      _deviceId = $v.deviceId;
      _deviceIdSource = $v.deviceIdSource;
      _externalUserId = $v.externalUserId;
      _externalUserName = $v.externalUserName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SdkIdentifyDto other) {
    _$v = other as _$SdkIdentifyDto;
  }

  @override
  void update(void Function(SdkIdentifyDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SdkIdentifyDto build() => _build();

  _$SdkIdentifyDto _build() {
    final _$result =
        _$v ??
        _$SdkIdentifyDto._(
          appToken: BuiltValueNullFieldError.checkNotNull(
            appToken,
            r'SdkIdentifyDto',
            'appToken',
          ),
          deviceId: BuiltValueNullFieldError.checkNotNull(
            deviceId,
            r'SdkIdentifyDto',
            'deviceId',
          ),
          deviceIdSource: deviceIdSource,
          externalUserId: externalUserId,
          externalUserName: externalUserName,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
