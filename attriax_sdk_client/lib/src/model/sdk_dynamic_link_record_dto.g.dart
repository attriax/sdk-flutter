// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_dynamic_link_record_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SdkDynamicLinkRecordDto extends SdkDynamicLinkRecordDto {
  @override
  final bool? androidRedirect;
  @override
  final DateTime createdAt;
  @override
  final BuiltMap<String, JsonObject?>? data;
  @override
  final String? destinationUrl;
  @override
  final String? group;
  @override
  final String id;
  @override
  final bool? iosRedirect;
  @override
  final String? name;
  @override
  final String path;
  @override
  final String? prefix;
  @override
  final String? previewDescription;
  @override
  final String? previewImagePath;
  @override
  final String? previewTitle;
  @override
  final String shortUrl;
  @override
  final String? utmCampaign;
  @override
  final String? utmContent;
  @override
  final String? utmMedium;
  @override
  final String? utmSource;
  @override
  final String? utmTerm;

  factory _$SdkDynamicLinkRecordDto([
    void Function(SdkDynamicLinkRecordDtoBuilder)? updates,
  ]) => (SdkDynamicLinkRecordDtoBuilder()..update(updates))._build();

  _$SdkDynamicLinkRecordDto._({
    this.androidRedirect,
    required this.createdAt,
    this.data,
    this.destinationUrl,
    this.group,
    required this.id,
    this.iosRedirect,
    this.name,
    required this.path,
    this.prefix,
    this.previewDescription,
    this.previewImagePath,
    this.previewTitle,
    required this.shortUrl,
    this.utmCampaign,
    this.utmContent,
    this.utmMedium,
    this.utmSource,
    this.utmTerm,
  }) : super._();
  @override
  SdkDynamicLinkRecordDto rebuild(
    void Function(SdkDynamicLinkRecordDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SdkDynamicLinkRecordDtoBuilder toBuilder() =>
      SdkDynamicLinkRecordDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SdkDynamicLinkRecordDto &&
        androidRedirect == other.androidRedirect &&
        createdAt == other.createdAt &&
        data == other.data &&
        destinationUrl == other.destinationUrl &&
        group == other.group &&
        id == other.id &&
        iosRedirect == other.iosRedirect &&
        name == other.name &&
        path == other.path &&
        prefix == other.prefix &&
        previewDescription == other.previewDescription &&
        previewImagePath == other.previewImagePath &&
        previewTitle == other.previewTitle &&
        shortUrl == other.shortUrl &&
        utmCampaign == other.utmCampaign &&
        utmContent == other.utmContent &&
        utmMedium == other.utmMedium &&
        utmSource == other.utmSource &&
        utmTerm == other.utmTerm;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, androidRedirect.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jc(_$hash, destinationUrl.hashCode);
    _$hash = $jc(_$hash, group.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, iosRedirect.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, path.hashCode);
    _$hash = $jc(_$hash, prefix.hashCode);
    _$hash = $jc(_$hash, previewDescription.hashCode);
    _$hash = $jc(_$hash, previewImagePath.hashCode);
    _$hash = $jc(_$hash, previewTitle.hashCode);
    _$hash = $jc(_$hash, shortUrl.hashCode);
    _$hash = $jc(_$hash, utmCampaign.hashCode);
    _$hash = $jc(_$hash, utmContent.hashCode);
    _$hash = $jc(_$hash, utmMedium.hashCode);
    _$hash = $jc(_$hash, utmSource.hashCode);
    _$hash = $jc(_$hash, utmTerm.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SdkDynamicLinkRecordDto')
          ..add('androidRedirect', androidRedirect)
          ..add('createdAt', createdAt)
          ..add('data', data)
          ..add('destinationUrl', destinationUrl)
          ..add('group', group)
          ..add('id', id)
          ..add('iosRedirect', iosRedirect)
          ..add('name', name)
          ..add('path', path)
          ..add('prefix', prefix)
          ..add('previewDescription', previewDescription)
          ..add('previewImagePath', previewImagePath)
          ..add('previewTitle', previewTitle)
          ..add('shortUrl', shortUrl)
          ..add('utmCampaign', utmCampaign)
          ..add('utmContent', utmContent)
          ..add('utmMedium', utmMedium)
          ..add('utmSource', utmSource)
          ..add('utmTerm', utmTerm))
        .toString();
  }
}

