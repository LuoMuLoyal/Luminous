// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

/// Visual tone hint
@JsonEnum()
enum SuggestionItemDtoCardToneCardTone {
  @JsonValue('urgent')
  urgent('urgent'),
  @JsonValue('warning')
  warning('warning'),
  @JsonValue('emphasis')
  emphasis('emphasis'),
  @JsonValue('soft')
  soft('soft'),
  @JsonValue('neutral')
  neutral('neutral'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const SuggestionItemDtoCardToneCardTone(this.json);

  factory SuggestionItemDtoCardToneCardTone.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  String toJson() => json ?? 'null';

  @override
  String toString() => json ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<SuggestionItemDtoCardToneCardTone> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
