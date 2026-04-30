// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unity_release_summary_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UnityReleaseSummaryDto extends UnityReleaseSummaryDto {
  @override
  final DateTime createdAt;
  @override
  final String downloadUrl;
  @override
  final String id;
  @override
  final bool isLatest;
  @override
  final String mimeType;
  @override
  final String originalFilename;
  @override
  final SdkReleasePlatform platform;
  @override
  final String? releaseNotes;
  @override
  final num sizeBytes;
  @override
  final DateTime updatedAt;
  @override
  final String version;

  factory _$UnityReleaseSummaryDto([
    void Function(UnityReleaseSummaryDtoBuilder)? updates,
  ]) => (UnityReleaseSummaryDtoBuilder()..update(updates))._build();

  _$UnityReleaseSummaryDto._({
    required this.createdAt,
    required this.downloadUrl,
    required this.id,
    required this.isLatest,
    required this.mimeType,
    required this.originalFilename,
    required this.platform,
    this.releaseNotes,
    required this.sizeBytes,
    required this.updatedAt,
    required this.version,
  }) : super._();
  @override
  UnityReleaseSummaryDto rebuild(
    void Function(UnityReleaseSummaryDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  UnityReleaseSummaryDtoBuilder toBuilder() =>
      UnityReleaseSummaryDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UnityReleaseSummaryDto &&
        createdAt == other.createdAt &&
        downloadUrl == other.downloadUrl &&
        id == other.id &&
        isLatest == other.isLatest &&
        mimeType == other.mimeType &&
        originalFilename == other.originalFilename &&
        platform == other.platform &&
        releaseNotes == other.releaseNotes &&
        sizeBytes == other.sizeBytes &&
        updatedAt == other.updatedAt &&
        version == other.version;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, downloadUrl.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, isLatest.hashCode);
    _$hash = $jc(_$hash, mimeType.hashCode);
    _$hash = $jc(_$hash, originalFilename.hashCode);
    _$hash = $jc(_$hash, platform.hashCode);
    _$hash = $jc(_$hash, releaseNotes.hashCode);
    _$hash = $jc(_$hash, sizeBytes.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UnityReleaseSummaryDto')
          ..add('createdAt', createdAt)
          ..add('downloadUrl', downloadUrl)
          ..add('id', id)
          ..add('isLatest', isLatest)
          ..add('mimeType', mimeType)
          ..add('originalFilename', originalFilename)
          ..add('platform', platform)
          ..add('releaseNotes', releaseNotes)
          ..add('sizeBytes', sizeBytes)
          ..add('updatedAt', updatedAt)
          ..add('version', version))
        .toString();
  }
}

class UnityReleaseSummaryDtoBuilder
    implements Builder<UnityReleaseSummaryDto, UnityReleaseSummaryDtoBuilder> {
  _$UnityReleaseSummaryDto? _$v;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  String? _downloadUrl;
  String? get downloadUrl => _$this._downloadUrl;
  set downloadUrl(String? downloadUrl) => _$this._downloadUrl = downloadUrl;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  bool? _isLatest;
  bool? get isLatest => _$this._isLatest;
  set isLatest(bool? isLatest) => _$this._isLatest = isLatest;

  String? _mimeType;
  String? get mimeType => _$this._mimeType;
  set mimeType(String? mimeType) => _$this._mimeType = mimeType;

  String? _originalFilename;
  String? get originalFilename => _$this._originalFilename;
  set originalFilename(String? originalFilename) =>
      _$this._originalFilename = originalFilename;

  SdkReleasePlatform? _platform;
  SdkReleasePlatform? get platform => _$this._platform;
  set platform(SdkReleasePlatform? platform) => _$this._platform = platform;

  String? _releaseNotes;
  String? get releaseNotes => _$this._releaseNotes;
  set releaseNotes(String? releaseNotes) => _$this._releaseNotes = releaseNotes;

  num? _sizeBytes;
  num? get sizeBytes => _$this._sizeBytes;
  set sizeBytes(num? sizeBytes) => _$this._sizeBytes = sizeBytes;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  String? _version;
  String? get version => _$this._version;
  set version(String? version) => _$this._version = version;

  UnityReleaseSummaryDtoBuilder() {
    UnityReleaseSummaryDto._defaults(this);
  }

  UnityReleaseSummaryDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _createdAt = $v.createdAt;
      _downloadUrl = $v.downloadUrl;
      _id = $v.id;
      _isLatest = $v.isLatest;
      _mimeType = $v.mimeType;
      _originalFilename = $v.originalFilename;
      _platform = $v.platform;
      _releaseNotes = $v.releaseNotes;
      _sizeBytes = $v.sizeBytes;
      _updatedAt = $v.updatedAt;
      _version = $v.version;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UnityReleaseSummaryDto other) {
    _$v = other as _$UnityReleaseSummaryDto;
  }

  @override
  void update(void Function(UnityReleaseSummaryDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UnityReleaseSummaryDto build() => _build();

  _$UnityReleaseSummaryDto _build() {
    final _$result =
        _$v ??
        _$UnityReleaseSummaryDto._(
          createdAt: BuiltValueNullFieldError.checkNotNull(
            createdAt,
            r'UnityReleaseSummaryDto',
            'createdAt',
          ),
          downloadUrl: BuiltValueNullFieldError.checkNotNull(
            downloadUrl,
            r'UnityReleaseSummaryDto',
            'downloadUrl',
          ),
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'UnityReleaseSummaryDto',
            'id',
          ),
          isLatest: BuiltValueNullFieldError.checkNotNull(
            isLatest,
            r'UnityReleaseSummaryDto',
            'isLatest',
          ),
          mimeType: BuiltValueNullFieldError.checkNotNull(
            mimeType,
            r'UnityReleaseSummaryDto',
            'mimeType',
          ),
          originalFilename: BuiltValueNullFieldError.checkNotNull(
            originalFilename,
            r'UnityReleaseSummaryDto',
            'originalFilename',
          ),
          platform: BuiltValueNullFieldError.checkNotNull(
            platform,
            r'UnityReleaseSummaryDto',
            'platform',
          ),
          releaseNotes: releaseNotes,
          sizeBytes: BuiltValueNullFieldError.checkNotNull(
            sizeBytes,
            r'UnityReleaseSummaryDto',
            'sizeBytes',
          ),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
            updatedAt,
            r'UnityReleaseSummaryDto',
            'updatedAt',
          ),
          version: BuiltValueNullFieldError.checkNotNull(
            version,
            r'UnityReleaseSummaryDto',
            'version',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
