//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'app_info_data_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AppInfoDataDto {
  /// Returns a new [AppInfoDataDto] instance.
  AppInfoDataDto({
    this.minClientVersion,
    this.latestVersion,
    this.downloadUrl,
    this.supportEmail,
  });

  @JsonKey(name: r'minClientVersion', required: false, includeIfNull: false)
  final String? minClientVersion;

  @JsonKey(name: r'latestVersion', required: false, includeIfNull: false)
  final String? latestVersion;

  @JsonKey(name: r'downloadUrl', required: false, includeIfNull: false)
  final String? downloadUrl;

  @JsonKey(name: r'supportEmail', required: false, includeIfNull: false)
  final String? supportEmail;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppInfoDataDto &&
          other.minClientVersion == minClientVersion &&
          other.latestVersion == latestVersion &&
          other.downloadUrl == downloadUrl &&
          other.supportEmail == supportEmail;

  @override
  int get hashCode =>
      (minClientVersion == null ? 0 : minClientVersion.hashCode) +
      (latestVersion == null ? 0 : latestVersion.hashCode) +
      (downloadUrl == null ? 0 : downloadUrl.hashCode) +
      (supportEmail == null ? 0 : supportEmail.hashCode);

  factory AppInfoDataDto.fromJson(Map<String, dynamic> json) =>
      _$AppInfoDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AppInfoDataDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
