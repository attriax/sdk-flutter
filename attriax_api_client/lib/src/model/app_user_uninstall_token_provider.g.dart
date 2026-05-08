// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user_uninstall_token_provider.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AppUserUninstallTokenProvider _$fcm =
    const AppUserUninstallTokenProvider._('fcm');

AppUserUninstallTokenProvider _$valueOf(String name) {
  switch (name) {
    case 'fcm':
      return _$fcm;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AppUserUninstallTokenProvider> _$values =
    BuiltSet<AppUserUninstallTokenProvider>(
      const <AppUserUninstallTokenProvider>[_$fcm],
    );

Serializer<AppUserUninstallTokenProvider>
_$appUserUninstallTokenProviderSerializer =
    _$AppUserUninstallTokenProviderSerializer();

class _$AppUserUninstallTokenProviderSerializer
    implements PrimitiveSerializer<AppUserUninstallTokenProvider> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'fcm': 'fcm',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'fcm': 'fcm',
  };

  @override
  final Iterable<Type> types = const <Type>[AppUserUninstallTokenProvider];
  @override
  final String wireName = 'AppUserUninstallTokenProvider';

  @override
  Object serialize(
    Serializers serializers,
    AppUserUninstallTokenProvider object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AppUserUninstallTokenProvider deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AppUserUninstallTokenProvider.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
