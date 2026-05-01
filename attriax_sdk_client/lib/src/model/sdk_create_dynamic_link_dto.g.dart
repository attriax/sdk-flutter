// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_create_dynamic_link_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SdkCreateDynamicLinkDto extends SdkCreateDynamicLinkDto {
  @override
  final bool? androidRedirect;
  @override
  final String appToken;
  @override
  final BuiltMap<String, JsonObject?>? data;
  @override
  final String? destinationUrl;
  @override
  final String? group;
  @override
  final bool? iosRedirect;
  @override
  final String? name;
  @override
  final String? prefix;
  @override
  final String? previewDescription;
  @override
  final String? previewImagePath;
  @override
  final String? previewTitle;
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

  factory _$SdkCreateDynamicLinkDto([
    void Function(SdkCreateDynamicLinkDtoBuilder)? updates,
  ]) => (SdkCreateDynamicLinkDtoBuilder()..update(updates))._build();

  _$SdkCreateDynamicLinkDto._({
    this.androidRedirect,
    required this.appToken,
    this.data,
    this.destinationUrl,
    this.group,
    this.iosRedirect,
    this.name,
    this.prefix,
    this.previewDescription,
    this.previewImagePath,
    this.previewTitle,
    this.utmCampaign,
    this.utmContent,
    this.utmMedium,
    this.utmSource,
    this.utmTerm,
  }) : super._();
  @override
  SdkCreateDynamicLinkDto rebuild(
    void Function(SdkCreateDynamicLinkDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SdkCreateDynamicLinkDtoBuilder toBuilder() =>
      SdkCreateDynamicLinkDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SdkCreateDynamicLinkDto &&
        androidRedirect == other.androidRedirect &&
        appToken == other.appToken &&
        data == other.data &&
        destinationUrl == other.destinationUrl &&
        group == other.group &&
        iosRedirect == other.iosRedirect &&
        name == other.name &&
        prefix == other.prefix &&
        previewDescription == other.previewDescription &&
        previewImagePath == other.previewImagePath &&
        previewTitle == other.previewTitle &&
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
    _$hash = $jc(_$hash, appToken.hashCode);
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jc(_$hash, destinationUrl.hashCode);
    _$hash = $jc(_$hash, group.hashCode);
    _$hash = $jc(_$hash, iosRedirect.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, prefix.hashCode);
    _$hash = $jc(_$hash, previewDescription.hashCode);
    _$hash = $jc(_$hash, previewImagePath.hashCode);
    _$hash = $jc(_$hash, previewTitle.hashCode);
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
    return (newBuiltValueToStringHelper(r'SdkCreateDynamicLinkDto')
          ..add('androidRedirect', androidRedirect)
          ..add('appToken', appToken)
          ..add('data', data)
          ..add('destinationUrl', destinationUrl)
          ..add('group', group)
          ..add('iosRedirect', iosRedirect)
          ..add('name', name)
          ..add('prefix', prefix)
          ..add('previewDescription', previewDescription)
          ..add('previewImagePath', previewImagePath)
          ..add('previewTitle', previewTitle)
          ..add('utmCampaign', utmCampaign)
          ..add('utmContent', utmContent)
          ..add('utmMedium', utmMedium)
          ..add('utmSource', utmSource)
          ..add('utmTerm', utmTerm))
        .toString();
  }
}

class SdkCreateDynamicLinkDtoBuilder
    implements
        Builder<SdkCreateDynamicLinkDto, SdkCreateDynamicLinkDtoBuilder> {
  _$SdkCreateDynamicLinkDto? _$v;

  bool? _androidRedirect;
  bool? get androidRedirect => _$this._androidRedirect;
  set androidRedirect(bool? androidRedirect) =>
      _$this._androidRedirect = androidRedirect;

  String? _appToken;
  String? get appToken => _$this._appToken;
  set appToken(String? appToken) => _$this._appToken = appToken;

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

  bool? _iosRedirect;
  bool? get iosRedirect => _$this._iosRedirect;
  set iosRedirect(bool? iosRedirect) => _$this._iosRedirect = iosRedirect;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

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

  SdkCreateDynamicLinkDtoBuilder() {
    SdkCreateDynamicLinkDto._defaults(this);
  }

  SdkCreateDynamicLinkDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _androidRedirect = $v.androidRedirect;
      _appToken = $v.appToken;
      _data = $v.data?.toBuilder();
      _destinationUrl = $v.destinationUrl;
      _group = $v.group;
      _iosRedirect = $v.iosRedirect;
      _name = $v.name;
      _prefix = $v.prefix;
      _previewDescription = $v.previewDescription;
      _previewImagePath = $v.previewImagePath;
      _previewTitle = $v.previewTitle;
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
  void replace(SdkCreateDynamicLinkDto other) {
    _$v = other as _$SdkCreateDynamicLinkDto;
  }

  @override
  void update(void Function(SdkCreateDynamicLinkDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SdkCreateDynamicLinkDto build() => _build();

  _$SdkCreateDynamicLinkDto _build() {
    _$SdkCreateDynamicLinkDto _$result;
    try {
      _$result =
          _$v ??
          _$SdkCreateDynamicLinkDto._(
            androidRedirect: androidRedirect,
            appToken: BuiltValueNullFieldError.checkNotNull(
              appToken,
              r'SdkCreateDynamicLinkDto',
              'appToken',
            ),
            data: _data?.build(),
            destinationUrl: destinationUrl,
            group: group,
            iosRedirect: iosRedirect,
            name: name,
            prefix: prefix,
            previewDescription: previewDescription,
            previewImagePath: previewImagePath,
            previewTitle: previewTitle,
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
          r'SdkCreateDynamicLinkDto',
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
