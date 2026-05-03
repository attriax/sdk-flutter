//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sdk_batch_item_kind.g.dart';

class SdkBatchItemKind extends EnumClass {

  @BuiltValueEnumConst(wireName: r'event')
  static const SdkBatchItemKind event = _$event;
  @BuiltValueEnumConst(wireName: r'session')
  static const SdkBatchItemKind session = _$session;
  @BuiltValueEnumConst(wireName: r'identify')
  static const SdkBatchItemKind identify = _$identify;

  static Serializer<SdkBatchItemKind> get serializer => _$sdkBatchItemKindSerializer;

  const SdkBatchItemKind._(String name): super(name);

  static BuiltSet<SdkBatchItemKind> get values => _$values;
  static SdkBatchItemKind valueOf(String name) => _$valueOf(name);
}


