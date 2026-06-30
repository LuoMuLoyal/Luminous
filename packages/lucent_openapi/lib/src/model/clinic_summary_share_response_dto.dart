//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'clinic_summary_share_response_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ClinicSummaryShareResponseDto {
  /// Returns a new [ClinicSummaryShareResponseDto] instance.
  ClinicSummaryShareResponseDto({
    required this.shareUrl,

    required this.expiresAt,
  });

  /// Shareable URL
  @JsonKey(name: r'shareUrl', required: true, includeIfNull: false)
  final String shareUrl;

  /// Expiration time (ISO 8601)
  @JsonKey(name: r'expiresAt', required: true, includeIfNull: false)
  final String expiresAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClinicSummaryShareResponseDto &&
          other.shareUrl == shareUrl &&
          other.expiresAt == expiresAt;

  @override
  int get hashCode => shareUrl.hashCode + expiresAt.hashCode;

  factory ClinicSummaryShareResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ClinicSummaryShareResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ClinicSummaryShareResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
