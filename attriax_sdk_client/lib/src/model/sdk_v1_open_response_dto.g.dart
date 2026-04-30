// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_v1_open_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SdkV1OpenResponseDto extends SdkV1OpenResponseDto {
  @override
  final DateTime acceptedAt;
  @override
  final SdkJsonDeepLinkDto? deepLink;
  @override
  final SdkInstallReferrerResultDto? installReferrer;
  @override
  final bool isFirstLaunch;
  @override
  final bool isNewUser;
  @override
  final String requestVersion;
  @override
  final String userId;

  factory _$SdkV1OpenResponseDto([
    void Function(SdkV1OpenResponseDtoBuilder)? updates,
  ]) => (SdkV1OpenResponseDtoBuilder()..update(updates))._build();

  _$SdkV1OpenResponseDto._({
    required this.acceptedAt,
    this.deepLink,
    this.installReferrer,
    required this.isFirstLaunch,
    required this.isNewUser,
    required this.requestVersion,
    required this.userId,
  }) : super._();
  @override
  SdkV1OpenResponseDto rebuild(
    void Function(SdkV1OpenResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SdkV1OpenResponseDtoBuilder toBuilder() =>
      SdkV1OpenResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SdkV1OpenResponseDto &&
        acceptedAt == other.acceptedAt &&
        deepLink == other.deepLink &&
        installReferrer == other.installReferrer &&
        isFirstLaunch == other.isFirstLaunch &&
        isNewUser == other.isNewUser &&
        requestVersion == other.requestVersion &&
        userId == other.userId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, acceptedAt.hashCode);
    _$hash = $jc(_$hash, deepLink.hashCode);
    _$hash = $jc(_$hash, installReferrer.hashCode);
    _$hash = $jc(_$hash, isFirstLaunch.hashCode);
    _$hash = $jc(_$hash, isNewUser.hashCode);
    _$hash = $jc(_$hash, requestVersion.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SdkV1OpenResponseDto')
          ..add('acceptedAt', acceptedAt)
          ..add('deepLink', deepLink)
          ..add('installReferrer', installReferrer)
          ..add('isFirstLaunch', isFirstLaunch)
          ..add('isNewUser', isNewUser)
          ..add('requestVersion', requestVersion)
          ..add('userId', userId))
        .toString();
  }
}

class SdkV1OpenResponseDtoBuilder
    implements Builder<SdkV1OpenResponseDto, SdkV1OpenResponseDtoBuilder> {
  _$SdkV1OpenResponseDto? _$v;

  DateTime? _acceptedAt;
  DateTime? get acceptedAt => _$this._acceptedAt;
  set acceptedAt(DateTime? acceptedAt) => _$this._acceptedAt = acceptedAt;

  SdkJsonDeepLinkDtoBuilder? _deepLink;
  SdkJsonDeepLinkDtoBuilder get deepLink =>
      _$this._deepLink ??= SdkJsonDeepLinkDtoBuilder();
  set deepLink(SdkJsonDeepLinkDtoBuilder? deepLink) =>
      _$this._deepLink = deepLink;

  SdkInstallReferrerResultDtoBuilder? _installReferrer;
  SdkInstallReferrerResultDtoBuilder get installReferrer =>
      _$this._installReferrer ??= SdkInstallReferrerResultDtoBuilder();
  set installReferrer(SdkInstallReferrerResultDtoBuilder? installReferrer) =>
      _$this._installReferrer = installReferrer;

  bool? _isFirstLaunch;
  bool? get isFirstLaunch => _$this._isFirstLaunch;
  set isFirstLaunch(bool? isFirstLaunch) =>
      _$this._isFirstLaunch = isFirstLaunch;

  bool? _isNewUser;
  bool? get isNewUser => _$this._isNewUser;
  set isNewUser(bool? isNewUser) => _$this._isNewUser = isNewUser;

  String? _requestVersion;
  String? get requestVersion => _$this._requestVersion;
  set requestVersion(String? requestVersion) =>
      _$this._requestVersion = requestVersion;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  SdkV1OpenResponseDtoBuilder() {
    SdkV1OpenResponseDto._defaults(this);
  }

  SdkV1OpenResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _acceptedAt = $v.acceptedAt;
      _deepLink = $v.deepLink?.toBuilder();
      _installReferrer = $v.installReferrer?.toBuilder();
      _isFirstLaunch = $v.isFirstLaunch;
      _isNewUser = $v.isNewUser;
      _requestVersion = $v.requestVersion;
      _userId = $v.userId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SdkV1OpenResponseDto other) {
    _$v = other as _$SdkV1OpenResponseDto;
  }

  @override
  void update(void Function(SdkV1OpenResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SdkV1OpenResponseDto build() => _build();

  _$SdkV1OpenResponseDto _build() {
    _$SdkV1OpenResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$SdkV1OpenResponseDto._(
            acceptedAt: BuiltValueNullFieldError.checkNotNull(
              acceptedAt,
              r'SdkV1OpenResponseDto',
              'acceptedAt',
            ),
            deepLink: _deepLink?.build(),
            installReferrer: _installReferrer?.build(),
            isFirstLaunch: BuiltValueNullFieldError.checkNotNull(
              isFirstLaunch,
              r'SdkV1OpenResponseDto',
              'isFirstLaunch',
            ),
            isNewUser: BuiltValueNullFieldError.checkNotNull(
              isNewUser,
              r'SdkV1OpenResponseDto',
              'isNewUser',
            ),
            requestVersion: BuiltValueNullFieldError.checkNotNull(
              requestVersion,
              r'SdkV1OpenResponseDto',
              'requestVersion',
            ),
            userId: BuiltValueNullFieldError.checkNotNull(
              userId,
              r'SdkV1OpenResponseDto',
              'userId',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'deepLink';
        _deepLink?.build();
        _$failedField = 'installReferrer';
        _installReferrer?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'SdkV1OpenResponseDto',
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
