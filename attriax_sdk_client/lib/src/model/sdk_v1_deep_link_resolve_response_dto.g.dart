// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_v1_deep_link_resolve_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SdkV1DeepLinkResolveResponseDto
    extends SdkV1DeepLinkResolveResponseDto {
  @override
  final DateTime acceptedAt;
  @override
  final DateTime? consumedAt;
  @override
  final SdkJsonDeepLinkDto? deepLink;
  @override
  final bool isFirstLaunch;
  @override
  final bool matched;
  @override
  final String? reason;
  @override
  final String requestVersion;
  @override
  final DeepLinkResolutionStatus status;

  factory _$SdkV1DeepLinkResolveResponseDto([
    void Function(SdkV1DeepLinkResolveResponseDtoBuilder)? updates,
  ]) => (SdkV1DeepLinkResolveResponseDtoBuilder()..update(updates))._build();

  _$SdkV1DeepLinkResolveResponseDto._({
    required this.acceptedAt,
    this.consumedAt,
    this.deepLink,
    required this.isFirstLaunch,
    required this.matched,
    this.reason,
    required this.requestVersion,
    required this.status,
  }) : super._();
  @override
  SdkV1DeepLinkResolveResponseDto rebuild(
    void Function(SdkV1DeepLinkResolveResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SdkV1DeepLinkResolveResponseDtoBuilder toBuilder() =>
      SdkV1DeepLinkResolveResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SdkV1DeepLinkResolveResponseDto &&
        acceptedAt == other.acceptedAt &&
        consumedAt == other.consumedAt &&
        deepLink == other.deepLink &&
        isFirstLaunch == other.isFirstLaunch &&
        matched == other.matched &&
        reason == other.reason &&
        requestVersion == other.requestVersion &&
        status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, acceptedAt.hashCode);
    _$hash = $jc(_$hash, consumedAt.hashCode);
    _$hash = $jc(_$hash, deepLink.hashCode);
    _$hash = $jc(_$hash, isFirstLaunch.hashCode);
    _$hash = $jc(_$hash, matched.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jc(_$hash, requestVersion.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SdkV1DeepLinkResolveResponseDto')
          ..add('acceptedAt', acceptedAt)
          ..add('consumedAt', consumedAt)
          ..add('deepLink', deepLink)
          ..add('isFirstLaunch', isFirstLaunch)
          ..add('matched', matched)
          ..add('reason', reason)
          ..add('requestVersion', requestVersion)
          ..add('status', status))
        .toString();
  }
}

class SdkV1DeepLinkResolveResponseDtoBuilder
    implements
        Builder<
          SdkV1DeepLinkResolveResponseDto,
          SdkV1DeepLinkResolveResponseDtoBuilder
        > {
  _$SdkV1DeepLinkResolveResponseDto? _$v;

  DateTime? _acceptedAt;
  DateTime? get acceptedAt => _$this._acceptedAt;
  set acceptedAt(DateTime? acceptedAt) => _$this._acceptedAt = acceptedAt;

  DateTime? _consumedAt;
  DateTime? get consumedAt => _$this._consumedAt;
  set consumedAt(DateTime? consumedAt) => _$this._consumedAt = consumedAt;

  SdkJsonDeepLinkDtoBuilder? _deepLink;
  SdkJsonDeepLinkDtoBuilder get deepLink =>
      _$this._deepLink ??= SdkJsonDeepLinkDtoBuilder();
  set deepLink(SdkJsonDeepLinkDtoBuilder? deepLink) =>
      _$this._deepLink = deepLink;

  bool? _isFirstLaunch;
  bool? get isFirstLaunch => _$this._isFirstLaunch;
  set isFirstLaunch(bool? isFirstLaunch) =>
      _$this._isFirstLaunch = isFirstLaunch;

  bool? _matched;
  bool? get matched => _$this._matched;
  set matched(bool? matched) => _$this._matched = matched;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  String? _requestVersion;
  String? get requestVersion => _$this._requestVersion;
  set requestVersion(String? requestVersion) =>
      _$this._requestVersion = requestVersion;

  DeepLinkResolutionStatus? _status;
  DeepLinkResolutionStatus? get status => _$this._status;
  set status(DeepLinkResolutionStatus? status) => _$this._status = status;

  SdkV1DeepLinkResolveResponseDtoBuilder() {
    SdkV1DeepLinkResolveResponseDto._defaults(this);
  }

  SdkV1DeepLinkResolveResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _acceptedAt = $v.acceptedAt;
      _consumedAt = $v.consumedAt;
      _deepLink = $v.deepLink?.toBuilder();
      _isFirstLaunch = $v.isFirstLaunch;
      _matched = $v.matched;
      _reason = $v.reason;
      _requestVersion = $v.requestVersion;
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SdkV1DeepLinkResolveResponseDto other) {
    _$v = other as _$SdkV1DeepLinkResolveResponseDto;
  }

  @override
  void update(void Function(SdkV1DeepLinkResolveResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SdkV1DeepLinkResolveResponseDto build() => _build();

  _$SdkV1DeepLinkResolveResponseDto _build() {
    _$SdkV1DeepLinkResolveResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$SdkV1DeepLinkResolveResponseDto._(
            acceptedAt: BuiltValueNullFieldError.checkNotNull(
              acceptedAt,
              r'SdkV1DeepLinkResolveResponseDto',
              'acceptedAt',
            ),
            consumedAt: consumedAt,
            deepLink: _deepLink?.build(),
            isFirstLaunch: BuiltValueNullFieldError.checkNotNull(
              isFirstLaunch,
              r'SdkV1DeepLinkResolveResponseDto',
              'isFirstLaunch',
            ),
            matched: BuiltValueNullFieldError.checkNotNull(
              matched,
              r'SdkV1DeepLinkResolveResponseDto',
              'matched',
            ),
            reason: reason,
            requestVersion: BuiltValueNullFieldError.checkNotNull(
              requestVersion,
              r'SdkV1DeepLinkResolveResponseDto',
              'requestVersion',
            ),
            status: BuiltValueNullFieldError.checkNotNull(
              status,
              r'SdkV1DeepLinkResolveResponseDto',
              'status',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'deepLink';
        _deepLink?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'SdkV1DeepLinkResolveResponseDto',
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
