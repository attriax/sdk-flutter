//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'deep_link_resolution_status.g.dart';

class DeepLinkResolutionStatus extends EnumClass {

  @BuiltValueEnumConst(wireName: r'matched')
  static const DeepLinkResolutionStatus matched = _$matched;
  @BuiltValueEnumConst(wireName: r'unmatched')
  static const DeepLinkResolutionStatus unmatched = _$unmatched;
  @BuiltValueEnumConst(wireName: r'invalid')
  static const DeepLinkResolutionStatus invalid = _$invalid;

  static Serializer<DeepLinkResolutionStatus> get serializer => _$deepLinkResolutionStatusSerializer;

  const DeepLinkResolutionStatus._(String name): super(name);

  static BuiltSet<DeepLinkResolutionStatus> get values => _$values;
  static DeepLinkResolutionStatus valueOf(String name) => _$valueOf(name);
}


