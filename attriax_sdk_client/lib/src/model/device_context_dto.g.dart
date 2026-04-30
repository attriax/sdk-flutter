// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_context_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DeviceContextDto extends DeviceContextDto {
  @override
  final String? advertisingId;
  @override
  final String? androidId;
  @override
  final String? brand;
  @override
  final String? hardware;
  @override
  final bool? isPhysicalDevice;
  @override
  final String? language;
  @override
  final String? manufacturer;
  @override
  final BuiltMap<String, JsonObject?>? metadata;
  @override
  final String? model;
  @override
  final String? name;
  @override
  final String? osVersion;
  @override
  final String? screenResolution;
  @override
  final BuiltList<String>? supportedAbis;
  @override
  final String? timezone;

  factory _$DeviceContextDto([
    void Function(DeviceContextDtoBuilder)? updates,
  ]) => (DeviceContextDtoBuilder()..update(updates))._build();

  _$DeviceContextDto._({
    this.advertisingId,
    this.androidId,
    this.brand,
    this.hardware,
    this.isPhysicalDevice,
    this.language,
    this.manufacturer,
    this.metadata,
    this.model,
    this.name,
    this.osVersion,
    this.screenResolution,
    this.supportedAbis,
    this.timezone,
  }) : super._();
  @override
  DeviceContextDto rebuild(void Function(DeviceContextDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DeviceContextDtoBuilder toBuilder() =>
      DeviceContextDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DeviceContextDto &&
        advertisingId == other.advertisingId &&
        androidId == other.androidId &&
        brand == other.brand &&
        hardware == other.hardware &&
        isPhysicalDevice == other.isPhysicalDevice &&
        language == other.language &&
        manufacturer == other.manufacturer &&
        metadata == other.metadata &&
        model == other.model &&
        name == other.name &&
        osVersion == other.osVersion &&
        screenResolution == other.screenResolution &&
        supportedAbis == other.supportedAbis &&
        timezone == other.timezone;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, advertisingId.hashCode);
    _$hash = $jc(_$hash, androidId.hashCode);
    _$hash = $jc(_$hash, brand.hashCode);
    _$hash = $jc(_$hash, hardware.hashCode);
    _$hash = $jc(_$hash, isPhysicalDevice.hashCode);
    _$hash = $jc(_$hash, language.hashCode);
    _$hash = $jc(_$hash, manufacturer.hashCode);
    _$hash = $jc(_$hash, metadata.hashCode);
    _$hash = $jc(_$hash, model.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, osVersion.hashCode);
    _$hash = $jc(_$hash, screenResolution.hashCode);
    _$hash = $jc(_$hash, supportedAbis.hashCode);
    _$hash = $jc(_$hash, timezone.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DeviceContextDto')
          ..add('advertisingId', advertisingId)
          ..add('androidId', androidId)
          ..add('brand', brand)
          ..add('hardware', hardware)
          ..add('isPhysicalDevice', isPhysicalDevice)
          ..add('language', language)
          ..add('manufacturer', manufacturer)
          ..add('metadata', metadata)
          ..add('model', model)
          ..add('name', name)
          ..add('osVersion', osVersion)
          ..add('screenResolution', screenResolution)
          ..add('supportedAbis', supportedAbis)
          ..add('timezone', timezone))
        .toString();
  }
}

class DeviceContextDtoBuilder
    implements Builder<DeviceContextDto, DeviceContextDtoBuilder> {
  _$DeviceContextDto? _$v;

  String? _advertisingId;
  String? get advertisingId => _$this._advertisingId;
  set advertisingId(String? advertisingId) =>
      _$this._advertisingId = advertisingId;

  String? _androidId;
  String? get androidId => _$this._androidId;
  set androidId(String? androidId) => _$this._androidId = androidId;

  String? _brand;
  String? get brand => _$this._brand;
  set brand(String? brand) => _$this._brand = brand;

  String? _hardware;
  String? get hardware => _$this._hardware;
  set hardware(String? hardware) => _$this._hardware = hardware;

  bool? _isPhysicalDevice;
  bool? get isPhysicalDevice => _$this._isPhysicalDevice;
  set isPhysicalDevice(bool? isPhysicalDevice) =>
      _$this._isPhysicalDevice = isPhysicalDevice;

  String? _language;
  String? get language => _$this._language;
  set language(String? language) => _$this._language = language;

  String? _manufacturer;
  String? get manufacturer => _$this._manufacturer;
  set manufacturer(String? manufacturer) => _$this._manufacturer = manufacturer;

  MapBuilder<String, JsonObject?>? _metadata;
  MapBuilder<String, JsonObject?> get metadata =>
      _$this._metadata ??= MapBuilder<String, JsonObject?>();
  set metadata(MapBuilder<String, JsonObject?>? metadata) =>
      _$this._metadata = metadata;

  String? _model;
  String? get model => _$this._model;
  set model(String? model) => _$this._model = model;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _osVersion;
  String? get osVersion => _$this._osVersion;
  set osVersion(String? osVersion) => _$this._osVersion = osVersion;

  String? _screenResolution;
  String? get screenResolution => _$this._screenResolution;
  set screenResolution(String? screenResolution) =>
      _$this._screenResolution = screenResolution;

  ListBuilder<String>? _supportedAbis;
  ListBuilder<String> get supportedAbis =>
      _$this._supportedAbis ??= ListBuilder<String>();
  set supportedAbis(ListBuilder<String>? supportedAbis) =>
      _$this._supportedAbis = supportedAbis;

  String? _timezone;
  String? get timezone => _$this._timezone;
  set timezone(String? timezone) => _$this._timezone = timezone;

  DeviceContextDtoBuilder() {
    DeviceContextDto._defaults(this);
  }

  DeviceContextDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _advertisingId = $v.advertisingId;
      _androidId = $v.androidId;
      _brand = $v.brand;
      _hardware = $v.hardware;
      _isPhysicalDevice = $v.isPhysicalDevice;
      _language = $v.language;
      _manufacturer = $v.manufacturer;
      _metadata = $v.metadata?.toBuilder();
      _model = $v.model;
      _name = $v.name;
      _osVersion = $v.osVersion;
      _screenResolution = $v.screenResolution;
      _supportedAbis = $v.supportedAbis?.toBuilder();
      _timezone = $v.timezone;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DeviceContextDto other) {
    _$v = other as _$DeviceContextDto;
  }

  @override
  void update(void Function(DeviceContextDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DeviceContextDto build() => _build();

  _$DeviceContextDto _build() {
    _$DeviceContextDto _$result;
    try {
      _$result =
          _$v ??
          _$DeviceContextDto._(
            advertisingId: advertisingId,
            androidId: androidId,
            brand: brand,
            hardware: hardware,
            isPhysicalDevice: isPhysicalDevice,
            language: language,
            manufacturer: manufacturer,
            metadata: _metadata?.build(),
            model: model,
            name: name,
            osVersion: osVersion,
            screenResolution: screenResolution,
            supportedAbis: _supportedAbis?.build(),
            timezone: timezone,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'metadata';
        _metadata?.build();

        _$failedField = 'supportedAbis';
        _supportedAbis?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'DeviceContextDto',
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
