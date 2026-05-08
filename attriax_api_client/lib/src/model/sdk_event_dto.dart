//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sdk_event_dto.g.dart';

/// SdkEventDto
///
/// Properties:
/// * [appToken]
/// * [clientOccurredAt]
/// * [deviceId]
/// * [deviceIdSource]
/// * [eventData]
/// * [eventName]
/// * [sessionId]
/// * [sessionRelativeTimeMs] - Milliseconds since the session started.
@BuiltValue()
abstract class SdkEventDto implements Built<SdkEventDto, SdkEventDtoBuilder> {
  @BuiltValueField(wireName: r'appToken')
  String get appToken;

  @BuiltValueField(wireName: r'clientOccurredAt')
  DateTime? get clientOccurredAt;

  @BuiltValueField(wireName: r'deviceId')
  String get deviceId;

  @BuiltValueField(wireName: r'deviceIdSource')
  String? get deviceIdSource;

  @BuiltValueField(wireName: r'eventData')
  BuiltMap<String, JsonObject?>? get eventData;

  @BuiltValueField(wireName: r'eventName')
  String get eventName;

  @BuiltValueField(wireName: r'sessionId')
  String? get sessionId;

  /// Milliseconds since the session started.
  @BuiltValueField(wireName: r'sessionRelativeTimeMs')
  num? get sessionRelativeTimeMs;

  SdkEventDto._();

  factory SdkEventDto([void updates(SdkEventDtoBuilder b)]) = _$SdkEventDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SdkEventDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SdkEventDto> get serializer => _$SdkEventDtoSerializer();
}

class _$SdkEventDtoSerializer implements PrimitiveSerializer<SdkEventDto> {
  @override
  final Iterable<Type> types = const [SdkEventDto, _$SdkEventDto];

  @override
  final String wireName = r'SdkEventDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SdkEventDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'appToken';
    yield serializers.serialize(
      object.appToken,
      specifiedType: const FullType(String),
    );
    if (object.clientOccurredAt != null) {
      yield r'clientOccurredAt';
      yield serializers.serialize(
        object.clientOccurredAt,
        specifiedType: const FullType(DateTime),
      );
    }
    yield r'deviceId';
    yield serializers.serialize(
      object.deviceId,
      specifiedType: const FullType(String),
    );
    if (object.deviceIdSource != null) {
      yield r'deviceIdSource';
      yield serializers.serialize(
        object.deviceIdSource,
        specifiedType: const FullType(String),
      );
    }
    if (object.eventData != null) {
      yield r'eventData';
      yield serializers.serialize(
        object.eventData,
        specifiedType: const FullType(BuiltMap, [
          FullType(String),
          FullType.nullable(JsonObject),
        ]),
      );
    }
    yield r'eventName';
    yield serializers.serialize(
      object.eventName,
      specifiedType: const FullType(String),
    );
    if (object.sessionId != null) {
      yield r'sessionId';
      yield serializers.serialize(
        object.sessionId,
        specifiedType: const FullType(String),
      );
    }
    if (object.sessionRelativeTimeMs != null) {
      yield r'sessionRelativeTimeMs';
      yield serializers.serialize(
        object.sessionRelativeTimeMs,
        specifiedType: const FullType(num),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SdkEventDto object, {
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
    required SdkEventDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'appToken':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.appToken = valueDes;
          break;
        case r'clientOccurredAt':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime;
          result.clientOccurredAt = valueDes;
          break;
        case r'deviceId':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.deviceId = valueDes;
          break;
        case r'deviceIdSource':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.deviceIdSource = valueDes;
          break;
        case r'eventData':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltMap, [
                      FullType(String),
                      FullType.nullable(JsonObject),
                    ]),
                  )
                  as BuiltMap<String, JsonObject?>;
          result.eventData.replace(valueDes);
          break;
        case r'eventName':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.eventName = valueDes;
          break;
        case r'sessionId':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.sessionId = valueDes;
          break;
        case r'sessionRelativeTimeMs':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(num))
                  as num;
          result.sessionRelativeTimeMs = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SdkEventDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SdkEventDtoBuilder();
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
