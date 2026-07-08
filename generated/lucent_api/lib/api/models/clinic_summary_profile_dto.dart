// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'clinic_summary_profile_dto.g.dart';

@JsonSerializable()
class ClinicSummaryProfileDto {
  const ClinicSummaryProfileDto({
    required this.nickname,
    required this.sexAtBirth,
    this.age,
    this.bloodType,
  });

  factory ClinicSummaryProfileDto.fromJson(Map<String, Object?> json) =>
      _$ClinicSummaryProfileDtoFromJson(json);

  /// Masked display name (e.g. 张**)
  final String nickname;

  /// Age in years (derived from birthDate, never raw date)
  final num? age;

  /// Sex at birth
  final String? sexAtBirth;

  /// Blood type
  final String? bloodType;

  Map<String, Object?> toJson() => _$ClinicSummaryProfileDtoToJson(this);
}
