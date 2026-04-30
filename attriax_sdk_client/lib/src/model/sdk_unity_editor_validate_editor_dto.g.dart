// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_unity_editor_validate_editor_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SdkUnityEditorValidateEditorDto
    extends SdkUnityEditorValidateEditorDto {
  @override
  final String? hostPlatform;
  @override
  final String? packageVersion;
  @override
  final String? unityVersion;

  factory _$SdkUnityEditorValidateEditorDto([
    void Function(SdkUnityEditorValidateEditorDtoBuilder)? updates,
  ]) => (SdkUnityEditorValidateEditorDtoBuilder()..update(updates))._build();

  _$SdkUnityEditorValidateEditorDto._({
    this.hostPlatform,
    this.packageVersion,
    this.unityVersion,
  }) : super._();
  @override
  SdkUnityEditorValidateEditorDto rebuild(
    void Function(SdkUnityEditorValidateEditorDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SdkUnityEditorValidateEditorDtoBuilder toBuilder() =>
      SdkUnityEditorValidateEditorDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SdkUnityEditorValidateEditorDto &&
        hostPlatform == other.hostPlatform &&
        packageVersion == other.packageVersion &&
        unityVersion == other.unityVersion;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, hostPlatform.hashCode);
    _$hash = $jc(_$hash, packageVersion.hashCode);
    _$hash = $jc(_$hash, unityVersion.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SdkUnityEditorValidateEditorDto')
          ..add('hostPlatform', hostPlatform)
          ..add('packageVersion', packageVersion)
          ..add('unityVersion', unityVersion))
        .toString();
  }
}

class SdkUnityEditorValidateEditorDtoBuilder
    implements
        Builder<
          SdkUnityEditorValidateEditorDto,
          SdkUnityEditorValidateEditorDtoBuilder
        > {
  _$SdkUnityEditorValidateEditorDto? _$v;

  String? _hostPlatform;
  String? get hostPlatform => _$this._hostPlatform;
  set hostPlatform(String? hostPlatform) => _$this._hostPlatform = hostPlatform;

  String? _packageVersion;
  String? get packageVersion => _$this._packageVersion;
  set packageVersion(String? packageVersion) =>
      _$this._packageVersion = packageVersion;

  String? _unityVersion;
  String? get unityVersion => _$this._unityVersion;
  set unityVersion(String? unityVersion) => _$this._unityVersion = unityVersion;

  SdkUnityEditorValidateEditorDtoBuilder() {
    SdkUnityEditorValidateEditorDto._defaults(this);
  }

  SdkUnityEditorValidateEditorDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _hostPlatform = $v.hostPlatform;
      _packageVersion = $v.packageVersion;
      _unityVersion = $v.unityVersion;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SdkUnityEditorValidateEditorDto other) {
    _$v = other as _$SdkUnityEditorValidateEditorDto;
  }

  @override
  void update(void Function(SdkUnityEditorValidateEditorDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SdkUnityEditorValidateEditorDto build() => _build();

  _$SdkUnityEditorValidateEditorDto _build() {
    final _$result =
        _$v ??
        _$SdkUnityEditorValidateEditorDto._(
          hostPlatform: hostPlatform,
          packageVersion: packageVersion,
          unityVersion: unityVersion,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
