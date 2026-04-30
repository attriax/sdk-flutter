// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_unity_editor_validate_app_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SdkUnityEditorValidateAppDto extends SdkUnityEditorValidateAppDto {
  @override
  final String? androidPackageName;
  @override
  final String id;
  @override
  final String? iosBundleId;
  @override
  final String name;
  @override
  final String publicHost;

  factory _$SdkUnityEditorValidateAppDto([
    void Function(SdkUnityEditorValidateAppDtoBuilder)? updates,
  ]) => (SdkUnityEditorValidateAppDtoBuilder()..update(updates))._build();

  _$SdkUnityEditorValidateAppDto._({
    this.androidPackageName,
    required this.id,
    this.iosBundleId,
    required this.name,
    required this.publicHost,
  }) : super._();
  @override
  SdkUnityEditorValidateAppDto rebuild(
    void Function(SdkUnityEditorValidateAppDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SdkUnityEditorValidateAppDtoBuilder toBuilder() =>
      SdkUnityEditorValidateAppDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SdkUnityEditorValidateAppDto &&
        androidPackageName == other.androidPackageName &&
        id == other.id &&
        iosBundleId == other.iosBundleId &&
        name == other.name &&
        publicHost == other.publicHost;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, androidPackageName.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, iosBundleId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, publicHost.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SdkUnityEditorValidateAppDto')
          ..add('androidPackageName', androidPackageName)
          ..add('id', id)
          ..add('iosBundleId', iosBundleId)
          ..add('name', name)
          ..add('publicHost', publicHost))
        .toString();
  }
}

class SdkUnityEditorValidateAppDtoBuilder
    implements
        Builder<
          SdkUnityEditorValidateAppDto,
          SdkUnityEditorValidateAppDtoBuilder
        > {
  _$SdkUnityEditorValidateAppDto? _$v;

  String? _androidPackageName;
  String? get androidPackageName => _$this._androidPackageName;
  set androidPackageName(String? androidPackageName) =>
      _$this._androidPackageName = androidPackageName;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _iosBundleId;
  String? get iosBundleId => _$this._iosBundleId;
  set iosBundleId(String? iosBundleId) => _$this._iosBundleId = iosBundleId;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _publicHost;
  String? get publicHost => _$this._publicHost;
  set publicHost(String? publicHost) => _$this._publicHost = publicHost;

  SdkUnityEditorValidateAppDtoBuilder() {
    SdkUnityEditorValidateAppDto._defaults(this);
  }

  SdkUnityEditorValidateAppDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _androidPackageName = $v.androidPackageName;
      _id = $v.id;
      _iosBundleId = $v.iosBundleId;
      _name = $v.name;
      _publicHost = $v.publicHost;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SdkUnityEditorValidateAppDto other) {
    _$v = other as _$SdkUnityEditorValidateAppDto;
  }

  @override
  void update(void Function(SdkUnityEditorValidateAppDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SdkUnityEditorValidateAppDto build() => _build();

  _$SdkUnityEditorValidateAppDto _build() {
    final _$result =
        _$v ??
        _$SdkUnityEditorValidateAppDto._(
          androidPackageName: androidPackageName,
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'SdkUnityEditorValidateAppDto',
            'id',
          ),
          iosBundleId: iosBundleId,
          name: BuiltValueNullFieldError.checkNotNull(
            name,
            r'SdkUnityEditorValidateAppDto',
            'name',
          ),
          publicHost: BuiltValueNullFieldError.checkNotNull(
            publicHost,
            r'SdkUnityEditorValidateAppDto',
            'publicHost',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
