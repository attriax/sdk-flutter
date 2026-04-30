// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_unity_release_list_response_envelope_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SdkUnityReleaseListResponseEnvelopeDto
    extends SdkUnityReleaseListResponseEnvelopeDto {
  @override
  final SdkUnityReleaseListResponseDto data;
  @override
  final bool success;
  @override
  final DateTime timestamp;

  factory _$SdkUnityReleaseListResponseEnvelopeDto([
    void Function(SdkUnityReleaseListResponseEnvelopeDtoBuilder)? updates,
  ]) => (SdkUnityReleaseListResponseEnvelopeDtoBuilder()..update(updates))
      ._build();

  _$SdkUnityReleaseListResponseEnvelopeDto._({
    required this.data,
    required this.success,
    required this.timestamp,
  }) : super._();
  @override
  SdkUnityReleaseListResponseEnvelopeDto rebuild(
    void Function(SdkUnityReleaseListResponseEnvelopeDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SdkUnityReleaseListResponseEnvelopeDtoBuilder toBuilder() =>
      SdkUnityReleaseListResponseEnvelopeDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SdkUnityReleaseListResponseEnvelopeDto &&
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
            r'SdkUnityReleaseListResponseEnvelopeDto',
          )
          ..add('data', data)
          ..add('success', success)
          ..add('timestamp', timestamp))
        .toString();
  }
}

class SdkUnityReleaseListResponseEnvelopeDtoBuilder
    implements
        Builder<
          SdkUnityReleaseListResponseEnvelopeDto,
          SdkUnityReleaseListResponseEnvelopeDtoBuilder
        > {
  _$SdkUnityReleaseListResponseEnvelopeDto? _$v;

  SdkUnityReleaseListResponseDtoBuilder? _data;
  SdkUnityReleaseListResponseDtoBuilder get data =>
      _$this._data ??= SdkUnityReleaseListResponseDtoBuilder();
  set data(SdkUnityReleaseListResponseDtoBuilder? data) => _$this._data = data;

  bool? _success;
  bool? get success => _$this._success;
  set success(bool? success) => _$this._success = success;

  DateTime? _timestamp;
  DateTime? get timestamp => _$this._timestamp;
  set timestamp(DateTime? timestamp) => _$this._timestamp = timestamp;

  SdkUnityReleaseListResponseEnvelopeDtoBuilder() {
    SdkUnityReleaseListResponseEnvelopeDto._defaults(this);
  }

  SdkUnityReleaseListResponseEnvelopeDtoBuilder get _$this {
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
  void replace(SdkUnityReleaseListResponseEnvelopeDto other) {
    _$v = other as _$SdkUnityReleaseListResponseEnvelopeDto;
  }

  @override
  void update(
    void Function(SdkUnityReleaseListResponseEnvelopeDtoBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  SdkUnityReleaseListResponseEnvelopeDto build() => _build();

  _$SdkUnityReleaseListResponseEnvelopeDto _build() {
    _$SdkUnityReleaseListResponseEnvelopeDto _$result;
    try {
      _$result =
          _$v ??
          _$SdkUnityReleaseListResponseEnvelopeDto._(
            data: data.build(),
            success: BuiltValueNullFieldError.checkNotNull(
              success,
              r'SdkUnityReleaseListResponseEnvelopeDto',
              'success',
            ),
            timestamp: BuiltValueNullFieldError.checkNotNull(
              timestamp,
              r'SdkUnityReleaseListResponseEnvelopeDto',
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
          r'SdkUnityReleaseListResponseEnvelopeDto',
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
