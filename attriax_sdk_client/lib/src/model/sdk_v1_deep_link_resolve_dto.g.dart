// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_v1_deep_link_resolve_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SdkV1DeepLinkResolveDto extends SdkV1DeepLinkResolveDto {
  @override
  final String appToken;
  @override
  final String deviceId;
  @override
  final String? deviceIdSource;
  @override
  final bool? isFirstLaunch;
  @override
  final String? linkPath;
  @override
  final BuiltMap<String, JsonObject?>? metadata;
  @override
  final Platform platform;
  @override
  final String? rawUrl;
  @override
  final String? source_;

  factory _$SdkV1DeepLinkResolveDto([
    void Function(SdkV1DeepLinkResolveDtoBuilder)? updates,
  ]) => (SdkV1DeepLinkResolveDtoBuilder()..update(updates))._build();

  _$SdkV1DeepLinkResolveDto._({
    required this.appToken,
    required this.deviceId,
    this.deviceIdSource,
    this.isFirstLaunch,
    this.linkPath,
    this.metadata,
    required this.platform,
    this.rawUrl,
    this.source_,
  }) : super._();
  @override
  SdkV1DeepLinkResolveDto rebuild(
    void Function(SdkV1DeepLinkResolveDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SdkV1DeepLinkResolveDtoBuilder toBuilder() =>
      SdkV1DeepLinkResolveDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SdkV1DeepLinkResolveDto &&
        appToken == other.appToken &&
        deviceId == other.deviceId &&
        deviceIdSource == other.deviceIdSource &&
        isFirstLaunch == other.isFirstLaunch &&
        linkPath == other.linkPath &&
        metadata == other.metadata &&
        platform == other.platform &&
        rawUrl == other.rawUrl &&
        source_ == other.source_;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, appToken.hashCode);
    _$hash = $jc(_$hash, deviceId.hashCode);
    _$hash = $jc(_$hash, deviceIdSource.hashCode);
    _$hash = $jc(_$hash, isFirstLaunch.hashCode);
    _$hash = $jc(_$hash, linkPath.hashCode);
    _$hash = $jc(_$hash, metadata.hashCode);
    _$hash = $jc(_$hash, platform.hashCode);
    _$hash = $jc(_$hash, rawUrl.hashCode);
    _$hash = $jc(_$hash, source_.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SdkV1DeepLinkResolveDto')
          ..add('appToken', appToken)
          ..add('deviceId', deviceId)
          ..add('deviceIdSource', deviceIdSource)
          ..add('isFirstLaunch', isFirstLaunch)
          ..add('linkPath', linkPath)
          ..add('metadata', metadata)
          ..add('platform', platform)
          ..add('rawUrl', rawUrl)
          ..add('source_', source_))
        .toString();
  }
}

class SdkV1DeepLinkResolveDtoBuilder
    implements
        Builder<SdkV1DeepLinkResolveDto, SdkV1DeepLinkResolveDtoBuilder> {
  _$SdkV1DeepLinkResolveDto? _$v;

  String? _appToken;
  String? get appToken => _$this._appToken;
  set appToken(String? appToken) => _$this._appToken = appToken;

  String? _deviceId;
  String? get deviceId => _$this._deviceId;
  set deviceId(String? deviceId) => _$this._deviceId = deviceId;

  String? _deviceIdSource;
  String? get deviceIdSource => _$this._deviceIdSource;
  set deviceIdSource(String? deviceIdSource) =>
      _$this._deviceIdSource = deviceIdSource;

  bool? _isFirstLaunch;
  bool? get isFirstLaunch => _$this._isFirstLaunch;
  set isFirstLaunch(bool? isFirstLaunch) =>
      _$this._isFirstLaunch = isFirstLaunch;

  String? _linkPath;
  String? get linkPath => _$this._linkPath;
  set linkPath(String? linkPath) => _$this._linkPath = linkPath;

  MapBuilder<String, JsonObject?>? _metadata;
  MapBuilder<String, JsonObject?> get metadata =>
      _$this._metadata ??= MapBuilder<String, JsonObject?>();
  set metadata(MapBuilder<String, JsonObject?>? metadata) =>
      _$this._metadata = metadata;

  Platform? _platform;
  Platform? get platform => _$this._platform;
  set platform(Platform? platform) => _$this._platform = platform;

  String? _rawUrl;
  String? get rawUrl => _$this._rawUrl;
  set rawUrl(String? rawUrl) => _$this._rawUrl = rawUrl;

  String? _source_;
  String? get source_ => _$this._source_;
  set source_(String? source_) => _$this._source_ = source_;

  SdkV1DeepLinkResolveDtoBuilder() {
    SdkV1DeepLinkResolveDto._defaults(this);
  }

  SdkV1DeepLinkResolveDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _appToken = $v.appToken;
      _deviceId = $v.deviceId;
      _deviceIdSource = $v.deviceIdSource;
      _isFirstLaunch = $v.isFirstLaunch;
      _linkPath = $v.linkPath;
      _metadata = $v.metadata?.toBuilder();
      _platform = $v.platform;
      _rawUrl = $v.rawUrl;
      _source_ = $v.source_;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SdkV1DeepLinkResolveDto other) {
    _$v = other as _$SdkV1DeepLinkResolveDto;
  }

  @override
  void update(void Function(SdkV1DeepLinkResolveDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SdkV1DeepLinkResolveDto build() => _build();

  _$SdkV1DeepLinkResolveDto _build() {
    _$SdkV1DeepLinkResolveDto _$result;
    try {
      _$result =
          _$v ??
          _$SdkV1DeepLinkResolveDto._(
            appToken: BuiltValueNullFieldError.checkNotNull(
              appToken,
              r'SdkV1DeepLinkResolveDto',
              'appToken',
            ),
            deviceId: BuiltValueNullFieldError.checkNotNull(
              deviceId,
              r'SdkV1DeepLinkResolveDto',
              'deviceId',
            ),
            deviceIdSource: deviceIdSource,
            isFirstLaunch: isFirstLaunch,
            linkPath: linkPath,
            metadata: _metadata?.build(),
            platform: BuiltValueNullFieldError.checkNotNull(
              platform,
              r'SdkV1DeepLinkResolveDto',
              'platform',
            ),
            rawUrl: rawUrl,
            source_: source_,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'metadata';
        _metadata?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'SdkV1DeepLinkResolveDto',
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
