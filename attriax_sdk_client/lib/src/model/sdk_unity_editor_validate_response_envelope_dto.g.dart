// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_unity_editor_validate_response_envelope_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SdkUnityEditorValidateResponseEnvelopeDto
    extends SdkUnityEditorValidateResponseEnvelopeDto {
  @override
  final SdkUnityEditorValidateResponseDto data;
  @override
  final bool success;
  @override
  final DateTime timestamp;

  factory _$SdkUnityEditorValidateResponseEnvelopeDto([
    void Function(SdkUnityEditorValidateResponseEnvelopeDtoBuilder)? updates,
  ]) => (SdkUnityEditorValidateResponseEnvelopeDtoBuilder()..update(updates))
      ._build();

  _$SdkUnityEditorValidateResponseEnvelopeDto._({
    required this.data,
    required this.success,
    required this.timestamp,
  }) : super._();
  @override
  SdkUnityEditorValidateResponseEnvelopeDto rebuild(
    void Function(SdkUnityEditorValidateResponseEnvelopeDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SdkUnityEditorValidateResponseEnvelopeDtoBuilder toBuilder() =>
      SdkUnityEditorValidateResponseEnvelopeDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SdkUnityEditorValidateResponseEnvelopeDto &&
        data == other.data &&
        success == other.success &&
        timestamp == other.timestamp;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jc(_$hash, success.hashCode);
    _$hash = $jc(_$hash, timestamp.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'SdkUnityEditorValidateResponseEnvelopeDto',
          )
          ..add('data', data)
          ..add('success', success)
          ..add('timestamp', timestamp))
        .toString();
  }
}

class SdkUnityEditorValidateResponseEnvelopeDtoBuilder
    implements
        Builder<
          SdkUnityEditorValidateResponseEnvelopeDto,
          SdkUnityEditorValidateResponseEnvelopeDtoBuilder
        > {
  _$SdkUnityEditorValidateResponseEnvelopeDto? _$v;

  SdkUnityEditorValidateResponseDtoBuilder? _data;
  SdkUnityEditorValidateResponseDtoBuilder get data =>
      _$this._data ??= SdkUnityEditorValidateResponseDtoBuilder();
  set data(SdkUnityEditorValidateResponseDtoBuilder? data) =>
      _$this._data = data;

  bool? _success;
  bool? get success => _$this._success;
  set success(bool? success) => _$this._success = success;

  DateTime? _timestamp;
  DateTime? get timestamp => _$this._timestamp;
  set timestamp(DateTime? timestamp) => _$this._timestamp = timestamp;

  SdkUnityEditorValidateResponseEnvelopeDtoBuilder() {
    SdkUnityEditorValidateResponseEnvelopeDto._defaults(this);
  }

  SdkUnityEditorValidateResponseEnvelopeDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _success = $v.success;
      _timestamp = $v.timestamp;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SdkUnityEditorValidateResponseEnvelopeDto other) {
    _$v = other as _$SdkUnityEditorValidateResponseEnvelopeDto;
  }

  @override
  void update(
    void Function(SdkUnityEditorValidateResponseEnvelopeDtoBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  SdkUnityEditorValidateResponseEnvelopeDto build() => _build();

  _$SdkUnityEditorValidateResponseEnvelopeDto _build() {
    _$SdkUnityEditorValidateResponseEnvelopeDto _$result;
    try {
      _$result =
          _$v ??
          _$SdkUnityEditorValidateResponseEnvelopeDto._(
            data: data.build(),
            success: BuiltValueNullFieldError.checkNotNull(
              success,
              r'SdkUnityEditorValidateResponseEnvelopeDto',
              'success',
            ),
            timestamp: BuiltValueNullFieldError.checkNotNull(
              timestamp,
              r'SdkUnityEditorValidateResponseEnvelopeDto',
              'timestamp',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'SdkUnityEditorValidateResponseEnvelopeDto',
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
