// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_acknowledge_response_envelope_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SdkAcknowledgeResponseEnvelopeDto
    extends SdkAcknowledgeResponseEnvelopeDto {
  @override
  final SdkAcknowledgeResponseDto data;
  @override
  final bool success;
  @override
  final DateTime timestamp;

  factory _$SdkAcknowledgeResponseEnvelopeDto([
    void Function(SdkAcknowledgeResponseEnvelopeDtoBuilder)? updates,
  ]) => (SdkAcknowledgeResponseEnvelopeDtoBuilder()..update(updates))._build();

  _$SdkAcknowledgeResponseEnvelopeDto._({
    required this.data,
    required this.success,
    required this.timestamp,
  }) : super._();
  @override
  SdkAcknowledgeResponseEnvelopeDto rebuild(
    void Function(SdkAcknowledgeResponseEnvelopeDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SdkAcknowledgeResponseEnvelopeDtoBuilder toBuilder() =>
      SdkAcknowledgeResponseEnvelopeDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SdkAcknowledgeResponseEnvelopeDto &&
        data == other.data &&
        success == other.success &&
        timestamp == other.timestamp;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jc(_$hash, success.hashCode);
    _$hash = $jc(_$hash, timestamp.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SdkAcknowledgeResponseEnvelopeDto')
          ..add('data', data)
          ..add('success', success)
          ..add('timestamp', timestamp))
        .toString();
  }
}

class SdkAcknowledgeResponseEnvelopeDtoBuilder
    implements
        Builder<
          SdkAcknowledgeResponseEnvelopeDto,
          SdkAcknowledgeResponseEnvelopeDtoBuilder
        > {
  _$SdkAcknowledgeResponseEnvelopeDto? _$v;

  SdkAcknowledgeResponseDtoBuilder? _data;
  SdkAcknowledgeResponseDtoBuilder get data =>
      _$this._data ??= SdkAcknowledgeResponseDtoBuilder();
  set data(SdkAcknowledgeResponseDtoBuilder? data) => _$this._data = data;

  bool? _success;
  bool? get success => _$this._success;
  set success(bool? success) => _$this._success = success;

  DateTime? _timestamp;
  DateTime? get timestamp => _$this._timestamp;
  set timestamp(DateTime? timestamp) => _$this._timestamp = timestamp;

  SdkAcknowledgeResponseEnvelopeDtoBuilder() {
    SdkAcknowledgeResponseEnvelopeDto._defaults(this);
  }

  SdkAcknowledgeResponseEnvelopeDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _success = $v.success;
      _timestamp = $v.timestamp;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SdkAcknowledgeResponseEnvelopeDto other) {
    _$v = other as _$SdkAcknowledgeResponseEnvelopeDto;
  }

  @override
  void update(
    void Function(SdkAcknowledgeResponseEnvelopeDtoBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  SdkAcknowledgeResponseEnvelopeDto build() => _build();

  _$SdkAcknowledgeResponseEnvelopeDto _build() {
    _$SdkAcknowledgeResponseEnvelopeDto _$result;
    try {
      _$result =
          _$v ??
          _$SdkAcknowledgeResponseEnvelopeDto._(
            data: data.build(),
            success: BuiltValueNullFieldError.checkNotNull(
              success,
              r'SdkAcknowledgeResponseEnvelopeDto',
              'success',
            ),
            timestamp: BuiltValueNullFieldError.checkNotNull(
              timestamp,
              r'SdkAcknowledgeResponseEnvelopeDto',
              'timestamp',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'SdkAcknowledgeResponseEnvelopeDto',
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
