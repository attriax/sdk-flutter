//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sdk_unity_editor_validate_checks_dto.g.dart';

/// SdkUnityEditorValidateChecksDto
///
/// Properties:
/// * [androidFingerprintsConfigured] 
/// * [androidPackageConfigured] 
/// * [appTokenValid] 
/// * [iosBundleConfigured] 
/// * [iosTeamConfigured] 
/// * [publicHostResolved] 
@BuiltValue()
abstract class SdkUnityEditorValidateChecksDto implements Built<SdkUnityEditorValidateChecksDto, SdkUnityEditorValidateChecksDtoBuilder> {
  @BuiltValueField(wireName: r'androidFingerprintsConfigured')
  bool get androidFingerprintsConfigured;

  @BuiltValueField(wireName: r'androidPackageConfigured')
  bool get androidPackageConfigured;

  @BuiltValueField(wireName: r'appTokenValid')
  bool get appTokenValid;

  @BuiltValueField(wireName: r'iosBundleConfigured')
  bool get iosBundleConfigured;

  @BuiltValueField(wireName: r'iosTeamConfigured')
  bool get iosTeamConfigured;

  @BuiltValueField(wireName: r'publicHostResolved')
  bool get publicHostResolved;

  SdkUnityEditorValidateChecksDto._();

  factory SdkUnityEditorValidateChecksDto([void updates(SdkUnityEditorValidateChecksDtoBuilder b)]) = _$SdkUnityEditorValidateChecksDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SdkUnityEditorValidateChecksDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SdkUnityEditorValidateChecksDto> get serializer => _$SdkUnityEditorValidateChecksDtoSerializer();
}

class _$SdkUnityEditorValidateChecksDtoSerializer implements PrimitiveSerializer<SdkUnityEditorValidateChecksDto> {
  @override
  final Iterable<Type> types = const [SdkUnityEditorValidateChecksDto, _$SdkUnityEditorValidateChecksDto];

  @override
  final String wireName = r'SdkUnityEditorValidateChecksDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SdkUnityEditorValidateChecksDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'androidFingerprintsConfigured';
    yield serializers.serialize(
      object.androidFingerprintsConfigured,
      specifiedType: const FullType(bool),
    );
    yield r'androidPackageConfigured';
    yield serializers.serialize(
      object.androidPackageConfigured,
      specifiedType: const FullType(bool),
    );
    yield r'appTokenValid';
    yield serializers.serialize(
      object.appTokenValid,
      specifiedType: const FullType(bool),
    );
    yield r'iosBundleConfigured';
    yield serializers.serialize(
      object.iosBundleConfigured,
      specifiedType: const FullType(bool),
    );
    yield r'iosTeamConfigured';
    yield serializers.serialize(
      object.iosTeamConfigured,
      specifiedType: const FullType(bool),
    );
    yield r'publicHostResolved';
    yield serializers.serialize(
      object.publicHostResolved,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SdkUnityEditorValidateChecksDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SdkUnityEditorValidateChecksDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'androidFingerprintsConfigured':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.androidFingerprintsConfigured = valueDes;
          break;
        case r'androidPackageConfigured':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.androidPackageConfigured = valueDes;
          break;
        case r'appTokenValid':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.appTokenValid = valueDes;
          break;
        case r'iosBundleConfigured':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.iosBundleConfigured = valueDes;
          break;
        case r'iosTeamConfigured':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.iosTeamConfigured = valueDes;
          break;
        case r'publicHostResolved':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.publicHostResolved = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SdkUnityEditorValidateChecksDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SdkUnityEditorValidateChecksDtoBuilder();
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

