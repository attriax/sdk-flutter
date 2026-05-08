// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_create_dynamic_link_response_envelope_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SdkCreateDynamicLinkResponseEnvelopeDto
    extends SdkCreateDynamicLinkResponseEnvelopeDto {
  @override
  final SdkCreateDynamicLinkResponseDto data;
  @override
  final bool success;
  @override
  final DateTime timestamp;

  factory _$SdkCreateDynamicLinkResponseEnvelopeDto([
    void Function(SdkCreateDynamicLinkResponseEnvelopeDtoBuilder)? updates,
  ]) => (SdkCreateDynamicLinkResponseEnvelopeDtoBuilder()..update(updates))
      ._build();

  _$SdkCreateDynamicLinkResponseEnvelopeDto._({
    required this.data,
    required this.success,
    required this.timestamp,
  }) : super._();
  @override
  SdkCreateDynamicLinkResponseEnvelopeDto rebuild(
    void Function(SdkCreateDynamicLinkResponseEnvelopeDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SdkCreateDynamicLinkResponseEnvelopeDtoBuilder toBuilder() =>
      SdkCreateDynamicLinkResponseEnvelopeDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SdkCreateDynamicLinkResponseEnvelopeDto &&
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
    return (newBuiltValueToStringHelper(
            r'SdkCreateDynamicLinkResponseEnvelopeDto',
          )
          ..add('data', data)
          ..add('success', success)
          ..add('timestamp', timestamp))
        .toString();
  }
}

class SdkCreateDynamicLinkResponseEnvelopeDtoBuilder
    implements
        Builder<
          SdkCreateDynamicLinkResponseEnvelopeDto,
          SdkCreateDynamicLinkResponseEnvelopeDtoBuilder
        > {
  _$SdkCreateDynamicLinkResponseEnvelopeDto? _$v;

  SdkCreateDynamicLinkResponseDtoBuilder? _data;
  SdkCreateDynamicLinkResponseDtoBuilder get data =>
      _$this._data ??= SdkCreateDynamicLinkResponseDtoBuilder();
  set data(SdkCreateDynamicLinkResponseDtoBuilder? data) => _$this._data = data;

  bool? _success;
  bool? get success => _$this._success;
  set success(bool? success) => _$this._success = success;

  DateTime? _timestamp;
  DateTime? get timestamp => _$this._timestamp;
  set timestamp(DateTime? timestamp) => _$this._timestamp = timestamp;

  SdkCreateDynamicLinkResponseEnvelopeDtoBuilder() {
    SdkCreateDynamicLinkResponseEnvelopeDto._defaults(this);
  }

  SdkCreateDynamicLinkResponseEnvelopeDtoBuilder get _$this {
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
  void replace(SdkCreateDynamicLinkResponseEnvelopeDto other) {
    _$v = other as _$SdkCreateDynamicLinkResponseEnvelopeDto;
  }

  @override
  void update(
    void Function(SdkCreateDynamicLinkResponseEnvelopeDtoBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  SdkCreateDynamicLinkResponseEnvelopeDto build() => _build();

  _$SdkCreateDynamicLinkResponseEnvelopeDto _build() {
    _$SdkCreateDynamicLinkResponseEnvelopeDto _$result;
    try {
      _$result =
          _$v ??
          _$SdkCreateDynamicLinkResponseEnvelopeDto._(
            data: data.build(),
            success: BuiltValueNullFieldError.checkNotNull(
              success,
              r'SdkCreateDynamicLinkResponseEnvelopeDto',
              'success',
            ),
            timestamp: BuiltValueNullFieldError.checkNotNull(
              timestamp,
              r'SdkCreateDynamicLinkResponseEnvelopeDto',
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
          r'SdkCreateDynamicLinkResponseEnvelopeDto',
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
