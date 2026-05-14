//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum SdkSessionLifecycleKind {
  @JsonValue(r'start')
  start(r'start'),
  @JsonValue(r'heartbeat')
  heartbeat(r'heartbeat'),
  @JsonValue(r'pause')
  pause(r'pause'),
  @JsonValue(r'resume')
  resume(r'resume'),
  @JsonValue(r'end')
  end(r'end');

  const SdkSessionLifecycleKind(this.value);

  final String value;

  @override
  String toString() => value;
}
