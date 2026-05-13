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
  final DateTime? deepLinkClickedAt;
  @override
  final DateTime? deepLinkConsumedAt;
  @override
  final SdkInstallReferrerResultDto? installReferrer;
  @override
  final SdkInstallState installState;
  @override
  final bool isFirstLaunch;
  @override
  final bool isNewUser;
  @override
  final SdkInstallReferrerResultDto? originalInstallReferrer;
  @override
  final SdkInstallReferrerResultDto? reinstallReferrer;
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
    this.deepLinkClickedAt,
    this.deepLinkConsumedAt,
    this.installReferrer,
    required this.installState,
    required this.isFirstLaunch,
    required this.isNewUser,
    this.originalInstallReferrer,
    this.reinstallReferrer,
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
        deepLinkClickedAt == other.deepLinkClickedAt &&
        deepLinkConsumedAt == other.deepLinkConsumedAt &&
        installReferrer == other.installReferrer &&
        installState == other.installState &&
        isFirstLaunch == other.isFirstLaunch &&
        isNewUser == other.isNewUser &&
        originalInstallReferrer == other.originalInstallReferrer &&
        reinstallReferrer == other.reinstallReferrer &&
        requestVersion == other.requestVersion &&
        userId == other.userId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, acceptedAt.hashCode);
    _$hash = $jc(_$hash, deepLink.hashCode);
    _$hash = $jc(_$hash, deepLinkClickedAt.hashCode);
    _$hash = $jc(_$hash, deepLinkConsumedAt.hashCode);
    _$hash = $jc(_$hash, installReferrer.hashCode);
    _$hash = $jc(_$hash, installState.hashCode);
    _$hash = $jc(_$hash, isFirstLaunch.hashCode);
    _$hash = $jc(_$hash, isNewUser.hashCode);
    _$hash = $jc(_$hash, originalInstallReferrer.hashCode);
    _$hash = $jc(_$hash, reinstallReferrer.hashCode);
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
          ..add('deepLinkClickedAt', deepLinkClickedAt)
          ..add('deepLinkConsumedAt', deepLinkConsumedAt)
          ..add('installReferrer', installReferrer)
          ..add('installState', installState)
          ..add('isFirstLaunch', isFirstLaunch)
          ..add('isNewUser', isNewUser)
          ..add('originalInstallReferrer', originalInstallReferrer)
          ..add('reinstallReferrer', reinstallReferrer)
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

  DateTime? _deepLinkClickedAt;
  DateTime? get deepLinkClickedAt => _$this._deepLinkClickedAt;
  set deepLinkClickedAt(DateTime? deepLinkClickedAt) =>
      _$this._deepLinkClickedAt = deepLinkClickedAt;

  DateTime? _deepLinkConsumedAt;
  DateTime? get deepLinkConsumedAt => _$this._deepLinkConsumedAt;
  set deepLinkConsumedAt(DateTime? deepLinkConsumedAt) =>
      _$this._deepLinkConsumedAt = deepLinkConsumedAt;

  SdkInstallReferrerResultDtoBuilder? _installReferrer;
  SdkInstallReferrerResultDtoBuilder get installReferrer =>
      _$this._installReferrer ??= SdkInstallReferrerResultDtoBuilder();
  set installReferrer(SdkInstallReferrerResultDtoBuilder? installReferrer) =>
      _$this._installReferrer = installReferrer;

  SdkInstallState? _installState;
  SdkInstallState? get installState => _$this._installState;
  set installState(SdkInstallState? installState) =>
      _$this._installState = installState;

  bool? _isFirstLaunch;
  bool? get isFirstLaunch => _$this._isFirstLaunch;
  set isFirstLaunch(bool? isFirstLaunch) =>
      _$this._isFirstLaunch = isFirstLaunch;

  bool? _isNewUser;
  bool? get isNewUser => _$this._isNewUser;
  set isNewUser(bool? isNewUser) => _$this._isNewUser = isNewUser;

  SdkInstallReferrerResultDtoBuilder? _originalInstallReferrer;
  SdkInstallReferrerResultDtoBuilder get originalInstallReferrer =>
      _$this._originalInstallReferrer ??= SdkInstallReferrerResultDtoBuilder();
  set originalInstallReferrer(
    SdkInstallReferrerResultDtoBuilder? originalInstallReferrer,
  ) => _$this._originalInstallReferrer = originalInstallReferrer;

  SdkInstallReferrerResultDtoBuilder? _reinstallReferrer;
  SdkInstallReferrerResultDtoBuilder get reinstallReferrer =>
      _$this._reinstallReferrer ??= SdkInstallReferrerResultDtoBuilder();
  set reinstallReferrer(
    SdkInstallReferrerResultDtoBuilder? reinstallReferrer,
  ) => _$this._reinstallReferrer = reinstallReferrer;

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
      _deepLinkClickedAt = $v.deepLinkClickedAt;
      _deepLinkConsumedAt = $v.deepLinkConsumedAt;
      _installReferrer = $v.installReferrer?.toBuilder();
      _installState = $v.installState;
      _isFirstLaunch = $v.isFirstLaunch;
      _isNewUser = $v.isNewUser;
      _originalInstallReferrer = $v.originalInstallReferrer?.toBuilder();
      _reinstallReferrer = $v.reinstallReferrer?.toBuilder();
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
            deepLinkClickedAt: deepLinkClickedAt,
            deepLinkConsumedAt: deepLinkConsumedAt,
            installReferrer: _installReferrer?.build(),
            installState: BuiltValueNullFieldError.checkNotNull(
              installState,
              r'SdkV1OpenResponseDto',
              'installState',
            ),
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
            originalInstallReferrer: _originalInstallReferrer?.build(),
            reinstallReferrer: _reinstallReferrer?.build(),
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

        _$failedField = 'originalInstallReferrer';
        _originalInstallReferrer?.build();
        _$failedField = 'reinstallReferrer';
        _reinstallReferrer?.build();
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
