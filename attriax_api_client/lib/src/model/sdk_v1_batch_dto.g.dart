// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_v1_batch_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SdkV1BatchDto extends SdkV1BatchDto {
  @override
  final String appToken;
  @override
  final String deviceId;
  @override
  final String? deviceIdSource;
  @override
  final BuiltList<SdkV1BatchItemDto> items;
  @override
  final String requestId;

  factory _$SdkV1BatchDto([void Function(SdkV1BatchDtoBuilder)? updates]) =>
      (SdkV1BatchDtoBuilder()..update(updates))._build();

  _$SdkV1BatchDto._({
    required this.appToken,
    required this.deviceId,
    this.deviceIdSource,
    required this.items,
    required this.requestId,
  }) : super._();
  @override
  SdkV1BatchDto rebuild(void Function(SdkV1BatchDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SdkV1BatchDtoBuilder toBuilder() => SdkV1BatchDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SdkV1BatchDto &&
        appToken == other.appToken &&
        deviceId == other.deviceId &&
        deviceIdSource == other.deviceIdSource &&
        items == other.items &&
        requestId == other.requestId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, appToken.hashCode);
    _$hash = $jc(_$hash, deviceId.hashCode);
    _$hash = $jc(_$hash, deviceIdSource.hashCode);
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, requestId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SdkV1BatchDto')
          ..add('appToken', appToken)
          ..add('deviceId', deviceId)
          ..add('deviceIdSource', deviceIdSource)
          ..add('items', items)
          ..add('requestId', requestId))
        .toString();
  }
}

class SdkV1BatchDtoBuilder
    implements Builder<SdkV1BatchDto, SdkV1BatchDtoBuilder> {
  _$SdkV1BatchDto? _$v;

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

  ListBuilder<SdkV1BatchItemDto>? _items;
  ListBuilder<SdkV1BatchItemDto> get items =>
      _$this._items ??= ListBuilder<SdkV1BatchItemDto>();
  set items(ListBuilder<SdkV1BatchItemDto>? items) => _$this._items = items;

  String? _requestId;
  String? get requestId => _$this._requestId;
  set requestId(String? requestId) => _$this._requestId = requestId;

  SdkV1BatchDtoBuilder() {
    SdkV1BatchDto._defaults(this);
  }

  SdkV1BatchDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _appToken = $v.appToken;
      _deviceId = $v.deviceId;
      _deviceIdSource = $v.deviceIdSource;
      _items = $v.items.toBuilder();
      _requestId = $v.requestId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SdkV1BatchDto other) {
    _$v = other as _$SdkV1BatchDto;
  }

  @override
  void update(void Function(SdkV1BatchDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SdkV1BatchDto build() => _build();

  _$SdkV1BatchDto _build() {
    _$SdkV1BatchDto _$result;
    try {
      _$result =
          _$v ??
          _$SdkV1BatchDto._(
            appToken: BuiltValueNullFieldError.checkNotNull(
              appToken,
              r'SdkV1BatchDto',
              'appToken',
            ),
            deviceId: BuiltValueNullFieldError.checkNotNull(
              deviceId,
              r'SdkV1BatchDto',
              'deviceId',
            ),
            deviceIdSource: deviceIdSource,
            items: items.build(),
            requestId: BuiltValueNullFieldError.checkNotNull(
              requestId,
              r'SdkV1BatchDto',
              'requestId',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'SdkV1BatchDto',
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
