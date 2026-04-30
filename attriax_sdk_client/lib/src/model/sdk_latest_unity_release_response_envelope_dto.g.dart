// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_latest_unity_release_response_envelope_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SdkLatestUnityReleaseResponseEnvelopeDto
    extends SdkLatestUnityReleaseResponseEnvelopeDto {
  @override
  final SdkLatestUnityReleaseResponseDto data;
  @override
  final bool success;
  @override
  final DateTime timestamp;

  factory _$SdkLatestUnityReleaseResponseEnvelopeDto([
    void Function(SdkLatestUnityReleaseResponseEnvelopeDtoBuilder)? updates,
  ]) => (SdkLatestUnityReleaseResponseEnvelopeDtoBuilder()..update(updates))
      ._build();

  _$SdkLatestUnityReleaseResponseEnvelopeDto._({
    required this.data,
    required this.success,
    required this.timestamp,
  }) : super._();
  @override
  SdkLatestUnityReleaseResponseEnvelopeDto rebuild(
    void Function(SdkLatestUnityReleaseResponseEnvelopeDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SdkLatestUnityReleaseResponseEnvelopeDtoBuilder toBuilder() =>
      SdkLatestUnityReleaseResponseEnvelopeDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SdkLatestUnityReleaseResponseEnvelopeDto &&
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
            r'SdkLatestUnityReleaseResponseEnvelopeDto',
          )
          ..add('data', data)
          ..add('success', success)
          ..add('timestamp', timestamp))
        .toString();
  }
}

class SdkLatestUnityReleaseResponseEnvelopeDtoBuilder
    implements
        Builder<
          SdkLatestUnityReleaseResponseEnvelopeDto,
          SdkLatestUnityReleaseResponseEnvelopeDtoBuilder
        > {
  _$SdkLatestUnityReleaseResponseEnvelopeDto? _$v;

  SdkLatestUnityReleaseResponseDtoBuilder? _data;
  SdkLatestUnityReleaseResponseDtoBuilder get data =>
      _$this._data ??= SdkLatestUnityReleaseResponseDtoBuilder();
  set data(SdkLatestUnityReleaseResponseDtoBuilder? data) =>
      _$this._data = data;

  bool? _success;
  bool? get success => _$this._success;
  set success(bool? success) => _$this._success = success;

  DateTime? _timestamp;
  DateTime? get timestamp => _$this._timestamp;
  set timestamp(DateTime? timestamp) => _$this._timestamp = timestamp;

  SdkLatestUnityReleaseResponseEnvelopeDtoBuilder() {
    SdkLatestUnityReleaseResponseEnvelopeDto._defaults(this);
  }

  SdkLatestUnityReleaseResponseEnvelopeDtoBuilder get _$this {
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
  void replace(SdkLatestUnityReleaseResponseEnvelopeDto other) {
    _$v = other as _$SdkLatestUnityReleaseResponseEnvelopeDto;
  }

  @override
  void update(
    void Function(SdkLatestUnityReleaseResponseEnvelopeDtoBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  SdkLatestUnityReleaseResponseEnvelopeDto build() => _build();

  _$SdkLatestUnityReleaseResponseEnvelopeDto _build() {
    _$SdkLatestUnityReleaseResponseEnvelopeDto _$result;
    try {
      _$result =
          _$v ??
          _$SdkLatestUnityReleaseResponseEnvelopeDto._(
            data: data.build(),
            success: BuiltValueNullFieldError.checkNotNull(
              success,
              r'SdkLatestUnityReleaseResponseEnvelopeDto',
              'success',
            ),
            timestamp: BuiltValueNullFieldError.checkNotNull(
              timestamp,
              r'SdkLatestUnityReleaseResponseEnvelopeDto',
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
          r'SdkLatestUnityReleaseResponseEnvelopeDto',
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
