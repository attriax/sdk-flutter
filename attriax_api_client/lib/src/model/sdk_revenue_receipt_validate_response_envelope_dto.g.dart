// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_revenue_receipt_validate_response_envelope_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SdkRevenueReceiptValidateResponseEnvelopeDto
    extends SdkRevenueReceiptValidateResponseEnvelopeDto {
  @override
  final SdkRevenueReceiptValidateResponseDto data;
  @override
  final bool success;
  @override
  final DateTime timestamp;

  factory _$SdkRevenueReceiptValidateResponseEnvelopeDto([
    void Function(SdkRevenueReceiptValidateResponseEnvelopeDtoBuilder)? updates,
  ]) => (SdkRevenueReceiptValidateResponseEnvelopeDtoBuilder()..update(updates))
      ._build();

  _$SdkRevenueReceiptValidateResponseEnvelopeDto._({
    required this.data,
    required this.success,
    required this.timestamp,
  }) : super._();
  @override
  SdkRevenueReceiptValidateResponseEnvelopeDto rebuild(
    void Function(SdkRevenueReceiptValidateResponseEnvelopeDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SdkRevenueReceiptValidateResponseEnvelopeDtoBuilder toBuilder() =>
      SdkRevenueReceiptValidateResponseEnvelopeDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SdkRevenueReceiptValidateResponseEnvelopeDto &&
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
            r'SdkRevenueReceiptValidateResponseEnvelopeDto',
          )
          ..add('data', data)
          ..add('success', success)
          ..add('timestamp', timestamp))
        .toString();
  }
}

class SdkRevenueReceiptValidateResponseEnvelopeDtoBuilder
    implements
        Builder<
          SdkRevenueReceiptValidateResponseEnvelopeDto,
          SdkRevenueReceiptValidateResponseEnvelopeDtoBuilder
        > {
  _$SdkRevenueReceiptValidateResponseEnvelopeDto? _$v;

  SdkRevenueReceiptValidateResponseDtoBuilder? _data;
  SdkRevenueReceiptValidateResponseDtoBuilder get data =>
      _$this._data ??= SdkRevenueReceiptValidateResponseDtoBuilder();
  set data(SdkRevenueReceiptValidateResponseDtoBuilder? data) =>
      _$this._data = data;

  bool? _success;
  bool? get success => _$this._success;
  set success(bool? success) => _$this._success = success;

  DateTime? _timestamp;
  DateTime? get timestamp => _$this._timestamp;
  set timestamp(DateTime? timestamp) => _$this._timestamp = timestamp;

  SdkRevenueReceiptValidateResponseEnvelopeDtoBuilder() {
    SdkRevenueReceiptValidateResponseEnvelopeDto._defaults(this);
  }

  SdkRevenueReceiptValidateResponseEnvelopeDtoBuilder get _$this {
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
  void replace(SdkRevenueReceiptValidateResponseEnvelopeDto other) {
    _$v = other as _$SdkRevenueReceiptValidateResponseEnvelopeDto;
  }

  @override
  void update(
    void Function(SdkRevenueReceiptValidateResponseEnvelopeDtoBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  SdkRevenueReceiptValidateResponseEnvelopeDto build() => _build();

  _$SdkRevenueReceiptValidateResponseEnvelopeDto _build() {
    _$SdkRevenueReceiptValidateResponseEnvelopeDto _$result;
    try {
      _$result =
          _$v ??
          _$SdkRevenueReceiptValidateResponseEnvelopeDto._(
            data: data.build(),
            success: BuiltValueNullFieldError.checkNotNull(
              success,
              r'SdkRevenueReceiptValidateResponseEnvelopeDto',
              'success',
            ),
            timestamp: BuiltValueNullFieldError.checkNotNull(
              timestamp,
              r'SdkRevenueReceiptValidateResponseEnvelopeDto',
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
          r'SdkRevenueReceiptValidateResponseEnvelopeDto',
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
