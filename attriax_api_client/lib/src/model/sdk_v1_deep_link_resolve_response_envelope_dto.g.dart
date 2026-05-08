// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_v1_deep_link_resolve_response_envelope_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SdkV1DeepLinkResolveResponseEnvelopeDto
    extends SdkV1DeepLinkResolveResponseEnvelopeDto {
  @override
  final SdkV1DeepLinkResolveResponseDto data;
  @override
  final bool success;
  @override
  final DateTime timestamp;

  factory _$SdkV1DeepLinkResolveResponseEnvelopeDto([
    void Function(SdkV1DeepLinkResolveResponseEnvelopeDtoBuilder)? updates,
  ]) => (SdkV1DeepLinkResolveResponseEnvelopeDtoBuilder()..update(updates))
      ._build();

  _$SdkV1DeepLinkResolveResponseEnvelopeDto._({
    required this.data,
    required this.success,
    required this.timestamp,
  }) : super._();
  @override
  SdkV1DeepLinkResolveResponseEnvelopeDto rebuild(
    void Function(SdkV1DeepLinkResolveResponseEnvelopeDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SdkV1DeepLinkResolveResponseEnvelopeDtoBuilder toBuilder() =>
      SdkV1DeepLinkResolveResponseEnvelopeDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SdkV1DeepLinkResolveResponseEnvelopeDto &&
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
            r'SdkV1DeepLinkResolveResponseEnvelopeDto',
          )
          ..add('data', data)
          ..add('success', success)
          ..add('timestamp', timestamp))
        .toString();
  }
}

class SdkV1DeepLinkResolveResponseEnvelopeDtoBuilder
    implements
        Builder<
          SdkV1DeepLinkResolveResponseEnvelopeDto,
          SdkV1DeepLinkResolveResponseEnvelopeDtoBuilder
        > {
  _$SdkV1DeepLinkResolveResponseEnvelopeDto? _$v;

  SdkV1DeepLinkResolveResponseDtoBuilder? _data;
  SdkV1DeepLinkResolveResponseDtoBuilder get data =>
      _$this._data ??= SdkV1DeepLinkResolveResponseDtoBuilder();
  set data(SdkV1DeepLinkResolveResponseDtoBuilder? data) => _$this._data = data;

  bool? _success;
  bool? get success => _$this._success;
  set success(bool? success) => _$this._success = success;

  DateTime? _timestamp;
  DateTime? get timestamp => _$this._timestamp;
  set timestamp(DateTime? timestamp) => _$this._timestamp = timestamp;

  SdkV1DeepLinkResolveResponseEnvelopeDtoBuilder() {
    SdkV1DeepLinkResolveResponseEnvelopeDto._defaults(this);
  }

  SdkV1DeepLinkResolveResponseEnvelopeDtoBuilder get _$this {
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
  void replace(SdkV1DeepLinkResolveResponseEnvelopeDto other) {
    _$v = other as _$SdkV1DeepLinkResolveResponseEnvelopeDto;
  }

  @override
  void update(
    void Function(SdkV1DeepLinkResolveResponseEnvelopeDtoBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  SdkV1DeepLinkResolveResponseEnvelopeDto build() => _build();

  _$SdkV1DeepLinkResolveResponseEnvelopeDto _build() {
    _$SdkV1DeepLinkResolveResponseEnvelopeDto _$result;
    try {
      _$result =
          _$v ??
          _$SdkV1DeepLinkResolveResponseEnvelopeDto._(
            data: data.build(),
            success: BuiltValueNullFieldError.checkNotNull(
              success,
              r'SdkV1DeepLinkResolveResponseEnvelopeDto',
              'success',
            ),
            timestamp: BuiltValueNullFieldError.checkNotNull(
              timestamp,
              r'SdkV1DeepLinkResolveResponseEnvelopeDto',
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
          r'SdkV1DeepLinkResolveResponseEnvelopeDto',
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
