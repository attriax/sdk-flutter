// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_v1_revenue_receipt_validate_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SdkV1RevenueReceiptValidateDto extends SdkV1RevenueReceiptValidateDto {
  @override
  final String appToken;
  @override
  final String? clientOccurredAt;
  @override
  final String? deviceId;
  @override
  final String? environment;
  @override
  final String? originalTransactionId;
  @override
  final String? packageName;
  @override
  final String? productId;
  @override
  final String? provider;
  @override
  final String? purchaseToken;
  @override
  final String? receiptData;
  @override
  final String? receiptSignature;
  @override
  final String? signedPayload;
  @override
  final String? store;
  @override
  final bool? test;
  @override
  final String? transactionId;

  factory _$SdkV1RevenueReceiptValidateDto([
    void Function(SdkV1RevenueReceiptValidateDtoBuilder)? updates,
  ]) => (SdkV1RevenueReceiptValidateDtoBuilder()..update(updates))._build();

  _$SdkV1RevenueReceiptValidateDto._({
    required this.appToken,
    this.clientOccurredAt,
    this.deviceId,
    this.environment,
    this.originalTransactionId,
    this.packageName,
    this.productId,
    this.provider,
    this.purchaseToken,
    this.receiptData,
    this.receiptSignature,
    this.signedPayload,
    this.store,
    this.test,
    this.transactionId,
  }) : super._();
  @override
  SdkV1RevenueReceiptValidateDto rebuild(
    void Function(SdkV1RevenueReceiptValidateDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SdkV1RevenueReceiptValidateDtoBuilder toBuilder() =>
      SdkV1RevenueReceiptValidateDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SdkV1RevenueReceiptValidateDto &&
        appToken == other.appToken &&
        clientOccurredAt == other.clientOccurredAt &&
        deviceId == other.deviceId &&
        environment == other.environment &&
        originalTransactionId == other.originalTransactionId &&
        packageName == other.packageName &&
        productId == other.productId &&
        provider == other.provider &&
        purchaseToken == other.purchaseToken &&
        receiptData == other.receiptData &&
        receiptSignature == other.receiptSignature &&
        signedPayload == other.signedPayload &&
        store == other.store &&
        test == other.test &&
        transactionId == other.transactionId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, appToken.hashCode);
    _$hash = $jc(_$hash, clientOccurredAt.hashCode);
    _$hash = $jc(_$hash, deviceId.hashCode);
    _$hash = $jc(_$hash, environment.hashCode);
    _$hash = $jc(_$hash, originalTransactionId.hashCode);
    _$hash = $jc(_$hash, packageName.hashCode);
    _$hash = $jc(_$hash, productId.hashCode);
    _$hash = $jc(_$hash, provider.hashCode);
    _$hash = $jc(_$hash, purchaseToken.hashCode);
    _$hash = $jc(_$hash, receiptData.hashCode);
    _$hash = $jc(_$hash, receiptSignature.hashCode);
    _$hash = $jc(_$hash, signedPayload.hashCode);
    _$hash = $jc(_$hash, store.hashCode);
    _$hash = $jc(_$hash, test.hashCode);
    _$hash = $jc(_$hash, transactionId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SdkV1RevenueReceiptValidateDto')
          ..add('appToken', appToken)
          ..add('clientOccurredAt', clientOccurredAt)
          ..add('deviceId', deviceId)
          ..add('environment', environment)
          ..add('originalTransactionId', originalTransactionId)
          ..add('packageName', packageName)
          ..add('productId', productId)
          ..add('provider', provider)
          ..add('purchaseToken', purchaseToken)
          ..add('receiptData', receiptData)
          ..add('receiptSignature', receiptSignature)
          ..add('signedPayload', signedPayload)
          ..add('store', store)
          ..add('test', test)
          ..add('transactionId', transactionId))
        .toString();
  }
}

