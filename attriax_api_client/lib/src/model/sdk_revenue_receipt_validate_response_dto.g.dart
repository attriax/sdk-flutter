// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_revenue_receipt_validate_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SdkRevenueReceiptValidateResponseDtoStatusEnum
_$sdkRevenueReceiptValidateResponseDtoStatusEnum_verified =
    const SdkRevenueReceiptValidateResponseDtoStatusEnum._('verified');
const SdkRevenueReceiptValidateResponseDtoStatusEnum
_$sdkRevenueReceiptValidateResponseDtoStatusEnum_rejected =
    const SdkRevenueReceiptValidateResponseDtoStatusEnum._('rejected');
const SdkRevenueReceiptValidateResponseDtoStatusEnum
_$sdkRevenueReceiptValidateResponseDtoStatusEnum_pending =
    const SdkRevenueReceiptValidateResponseDtoStatusEnum._('pending');
const SdkRevenueReceiptValidateResponseDtoStatusEnum
_$sdkRevenueReceiptValidateResponseDtoStatusEnum_unconfigured =
    const SdkRevenueReceiptValidateResponseDtoStatusEnum._('unconfigured');
const SdkRevenueReceiptValidateResponseDtoStatusEnum
_$sdkRevenueReceiptValidateResponseDtoStatusEnum_providerError =
    const SdkRevenueReceiptValidateResponseDtoStatusEnum._('providerError');
const SdkRevenueReceiptValidateResponseDtoStatusEnum
_$sdkRevenueReceiptValidateResponseDtoStatusEnum_passthrough =
    const SdkRevenueReceiptValidateResponseDtoStatusEnum._('passthrough');

