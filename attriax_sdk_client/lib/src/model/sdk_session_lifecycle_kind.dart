//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sdk_session_lifecycle_kind.g.dart';

class SdkSessionLifecycleKind extends EnumClass {

  @BuiltValueEnumConst(wireName: r'start')
  static const SdkSessionLifecycleKind start = _$start;
  @BuiltValueEnumConst(wireName: r'heartbeat')
  static const SdkSessionLifecycleKind heartbeat = _$heartbeat;
  @BuiltValueEnumConst(wireName: r'pause')
  static const SdkSessionLifecycleKind pause = _$pause;
  @BuiltValueEnumConst(wireName: r'resume')
  static const SdkSessionLifecycleKind resume = _$resume;
  @BuiltValueEnumConst(wireName: r'end')
  static const SdkSessionLifecycleKind end = _$end;

  static Serializer<SdkSessionLifecycleKind> get serializer => _$sdkSessionLifecycleKindSerializer;

  const SdkSessionLifecycleKind._(String name): super(name);

  static BuiltSet<SdkSessionLifecycleKind> get values => _$values;
  static SdkSessionLifecycleKind valueOf(String name) => _$valueOf(name);
}


