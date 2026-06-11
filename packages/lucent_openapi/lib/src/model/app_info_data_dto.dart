//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'app_info_data_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AppInfoDataDto {
  /// Returns a new [AppInfoDataDto] instance.
  AppInfoDataDto({
    required this.name,

    required this.version,

    required this.description,

    required this.buildDate,

    this.minClientVersion,

    this.supportEmail,

    this.privacyPolicyUrl,

    this.termsOfServiceUrl,
  });

  @JsonKey(name: r'name', required: true, includeIfNull: false)
  final String name;

  @JsonKey(name: r'version', required: true, includeIfNull: false)
  final String version;

  @JsonKey(name: r'description', required: true, includeIfNull: false)
  final String description;

  /// ISO-8601 build/publish timestamp.
  @JsonKey(name: r'buildDate', required: true, includeIfNull: false)
  final String buildDate;

  @JsonKey(name: r'minClientVersion', required: false, includeIfNull: false)
  final String? minClientVersion;

  @JsonKey(name: r'supportEmail', required: false, includeIfNull: false)
  final String? supportEmail;

  @JsonKey(name: r'privacyPolicyUrl', required: false, includeIfNull: false)
  final String? privacyPolicyUrl;

  @JsonKey(name: r'termsOfServiceUrl', required: false, includeIfNull: false)
  final String? termsOfServiceUrl;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppInfoDataDto &&
          other.name == name &&
          other.version == version &&
          other.description == description &&
          other.buildDate == buildDate &&
          other.minClientVersion == minClientVersion &&
          other.supportEmail == supportEmail &&
          other.privacyPolicyUrl == privacyPolicyUrl &&
          other.termsOfServiceUrl == termsOfServiceUrl;

  @override
  int get hashCode =>
      name.hashCode +
      version.hashCode +
      description.hashCode +
      buildDate.hashCode +
      (minClientVersion == null ? 0 : minClientVersion.hashCode) +
      (supportEmail == null ? 0 : supportEmail.hashCode) +
      (privacyPolicyUrl == null ? 0 : privacyPolicyUrl.hashCode) +
      (termsOfServiceUrl == null ? 0 : termsOfServiceUrl.hashCode);

  factory AppInfoDataDto.fromJson(Map<String, dynamic> json) =>
      _$AppInfoDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AppInfoDataDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
