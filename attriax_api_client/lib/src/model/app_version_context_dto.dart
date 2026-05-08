//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'app_version_context_dto.g.dart';

/// AppVersionContextDto
///
/// Properties:
/// * [buildNumber]
/// * [packageName]
/// * [version]
@BuiltValue()
abstract class AppVersionContextDto
    implements Built<AppVersionContextDto, AppVersionContextDtoBuilder> {
  @BuiltValueField(wireName: r'buildNumber')
  String? get buildNumber;

  @BuiltValueField(wireName: r'packageName')
  String? get packageName;

  @BuiltValueField(wireName: r'version')
  String? get version;

  AppVersionContextDto._();

  factory AppVersionContextDto([void updates(AppVersionContextDtoBuilder b)]) =
      _$AppVersionContextDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AppVersionContextDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AppVersionContextDto> get serializer =>
      _$AppVersionContextDtoSerializer();
}

class _$AppVersionContextDtoSerializer
    implements PrimitiveSerializer<AppVersionContextDto> {
  @override
  final Iterable<Type> types = const [
    AppVersionContextDto,
    _$AppVersionContextDto,
  ];

  @override
  final String wireName = r'AppVersionContextDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AppVersionContextDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.buildNumber != null) {
      yield r'buildNumber';
      yield serializers.serialize(
        object.buildNumber,
        specifiedType: const FullType(String),
      );
    }
    if (object.packageName != null) {
      yield r'packageName';
      yield serializers.serialize(
        object.packageName,
        specifiedType: const FullType(String),
      );
    }
    if (object.version != null) {
      yield r'version';
      yield serializers.serialize(
        object.version,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AppVersionContextDto object, {
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
    required AppVersionContextDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'buildNumber':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.buildNumber = valueDes;
          break;
        case r'packageName':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.packageName = valueDes;
          break;
        case r'version':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.version = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AppVersionContextDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AppVersionContextDtoBuilder();
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
