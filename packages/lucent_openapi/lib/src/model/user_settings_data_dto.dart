//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'user_settings_data_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UserSettingsDataDto {
  /// Returns a new [UserSettingsDataDto] instance.
  UserSettingsDataDto({
    required this.aiSummariesEnabled,

    required this.dataSharingConsent,

    required this.updatedAt,
  });

  /// Allow AI-generated summaries and advice.
  @JsonKey(name: r'aiSummariesEnabled', required: true, includeIfNull: false)
  final bool aiSummariesEnabled;

  /// Consent to share anonymized data for research.
  @JsonKey(name: r'dataSharingConsent', required: true, includeIfNull: false)
  final bool dataSharingConsent;

  /// ISO-8601 timestamp of last update.
  @JsonKey(name: r'updatedAt', required: true, includeIfNull: true)
  final String? updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettingsDataDto &&
          other.aiSummariesEnabled == aiSummariesEnabled &&
          other.dataSharingConsent == dataSharingConsent &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode =>
      aiSummariesEnabled.hashCode +
      dataSharingConsent.hashCode +
      (updatedAt == null ? 0 : updatedAt.hashCode);

  factory UserSettingsDataDto.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserSettingsDataDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
