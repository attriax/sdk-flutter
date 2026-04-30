// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_unity_editor_validate_checks_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SdkUnityEditorValidateChecksDto
    extends SdkUnityEditorValidateChecksDto {
  @override
  final bool androidFingerprintsConfigured;
  @override
  final bool androidPackageConfigured;
  @override
  final bool appTokenValid;
  @override
  final bool iosBundleConfigured;
  @override
  final bool iosTeamConfigured;
  @override
  final bool publicHostResolved;

  factory _$SdkUnityEditorValidateChecksDto([
    void Function(SdkUnityEditorValidateChecksDtoBuilder)? updates,
  ]) => (SdkUnityEditorValidateChecksDtoBuilder()..update(updates))._build();

  _$SdkUnityEditorValidateChecksDto._({
    required this.androidFingerprintsConfigured,
    required this.androidPackageConfigured,
    required this.appTokenValid,
    required this.iosBundleConfigured,
    required this.iosTeamConfigured,
    required this.publicHostResolved,
  }) : super._();
  @override
  SdkUnityEditorValidateChecksDto rebuild(
    void Function(SdkUnityEditorValidateChecksDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SdkUnityEditorValidateChecksDtoBuilder toBuilder() =>
      SdkUnityEditorValidateChecksDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SdkUnityEditorValidateChecksDto &&
        androidFingerprintsConfigured == other.androidFingerprintsConfigured &&
        androidPackageConfigured == other.androidPackageConfigured &&
        appTokenValid == other.appTokenValid &&
        iosBundleConfigured == other.iosBundleConfigured &&
        iosTeamConfigured == other.iosTeamConfigured &&
        publicHostResolved == other.publicHostResolved;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, androidFingerprintsConfigured.hashCode);
    _$hash = $jc(_$hash, androidPackageConfigured.hashCode);
    _$hash = $jc(_$hash, appTokenValid.hashCode);
    _$hash = $jc(_$hash, iosBundleConfigured.hashCode);
    _$hash = $jc(_$hash, iosTeamConfigured.hashCode);
    _$hash = $jc(_$hash, publicHostResolved.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SdkUnityEditorValidateChecksDto')
          ..add('androidFingerprintsConfigured', androidFingerprintsConfigured)
          ..add('androidPackageConfigured', androidPackageConfigured)
          ..add('appTokenValid', appTokenValid)
          ..add('iosBundleConfigured', iosBundleConfigured)
          ..add('iosTeamConfigured', iosTeamConfigured)
          ..add('publicHostResolved', publicHostResolved))
        .toString();
  }
}

class SdkUnityEditorValidateChecksDtoBuilder
    implements
        Builder<
          SdkUnityEditorValidateChecksDto,
          SdkUnityEditorValidateChecksDtoBuilder
        > {
  _$SdkUnityEditorValidateChecksDto? _$v;

  bool? _androidFingerprintsConfigured;
  bool? get androidFingerprintsConfigured =>
      _$this._androidFingerprintsConfigured;
  set androidFingerprintsConfigured(bool? androidFingerprintsConfigured) =>
      _$this._androidFingerprintsConfigured = androidFingerprintsConfigured;

  bool? _androidPackageConfigured;
  bool? get androidPackageConfigured => _$this._androidPackageConfigured;
  set androidPackageConfigured(bool? androidPackageConfigured) =>
      _$this._androidPackageConfigured = androidPackageConfigured;

  bool? _appTokenValid;
  bool? get appTokenValid => _$this._appTokenValid;
  set appTokenValid(bool? appTokenValid) =>
      _$this._appTokenValid = appTokenValid;

  bool? _iosBundleConfigured;
  bool? get iosBundleConfigured => _$this._iosBundleConfigured;
  set iosBundleConfigured(bool? iosBundleConfigured) =>
      _$this._iosBundleConfigured = iosBundleConfigured;

  bool? _iosTeamConfigured;
  bool? get iosTeamConfigured => _$this._iosTeamConfigured;
  set iosTeamConfigured(bool? iosTeamConfigured) =>
      _$this._iosTeamConfigured = iosTeamConfigured;

  bool? _publicHostResolved;
  bool? get publicHostResolved => _$this._publicHostResolved;
  set publicHostResolved(bool? publicHostResolved) =>
      _$this._publicHostResolved = publicHostResolved;

  SdkUnityEditorValidateChecksDtoBuilder() {
    SdkUnityEditorValidateChecksDto._defaults(this);
  }

  SdkUnityEditorValidateChecksDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _androidFingerprintsConfigured = $v.androidFingerprintsConfigured;
      _androidPackageConfigured = $v.androidPackageConfigured;
      _appTokenValid = $v.appTokenValid;
      _iosBundleConfigured = $v.iosBundleConfigured;
      _iosTeamConfigured = $v.iosTeamConfigured;
      _publicHostResolved = $v.publicHostResolved;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SdkUnityEditorValidateChecksDto other) {
    _$v = other as _$SdkUnityEditorValidateChecksDto;
  }

  @override
  void update(void Function(SdkUnityEditorValidateChecksDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SdkUnityEditorValidateChecksDto build() => _build();

  _$SdkUnityEditorValidateChecksDto _build() {
    final _$result =
        _$v ??
        _$SdkUnityEditorValidateChecksDto._(
          androidFingerprintsConfigured: BuiltValueNullFieldError.checkNotNull(
            androidFingerprintsConfigured,
            r'SdkUnityEditorValidateChecksDto',
            'androidFingerprintsConfigured',
          ),
          androidPackageConfigured: BuiltValueNullFieldError.checkNotNull(
            androidPackageConfigured,
            r'SdkUnityEditorValidateChecksDto',
            'androidPackageConfigured',
          ),
          appTokenValid: BuiltValueNullFieldError.checkNotNull(
            appTokenValid,
            r'SdkUnityEditorValidateChecksDto',
            'appTokenValid',
          ),
          iosBundleConfigured: BuiltValueNullFieldError.checkNotNull(
            iosBundleConfigured,
            r'SdkUnityEditorValidateChecksDto',
            'iosBundleConfigured',
          ),
          iosTeamConfigured: BuiltValueNullFieldError.checkNotNull(
            iosTeamConfigured,
            r'SdkUnityEditorValidateChecksDto',
            'iosTeamConfigured',
          ),
          publicHostResolved: BuiltValueNullFieldError.checkNotNull(
            publicHostResolved,
            r'SdkUnityEditorValidateChecksDto',
            'publicHostResolved',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
