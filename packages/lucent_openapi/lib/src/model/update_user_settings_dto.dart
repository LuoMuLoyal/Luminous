//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'update_user_settings_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateUserSettingsDto {
  /// Returns a new [UpdateUserSettingsDto] instance.
  UpdateUserSettingsDto({this.aiSummariesEnabled, this.dataSharingConsent});

  /// Allow AI-generated summaries and advice.
  @JsonKey(name: r'aiSummariesEnabled', required: false, includeIfNull: false)
  final bool? aiSummariesEnabled;

  /// Consent to share anonymized data for research.
  @JsonKey(name: r'dataSharingConsent', required: false, includeIfNull: false)
  final bool? dataSharingConsent;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateUserSettingsDto &&
          other.aiSummariesEnabled == aiSummariesEnabled &&
          other.dataSharingConsent == dataSharingConsent;

  @override
  int get hashCode => aiSummariesEnabled.hashCode + dataSharingConsent.hashCode;

  factory UpdateUserSettingsDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateUserSettingsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateUserSettingsDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