class SdkDynamicLinkRecordDtoBuilder
    implements
        Builder<SdkDynamicLinkRecordDto, SdkDynamicLinkRecordDtoBuilder> {
  _$SdkDynamicLinkRecordDto? _$v;

  bool? _androidRedirect;
  bool? get androidRedirect => _$this._androidRedirect;
  set androidRedirect(bool? androidRedirect) =>
      _$this._androidRedirect = androidRedirect;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  MapBuilder<String, JsonObject?>? _data;
  MapBuilder<String, JsonObject?> get data =>
      _$this._data ??= MapBuilder<String, JsonObject?>();
  set data(MapBuilder<String, JsonObject?>? data) => _$this._data = data;

  String? _destinationUrl;
  String? get destinationUrl => _$this._destinationUrl;
  set destinationUrl(String? destinationUrl) =>
      _$this._destinationUrl = destinationUrl;

  String? _group;
  String? get group => _$this._group;
  set group(String? group) => _$this._group = group;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  bool? _iosRedirect;
  bool? get iosRedirect => _$this._iosRedirect;
  set iosRedirect(bool? iosRedirect) => _$this._iosRedirect = iosRedirect;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _path;
  String? get path => _$this._path;
  set path(String? path) => _$this._path = path;

  String? _prefix;
  String? get prefix => _$this._prefix;
  set prefix(String? prefix) => _$this._prefix = prefix;

  String? _previewDescription;
  String? get previewDescription => _$this._previewDescription;
  set previewDescription(String? previewDescription) =>
      _$this._previewDescription = previewDescription;

  String? _previewImagePath;
  String? get previewImagePath => _$this._previewImagePath;
  set previewImagePath(String? previewImagePath) =>
      _$this._previewImagePath = previewImagePath;

  String? _previewTitle;
  String? get previewTitle => _$this._previewTitle;
  set previewTitle(String? previewTitle) => _$this._previewTitle = previewTitle;

  String? _shortUrl;
  String? get shortUrl => _$this._shortUrl;
  set shortUrl(String? shortUrl) => _$this._shortUrl = shortUrl;

  String? _utmCampaign;
  String? get utmCampaign => _$this._utmCampaign;
  set utmCampaign(String? utmCampaign) => _$this._utmCampaign = utmCampaign;

  String? _utmContent;
  String? get utmContent => _$this._utmContent;
  set utmContent(String? utmContent) => _$this._utmContent = utmContent;

  String? _utmMedium;
  String? get utmMedium => _$this._utmMedium;
  set utmMedium(String? utmMedium) => _$this._utmMedium = utmMedium;

  String? _utmSource;
  String? get utmSource => _$this._utmSource;
  set utmSource(String? utmSource) => _$this._utmSource = utmSource;

  String? _utmTerm;
  String? get utmTerm => _$this._utmTerm;
  set utmTerm(String? utmTerm) => _$this._utmTerm = utmTerm;

  SdkDynamicLinkRecordDtoBuilder() {
    SdkDynamicLinkRecordDto._defaults(this);
  }

  SdkDynamicLinkRecordDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _androidRedirect = $v.androidRedirect;
      _createdAt = $v.createdAt;
      _data = $v.data?.toBuilder();
      _destinationUrl = $v.destinationUrl;
      _group = $v.group;
      _id = $v.id;
      _iosRedirect = $v.iosRedirect;
      _name = $v.name;
      _path = $v.path;
      _prefix = $v.prefix;
      _previewDescription = $v.previewDescription;
      _previewImagePath = $v.previewImagePath;
      _previewTitle = $v.previewTitle;
      _shortUrl = $v.shortUrl;
      _utmCampaign = $v.utmCampaign;
      _utmContent = $v.utmContent;
      _utmMedium = $v.utmMedium;
      _utmSource = $v.utmSource;
      _utmTerm = $v.utmTerm;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SdkDynamicLinkRecordDto other) {
    _$v = other as _$SdkDynamicLinkRecordDto;
  }

  @override
  void update(void Function(SdkDynamicLinkRecordDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SdkDynamicLinkRecordDto build() => _build();

  _$SdkDynamicLinkRecordDto _build() {
    _$SdkDynamicLinkRecordDto _$result;
    try {
      _$result =
          _$v ??
          _$SdkDynamicLinkRecordDto._(
            androidRedirect: androidRedirect,
            createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt,
              r'SdkDynamicLinkRecordDto',
              'createdAt',
            ),
            data: _data?.build(),
            destinationUrl: destinationUrl,
            group: group,
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'SdkDynamicLinkRecordDto',
              'id',
            ),
            iosRedirect: iosRedirect,
            name: name,
            path: BuiltValueNullFieldError.checkNotNull(
              path,
              r'SdkDynamicLinkRecordDto',
              'path',
            ),
            prefix: prefix,
            previewDescription: previewDescription,
            previewImagePath: previewImagePath,
            previewTitle: previewTitle,
            shortUrl: BuiltValueNullFieldError.checkNotNull(
              shortUrl,
              r'SdkDynamicLinkRecordDto',
              'shortUrl',
            ),
            utmCampaign: utmCampaign,
            utmContent: utmContent,
            utmMedium: utmMedium,
            utmSource: utmSource,
            utmTerm: utmTerm,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        _data?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'SdkDynamicLinkRecordDto',
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
