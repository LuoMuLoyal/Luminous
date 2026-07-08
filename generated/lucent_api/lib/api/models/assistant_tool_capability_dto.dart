// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'assistant_tool_capability_dto_disabled_reason_disabled_reason.dart';
import 'assistant_tool_capability_dto_name_name.dart';

part 'assistant_tool_capability_dto.g.dart';

@JsonSerializable()
class AssistantToolCapabilityDto {
  const AssistantToolCapabilityDto({
    required this.name,
    required this.requiredContextSources,
    required this.permittedByUser,
    required this.enabled,
    required this.implemented,
    required this.disabledReason,
  });

  factory AssistantToolCapabilityDto.fromJson(Map<String, Object?> json) =>
      _$AssistantToolCapabilityDtoFromJson(json);

  /// Stable tool identifier exposed to the client.
  final AssistantToolCapabilityDtoNameName name;

  /// Context sources this tool requires before it may run. Allowed values: health_profile, daily_records, sleep_records, current_medicines.
  final List<String> requiredContextSources;

  /// Whether the current user settings permit this tool in principle.
  final bool permittedByUser;

  /// Whether this tool is currently executable for this user.
  final bool enabled;

  /// Whether the server has already implemented this tool beyond planning/foundation wiring.
  final bool implemented;

  /// Why the tool is currently disabled, or null when enabled.
  final AssistantToolCapabilityDtoDisabledReasonDisabledReason? disabledReason;

  Map<String, Object?> toJson() => _$AssistantToolCapabilityDtoToJson(this);
}
