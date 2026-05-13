// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_install_referrer_result_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SdkInstallReferrerResultDto extends SdkInstallReferrerResultDto {
  @override
  final String? adClickId;
  @override
  final String? adNetwork;
  @override
  final AttributionType attributionType;
  @override
  final String? campaign;
  @override
  final String? content;
  @override
  final BuiltMap<String, String>? deepLinkData;
  @override
  final String? deepLinkUri;
  @override
  final String? deepLinkUrl;
  @override
  final bool? googlePlayInstantParam;
  @override
  final num? installBeginTimestampSeconds;
  @override
  final String? medium;
  @override
  final num precision;
  @override
  final String? rawPlatformInstallReferrer;
  @override
  final num? referrerClickTimestampSeconds;
  @override
  final DateTime? registeredAt;
  @override
  final String? source_;
  @override
  final String? term;

  factory _$SdkInstallReferrerResultDto([
    void Function(SdkInstallReferrerResultDtoBuilder)? updates,
  ]) => (SdkInstallReferrerResultDtoBuilder()..update(updates))._build();

  _$SdkInstallReferrerResultDto._({
    this.adClickId,
    this.adNetwork,
    required this.attributionType,
    this.campaign,
    this.content,
    this.deepLinkData,
    this.deepLinkUri,
    this.deepLinkUrl,
    this.googlePlayInstantParam,
    this.installBeginTimestampSeconds,
    this.medium,
    required this.precision,
    this.rawPlatformInstallReferrer,
    this.referrerClickTimestampSeconds,
    this.registeredAt,
    this.source_,
    this.term,
  }) : super._();
  @override
  SdkInstallReferrerResultDto rebuild(
    void Function(SdkInstallReferrerResultDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SdkInstallReferrerResultDtoBuilder toBuilder() =>
      SdkInstallReferrerResultDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SdkInstallReferrerResultDto &&
        adClickId == other.adClickId &&
        adNetwork == other.adNetwork &&
        attributionType == other.attributionType &&
        campaign == other.campaign &&
        content == other.content &&
        deepLinkData == other.deepLinkData &&
        deepLinkUri == other.deepLinkUri &&
        deepLinkUrl == other.deepLinkUrl &&
        googlePlayInstantParam == other.googlePlayInstantParam &&
        installBeginTimestampSeconds == other.installBeginTimestampSeconds &&
        medium == other.medium &&
        precision == other.precision &&
        rawPlatformInstallReferrer == other.rawPlatformInstallReferrer &&
        referrerClickTimestampSeconds == other.referrerClickTimestampSeconds &&
        registeredAt == other.registeredAt &&
        source_ == other.source_ &&
        term == other.term;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, adClickId.hashCode);
    _$hash = $jc(_$hash, adNetwork.hashCode);
    _$hash = $jc(_$hash, attributionType.hashCode);
    _$hash = $jc(_$hash, campaign.hashCode);
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, deepLinkData.hashCode);
    _$hash = $jc(_$hash, deepLinkUri.hashCode);
    _$hash = $jc(_$hash, deepLinkUrl.hashCode);
    _$hash = $jc(_$hash, googlePlayInstantParam.hashCode);
    _$hash = $jc(_$hash, installBeginTimestampSeconds.hashCode);
    _$hash = $jc(_$hash, medium.hashCode);
    _$hash = $jc(_$hash, precision.hashCode);
    _$hash = $jc(_$hash, rawPlatformInstallReferrer.hashCode);
    _$hash = $jc(_$hash, referrerClickTimestampSeconds.hashCode);
    _$hash = $jc(_$hash, registeredAt.hashCode);
    _$hash = $jc(_$hash, source_.hashCode);
    _$hash = $jc(_$hash, term.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SdkInstallReferrerResultDto')
          ..add('adClickId', adClickId)
          ..add('adNetwork', adNetwork)
          ..add('attributionType', attributionType)
          ..add('campaign', campaign)
          ..add('content', content)
          ..add('deepLinkData', deepLinkData)
          ..add('deepLinkUri', deepLinkUri)
          ..add('deepLinkUrl', deepLinkUrl)
          ..add('googlePlayInstantParam', googlePlayInstantParam)
          ..add('installBeginTimestampSeconds', installBeginTimestampSeconds)
          ..add('medium', medium)
          ..add('precision', precision)
          ..add('rawPlatformInstallReferrer', rawPlatformInstallReferrer)
          ..add('referrerClickTimestampSeconds', referrerClickTimestampSeconds)
          ..add('registeredAt', registeredAt)
          ..add('source_', source_)
          ..add('term', term))
        .toString();
  }
}

