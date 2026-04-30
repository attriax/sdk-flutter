// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_latest_unity_release_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SdkLatestUnityReleaseResponseDto
    extends SdkLatestUnityReleaseResponseDto {
  @override
  final UnityReleaseSummaryDto? release;

  factory _$SdkLatestUnityReleaseResponseDto([
    void Function(SdkLatestUnityReleaseResponseDtoBuilder)? updates,
  ]) => (SdkLatestUnityReleaseResponseDtoBuilder()..update(updates))._build();

  _$SdkLatestUnityReleaseResponseDto._({this.release}) : super._();
  @override
  SdkLatestUnityReleaseResponseDto rebuild(
    void Function(SdkLatestUnityReleaseResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SdkLatestUnityReleaseResponseDtoBuilder toBuilder() =>
      SdkLatestUnityReleaseResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SdkLatestUnityReleaseResponseDto &&
        release == other.release;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, release.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'SdkLatestUnityReleaseResponseDto',
    )..add('release', release)).toString();
  }
}

class SdkLatestUnityReleaseResponseDtoBuilder
    implements
        Builder<
          SdkLatestUnityReleaseResponseDto,
          SdkLatestUnityReleaseResponseDtoBuilder
        > {
  _$SdkLatestUnityReleaseResponseDto? _$v;

  UnityReleaseSummaryDtoBuilder? _release;
  UnityReleaseSummaryDtoBuilder get release =>
      _$this._release ??= UnityReleaseSummaryDtoBuilder();
  set release(UnityReleaseSummaryDtoBuilder? release) =>
      _$this._release = release;

  SdkLatestUnityReleaseResponseDtoBuilder() {
    SdkLatestUnityReleaseResponseDto._defaults(this);
  }

  SdkLatestUnityReleaseResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _release = $v.release?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SdkLatestUnityReleaseResponseDto other) {
    _$v = other as _$SdkLatestUnityReleaseResponseDto;
  }

  @override
  void update(void Function(SdkLatestUnityReleaseResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SdkLatestUnityReleaseResponseDto build() => _build();

  _$SdkLatestUnityReleaseResponseDto _build() {
    _$SdkLatestUnityReleaseResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$SdkLatestUnityReleaseResponseDto._(release: _release?.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'release';
        _release?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'SdkLatestUnityReleaseResponseDto',
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
