// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_event_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SdkEventDto extends SdkEventDto {
  @override
  final String appToken;
  @override
  final DateTime? clientOccurredAt;
  @override
  final String deviceId;
  @override
  final String? deviceIdSource;
  @override
  final BuiltMap<String, JsonObject?>? eventData;
  @override
  final String eventName;
  @override
  final String? sessionId;
  @override
  final num? sessionRelativeTimeMs;

  factory _$SdkEventDto([void Function(SdkEventDtoBuilder)? updates]) =>
      (SdkEventDtoBuilder()..update(updates))._build();

  _$SdkEventDto._({
    required this.appToken,
    this.clientOccurredAt,
    required this.deviceId,
    this.deviceIdSource,
    this.eventData,
    required this.eventName,
    this.sessionId,
    this.sessionRelativeTimeMs,
  }) : super._();
  @override
  SdkEventDto rebuild(void Function(SdkEventDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SdkEventDtoBuilder toBuilder() => SdkEventDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SdkEventDto &&
        appToken == other.appToken &&
        clientOccurredAt == other.clientOccurredAt &&
        deviceId == other.deviceId &&
        deviceIdSource == other.deviceIdSource &&
        eventData == other.eventData &&
        eventName == other.eventName &&
        sessionId == other.sessionId &&
        sessionRelativeTimeMs == other.sessionRelativeTimeMs;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, appToken.hashCode);
    _$hash = $jc(_$hash, clientOccurredAt.hashCode);
    _$hash = $jc(_$hash, deviceId.hashCode);
    _$hash = $jc(_$hash, deviceIdSource.hashCode);
    _$hash = $jc(_$hash, eventData.hashCode);
    _$hash = $jc(_$hash, eventName.hashCode);
    _$hash = $jc(_$hash, sessionId.hashCode);
    _$hash = $jc(_$hash, sessionRelativeTimeMs.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SdkEventDto')
          ..add('appToken', appToken)
          ..add('clientOccurredAt', clientOccurredAt)
          ..add('deviceId', deviceId)
          ..add('deviceIdSource', deviceIdSource)
          ..add('eventData', eventData)
          ..add('eventName', eventName)
          ..add('sessionId', sessionId)
          ..add('sessionRelativeTimeMs', sessionRelativeTimeMs))
        .toString();
  }
}

class SdkEventDtoBuilder implements Builder<SdkEventDto, SdkEventDtoBuilder> {
  _$SdkEventDto? _$v;

  String? _appToken;
  String? get appToken => _$this._appToken;
  set appToken(String? appToken) => _$this._appToken = appToken;

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

  MapBuilder<String, JsonObject?>? _eventData;
  MapBuilder<String, JsonObject?> get eventData =>
      _$this._eventData ??= MapBuilder<String, JsonObject?>();
  set eventData(MapBuilder<String, JsonObject?>? eventData) =>
      _$this._eventData = eventData;

  String? _eventName;
  String? get eventName => _$this._eventName;
  set eventName(String? eventName) => _$this._eventName = eventName;

  String? _sessionId;
  String? get sessionId => _$this._sessionId;
  set sessionId(String? sessionId) => _$this._sessionId = sessionId;

  num? _sessionRelativeTimeMs;
  num? get sessionRelativeTimeMs => _$this._sessionRelativeTimeMs;
  set sessionRelativeTimeMs(num? sessionRelativeTimeMs) =>
      _$this._sessionRelativeTimeMs = sessionRelativeTimeMs;

  SdkEventDtoBuilder() {
    SdkEventDto._defaults(this);
  }

  SdkEventDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _appToken = $v.appToken;
      _clientOccurredAt = $v.clientOccurredAt;
      _deviceId = $v.deviceId;
      _deviceIdSource = $v.deviceIdSource;
      _eventData = $v.eventData?.toBuilder();
      _eventName = $v.eventName;
      _sessionId = $v.sessionId;
      _sessionRelativeTimeMs = $v.sessionRelativeTimeMs;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SdkEventDto other) {
    _$v = other as _$SdkEventDto;
  }

  @override
  void update(void Function(SdkEventDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SdkEventDto build() => _build();

  _$SdkEventDto _build() {
    _$SdkEventDto _$result;
    try {
      _$result =
          _$v ??
          _$SdkEventDto._(
            appToken: BuiltValueNullFieldError.checkNotNull(
              appToken,
              r'SdkEventDto',
              'appToken',
            ),
            clientOccurredAt: clientOccurredAt,
            deviceId: BuiltValueNullFieldError.checkNotNull(
              deviceId,
              r'SdkEventDto',
              'deviceId',
            ),
            deviceIdSource: deviceIdSource,
            eventData: _eventData?.build(),
            eventName: BuiltValueNullFieldError.checkNotNull(
              eventName,
              r'SdkEventDto',
              'eventName',
            ),
            sessionId: sessionId,
            sessionRelativeTimeMs: sessionRelativeTimeMs,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'eventData';
        _eventData?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'SdkEventDto',
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
