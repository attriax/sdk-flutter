// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_utm_payload_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SdkUtmPayloadDto extends SdkUtmPayloadDto {
  @override
  final String? campaign;
  @override
  final String? content;
  @override
  final String? medium;
  @override
  final String? source_;
  @override
  final String? term;

  factory _$SdkUtmPayloadDto([
    void Function(SdkUtmPayloadDtoBuilder)? updates,
  ]) => (SdkUtmPayloadDtoBuilder()..update(updates))._build();

  _$SdkUtmPayloadDto._({
    this.campaign,
    this.content,
    this.medium,
    this.source_,
    this.term,
  }) : super._();
  @override
  SdkUtmPayloadDto rebuild(void Function(SdkUtmPayloadDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SdkUtmPayloadDtoBuilder toBuilder() =>
      SdkUtmPayloadDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SdkUtmPayloadDto &&
        campaign == other.campaign &&
        content == other.content &&
        medium == other.medium &&
        source_ == other.source_ &&
        term == other.term;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, campaign.hashCode);
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, medium.hashCode);
    _$hash = $jc(_$hash, source_.hashCode);
    _$hash = $jc(_$hash, term.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SdkUtmPayloadDto')
          ..add('campaign', campaign)
          ..add('content', content)
          ..add('medium', medium)
          ..add('source_', source_)
          ..add('term', term))
        .toString();
  }
}

class SdkUtmPayloadDtoBuilder
    implements Builder<SdkUtmPayloadDto, SdkUtmPayloadDtoBuilder> {
  _$SdkUtmPayloadDto? _$v;

  String? _campaign;
  String? get campaign => _$this._campaign;
  set campaign(String? campaign) => _$this._campaign = campaign;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  String? _medium;
  String? get medium => _$this._medium;
  set medium(String? medium) => _$this._medium = medium;

  String? _source_;
  String? get source_ => _$this._source_;
  set source_(String? source_) => _$this._source_ = source_;

  String? _term;
  String? get term => _$this._term;
  set term(String? term) => _$this._term = term;

  SdkUtmPayloadDtoBuilder() {
    SdkUtmPayloadDto._defaults(this);
  }

  SdkUtmPayloadDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _campaign = $v.campaign;
      _content = $v.content;
      _medium = $v.medium;
      _source_ = $v.source_;
      _term = $v.term;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SdkUtmPayloadDto other) {
    _$v = other as _$SdkUtmPayloadDto;
  }

  @override
  void update(void Function(SdkUtmPayloadDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SdkUtmPayloadDto build() => _build();

  _$SdkUtmPayloadDto _build() {
    final _$result =
        _$v ??
        _$SdkUtmPayloadDto._(
          campaign: campaign,
          content: content,
          medium: medium,
          source_: source_,
          term: term,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
