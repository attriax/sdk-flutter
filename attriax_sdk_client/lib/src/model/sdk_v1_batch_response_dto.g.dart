// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_v1_batch_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SdkV1BatchResponseDto extends SdkV1BatchResponseDto {
  @override
  final DateTime acceptedAt;
  @override
  final num duplicateCount;
  @override
  final num itemCount;
  @override
  final num processedCount;
  @override
  final String requestVersion;

  factory _$SdkV1BatchResponseDto([
    void Function(SdkV1BatchResponseDtoBuilder)? updates,
  ]) => (SdkV1BatchResponseDtoBuilder()..update(updates))._build();

  _$SdkV1BatchResponseDto._({
    required this.acceptedAt,
    required this.duplicateCount,
    required this.itemCount,
    required this.processedCount,
    required this.requestVersion,
  }) : super._();
  @override
  SdkV1BatchResponseDto rebuild(
    void Function(SdkV1BatchResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SdkV1BatchResponseDtoBuilder toBuilder() =>
      SdkV1BatchResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SdkV1BatchResponseDto &&
        acceptedAt == other.acceptedAt &&
        duplicateCount == other.duplicateCount &&
        itemCount == other.itemCount &&
        processedCount == other.processedCount &&
        requestVersion == other.requestVersion;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, acceptedAt.hashCode);
    _$hash = $jc(_$hash, duplicateCount.hashCode);
    _$hash = $jc(_$hash, itemCount.hashCode);
    _$hash = $jc(_$hash, processedCount.hashCode);
    _$hash = $jc(_$hash, requestVersion.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SdkV1BatchResponseDto')
          ..add('acceptedAt', acceptedAt)
          ..add('duplicateCount', duplicateCount)
          ..add('itemCount', itemCount)
          ..add('processedCount', processedCount)
          ..add('requestVersion', requestVersion))
        .toString();
  }
}

class SdkV1BatchResponseDtoBuilder
    implements Builder<SdkV1BatchResponseDto, SdkV1BatchResponseDtoBuilder> {
  _$SdkV1BatchResponseDto? _$v;

  DateTime? _acceptedAt;
  DateTime? get acceptedAt => _$this._acceptedAt;
  set acceptedAt(DateTime? acceptedAt) => _$this._acceptedAt = acceptedAt;

  num? _duplicateCount;
  num? get duplicateCount => _$this._duplicateCount;
  set duplicateCount(num? duplicateCount) =>
      _$this._duplicateCount = duplicateCount;

  num? _itemCount;
  num? get itemCount => _$this._itemCount;
  set itemCount(num? itemCount) => _$this._itemCount = itemCount;

  num? _processedCount;
  num? get processedCount => _$this._processedCount;
  set processedCount(num? processedCount) =>
      _$this._processedCount = processedCount;

  String? _requestVersion;
  String? get requestVersion => _$this._requestVersion;
  set requestVersion(String? requestVersion) =>
      _$this._requestVersion = requestVersion;

  SdkV1BatchResponseDtoBuilder() {
    SdkV1BatchResponseDto._defaults(this);
  }

  SdkV1BatchResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _acceptedAt = $v.acceptedAt;
      _duplicateCount = $v.duplicateCount;
      _itemCount = $v.itemCount;
      _processedCount = $v.processedCount;
      _requestVersion = $v.requestVersion;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SdkV1BatchResponseDto other) {
    _$v = other as _$SdkV1BatchResponseDto;
  }

  @override
  void update(void Function(SdkV1BatchResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SdkV1BatchResponseDto build() => _build();

  _$SdkV1BatchResponseDto _build() {
    final _$result =
        _$v ??
        _$SdkV1BatchResponseDto._(
          acceptedAt: BuiltValueNullFieldError.checkNotNull(
            acceptedAt,
            r'SdkV1BatchResponseDto',
            'acceptedAt',
          ),
          duplicateCount: BuiltValueNullFieldError.checkNotNull(
            duplicateCount,
            r'SdkV1BatchResponseDto',
            'duplicateCount',
          ),
          itemCount: BuiltValueNullFieldError.checkNotNull(
            itemCount,
            r'SdkV1BatchResponseDto',
            'itemCount',
          ),
          processedCount: BuiltValueNullFieldError.checkNotNull(
            processedCount,
            r'SdkV1BatchResponseDto',
            'processedCount',
          ),
          requestVersion: BuiltValueNullFieldError.checkNotNull(
            requestVersion,
            r'SdkV1BatchResponseDto',
            'requestVersion',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
