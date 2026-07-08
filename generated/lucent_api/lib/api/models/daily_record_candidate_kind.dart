// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum DailyRecordCandidateKind {
  @JsonValue('water')
  water('water'),
  @JsonValue('meal')
  meal('meal'),
  @JsonValue('symptom')
  symptom('symptom'),
  @JsonValue('note')
  note('note'),
  @JsonValue('sleep')
  sleep('sleep'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const DailyRecordCandidateKind(this.json);

  factory DailyRecordCandidateKind.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  String toJson() => json ?? 'null';

  @override
  String toString() => json ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<DailyRecordCandidateKind> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
