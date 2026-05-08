//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'device_context_dto.g.dart';

/// DeviceContextDto
///
/// Properties:
/// * [advertisingId]
/// * [androidId]
/// * [brand]
/// * [colorDepth]
/// * [devicePixelRatio]
/// * [hardware]
/// * [isPhysicalDevice]
/// * [language]
/// * [manufacturer]
/// * [metadata]
/// * [model]
/// * [name]
/// * [osVersion]
/// * [screenHeight]
/// * [screenResolution]
/// * [screenWidth]
/// * [supportedAbis]
/// * [timezone]
@BuiltValue()
abstract class DeviceContextDto
    implements Built<DeviceContextDto, DeviceContextDtoBuilder> {
  @BuiltValueField(wireName: r'advertisingId')
  String? get advertisingId;

  @BuiltValueField(wireName: r'androidId')
  String? get androidId;

  @BuiltValueField(wireName: r'brand')
  String? get brand;

  @BuiltValueField(wireName: r'colorDepth')
  num? get colorDepth;

  @BuiltValueField(wireName: r'devicePixelRatio')
  num? get devicePixelRatio;

  @BuiltValueField(wireName: r'hardware')
  String? get hardware;

  @BuiltValueField(wireName: r'isPhysicalDevice')
  bool? get isPhysicalDevice;

  @BuiltValueField(wireName: r'language')
  String? get language;

  @BuiltValueField(wireName: r'manufacturer')
  String? get manufacturer;

  @BuiltValueField(wireName: r'metadata')
  BuiltMap<String, JsonObject?>? get metadata;

  @BuiltValueField(wireName: r'model')
  String? get model;

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'osVersion')
  String? get osVersion;

  @BuiltValueField(wireName: r'screenHeight')
  num? get screenHeight;

  @BuiltValueField(wireName: r'screenResolution')
  String? get screenResolution;

  @BuiltValueField(wireName: r'screenWidth')
  num? get screenWidth;

  @BuiltValueField(wireName: r'supportedAbis')
  BuiltList<String>? get supportedAbis;

  @BuiltValueField(wireName: r'timezone')
  String? get timezone;

  DeviceContextDto._();

  factory DeviceContextDto([void updates(DeviceContextDtoBuilder b)]) =
      _$DeviceContextDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DeviceContextDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DeviceContextDto> get serializer =>
      _$DeviceContextDtoSerializer();
}

class _$DeviceContextDtoSerializer
    implements PrimitiveSerializer<DeviceContextDto> {
  @override
  final Iterable<Type> types = const [DeviceContextDto, _$DeviceContextDto];

  @override
  final String wireName = r'DeviceContextDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DeviceContextDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.advertisingId != null) {
      yield r'advertisingId';
      yield serializers.serialize(
        object.advertisingId,
        specifiedType: const FullType(String),
      );
    }
    if (object.androidId != null) {
      yield r'androidId';
      yield serializers.serialize(
        object.androidId,
        specifiedType: const FullType(String),
      );
    }
    if (object.brand != null) {
      yield r'brand';
      yield serializers.serialize(
        object.brand,
        specifiedType: const FullType(String),
      );
    }
    if (object.colorDepth != null) {
      yield r'colorDepth';
      yield serializers.serialize(
        object.colorDepth,
        specifiedType: const FullType(num),
      );
    }
    if (object.devicePixelRatio != null) {
      yield r'devicePixelRatio';
      yield serializers.serialize(
        object.devicePixelRatio,
        specifiedType: const FullType(num),
      );
    }
    if (object.hardware != null) {
      yield r'hardware';
      yield serializers.serialize(
        object.hardware,
        specifiedType: const FullType(String),
      );
    }
    if (object.isPhysicalDevice != null) {
      yield r'isPhysicalDevice';
      yield serializers.serialize(
        object.isPhysicalDevice,
        specifiedType: const FullType(bool),
      );
    }
    if (object.language != null) {
      yield r'language';
      yield serializers.serialize(
        object.language,
        specifiedType: const FullType(String),
      );
    }
    if (object.manufacturer != null) {
      yield r'manufacturer';
      yield serializers.serialize(
        object.manufacturer,
        specifiedType: const FullType(String),
      );
    }
    if (object.metadata != null) {
      yield r'metadata';
      yield serializers.serialize(
        object.metadata,
        specifiedType: const FullType(BuiltMap, [
          FullType(String),
          FullType.nullable(JsonObject),
        ]),
      );
    }
    if (object.model != null) {
      yield r'model';
      yield serializers.serialize(
        object.model,
        specifiedType: const FullType(String),
      );
    }
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.osVersion != null) {
      yield r'osVersion';
      yield serializers.serialize(
        object.osVersion,
        specifiedType: const FullType(String),
      );
    }
    if (object.screenHeight != null) {
      yield r'screenHeight';
      yield serializers.serialize(
        object.screenHeight,
        specifiedType: const FullType(num),
      );
    }
    if (object.screenResolution != null) {
      yield r'screenResolution';
      yield serializers.serialize(
        object.screenResolution,
        specifiedType: const FullType(String),
      );
    }
    if (object.screenWidth != null) {
      yield r'screenWidth';
      yield serializers.serialize(
        object.screenWidth,
        specifiedType: const FullType(num),
      );
    }
    if (object.supportedAbis != null) {
      yield r'supportedAbis';
      yield serializers.serialize(
        object.supportedAbis,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
    if (object.timezone != null) {
      yield r'timezone';
      yield serializers.serialize(
        object.timezone,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    DeviceContextDto object, {
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
    required DeviceContextDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'advertisingId':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.advertisingId = valueDes;
          break;
        case r'androidId':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.androidId = valueDes;
          break;
        case r'brand':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.brand = valueDes;
          break;
        case r'colorDepth':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(num))
                  as num;
          result.colorDepth = valueDes;
          break;
        case r'devicePixelRatio':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(num))
                  as num;
          result.devicePixelRatio = valueDes;
          break;
        case r'hardware':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.hardware = valueDes;
          break;
        case r'isPhysicalDevice':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )
                  as bool;
          result.isPhysicalDevice = valueDes;
          break;
        case r'language':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.language = valueDes;
          break;
        case r'manufacturer':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.manufacturer = valueDes;
          break;
        case r'metadata':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltMap, [
                      FullType(String),
                      FullType.nullable(JsonObject),
                    ]),
                  )
                  as BuiltMap<String, JsonObject?>;
          result.metadata.replace(valueDes);
          break;
        case r'model':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.model = valueDes;
          break;
        case r'name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.name = valueDes;
          break;
        case r'osVersion':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.osVersion = valueDes;
          break;
        case r'screenHeight':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(num))
                  as num;
          result.screenHeight = valueDes;
          break;
        case r'screenResolution':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.screenResolution = valueDes;
          break;
        case r'screenWidth':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(num))
                  as num;
          result.screenWidth = valueDes;
          break;
        case r'supportedAbis':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltList, [
                      FullType(String),
                    ]),
                  )
                  as BuiltList<String>;
          result.supportedAbis.replace(valueDes);
          break;
        case r'timezone':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.timezone = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DeviceContextDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DeviceContextDtoBuilder();
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
