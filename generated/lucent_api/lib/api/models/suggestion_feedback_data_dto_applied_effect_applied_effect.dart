// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

/// Effect applied by the feedback engine
@JsonEnum()
enum SuggestionFeedbackDataDtoAppliedEffectAppliedEffect {
  @JsonValue('boosted_type')
  boostedType('boosted_type'),
  @JsonValue('delayed_until')
  delayedUntil('delayed_until'),
  @JsonValue('suppressed_type')
  suppressedType('suppressed_type'),
  @JsonValue('noted')
  noted('noted'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const SuggestionFeedbackDataDtoAppliedEffectAppliedEffect(this.json);

  factory SuggestionFeedbackDataDtoAppliedEffectAppliedEffect.fromJson(
    String json,
  ) => values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  String toJson() => json ?? 'null';

  @override
  String toString() => json ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<SuggestionFeedbackDataDtoAppliedEffectAppliedEffect>
  get $valuesDefined => values.where((value) => value != $unknown).toList();
}
