//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum DailyRecordKind {
  @JsonValue(r'water')
  water(r'water'),
  @JsonValue(r'meal')
  meal(r'meal'),
  @JsonValue(r'vital')
  vital(r'vital'),
  @JsonValue(r'mood')
  mood(r'mood'),
  @JsonValue(r'symptom')
  symptom(r'symptom'),
  @JsonValue(r'activity')
  activity(r'activity'),
  @JsonValue(r'note')
  note(r'note'),
  @JsonValue(r'sleep')
  sleep(r'sleep'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const DailyRecordKind(this.value);

  final String value;

  @override
  String toString() => value;
}
