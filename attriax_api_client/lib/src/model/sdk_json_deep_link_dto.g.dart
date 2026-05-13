// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_json_deep_link_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SdkJsonDeepLinkDto extends SdkJsonDeepLinkDto {
  @override
  final BuiltMap<String, String>? data;
  @override
  final String path;
  @override
  final String? uri;
  @override
  final SdkUtmPayloadDto? utm;

  factory _$SdkJsonDeepLinkDto([
    void Function(SdkJsonDeepLinkDtoBuilder)? updates,
  ]) => (SdkJsonDeepLinkDtoBuilder()..update(updates))._build();

  _$SdkJsonDeepLinkDto._({this.data, required this.path, this.uri, this.utm})
    : super._();
  @override
  SdkJsonDeepLinkDto rebuild(
    void Function(SdkJsonDeepLinkDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SdkJsonDeepLinkDtoBuilder toBuilder() =>
      SdkJsonDeepLinkDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SdkJsonDeepLinkDto &&
        data == other.data &&
        path == other.path &&
        uri == other.uri &&
        utm == other.utm;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jc(_$hash, path.hashCode);
    _$hash = $jc(_$hash, uri.hashCode);
    _$hash = $jc(_$hash, utm.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SdkJsonDeepLinkDto')
          ..add('data', data)
          ..add('path', path)
          ..add('uri', uri)
          ..add('utm', utm))
        .toString();
  }
}

class SdkJsonDeepLinkDtoBuilder
    implements Builder<SdkJsonDeepLinkDto, SdkJsonDeepLinkDtoBuilder> {
  _$SdkJsonDeepLinkDto? _$v;

  MapBuilder<String, String>? _data;
  MapBuilder<String, String> get data =>
      _$this._data ??= MapBuilder<String, String>();
  set data(MapBuilder<String, String>? data) => _$this._data = data;

  String? _path;
  String? get path => _$this._path;
  set path(String? path) => _$this._path = path;

  String? _uri;
  String? get uri => _$this._uri;
  set uri(String? uri) => _$this._uri = uri;

  SdkUtmPayloadDtoBuilder? _utm;
  SdkUtmPayloadDtoBuilder get utm => _$this._utm ??= SdkUtmPayloadDtoBuilder();
  set utm(SdkUtmPayloadDtoBuilder? utm) => _$this._utm = utm;

  SdkJsonDeepLinkDtoBuilder() {
    SdkJsonDeepLinkDto._defaults(this);
  }

  SdkJsonDeepLinkDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data?.toBuilder();
      _path = $v.path;
      _uri = $v.uri;
      _utm = $v.utm?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SdkJsonDeepLinkDto other) {
    _$v = other as _$SdkJsonDeepLinkDto;
  }

  @override
  void update(void Function(SdkJsonDeepLinkDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SdkJsonDeepLinkDto build() => _build();

  _$SdkJsonDeepLinkDto _build() {
    _$SdkJsonDeepLinkDto _$result;
    try {
      _$result =
          _$v ??
          _$SdkJsonDeepLinkDto._(
            data: _data?.build(),
            path: BuiltValueNullFieldError.checkNotNull(
              path,
              r'SdkJsonDeepLinkDto',
              'path',
            ),
            uri: uri,
            utm: _utm?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        _data?.build();

        _$failedField = 'utm';
        _utm?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'SdkJsonDeepLinkDto',
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
