// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_user_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SdkUserDto extends SdkUserDto {
  @override
  final String appToken;
  @override
  final bool? clearAllProperties;
  @override
  final bool? clearExternalUser;
  @override
  final BuiltList<String>? clearPropertyKeys;
  @override
  final String deviceId;
  @override
  final String? deviceIdSource;
  @override
  final String? externalUserId;
  @override
  final String? externalUserName;
  @override
  final BuiltMap<String, JsonObject?>? properties;

  factory _$SdkUserDto([void Function(SdkUserDtoBuilder)? updates]) =>
      (SdkUserDtoBuilder()..update(updates))._build();

  _$SdkUserDto._({
    required this.appToken,
    this.clearAllProperties,
    this.clearExternalUser,
    this.clearPropertyKeys,
    required this.deviceId,
    this.deviceIdSource,
    this.externalUserId,
    this.externalUserName,
    this.properties,
  }) : super._();
  @override
  SdkUserDto rebuild(void Function(SdkUserDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SdkUserDtoBuilder toBuilder() => SdkUserDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SdkUserDto &&
        appToken == other.appToken &&
        clearAllProperties == other.clearAllProperties &&
        clearExternalUser == other.clearExternalUser &&
        clearPropertyKeys == other.clearPropertyKeys &&
        deviceId == other.deviceId &&
        deviceIdSource == other.deviceIdSource &&
        externalUserId == other.externalUserId &&
        externalUserName == other.externalUserName &&
        properties == other.properties;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, appToken.hashCode);
    _$hash = $jc(_$hash, clearAllProperties.hashCode);
    _$hash = $jc(_$hash, clearExternalUser.hashCode);
    _$hash = $jc(_$hash, clearPropertyKeys.hashCode);
    _$hash = $jc(_$hash, deviceId.hashCode);
    _$hash = $jc(_$hash, deviceIdSource.hashCode);
    _$hash = $jc(_$hash, externalUserId.hashCode);
    _$hash = $jc(_$hash, externalUserName.hashCode);
    _$hash = $jc(_$hash, properties.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SdkUserDto')
          ..add('appToken', appToken)
          ..add('clearAllProperties', clearAllProperties)
          ..add('clearExternalUser', clearExternalUser)
          ..add('clearPropertyKeys', clearPropertyKeys)
          ..add('deviceId', deviceId)
          ..add('deviceIdSource', deviceIdSource)
          ..add('externalUserId', externalUserId)
          ..add('externalUserName', externalUserName)
          ..add('properties', properties))
        .toString();
  }
}

class SdkUserDtoBuilder implements Builder<SdkUserDto, SdkUserDtoBuilder> {
  _$SdkUserDto? _$v;

  String? _appToken;
  String? get appToken => _$this._appToken;
  set appToken(String? appToken) => _$this._appToken = appToken;

  bool? _clearAllProperties;
  bool? get clearAllProperties => _$this._clearAllProperties;
  set clearAllProperties(bool? clearAllProperties) =>
      _$this._clearAllProperties = clearAllProperties;

  bool? _clearExternalUser;
  bool? get clearExternalUser => _$this._clearExternalUser;
  set clearExternalUser(bool? clearExternalUser) =>
      _$this._clearExternalUser = clearExternalUser;

  ListBuilder<String>? _clearPropertyKeys;
  ListBuilder<String> get clearPropertyKeys =>
      _$this._clearPropertyKeys ??= ListBuilder<String>();
  set clearPropertyKeys(ListBuilder<String>? clearPropertyKeys) =>
      _$this._clearPropertyKeys = clearPropertyKeys;

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

  MapBuilder<String, JsonObject?>? _properties;
  MapBuilder<String, JsonObject?> get properties =>
      _$this._properties ??= MapBuilder<String, JsonObject?>();
  set properties(MapBuilder<String, JsonObject?>? properties) =>
      _$this._properties = properties;

  SdkUserDtoBuilder() {
    SdkUserDto._defaults(this);
  }

  SdkUserDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _appToken = $v.appToken;
      _clearAllProperties = $v.clearAllProperties;
      _clearExternalUser = $v.clearExternalUser;
      _clearPropertyKeys = $v.clearPropertyKeys?.toBuilder();
      _deviceId = $v.deviceId;
      _deviceIdSource = $v.deviceIdSource;
      _externalUserId = $v.externalUserId;
      _externalUserName = $v.externalUserName;
      _properties = $v.properties?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SdkUserDto other) {
    _$v = other as _$SdkUserDto;
  }

  @override
  void update(void Function(SdkUserDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SdkUserDto build() => _build();

  _$SdkUserDto _build() {
    _$SdkUserDto _$result;
    try {
      _$result =
          _$v ??
          _$SdkUserDto._(
            appToken: BuiltValueNullFieldError.checkNotNull(
              appToken,
              r'SdkUserDto',
              'appToken',
            ),
            clearAllProperties: clearAllProperties,
            clearExternalUser: clearExternalUser,
            clearPropertyKeys: _clearPropertyKeys?.build(),
            deviceId: BuiltValueNullFieldError.checkNotNull(
              deviceId,
              r'SdkUserDto',
              'deviceId',
            ),
            deviceIdSource: deviceIdSource,
            externalUserId: externalUserId,
            externalUserName: externalUserName,
            properties: _properties?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'clearPropertyKeys';
        _clearPropertyKeys?.build();

        _$failedField = 'properties';
        _properties?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'SdkUserDto',
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
