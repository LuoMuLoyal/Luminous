// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'medicine_source.dart';

part 'update_current_medicine_dto.g.dart';

@JsonSerializable()
class UpdateCurrentMedicineDto {
  const UpdateCurrentMedicineDto({
    required this.source,
    required this.sourceRefId,
    required this.displayName,
    required this.strengthText,
    required this.doseText,
    required this.route,
    required this.startedAt,
    required this.endedAt,
    required this.note,
    required this.isCurrent,
  });

  factory UpdateCurrentMedicineDto.fromJson(Map<String, Object?> json) =>
      _$UpdateCurrentMedicineDtoFromJson(json);

  /// Upstream source.
  final MedicineSource source;

  /// Source-specific reference id.
  final String? sourceRefId;

  /// Display name shown to the user.
  final String displayName;

  /// Strength text. Use null to clear.
  final String? strengthText;

  /// Dose text. Use null to clear.
  final String? doseText;

  /// Administration route. Use null to clear.
  final String? route;

  /// Start date in YYYY-MM-DD format. Use null to clear.
  final String? startedAt;

  /// End date in YYYY-MM-DD format. Use null to clear.
  final String? endedAt;

  /// User note. Use null to clear.
  final String? note;

  /// Whether the medicine is currently active.
  final bool isCurrent;

  Map<String, Object?> toJson() => _$UpdateCurrentMedicineDtoToJson(this);
}
