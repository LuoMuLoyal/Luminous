//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'app_info_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AppInfoResponse {
  /// Returns a new [AppInfoResponse] instance.
  AppInfoResponse({
    required this.supportEmail,

    required this.minClientVersion,

    required this.latestVersion,

    required this.downloadUrl,
  });

  @JsonKey(name: r'supportEmail', required: true, includeIfNull: true)
  final String? supportEmail;

  @JsonKey(name: r'minClientVersion', required: true, includeIfNull: true)
  final String? minClientVersion;

  @JsonKey(name: r'latestVersion', required: true, includeIfNull: true)
  final String? latestVersion;

  @JsonKey(name: r'downloadUrl', required: true, includeIfNull: true)
  final String? downloadUrl;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppInfoResponse &&
          other.supportEmail == supportEmail &&
          other.minClientVersion == minClientVersion &&
          other.latestVersion == latestVersion &&
          other.downloadUrl == downloadUrl;

  @override
  int get hashCode =>
      (supportEmail == null ? 0 : supportEmail.hashCode) +
      (minClientVersion == null ? 0 : minClientVersion.hashCode) +
      (latestVersion == null ? 0 : latestVersion.hashCode) +
      (downloadUrl == null ? 0 : downloadUrl.hashCode);

  factory AppInfoResponse.fromJson(Map<String, dynamic> json) =>
      _$AppInfoResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AppInfoResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
