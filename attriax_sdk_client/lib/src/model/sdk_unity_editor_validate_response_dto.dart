//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:attriax_sdk_client/src/model/sdk_unity_editor_validate_app_dto.dart';
import 'package:attriax_sdk_client/src/model/sdk_unity_editor_validate_checks_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:attriax_sdk_client/src/model/sdk_unity_editor_validate_editor_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sdk_unity_editor_validate_response_dto.g.dart';

/// SdkUnityEditorValidateResponseDto
///
/// Properties:
/// * [acceptedAt] 
/// * [app] 
/// * [checks] 
/// * [editor] 
/// * [ok] 
/// * [requestVersion] 
/// * [warnings] 
@BuiltValue()
abstract class SdkUnityEditorValidateResponseDto implements Built<SdkUnityEditorValidateResponseDto, SdkUnityEditorValidateResponseDtoBuilder> {
  @BuiltValueField(wireName: r'acceptedAt')
  DateTime get acceptedAt;

  @BuiltValueField(wireName: r'app')
  SdkUnityEditorValidateAppDto get app;

  @BuiltValueField(wireName: r'checks')
  SdkUnityEditorValidateChecksDto get checks;

  @BuiltValueField(wireName: r'editor')
  SdkUnityEditorValidateEditorDto get editor;

  @BuiltValueField(wireName: r'ok')
  bool get ok;

  @BuiltValueField(wireName: r'requestVersion')
  String get requestVersion;

  @BuiltValueField(wireName: r'warnings')
  BuiltList<String> get warnings;

  SdkUnityEditorValidateResponseDto._();

  factory SdkUnityEditorValidateResponseDto([void updates(SdkUnityEditorValidateResponseDtoBuilder b)]) = _$SdkUnityEditorValidateResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SdkUnityEditorValidateResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SdkUnityEditorValidateResponseDto> get serializer => _$SdkUnityEditorValidateResponseDtoSerializer();
}

class _$SdkUnityEditorValidateResponseDtoSerializer implements PrimitiveSerializer<SdkUnityEditorValidateResponseDto> {
  @override
  final Iterable<Type> types = const [SdkUnityEditorValidateResponseDto, _$SdkUnityEditorValidateResponseDto];

  @override
  final String wireName = r'SdkUnityEditorValidateResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SdkUnityEditorValidateResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'acceptedAt';
    yield serializers.serialize(
      object.acceptedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'app';
    yield serializers.serialize(
      object.app,
      specifiedType: const FullType(SdkUnityEditorValidateAppDto),
    );
    yield r'checks';
    yield serializers.serialize(
      object.checks,
      specifiedType: const FullType(SdkUnityEditorValidateChecksDto),
    );
    yield r'editor';
    yield serializers.serialize(
      object.editor,
      specifiedType: const FullType(SdkUnityEditorValidateEditorDto),
    );
    yield r'ok';
    yield serializers.serialize(
      object.ok,
      specifiedType: const FullType(bool),
    );
    yield r'requestVersion';
    yield serializers.serialize(
      object.requestVersion,
      specifiedType: const FullType(String),
    );
    yield r'warnings';
    yield serializers.serialize(
      object.warnings,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SdkUnityEditorValidateResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SdkUnityEditorValidateResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'acceptedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.acceptedAt = valueDes;
          break;
        case r'app':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SdkUnityEditorValidateAppDto),
          ) as SdkUnityEditorValidateAppDto;
          result.app.replace(valueDes);
          break;
        case r'checks':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SdkUnityEditorValidateChecksDto),
          ) as SdkUnityEditorValidateChecksDto;
          result.checks.replace(valueDes);
          break;
        case r'editor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SdkUnityEditorValidateEditorDto),
          ) as SdkUnityEditorValidateEditorDto;
          result.editor.replace(valueDes);
          break;
        case r'ok':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.ok = valueDes;
          break;
        case r'requestVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.requestVersion = valueDes;
          break;
        case r'warnings':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.warnings.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SdkUnityEditorValidateResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SdkUnityEditorValidateResponseDtoBuilder();
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

