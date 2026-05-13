// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_install_state.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SdkInstallState _$existing = const SdkInstallState._('existing');
const SdkInstallState _$newInstall = const SdkInstallState._('newInstall');
const SdkInstallState _$reinstall = const SdkInstallState._('reinstall');
const SdkInstallState _$appDataClear = const SdkInstallState._('appDataClear');

SdkInstallState _$valueOf(String name) {
  switch (name) {
    case 'existing':
      return _$existing;
    case 'newInstall':
      return _$newInstall;
    case 'reinstall':
      return _$reinstall;
    case 'appDataClear':
      return _$appDataClear;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<SdkInstallState> _$values = BuiltSet<SdkInstallState>(
  const <SdkInstallState>[
    _$existing,
    _$newInstall,
    _$reinstall,
    _$appDataClear,
  ],
);

Serializer<SdkInstallState> _$sdkInstallStateSerializer =
    _$SdkInstallStateSerializer();

class _$SdkInstallStateSerializer
    implements PrimitiveSerializer<SdkInstallState> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'existing': 'existing',
    'newInstall': 'new_install',
    'reinstall': 'reinstall',
    'appDataClear': 'app_data_clear',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'existing': 'existing',
    'new_install': 'newInstall',
    'reinstall': 'reinstall',
    'app_data_clear': 'appDataClear',
  };

  @override
  final Iterable<Type> types = const <Type>[SdkInstallState];
  @override
  final String wireName = 'SdkInstallState';

  @override
  Object serialize(
    Serializers serializers,
    SdkInstallState object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  SdkInstallState deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => SdkInstallState.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
