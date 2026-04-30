//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sdk_v1_unity_editor_validate_dto.g.dart';

/// SdkV1UnityEditorValidateDto
///
/// Properties:
/// * [appToken] 
/// * [editorHostPlatform] 
/// * [packageVersion] 
/// * [unityVersion] 
@BuiltValue()
abstract class SdkV1UnityEditorValidateDto implements Built<SdkV1UnityEditorValidateDto, SdkV1UnityEditorValidateDtoBuilder> {
  @BuiltValueField(wireName: r'appToken')
  String get appToken;

  @BuiltValueField(wireName: r'editorHostPlatform')
  String? get editorHostPlatform;

  @BuiltValueField(wireName: r'packageVersion')
  String? get packageVersion;

  @BuiltValueField(wireName: r'unityVersion')
  String? get unityVersion;

  SdkV1UnityEditorValidateDto._();

  factory SdkV1UnityEditorValidateDto([void updates(SdkV1UnityEditorValidateDtoBuilder b)]) = _$SdkV1UnityEditorValidateDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SdkV1UnityEditorValidateDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SdkV1UnityEditorValidateDto> get serializer => _$SdkV1UnityEditorValidateDtoSerializer();
}

class _$SdkV1UnityEditorValidateDtoSerializer implements PrimitiveSerializer<SdkV1UnityEditorValidateDto> {
  @override
  final Iterable<Type> types = const [SdkV1UnityEditorValidateDto, _$SdkV1UnityEditorValidateDto];

  @override
  final String wireName = r'SdkV1UnityEditorValidateDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SdkV1UnityEditorValidateDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'appToken';
    yield serializers.serialize(
      object.appToken,
      specifiedType: const FullType(String),
    );
    if (object.editorHostPlatform != null) {
      yield r'editorHostPlatform';
      yield serializers.serialize(
        object.editorHostPlatform,
        specifiedType: const FullType(String),
      );
    }
    if (object.packageVersion != null) {
      yield r'packageVersion';
      yield serializers.serialize(
        object.packageVersion,
        specifiedType: const FullType(String),
      );
    }
    if (object.unityVersion != null) {
      yield r'unityVersion';
      yield serializers.serialize(
        object.unityVersion,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SdkV1UnityEditorValidateDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SdkV1UnityEditorValidateDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'appToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.appToken = valueDes;
          break;
        case r'editorHostPlatform':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.editorHostPlatform = valueDes;
          break;
        case r'packageVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.packageVersion = valueDes;
          break;
        case r'unityVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
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
  SdkV1UnityEditorValidateDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SdkV1UnityEditorValidateDtoBuilder();
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

