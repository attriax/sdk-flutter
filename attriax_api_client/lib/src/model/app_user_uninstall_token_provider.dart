//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'app_user_uninstall_token_provider.g.dart';

class AppUserUninstallTokenProvider extends EnumClass {
  @BuiltValueEnumConst(wireName: r'fcm')
  static const AppUserUninstallTokenProvider fcm = _$fcm;
  @BuiltValueEnumConst(wireName: r'apns')
  static const AppUserUninstallTokenProvider apns = _$apns;

  static Serializer<AppUserUninstallTokenProvider> get serializer =>
      _$appUserUninstallTokenProviderSerializer;

  const AppUserUninstallTokenProvider._(String name) : super(name);

  static BuiltSet<AppUserUninstallTokenProvider> get values => _$values;
  static AppUserUninstallTokenProvider valueOf(String name) => _$valueOf(name);
}
