//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sdk_unity_editor_validate_editor_dto.g.dart';

/// SdkUnityEditorValidateEditorDto
///
/// Properties:
/// * [hostPlatform] 
/// * [packageVersion] 
/// * [unityVersion] 
@BuiltValue()
abstract class SdkUnityEditorValidateEditorDto implements Built<SdkUnityEditorValidateEditorDto, SdkUnityEditorValidateEditorDtoBuilder> {
  @BuiltValueField(wireName: r'hostPlatform')
  String? get hostPlatform;

  @BuiltValueField(wireName: r'packageVersion')
  String? get packageVersion;

  @BuiltValueField(wireName: r'unityVersion')
  String? get unityVersion;

  SdkUnityEditorValidateEditorDto._();

  factory SdkUnityEditorValidateEditorDto([void updates(SdkUnityEditorValidateEditorDtoBuilder b)]) = _$SdkUnityEditorValidateEditorDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SdkUnityEditorValidateEditorDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SdkUnityEditorValidateEditorDto> get serializer => _$SdkUnityEditorValidateEditorDtoSerializer();
}

class _$SdkUnityEditorValidateEditorDtoSerializer implements PrimitiveSerializer<SdkUnityEditorValidateEditorDto> {
  @override
  final Iterable<Type> types = const [SdkUnityEditorValidateEditorDto, _$SdkUnityEditorValidateEditorDto];

  @override
  final String wireName = r'SdkUnityEditorValidateEditorDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SdkUnityEditorValidateEditorDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.hostPlatform != null) {
      yield r'hostPlatform';
      yield serializers.serialize(
        object.hostPlatform,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.packageVersion != null) {
      yield r'packageVersion';
      yield serializers.serialize(
        object.packageVersion,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.unityVersion != null) {
      yield r'unityVersion';
      yield serializers.serialize(
        object.unityVersion,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SdkUnityEditorValidateEditorDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SdkUnityEditorValidateEditorDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'hostPlatform':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.hostPlatform = valueDes;
          break;
        case r'packageVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.packageVersion = valueDes;
          break;
        case r'unityVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.unityVersion = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SdkUnityEditorValidateEditorDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SdkUnityEditorValidateEditorDtoBuilder();
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

