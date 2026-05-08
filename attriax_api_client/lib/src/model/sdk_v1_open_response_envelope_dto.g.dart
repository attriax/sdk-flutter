// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_v1_open_response_envelope_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SdkV1OpenResponseEnvelopeDto extends SdkV1OpenResponseEnvelopeDto {
  @override
  final SdkV1OpenResponseDto data;
  @override
  final bool success;
  @override
  final DateTime timestamp;

  factory _$SdkV1OpenResponseEnvelopeDto([
    void Function(SdkV1OpenResponseEnvelopeDtoBuilder)? updates,
  ]) => (SdkV1OpenResponseEnvelopeDtoBuilder()..update(updates))._build();

  _$SdkV1OpenResponseEnvelopeDto._({
    required this.data,
    required this.success,
    required this.timestamp,
  }) : super._();
  @override
  SdkV1OpenResponseEnvelopeDto rebuild(
    void Function(SdkV1OpenResponseEnvelopeDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SdkV1OpenResponseEnvelopeDtoBuilder toBuilder() =>
      SdkV1OpenResponseEnvelopeDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SdkV1OpenResponseEnvelopeDto &&
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
    return (newBuiltValueToStringHelper(r'SdkV1OpenResponseEnvelopeDto')
          ..add('data', data)
          ..add('success', success)
          ..add('timestamp', timestamp))
        .toString();
  }
}

class SdkV1OpenResponseEnvelopeDtoBuilder
    implements
        Builder<
          SdkV1OpenResponseEnvelopeDto,
          SdkV1OpenResponseEnvelopeDtoBuilder
        > {
  _$SdkV1OpenResponseEnvelopeDto? _$v;

  SdkV1OpenResponseDtoBuilder? _data;
  SdkV1OpenResponseDtoBuilder get data =>
      _$this._data ??= SdkV1OpenResponseDtoBuilder();
  set data(SdkV1OpenResponseDtoBuilder? data) => _$this._data = data;

  bool? _success;
  bool? get success => _$this._success;
  set success(bool? success) => _$this._success = success;

  DateTime? _timestamp;
  DateTime? get timestamp => _$this._timestamp;
  set timestamp(DateTime? timestamp) => _$this._timestamp = timestamp;

  SdkV1OpenResponseEnvelopeDtoBuilder() {
    SdkV1OpenResponseEnvelopeDto._defaults(this);
  }

  SdkV1OpenResponseEnvelopeDtoBuilder get _$this {
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
  void replace(SdkV1OpenResponseEnvelopeDto other) {
    _$v = other as _$SdkV1OpenResponseEnvelopeDto;
  }

  @override
  void update(void Function(SdkV1OpenResponseEnvelopeDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SdkV1OpenResponseEnvelopeDto build() => _build();

  _$SdkV1OpenResponseEnvelopeDto _build() {
    _$SdkV1OpenResponseEnvelopeDto _$result;
    try {
      _$result =
          _$v ??
          _$SdkV1OpenResponseEnvelopeDto._(
            data: data.build(),
            success: BuiltValueNullFieldError.checkNotNull(
              success,
              r'SdkV1OpenResponseEnvelopeDto',
              'success',
            ),
            timestamp: BuiltValueNullFieldError.checkNotNull(
              timestamp,
              r'SdkV1OpenResponseEnvelopeDto',
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
          r'SdkV1OpenResponseEnvelopeDto',
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
