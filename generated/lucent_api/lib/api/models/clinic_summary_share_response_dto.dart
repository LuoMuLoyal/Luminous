// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'clinic_summary_share_response_dto.g.dart';

@JsonSerializable()
class ClinicSummaryShareResponseDto {
  const ClinicSummaryShareResponseDto({
    required this.shareUrl,
    required this.expiresAt,
  });

  factory ClinicSummaryShareResponseDto.fromJson(Map<String, Object?> json) =>
      _$ClinicSummaryShareResponseDtoFromJson(json);

  /// Shareable URL
  final String shareUrl;

  /// Expiration time (ISO 8601)
  final String expiresAt;

  Map<String, Object?> toJson() => _$ClinicSummaryShareResponseDtoToJson(this);
}
