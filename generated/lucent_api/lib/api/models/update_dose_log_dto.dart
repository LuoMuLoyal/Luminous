// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'dose_log_status.dart';

part 'update_dose_log_dto.g.dart';

@JsonSerializable()
class UpdateDoseLogDto {
  const UpdateDoseLogDto({
    required this.status,
    required this.doseText,
    required this.note,
  });

  factory UpdateDoseLogDto.fromJson(Map<String, Object?> json) =>
      _$UpdateDoseLogDtoFromJson(json);

  final DoseLogStatus status;
  final String? doseText;
  final String? note;

  Map<String, Object?> toJson() => _$UpdateDoseLogDtoToJson(this);
}
