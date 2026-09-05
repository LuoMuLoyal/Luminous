//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_settings_request_assistant_context.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateSettingsRequestAssistantContext {
  /// Returns a new [UpdateSettingsRequestAssistantContext] instance.
  UpdateSettingsRequestAssistantContext({
    this.healthProfile,

    this.dailyRecords,

    this.sleepRecords,

    this.currentMedicines,
  });

  /// Allow the assistant to read stored health profile, allergies, and conditions.
  @JsonKey(name: r'healthProfile', required: false, includeIfNull: false)
  final bool? healthProfile;

  /// Allow the assistant to read recent daily records.
  @JsonKey(name: r'dailyRecords', required: false, includeIfNull: false)
  final bool? dailyRecords;

  /// Allow the assistant to read sleep records and summaries.
  @JsonKey(name: r'sleepRecords', required: false, includeIfNull: false)
  final bool? sleepRecords;

  /// Allow the assistant to read current medicines and medicine-box data.
  @JsonKey(name: r'currentMedicines', required: false, includeIfNull: false)
  final bool? currentMedicines;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateSettingsRequestAssistantContext &&
          other.healthProfile == healthProfile &&
          other.dailyRecords == dailyRecords &&
          other.sleepRecords == sleepRecords &&
          other.currentMedicines == currentMedicines;

  @override
  int get hashCode =>
      healthProfile.hashCode +
      dailyRecords.hashCode +
      sleepRecords.hashCode +
      currentMedicines.hashCode;

  factory UpdateSettingsRequestAssistantContext.fromJson(
    Map<String, dynamic> json,
  ) => _$UpdateSettingsRequestAssistantContextFromJson(json);

  Map<String, dynamic> toJson() =>
      _$UpdateSettingsRequestAssistantContextToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
