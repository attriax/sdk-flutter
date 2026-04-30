// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_version_context_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SdkVersionContextDto extends SdkVersionContextDto {
  @override
  final String apiVersion;
  @override
  final BuiltMap<String, JsonObject?>? metadata;
  @override
  final String packageVersion;

  factory _$SdkVersionContextDto([
    void Function(SdkVersionContextDtoBuilder)? updates,
  ]) => (SdkVersionContextDtoBuilder()..update(updates))._build();

  _$SdkVersionContextDto._({
    required this.apiVersion,
    this.metadata,
    required this.packageVersion,
  }) : super._();
  @override
  SdkVersionContextDto rebuild(
    void Function(SdkVersionContextDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SdkVersionContextDtoBuilder toBuilder() =>
      SdkVersionContextDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SdkVersionContextDto &&
        apiVersion == other.apiVersion &&
        metadata == other.metadata &&
        packageVersion == other.packageVersion;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, apiVersion.hashCode);
    _$hash = $jc(_$hash, metadata.hashCode);
    _$hash = $jc(_$hash, packageVersion.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SdkVersionContextDto')
          ..add('apiVersion', apiVersion)
          ..add('metadata', metadata)
          ..add('packageVersion', packageVersion))
        .toString();
  }
}

class SdkVersionContextDtoBuilder
    implements Builder<SdkVersionContextDto, SdkVersionContextDtoBuilder> {
  _$SdkVersionContextDto? _$v;

  String? _apiVersion;
  String? get apiVersion => _$this._apiVersion;
  set apiVersion(String? apiVersion) => _$this._apiVersion = apiVersion;

  MapBuilder<String, JsonObject?>? _metadata;
  MapBuilder<String, JsonObject?> get metadata =>
      _$this._metadata ??= MapBuilder<String, JsonObject?>();
  set metadata(MapBuilder<String, JsonObject?>? metadata) =>
      _$this._metadata = metadata;

  String? _packageVersion;
  String? get packageVersion => _$this._packageVersion;
  set packageVersion(String? packageVersion) =>
      _$this._packageVersion = packageVersion;

  SdkVersionContextDtoBuilder() {
    SdkVersionContextDto._defaults(this);
  }

  SdkVersionContextDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _apiVersion = $v.apiVersion;
      _metadata = $v.metadata?.toBuilder();
      _packageVersion = $v.packageVersion;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SdkVersionContextDto other) {
    _$v = other as _$SdkVersionContextDto;
  }

  @override
  void update(void Function(SdkVersionContextDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SdkVersionContextDto build() => _build();

  _$SdkVersionContextDto _build() {
    _$SdkVersionContextDto _$result;
    try {
      _$result =
          _$v ??
          _$SdkVersionContextDto._(
            apiVersion: BuiltValueNullFieldError.checkNotNull(
              apiVersion,
              r'SdkVersionContextDto',
              'apiVersion',
            ),
            metadata: _metadata?.build(),
            packageVersion: BuiltValueNullFieldError.checkNotNull(
              packageVersion,
              r'SdkVersionContextDto',
              'packageVersion',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'metadata';
        _metadata?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'SdkVersionContextDto',
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
