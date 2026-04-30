// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_create_dynamic_link_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SdkCreateDynamicLinkResponseDto
    extends SdkCreateDynamicLinkResponseDto {
  @override
  final DateTime acceptedAt;
  @override
  final SdkDynamicLinkRecordDto link;
  @override
  final String requestVersion;

  factory _$SdkCreateDynamicLinkResponseDto([
    void Function(SdkCreateDynamicLinkResponseDtoBuilder)? updates,
  ]) => (SdkCreateDynamicLinkResponseDtoBuilder()..update(updates))._build();

  _$SdkCreateDynamicLinkResponseDto._({
    required this.acceptedAt,
    required this.link,
    required this.requestVersion,
  }) : super._();
  @override
  SdkCreateDynamicLinkResponseDto rebuild(
    void Function(SdkCreateDynamicLinkResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SdkCreateDynamicLinkResponseDtoBuilder toBuilder() =>
      SdkCreateDynamicLinkResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SdkCreateDynamicLinkResponseDto &&
        acceptedAt == other.acceptedAt &&
        link == other.link &&
        requestVersion == other.requestVersion;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, acceptedAt.hashCode);
    _$hash = $jc(_$hash, link.hashCode);
    _$hash = $jc(_$hash, requestVersion.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SdkCreateDynamicLinkResponseDto')
          ..add('acceptedAt', acceptedAt)
          ..add('link', link)
          ..add('requestVersion', requestVersion))
        .toString();
  }
}

class SdkCreateDynamicLinkResponseDtoBuilder
    implements
        Builder<
          SdkCreateDynamicLinkResponseDto,
          SdkCreateDynamicLinkResponseDtoBuilder
        > {
  _$SdkCreateDynamicLinkResponseDto? _$v;

  DateTime? _acceptedAt;
  DateTime? get acceptedAt => _$this._acceptedAt;
  set acceptedAt(DateTime? acceptedAt) => _$this._acceptedAt = acceptedAt;

  SdkDynamicLinkRecordDtoBuilder? _link;
  SdkDynamicLinkRecordDtoBuilder get link =>
      _$this._link ??= SdkDynamicLinkRecordDtoBuilder();
  set link(SdkDynamicLinkRecordDtoBuilder? link) => _$this._link = link;

  String? _requestVersion;
  String? get requestVersion => _$this._requestVersion;
  set requestVersion(String? requestVersion) =>
      _$this._requestVersion = requestVersion;

  SdkCreateDynamicLinkResponseDtoBuilder() {
    SdkCreateDynamicLinkResponseDto._defaults(this);
  }

  SdkCreateDynamicLinkResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _acceptedAt = $v.acceptedAt;
      _link = $v.link.toBuilder();
      _requestVersion = $v.requestVersion;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SdkCreateDynamicLinkResponseDto other) {
    _$v = other as _$SdkCreateDynamicLinkResponseDto;
  }

  @override
  void update(void Function(SdkCreateDynamicLinkResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SdkCreateDynamicLinkResponseDto build() => _build();

  _$SdkCreateDynamicLinkResponseDto _build() {
    _$SdkCreateDynamicLinkResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$SdkCreateDynamicLinkResponseDto._(
            acceptedAt: BuiltValueNullFieldError.checkNotNull(
              acceptedAt,
              r'SdkCreateDynamicLinkResponseDto',
              'acceptedAt',
            ),
            link: link.build(),
            requestVersion: BuiltValueNullFieldError.checkNotNull(
              requestVersion,
              r'SdkCreateDynamicLinkResponseDto',
              'requestVersion',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'link';
        link.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'SdkCreateDynamicLinkResponseDto',
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
