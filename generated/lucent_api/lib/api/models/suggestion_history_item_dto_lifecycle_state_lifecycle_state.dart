// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

/// Lifecycle state
@JsonEnum()
enum SuggestionHistoryItemDtoLifecycleStateLifecycleState {
  @JsonValue('generated')
  generated('generated'),
  @JsonValue('active')
  active('active'),
  @JsonValue('fading')
  fading('fading'),
  @JsonValue('expired')
  expired('expired'),
  @JsonValue('dismissed')
  dismissed('dismissed'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const SuggestionHistoryItemDtoLifecycleStateLifecycleState(this.json);

  factory SuggestionHistoryItemDtoLifecycleStateLifecycleState.fromJson(
    String json,
  ) => values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  String toJson() => json ?? 'null';

  @override
  String toString() => json ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<SuggestionHistoryItemDtoLifecycleStateLifecycleState>
  get $valuesDefined => values.where((value) => value != $unknown).toList();
}
