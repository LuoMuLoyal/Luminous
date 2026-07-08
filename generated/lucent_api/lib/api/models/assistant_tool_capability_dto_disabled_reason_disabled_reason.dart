// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

/// Why the tool is currently disabled, or null when enabled.
@JsonEnum()
enum AssistantToolCapabilityDtoDisabledReasonDisabledReason {
  @JsonValue('chat_disabled')
  chatDisabled('chat_disabled'),
  @JsonValue('context_disabled')
  contextDisabled('context_disabled'),
  @JsonValue('model_not_configured')
  modelNotConfigured('model_not_configured'),
  @JsonValue('not_implemented')
  notImplemented('not_implemented'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const AssistantToolCapabilityDtoDisabledReasonDisabledReason(this.json);

  factory AssistantToolCapabilityDtoDisabledReasonDisabledReason.fromJson(
    String json,
  ) => values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  String toJson() => json ?? 'null';

  @override
  String toString() => json ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<AssistantToolCapabilityDtoDisabledReasonDisabledReason>
  get $valuesDefined => values.where((value) => value != $unknown).toList();
}
