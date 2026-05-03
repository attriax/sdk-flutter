// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_v1_batch_response_envelope_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SdkV1BatchResponseEnvelopeDto extends SdkV1BatchResponseEnvelopeDto {
  @override
  final SdkV1BatchResponseDto data;
  @override
  final bool success;
  @override
  final DateTime timestamp;

  factory _$SdkV1BatchResponseEnvelopeDto([
    void Function(SdkV1BatchResponseEnvelopeDtoBuilder)? updates,
  ]) => (SdkV1BatchResponseEnvelopeDtoBuilder()..update(updates))._build();

  _$SdkV1BatchResponseEnvelopeDto._({
    required this.data,
    required this.success,
    required this.timestamp,
  }) : super._();
  @override
  SdkV1BatchResponseEnvelopeDto rebuild(
    void Function(SdkV1BatchResponseEnvelopeDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SdkV1BatchResponseEnvelopeDtoBuilder toBuilder() =>
      SdkV1BatchResponseEnvelopeDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SdkV1BatchResponseEnvelopeDto &&
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
    return (newBuiltValueToStringHelper(r'SdkV1BatchResponseEnvelopeDto')
          ..add('data', data)
          ..add('success', success)
          ..add('timestamp', timestamp))
        .toString();
  }
}

class SdkV1BatchResponseEnvelopeDtoBuilder
    implements
        Builder<
          SdkV1BatchResponseEnvelopeDto,
          SdkV1BatchResponseEnvelopeDtoBuilder
        > {
  _$SdkV1BatchResponseEnvelopeDto? _$v;

  SdkV1BatchResponseDtoBuilder? _data;
  SdkV1BatchResponseDtoBuilder get data =>
      _$this._data ??= SdkV1BatchResponseDtoBuilder();
  set data(SdkV1BatchResponseDtoBuilder? data) => _$this._data = data;

  bool? _success;
  bool? get success => _$this._success;
  set success(bool? success) => _$this._success = success;

  DateTime? _timestamp;
  DateTime? get timestamp => _$this._timestamp;
  set timestamp(DateTime? timestamp) => _$this._timestamp = timestamp;

  SdkV1BatchResponseEnvelopeDtoBuilder() {
    SdkV1BatchResponseEnvelopeDto._defaults(this);
  }

  SdkV1BatchResponseEnvelopeDtoBuilder get _$this {
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
  void replace(SdkV1BatchResponseEnvelopeDto other) {
    _$v = other as _$SdkV1BatchResponseEnvelopeDto;
  }

  @override
  void update(void Function(SdkV1BatchResponseEnvelopeDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SdkV1BatchResponseEnvelopeDto build() => _build();

  _$SdkV1BatchResponseEnvelopeDto _build() {
    _$SdkV1BatchResponseEnvelopeDto _$result;
    try {
      _$result =
          _$v ??
          _$SdkV1BatchResponseEnvelopeDto._(
            data: data.build(),
            success: BuiltValueNullFieldError.checkNotNull(
              success,
              r'SdkV1BatchResponseEnvelopeDto',
              'success',
            ),
            timestamp: BuiltValueNullFieldError.checkNotNull(
              timestamp,
              r'SdkV1BatchResponseEnvelopeDto',
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
          r'SdkV1BatchResponseEnvelopeDto',
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
