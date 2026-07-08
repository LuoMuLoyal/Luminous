// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'medicine_source.dart';

part 'create_current_medicine_dto.g.dart';

@JsonSerializable()
class CreateCurrentMedicineDto {
  const CreateCurrentMedicineDto({
    required this.source,
    required this.displayName,
    this.sourceRefId,
    this.strengthText,
    this.doseText,
    this.route,
    this.startedAt,
    this.endedAt,
    this.note,
  });

  factory CreateCurrentMedicineDto.fromJson(Map<String, Object?> json) =>
      _$CreateCurrentMedicineDtoFromJson(json);

  /// Upstream source used to anchor this medicine.
  final MedicineSource source;

  /// Source-specific reference id. Required for drugbank and cn sources.
  final String? sourceRefId;

  /// Display name shown to the user.
  final String displayName;

  /// Strength text.
  final String? strengthText;

  /// Dose text.
  final String? doseText;

  /// Administration route.
  final String? route;

  /// Start date in YYYY-MM-DD format.
  final String? startedAt;

  /// End date in YYYY-MM-DD format.
  final String? endedAt;

  /// User note for the medicine.
  final String? note;

  Map<String, Object?> toJson() => _$CreateCurrentMedicineDtoToJson(this);
}
