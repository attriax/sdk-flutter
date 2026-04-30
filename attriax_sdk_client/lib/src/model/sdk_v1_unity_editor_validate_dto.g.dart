// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_v1_unity_editor_validate_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SdkV1UnityEditorValidateDto extends SdkV1UnityEditorValidateDto {
  @override
  final String appToken;
  @override
  final String? editorHostPlatform;
  @override
  final String? packageVersion;
  @override
  final String? unityVersion;

  factory _$SdkV1UnityEditorValidateDto([
    void Function(SdkV1UnityEditorValidateDtoBuilder)? updates,
  ]) => (SdkV1UnityEditorValidateDtoBuilder()..update(updates))._build();

  _$SdkV1UnityEditorValidateDto._({
    required this.appToken,
    this.editorHostPlatform,
    this.packageVersion,
    this.unityVersion,
  }) : super._();
  @override
  SdkV1UnityEditorValidateDto rebuild(
    void Function(SdkV1UnityEditorValidateDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SdkV1UnityEditorValidateDtoBuilder toBuilder() =>
      SdkV1UnityEditorValidateDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SdkV1UnityEditorValidateDto &&
        appToken == other.appToken &&
        editorHostPlatform == other.editorHostPlatform &&
        packageVersion == other.packageVersion &&
        unityVersion == other.unityVersion;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, appToken.hashCode);
    _$hash = $jc(_$hash, editorHostPlatform.hashCode);
    _$hash = $jc(_$hash, packageVersion.hashCode);
    _$hash = $jc(_$hash, unityVersion.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SdkV1UnityEditorValidateDto')
          ..add('appToken', appToken)
          ..add('editorHostPlatform', editorHostPlatform)
          ..add('packageVersion', packageVersion)
          ..add('unityVersion', unityVersion))
        .toString();
  }
}

class SdkV1UnityEditorValidateDtoBuilder
    implements
        Builder<
          SdkV1UnityEditorValidateDto,
          SdkV1UnityEditorValidateDtoBuilder
        > {
  _$SdkV1UnityEditorValidateDto? _$v;

  String? _appToken;
  String? get appToken => _$this._appToken;
  set appToken(String? appToken) => _$this._appToken = appToken;

  String? _editorHostPlatform;
  String? get editorHostPlatform => _$this._editorHostPlatform;
  set editorHostPlatform(String? editorHostPlatform) =>
      _$this._editorHostPlatform = editorHostPlatform;

  String? _packageVersion;
  String? get packageVersion => _$this._packageVersion;
  set packageVersion(String? packageVersion) =>
      _$this._packageVersion = packageVersion;

  String? _unityVersion;
  String? get unityVersion => _$this._unityVersion;
  set unityVersion(String? unityVersion) => _$this._unityVersion = unityVersion;

  SdkV1UnityEditorValidateDtoBuilder() {
    SdkV1UnityEditorValidateDto._defaults(this);
  }

  SdkV1UnityEditorValidateDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _appToken = $v.appToken;
      _editorHostPlatform = $v.editorHostPlatform;
      _packageVersion = $v.packageVersion;
      _unityVersion = $v.unityVersion;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SdkV1UnityEditorValidateDto other) {
    _$v = other as _$SdkV1UnityEditorValidateDto;
  }

  @override
  void update(void Function(SdkV1UnityEditorValidateDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SdkV1UnityEditorValidateDto build() => _build();

  _$SdkV1UnityEditorValidateDto _build() {
    final _$result =
        _$v ??
        _$SdkV1UnityEditorValidateDto._(
          appToken: BuiltValueNullFieldError.checkNotNull(
            appToken,
            r'SdkV1UnityEditorValidateDto',
            'appToken',
          ),
          editorHostPlatform: editorHostPlatform,
          packageVersion: packageVersion,
          unityVersion: unityVersion,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
