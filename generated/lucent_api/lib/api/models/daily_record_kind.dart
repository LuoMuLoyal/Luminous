// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum DailyRecordKind {
  @JsonValue('water')
  water('water'),
  @JsonValue('meal')
  meal('meal'),
  @JsonValue('vital')
  vital('vital'),
  @JsonValue('mood')
  mood('mood'),
  @JsonValue('symptom')
  symptom('symptom'),
  @JsonValue('activity')
  activity('activity'),
  @JsonValue('note')
  note('note'),
  @JsonValue('sleep')
  sleep('sleep'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const DailyRecordKind(this.json);

  factory DailyRecordKind.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  String toJson() => json ?? 'null';

  @override
  String toString() => json ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<DailyRecordKind> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