SdkRevenueReceiptValidateResponseDtoStatusEnum
_$sdkRevenueReceiptValidateResponseDtoStatusEnumValueOf(String name) {
  switch (name) {
    case 'verified':
      return _$sdkRevenueReceiptValidateResponseDtoStatusEnum_verified;
    case 'rejected':
      return _$sdkRevenueReceiptValidateResponseDtoStatusEnum_rejected;
    case 'pending':
      return _$sdkRevenueReceiptValidateResponseDtoStatusEnum_pending;
    case 'unconfigured':
      return _$sdkRevenueReceiptValidateResponseDtoStatusEnum_unconfigured;
    case 'providerError':
      return _$sdkRevenueReceiptValidateResponseDtoStatusEnum_providerError;
    case 'passthrough':
      return _$sdkRevenueReceiptValidateResponseDtoStatusEnum_passthrough;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<SdkRevenueReceiptValidateResponseDtoStatusEnum>
_$sdkRevenueReceiptValidateResponseDtoStatusEnumValues =
    BuiltSet<SdkRevenueReceiptValidateResponseDtoStatusEnum>(
      const <SdkRevenueReceiptValidateResponseDtoStatusEnum>[
        _$sdkRevenueReceiptValidateResponseDtoStatusEnum_verified,
        _$sdkRevenueReceiptValidateResponseDtoStatusEnum_rejected,
        _$sdkRevenueReceiptValidateResponseDtoStatusEnum_pending,
        _$sdkRevenueReceiptValidateResponseDtoStatusEnum_unconfigured,
        _$sdkRevenueReceiptValidateResponseDtoStatusEnum_providerError,
        _$sdkRevenueReceiptValidateResponseDtoStatusEnum_passthrough,
      ],
    );

Serializer<SdkRevenueReceiptValidateResponseDtoStatusEnum>
_$sdkRevenueReceiptValidateResponseDtoStatusEnumSerializer =
    _$SdkRevenueReceiptValidateResponseDtoStatusEnumSerializer();

class _$SdkRevenueReceiptValidateResponseDtoStatusEnumSerializer
    implements
        PrimitiveSerializer<SdkRevenueReceiptValidateResponseDtoStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'verified': 'verified',
    'rejected': 'rejected',
    'pending': 'pending',
    'unconfigured': 'unconfigured',
    'providerError': 'provider_error',
    'passthrough': 'passthrough',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'verified': 'verified',
    'rejected': 'rejected',
    'pending': 'pending',
    'unconfigured': 'unconfigured',
    'provider_error': 'providerError',
    'passthrough': 'passthrough',
  };

  @override
  final Iterable<Type> types = const <Type>[
    SdkRevenueReceiptValidateResponseDtoStatusEnum,
  ];
  @override
  final String wireName = 'SdkRevenueReceiptValidateResponseDtoStatusEnum';

  @override
  Object serialize(
    Serializers serializers,
    SdkRevenueReceiptValidateResponseDtoStatusEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  SdkRevenueReceiptValidateResponseDtoStatusEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => SdkRevenueReceiptValidateResponseDtoStatusEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$SdkRevenueReceiptValidateResponseDto
    extends SdkRevenueReceiptValidateResponseDto {
  @override
  final DateTime acceptedAt;
  @override
  final String? environment;
  @override
  final DateTime? expiresAt;
  @override
  final String? failureReason;
  @override
  final String? originalTransactionId;
  @override
  final String? productId;
  @override
  final String? provider;
  @override
  final BuiltMap<String, JsonObject?>? providerResult;
  @override
  final BuiltMap<String, JsonObject?> publicReceipt;
  @override
  final String requestVersion;
  @override
  final SdkRevenueReceiptValidateResponseDtoStatusEnum status;
  @override
  final String? transactionId;
  @override
  final String validationId;

  factory _$SdkRevenueReceiptValidateResponseDto([
    void Function(SdkRevenueReceiptValidateResponseDtoBuilder)? updates,
  ]) =>
      (SdkRevenueReceiptValidateResponseDtoBuilder()..update(updates))._build();

  _$SdkRevenueReceiptValidateResponseDto._({
    required this.acceptedAt,
    this.environment,
    this.expiresAt,
    this.failureReason,
    this.originalTransactionId,
    this.productId,
    this.provider,
    this.providerResult,
    required this.publicReceipt,
    required this.requestVersion,
    required this.status,
    this.transactionId,
    required this.validationId,
  }) : super._();
  @override
  SdkRevenueReceiptValidateResponseDto rebuild(
    void Function(SdkRevenueReceiptValidateResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SdkRevenueReceiptValidateResponseDtoBuilder toBuilder() =>
      SdkRevenueReceiptValidateResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SdkRevenueReceiptValidateResponseDto &&
        acceptedAt == other.acceptedAt &&
        environment == other.environment &&
        expiresAt == other.expiresAt &&
        failureReason == other.failureReason &&
        originalTransactionId == other.originalTransactionId &&
        productId == other.productId &&
        provider == other.provider &&
        providerResult == other.providerResult &&
        publicReceipt == other.publicReceipt &&
        requestVersion == other.requestVersion &&
        status == other.status &&
        transactionId == other.transactionId &&
        validationId == other.validationId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, acceptedAt.hashCode);
    _$hash = $jc(_$hash, environment.hashCode);
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jc(_$hash, failureReason.hashCode);
    _$hash = $jc(_$hash, originalTransactionId.hashCode);
    _$hash = $jc(_$hash, productId.hashCode);
    _$hash = $jc(_$hash, provider.hashCode);
    _$hash = $jc(_$hash, providerResult.hashCode);
    _$hash = $jc(_$hash, publicReceipt.hashCode);
    _$hash = $jc(_$hash, requestVersion.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, transactionId.hashCode);
    _$hash = $jc(_$hash, validationId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SdkRevenueReceiptValidateResponseDto')
          ..add('acceptedAt', acceptedAt)
          ..add('environment', environment)
          ..add('expiresAt', expiresAt)
          ..add('failureReason', failureReason)
          ..add('originalTransactionId', originalTransactionId)
          ..add('productId', productId)
          ..add('provider', provider)
          ..add('providerResult', providerResult)
          ..add('publicReceipt', publicReceipt)
          ..add('requestVersion', requestVersion)
          ..add('status', status)
          ..add('transactionId', transactionId)
          ..add('validationId', validationId))
        .toString();
  }
}

class SdkRevenueReceiptValidateResponseDtoBuilder
    implements
        Builder<
          SdkRevenueReceiptValidateResponseDto,
          SdkRevenueReceiptValidateResponseDtoBuilder
        > {
  _$SdkRevenueReceiptValidateResponseDto? _$v;

  DateTime? _acceptedAt;
  DateTime? get acceptedAt => _$this._acceptedAt;
  set acceptedAt(DateTime? acceptedAt) => _$this._acceptedAt = acceptedAt;

  String? _environment;
  String? get environment => _$this._environment;
  set environment(String? environment) => _$this._environment = environment;

  DateTime? _expiresAt;
  DateTime? get expiresAt => _$this._expiresAt;
  set expiresAt(DateTime? expiresAt) => _$this._expiresAt = expiresAt;

  String? _failureReason;
  String? get failureReason => _$this._failureReason;
  set failureReason(String? failureReason) =>
      _$this._failureReason = failureReason;

  String? _originalTransactionId;
  String? get originalTransactionId => _$this._originalTransactionId;
  set originalTransactionId(String? originalTransactionId) =>
      _$this._originalTransactionId = originalTransactionId;

  String? _productId;
  String? get productId => _$this._productId;
  set productId(String? productId) => _$this._productId = productId;

  String? _provider;
  String? get provider => _$this._provider;
  set provider(String? provider) => _$this._provider = provider;

  MapBuilder<String, JsonObject?>? _providerResult;
  MapBuilder<String, JsonObject?> get providerResult =>
      _$this._providerResult ??= MapBuilder<String, JsonObject?>();
  set providerResult(MapBuilder<String, JsonObject?>? providerResult) =>
      _$this._providerResult = providerResult;

  MapBuilder<String, JsonObject?>? _publicReceipt;
  MapBuilder<String, JsonObject?> get publicReceipt =>
      _$this._publicReceipt ??= MapBuilder<String, JsonObject?>();
  set publicReceipt(MapBuilder<String, JsonObject?>? publicReceipt) =>
      _$this._publicReceipt = publicReceipt;

  String? _requestVersion;
  String? get requestVersion => _$this._requestVersion;
  set requestVersion(String? requestVersion) =>
      _$this._requestVersion = requestVersion;

  SdkRevenueReceiptValidateResponseDtoStatusEnum? _status;
  SdkRevenueReceiptValidateResponseDtoStatusEnum? get status => _$this._status;
  set status(SdkRevenueReceiptValidateResponseDtoStatusEnum? status) =>
      _$this._status = status;

  String? _transactionId;
  String? get transactionId => _$this._transactionId;
  set transactionId(String? transactionId) =>
      _$this._transactionId = transactionId;

  String? _validationId;
  String? get validationId => _$this._validationId;
  set validationId(String? validationId) => _$this._validationId = validationId;

  SdkRevenueReceiptValidateResponseDtoBuilder() {
    SdkRevenueReceiptValidateResponseDto._defaults(this);
  }

  SdkRevenueReceiptValidateResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _acceptedAt = $v.acceptedAt;
      _environment = $v.environment;
      _expiresAt = $v.expiresAt;
      _failureReason = $v.failureReason;
      _originalTransactionId = $v.originalTransactionId;
      _productId = $v.productId;
      _provider = $v.provider;
      _providerResult = $v.providerResult?.toBuilder();
      _publicReceipt = $v.publicReceipt.toBuilder();
      _requestVersion = $v.requestVersion;
      _status = $v.status;
      _transactionId = $v.transactionId;
      _validationId = $v.validationId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SdkRevenueReceiptValidateResponseDto other) {
    _$v = other as _$SdkRevenueReceiptValidateResponseDto;
  }

  @override
  void update(
    void Function(SdkRevenueReceiptValidateResponseDtoBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  SdkRevenueReceiptValidateResponseDto build() => _build();

  _$SdkRevenueReceiptValidateResponseDto _build() {
    _$SdkRevenueReceiptValidateResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$SdkRevenueReceiptValidateResponseDto._(
            acceptedAt: BuiltValueNullFieldError.checkNotNull(
              acceptedAt,
              r'SdkRevenueReceiptValidateResponseDto',
              'acceptedAt',
            ),
            environment: environment,
            expiresAt: expiresAt,
            failureReason: failureReason,
            originalTransactionId: originalTransactionId,
            productId: productId,
            provider: provider,
            providerResult: _providerResult?.build(),
            publicReceipt: publicReceipt.build(),
            requestVersion: BuiltValueNullFieldError.checkNotNull(
              requestVersion,
              r'SdkRevenueReceiptValidateResponseDto',
              'requestVersion',
            ),
            status: BuiltValueNullFieldError.checkNotNull(
              status,
              r'SdkRevenueReceiptValidateResponseDto',
              'status',
            ),
            transactionId: transactionId,
            validationId: BuiltValueNullFieldError.checkNotNull(
              validationId,
              r'SdkRevenueReceiptValidateResponseDto',
              'validationId',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'providerResult';
        _providerResult?.build();
        _$failedField = 'publicReceipt';
        publicReceipt.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'SdkRevenueReceiptValidateResponseDto',
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