class SdkInstallReferrerResultDtoBuilder
    implements
        Builder<
          SdkInstallReferrerResultDto,
          SdkInstallReferrerResultDtoBuilder
        > {
  _$SdkInstallReferrerResultDto? _$v;

  String? _adClickId;
  String? get adClickId => _$this._adClickId;
  set adClickId(String? adClickId) => _$this._adClickId = adClickId;

  String? _adNetwork;
  String? get adNetwork => _$this._adNetwork;
  set adNetwork(String? adNetwork) => _$this._adNetwork = adNetwork;

  AttributionType? _attributionType;
  AttributionType? get attributionType => _$this._attributionType;
  set attributionType(AttributionType? attributionType) =>
      _$this._attributionType = attributionType;

  String? _campaign;
  String? get campaign => _$this._campaign;
  set campaign(String? campaign) => _$this._campaign = campaign;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  MapBuilder<String, String>? _deepLinkData;
  MapBuilder<String, String> get deepLinkData =>
      _$this._deepLinkData ??= MapBuilder<String, String>();
  set deepLinkData(MapBuilder<String, String>? deepLinkData) =>
      _$this._deepLinkData = deepLinkData;

  String? _deepLinkUri;
  String? get deepLinkUri => _$this._deepLinkUri;
  set deepLinkUri(String? deepLinkUri) => _$this._deepLinkUri = deepLinkUri;

  String? _deepLinkUrl;
  String? get deepLinkUrl => _$this._deepLinkUrl;
  set deepLinkUrl(String? deepLinkUrl) => _$this._deepLinkUrl = deepLinkUrl;

  bool? _googlePlayInstantParam;
  bool? get googlePlayInstantParam => _$this._googlePlayInstantParam;
  set googlePlayInstantParam(bool? googlePlayInstantParam) =>
      _$this._googlePlayInstantParam = googlePlayInstantParam;

  num? _installBeginTimestampSeconds;
  num? get installBeginTimestampSeconds => _$this._installBeginTimestampSeconds;
  set installBeginTimestampSeconds(num? installBeginTimestampSeconds) =>
      _$this._installBeginTimestampSeconds = installBeginTimestampSeconds;

  String? _medium;
  String? get medium => _$this._medium;
  set medium(String? medium) => _$this._medium = medium;

  num? _precision;
  num? get precision => _$this._precision;
  set precision(num? precision) => _$this._precision = precision;

  String? _rawPlatformInstallReferrer;
  String? get rawPlatformInstallReferrer => _$this._rawPlatformInstallReferrer;
  set rawPlatformInstallReferrer(String? rawPlatformInstallReferrer) =>
      _$this._rawPlatformInstallReferrer = rawPlatformInstallReferrer;

  num? _referrerClickTimestampSeconds;
  num? get referrerClickTimestampSeconds =>
      _$this._referrerClickTimestampSeconds;
  set referrerClickTimestampSeconds(num? referrerClickTimestampSeconds) =>
      _$this._referrerClickTimestampSeconds = referrerClickTimestampSeconds;

  DateTime? _registeredAt;
  DateTime? get registeredAt => _$this._registeredAt;
  set registeredAt(DateTime? registeredAt) =>
      _$this._registeredAt = registeredAt;

  String? _source_;
  String? get source_ => _$this._source_;
  set source_(String? source_) => _$this._source_ = source_;

  String? _term;
  String? get term => _$this._term;
  set term(String? term) => _$this._term = term;

  SdkInstallReferrerResultDtoBuilder() {
    SdkInstallReferrerResultDto._defaults(this);
  }

  SdkInstallReferrerResultDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _adClickId = $v.adClickId;
      _adNetwork = $v.adNetwork;
      _attributionType = $v.attributionType;
      _campaign = $v.campaign;
      _content = $v.content;
      _deepLinkData = $v.deepLinkData?.toBuilder();
      _deepLinkUri = $v.deepLinkUri;
      _deepLinkUrl = $v.deepLinkUrl;
      _googlePlayInstantParam = $v.googlePlayInstantParam;
      _installBeginTimestampSeconds = $v.installBeginTimestampSeconds;
      _medium = $v.medium;
      _precision = $v.precision;
      _rawPlatformInstallReferrer = $v.rawPlatformInstallReferrer;
      _referrerClickTimestampSeconds = $v.referrerClickTimestampSeconds;
      _registeredAt = $v.registeredAt;
      _source_ = $v.source_;
      _term = $v.term;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SdkInstallReferrerResultDto other) {
    _$v = other as _$SdkInstallReferrerResultDto;
  }

  @override
  void update(void Function(SdkInstallReferrerResultDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SdkInstallReferrerResultDto build() => _build();

  _$SdkInstallReferrerResultDto _build() {
    _$SdkInstallReferrerResultDto _$result;
    try {
      _$result =
          _$v ??
          _$SdkInstallReferrerResultDto._(
            adClickId: adClickId,
            adNetwork: adNetwork,
            attributionType: BuiltValueNullFieldError.checkNotNull(
              attributionType,
              r'SdkInstallReferrerResultDto',
              'attributionType',
            ),
            campaign: campaign,
            content: content,
            deepLinkData: _deepLinkData?.build(),
            deepLinkUri: deepLinkUri,
            deepLinkUrl: deepLinkUrl,
            googlePlayInstantParam: googlePlayInstantParam,
            installBeginTimestampSeconds: installBeginTimestampSeconds,
            medium: medium,
            precision: BuiltValueNullFieldError.checkNotNull(
              precision,
              r'SdkInstallReferrerResultDto',
              'precision',
            ),
            rawPlatformInstallReferrer: rawPlatformInstallReferrer,
            referrerClickTimestampSeconds: referrerClickTimestampSeconds,
            registeredAt: registeredAt,
            source_: source_,
            term: term,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'deepLinkData';
        _deepLinkData?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'SdkInstallReferrerResultDto',
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
