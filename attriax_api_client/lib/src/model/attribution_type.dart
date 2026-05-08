//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'attribution_type.g.dart';

class AttributionType extends EnumClass {
  /// Attribution source classification for the install-referrer payload. Current platform install-referrer parsing reports `referrer`; `external` is reserved for future provider-based payloads.
  @BuiltValueEnumConst(wireName: r'referrer')
  static const AttributionType referrer = _$referrer;

  /// Attribution source classification for the install-referrer payload. Current platform install-referrer parsing reports `referrer`; `external` is reserved for future provider-based payloads.
  @BuiltValueEnumConst(wireName: r'fingerprint')
  static const AttributionType fingerprint = _$fingerprint;

  /// Attribution source classification for the install-referrer payload. Current platform install-referrer parsing reports `referrer`; `external` is reserved for future provider-based payloads.
  @BuiltValueEnumConst(wireName: r'external')
  static const AttributionType external_ = _$external_;

  /// Attribution source classification for the install-referrer payload. Current platform install-referrer parsing reports `referrer`; `external` is reserved for future provider-based payloads.
  @BuiltValueEnumConst(wireName: r'organic')
  static const AttributionType organic = _$organic;

  static Serializer<AttributionType> get serializer =>
      _$attributionTypeSerializer;

  const AttributionType._(String name) : super(name);

  static BuiltSet<AttributionType> get values => _$values;
  static AttributionType valueOf(String name) => _$valueOf(name);
}
