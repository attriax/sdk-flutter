// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_unity_release_list_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SdkUnityReleaseListResponseDto extends SdkUnityReleaseListResponseDto {
  @override
  final BuiltList<UnityReleaseSummaryDto> releases;

  factory _$SdkUnityReleaseListResponseDto([
    void Function(SdkUnityReleaseListResponseDtoBuilder)? updates,
  ]) => (SdkUnityReleaseListResponseDtoBuilder()..update(updates))._build();

  _$SdkUnityReleaseListResponseDto._({required this.releases}) : super._();
  @override
  SdkUnityReleaseListResponseDto rebuild(
    void Function(SdkUnityReleaseListResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SdkUnityReleaseListResponseDtoBuilder toBuilder() =>
      SdkUnityReleaseListResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SdkUnityReleaseListResponseDto &&
        releases == other.releases;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, releases.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'SdkUnityReleaseListResponseDto',
    )..add('releases', releases)).toString();
  }
}

class SdkUnityReleaseListResponseDtoBuilder
    implements
        Builder<
          SdkUnityReleaseListResponseDto,
          SdkUnityReleaseListResponseDtoBuilder
        > {
  _$SdkUnityReleaseListResponseDto? _$v;

  ListBuilder<UnityReleaseSummaryDto>? _releases;
  ListBuilder<UnityReleaseSummaryDto> get releases =>
      _$this._releases ??= ListBuilder<UnityReleaseSummaryDto>();
  set releases(ListBuilder<UnityReleaseSummaryDto>? releases) =>
      _$this._releases = releases;

  SdkUnityReleaseListResponseDtoBuilder() {
    SdkUnityReleaseListResponseDto._defaults(this);
  }

  SdkUnityReleaseListResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _releases = $v.releases.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SdkUnityReleaseListResponseDto other) {
    _$v = other as _$SdkUnityReleaseListResponseDto;
  }

  @override
  void update(void Function(SdkUnityReleaseListResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SdkUnityReleaseListResponseDto build() => _build();

  _$SdkUnityReleaseListResponseDto _build() {
    _$SdkUnityReleaseListResponseDto _$result;
    try {
      _$result =
          _$v ?? _$SdkUnityReleaseListResponseDto._(releases: releases.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'releases';
        releases.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'SdkUnityReleaseListResponseDto',
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
