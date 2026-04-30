// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_version_context_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AppVersionContextDto extends AppVersionContextDto {
  @override
  final String? buildNumber;
  @override
  final String? packageName;
  @override
  final String? version;

  factory _$AppVersionContextDto([
    void Function(AppVersionContextDtoBuilder)? updates,
  ]) => (AppVersionContextDtoBuilder()..update(updates))._build();

  _$AppVersionContextDto._({this.buildNumber, this.packageName, this.version})
    : super._();
  @override
  AppVersionContextDto rebuild(
    void Function(AppVersionContextDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AppVersionContextDtoBuilder toBuilder() =>
      AppVersionContextDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AppVersionContextDto &&
        buildNumber == other.buildNumber &&
        packageName == other.packageName &&
        version == other.version;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, buildNumber.hashCode);
    _$hash = $jc(_$hash, packageName.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AppVersionContextDto')
          ..add('buildNumber', buildNumber)
          ..add('packageName', packageName)
          ..add('version', version))
        .toString();
  }
}

class AppVersionContextDtoBuilder
    implements Builder<AppVersionContextDto, AppVersionContextDtoBuilder> {
  _$AppVersionContextDto? _$v;

  String? _buildNumber;
  String? get buildNumber => _$this._buildNumber;
  set buildNumber(String? buildNumber) => _$this._buildNumber = buildNumber;

  String? _packageName;
  String? get packageName => _$this._packageName;
  set packageName(String? packageName) => _$this._packageName = packageName;

  String? _version;
  String? get version => _$this._version;
  set version(String? version) => _$this._version = version;

  AppVersionContextDtoBuilder() {
    AppVersionContextDto._defaults(this);
  }

  AppVersionContextDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _buildNumber = $v.buildNumber;
      _packageName = $v.packageName;
      _version = $v.version;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AppVersionContextDto other) {
    _$v = other as _$AppVersionContextDto;
  }

  @override
  void update(void Function(AppVersionContextDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AppVersionContextDto build() => _build();

  _$AppVersionContextDto _build() {
    final _$result =
        _$v ??
        _$AppVersionContextDto._(
          buildNumber: buildNumber,
          packageName: packageName,
          version: version,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
