// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_acknowledge_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SdkAcknowledgeResponseDto extends SdkAcknowledgeResponseDto {
  @override
  final bool success;

  factory _$SdkAcknowledgeResponseDto([
    void Function(SdkAcknowledgeResponseDtoBuilder)? updates,
  ]) => (SdkAcknowledgeResponseDtoBuilder()..update(updates))._build();

  _$SdkAcknowledgeResponseDto._({required this.success}) : super._();
  @override
  SdkAcknowledgeResponseDto rebuild(
    void Function(SdkAcknowledgeResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SdkAcknowledgeResponseDtoBuilder toBuilder() =>
      SdkAcknowledgeResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SdkAcknowledgeResponseDto && success == other.success;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, success.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'SdkAcknowledgeResponseDto',
    )..add('success', success)).toString();
  }
}

class SdkAcknowledgeResponseDtoBuilder
    implements
        Builder<SdkAcknowledgeResponseDto, SdkAcknowledgeResponseDtoBuilder> {
  _$SdkAcknowledgeResponseDto? _$v;

  bool? _success;
  bool? get success => _$this._success;
  set success(bool? success) => _$this._success = success;

  SdkAcknowledgeResponseDtoBuilder() {
    SdkAcknowledgeResponseDto._defaults(this);
  }

  SdkAcknowledgeResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _success = $v.success;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SdkAcknowledgeResponseDto other) {
    _$v = other as _$SdkAcknowledgeResponseDto;
  }

  @override
  void update(void Function(SdkAcknowledgeResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SdkAcknowledgeResponseDto build() => _build();

  _$SdkAcknowledgeResponseDto _build() {
    final _$result =
        _$v ??
        _$SdkAcknowledgeResponseDto._(
          success: BuiltValueNullFieldError.checkNotNull(
            success,
            r'SdkAcknowledgeResponseDto',
            'success',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
