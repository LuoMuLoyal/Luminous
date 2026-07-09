// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

/// User feedback, if any
@JsonEnum()
enum SuggestionHistoryItemDtoFeedbackFeedback {
  @JsonValue('accepted')
  accepted('accepted'),
  @JsonValue('later')
  later('later'),
  @JsonValue('not_applicable')
  notApplicable('not_applicable'),
  @JsonValue('suppress')
  suppress('suppress'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const SuggestionHistoryItemDtoFeedbackFeedback(this.json);

  factory SuggestionHistoryItemDtoFeedbackFeedback.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  String toJson() => json ?? 'null';

  @override
  String toString() => json ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<SuggestionHistoryItemDtoFeedbackFeedback> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