class SdkV1RevenueReceiptValidateDtoBuilder
    implements
        Builder<
          SdkV1RevenueReceiptValidateDto,
          SdkV1RevenueReceiptValidateDtoBuilder
        > {
  _$SdkV1RevenueReceiptValidateDto? _$v;

  String? _appToken;
  String? get appToken => _$this._appToken;
  set appToken(String? appToken) => _$this._appToken = appToken;

  String? _clientOccurredAt;
  String? get clientOccurredAt => _$this._clientOccurredAt;
  set clientOccurredAt(String? clientOccurredAt) =>
      _$this._clientOccurredAt = clientOccurredAt;

  String? _deviceId;
  String? get deviceId => _$this._deviceId;
  set deviceId(String? deviceId) => _$this._deviceId = deviceId;

  String? _environment;
  String? get environment => _$this._environment;
  set environment(String? environment) => _$this._environment = environment;

  String? _originalTransactionId;
  String? get originalTransactionId => _$this._originalTransactionId;
  set originalTransactionId(String? originalTransactionId) =>
      _$this._originalTransactionId = originalTransactionId;

  String? _packageName;
  String? get packageName => _$this._packageName;
  set packageName(String? packageName) => _$this._packageName = packageName;

  String? _productId;
  String? get productId => _$this._productId;
  set productId(String? productId) => _$this._productId = productId;

  String? _provider;
  String? get provider => _$this._provider;
  set provider(String? provider) => _$this._provider = provider;

  String? _purchaseToken;
  String? get purchaseToken => _$this._purchaseToken;
  set purchaseToken(String? purchaseToken) =>
      _$this._purchaseToken = purchaseToken;

  String? _receiptData;
  String? get receiptData => _$this._receiptData;
  set receiptData(String? receiptData) => _$this._receiptData = receiptData;

  String? _receiptSignature;
  String? get receiptSignature => _$this._receiptSignature;
  set receiptSignature(String? receiptSignature) =>
      _$this._receiptSignature = receiptSignature;

  String? _signedPayload;
  String? get signedPayload => _$this._signedPayload;
  set signedPayload(String? signedPayload) =>
      _$this._signedPayload = signedPayload;

  String? _store;
  String? get store => _$this._store;
  set store(String? store) => _$this._store = store;

  bool? _test;
  bool? get test => _$this._test;
  set test(bool? test) => _$this._test = test;

  String? _transactionId;
  String? get transactionId => _$this._transactionId;
  set transactionId(String? transactionId) =>
      _$this._transactionId = transactionId;

  SdkV1RevenueReceiptValidateDtoBuilder() {
    SdkV1RevenueReceiptValidateDto._defaults(this);
  }

  SdkV1RevenueReceiptValidateDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _appToken = $v.appToken;
      _clientOccurredAt = $v.clientOccurredAt;
      _deviceId = $v.deviceId;
      _environment = $v.environment;
      _originalTransactionId = $v.originalTransactionId;
      _packageName = $v.packageName;
      _productId = $v.productId;
      _provider = $v.provider;
      _purchaseToken = $v.purchaseToken;
      _receiptData = $v.receiptData;
      _receiptSignature = $v.receiptSignature;
      _signedPayload = $v.signedPayload;
      _store = $v.store;
      _test = $v.test;
      _transactionId = $v.transactionId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SdkV1RevenueReceiptValidateDto other) {
    _$v = other as _$SdkV1RevenueReceiptValidateDto;
  }

  @override
  void update(void Function(SdkV1RevenueReceiptValidateDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SdkV1RevenueReceiptValidateDto build() => _build();

  _$SdkV1RevenueReceiptValidateDto _build() {
    final _$result =
        _$v ??
        _$SdkV1RevenueReceiptValidateDto._(
          appToken: BuiltValueNullFieldError.checkNotNull(
            appToken,
            r'SdkV1RevenueReceiptValidateDto',
            'appToken',
          ),
          clientOccurredAt: clientOccurredAt,
          deviceId: deviceId,
          environment: environment,
          originalTransactionId: originalTransactionId,
          packageName: packageName,
          productId: productId,
          provider: provider,
          purchaseToken: purchaseToken,
          receiptData: receiptData,
          receiptSignature: receiptSignature,
          signedPayload: signedPayload,
          store: store,
          test: test,
          transactionId: transactionId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
