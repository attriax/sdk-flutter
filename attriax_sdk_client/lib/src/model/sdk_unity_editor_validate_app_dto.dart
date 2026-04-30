//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sdk_unity_editor_validate_app_dto.g.dart';

/// SdkUnityEditorValidateAppDto
///
/// Properties:
/// * [androidPackageName] 
/// * [id] 
/// * [iosBundleId] 
/// * [name] 
/// * [publicHost] 
@BuiltValue()
abstract class SdkUnityEditorValidateAppDto implements Built<SdkUnityEditorValidateAppDto, SdkUnityEditorValidateAppDtoBuilder> {
  @BuiltValueField(wireName: r'androidPackageName')
  String? get androidPackageName;

  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'iosBundleId')
  String? get iosBundleId;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'publicHost')
  String get publicHost;

  SdkUnityEditorValidateAppDto._();

  factory SdkUnityEditorValidateAppDto([void updates(SdkUnityEditorValidateAppDtoBuilder b)]) = _$SdkUnityEditorValidateAppDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SdkUnityEditorValidateAppDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SdkUnityEditorValidateAppDto> get serializer => _$SdkUnityEditorValidateAppDtoSerializer();
}

class _$SdkUnityEditorValidateAppDtoSerializer implements PrimitiveSerializer<SdkUnityEditorValidateAppDto> {
  @override
  final Iterable<Type> types = const [SdkUnityEditorValidateAppDto, _$SdkUnityEditorValidateAppDto];

  @override
  final String wireName = r'SdkUnityEditorValidateAppDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SdkUnityEditorValidateAppDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.androidPackageName != null) {
      yield r'androidPackageName';
      yield serializers.serialize(
        object.androidPackageName,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    if (object.iosBundleId != null) {
      yield r'iosBundleId';
      yield serializers.serialize(
        object.iosBundleId,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'publicHost';
    yield serializers.serialize(
      object.publicHost,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SdkUnityEditorValidateAppDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SdkUnityEditorValidateAppDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'androidPackageName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.androidPackageName = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'iosBundleId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.iosBundleId = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'publicHost':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.publicHost = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SdkUnityEditorValidateAppDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SdkUnityEditorValidateAppDtoBuilder();
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

