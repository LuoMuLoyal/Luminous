// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'clinic_summary_profile_dto.dart';

part 'clinic_summary_dto.g.dart';

@JsonSerializable()
class ClinicSummaryDto {
  const ClinicSummaryDto({
    required this.generatedAt,
    required this.dataRange,
    required this.profile,
    required this.allergies,
    required this.conditions,
    required this.currentMedicines,
    required this.disclaimer,
    this.findings,
  });

  factory ClinicSummaryDto.fromJson(Map<String, Object?> json) =>
      _$ClinicSummaryDtoFromJson(json);

  /// Generated timestamp
  final String generatedAt;

  /// Data range (e.g. last_30_days)
  final String dataRange;

  /// De-identified profile
  final ClinicSummaryProfileDto profile;

  /// Active allergies
  final List<String> allergies;

  /// Active conditions
  final List<String> conditions;

  /// Current medicines
  final List<String> currentMedicines;

  /// Key findings / notes for the doctor
  final List<String>? findings;

  /// Disclaimer text
  final String disclaimer;

  Map<String, Object?> toJson() => _$ClinicSummaryDtoToJson(this);
}
