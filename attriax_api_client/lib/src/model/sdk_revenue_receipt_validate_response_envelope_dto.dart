//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:attriax_api_client/src/model/sdk_revenue_receipt_validate_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sdk_revenue_receipt_validate_response_envelope_dto.g.dart';

/// SdkRevenueReceiptValidateResponseEnvelopeDto
///
/// Properties:
/// * [data]
/// * [success]
/// * [timestamp]
@BuiltValue()
abstract class SdkRevenueReceiptValidateResponseEnvelopeDto
    implements
        Built<
          SdkRevenueReceiptValidateResponseEnvelopeDto,
          SdkRevenueReceiptValidateResponseEnvelopeDtoBuilder
        > {
  @BuiltValueField(wireName: r'data')
  SdkRevenueReceiptValidateResponseDto get data;

  @BuiltValueField(wireName: r'success')
  bool get success;

  @BuiltValueField(wireName: r'timestamp')
  DateTime get timestamp;

  SdkRevenueReceiptValidateResponseEnvelopeDto._();

  factory SdkRevenueReceiptValidateResponseEnvelopeDto([
    void updates(SdkRevenueReceiptValidateResponseEnvelopeDtoBuilder b),
  ]) = _$SdkRevenueReceiptValidateResponseEnvelopeDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
    SdkRevenueReceiptValidateResponseEnvelopeDtoBuilder b,
  ) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SdkRevenueReceiptValidateResponseEnvelopeDto>
  get serializer => _$SdkRevenueReceiptValidateResponseEnvelopeDtoSerializer();
}

class _$SdkRevenueReceiptValidateResponseEnvelopeDtoSerializer
    implements
        PrimitiveSerializer<SdkRevenueReceiptValidateResponseEnvelopeDto> {
  @override
  final Iterable<Type> types = const [
    SdkRevenueReceiptValidateResponseEnvelopeDto,
    _$SdkRevenueReceiptValidateResponseEnvelopeDto,
  ];

  @override
  final String wireName = r'SdkRevenueReceiptValidateResponseEnvelopeDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SdkRevenueReceiptValidateResponseEnvelopeDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(SdkRevenueReceiptValidateResponseDto),
    );
    yield r'success';
    yield serializers.serialize(
      object.success,
      specifiedType: const FullType(bool),
    );
    yield r'timestamp';
    yield serializers.serialize(
      object.timestamp,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SdkRevenueReceiptValidateResponseEnvelopeDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(
      serializers,
      object,
      specifiedType: specifiedType,
    ).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SdkRevenueReceiptValidateResponseEnvelopeDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(
                      SdkRevenueReceiptValidateResponseDto,
                    ),
                  )
                  as SdkRevenueReceiptValidateResponseDto;
          result.data.replace(valueDes);
          break;
        case r'success':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )
                  as bool;
          result.success = valueDes;
          break;
        case r'timestamp':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime;
          result.timestamp = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SdkRevenueReceiptValidateResponseEnvelopeDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SdkRevenueReceiptValidateResponseEnvelopeDtoBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}
