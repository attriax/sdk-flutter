// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_v1_batch_item_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SdkV1BatchItemDto extends SdkV1BatchItemDto {
  @override
  final BuiltMap<String, JsonObject?> body;
  @override
  final SdkBatchItemKind kind;

  factory _$SdkV1BatchItemDto([
    void Function(SdkV1BatchItemDtoBuilder)? updates,
  ]) => (SdkV1BatchItemDtoBuilder()..update(updates))._build();

  _$SdkV1BatchItemDto._({required this.body, required this.kind}) : super._();
  @override
  SdkV1BatchItemDto rebuild(void Function(SdkV1BatchItemDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SdkV1BatchItemDtoBuilder toBuilder() =>
      SdkV1BatchItemDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SdkV1BatchItemDto &&
        body == other.body &&
        kind == other.kind;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, body.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SdkV1BatchItemDto')
          ..add('body', body)
          ..add('kind', kind))
        .toString();
  }
}

class SdkV1BatchItemDtoBuilder
    implements Builder<SdkV1BatchItemDto, SdkV1BatchItemDtoBuilder> {
  _$SdkV1BatchItemDto? _$v;

  MapBuilder<String, JsonObject?>? _body;
  MapBuilder<String, JsonObject?> get body =>
      _$this._body ??= MapBuilder<String, JsonObject?>();
  set body(MapBuilder<String, JsonObject?>? body) => _$this._body = body;

  SdkBatchItemKind? _kind;
  SdkBatchItemKind? get kind => _$this._kind;
  set kind(SdkBatchItemKind? kind) => _$this._kind = kind;

  SdkV1BatchItemDtoBuilder() {
    SdkV1BatchItemDto._defaults(this);
  }

  SdkV1BatchItemDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _body = $v.body.toBuilder();
      _kind = $v.kind;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SdkV1BatchItemDto other) {
    _$v = other as _$SdkV1BatchItemDto;
  }

  @override
  void update(void Function(SdkV1BatchItemDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SdkV1BatchItemDto build() => _build();

  _$SdkV1BatchItemDto _build() {
    _$SdkV1BatchItemDto _$result;
    try {
      _$result =
          _$v ??
          _$SdkV1BatchItemDto._(
            body: body.build(),
            kind: BuiltValueNullFieldError.checkNotNull(
              kind,
              r'SdkV1BatchItemDto',
              'kind',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'body';
        body.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'SdkV1BatchItemDto',
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
