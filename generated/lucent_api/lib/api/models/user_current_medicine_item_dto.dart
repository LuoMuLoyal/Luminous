// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'medicine_source.dart';

part 'user_current_medicine_item_dto.g.dart';

@JsonSerializable()
class UserCurrentMedicineItemDto {
  const UserCurrentMedicineItemDto({
    required this.id,
    required this.source,
    required this.sourceRefId,
    required this.displayName,
    required this.strengthText,
    required this.doseText,
    required this.route,
    required this.startedAt,
    required this.endedAt,
    required this.isCurrent,
    required this.note,
    required this.sourcePayload,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserCurrentMedicineItemDto.fromJson(Map<String, Object?> json) =>
      _$UserCurrentMedicineItemDtoFromJson(json);

  /// Current medicine id.
  final String id;

  /// Upstream source used to anchor this medicine.
  final MedicineSource source;

  /// Source-specific reference id.
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

  /// Whether the medicine is currently active.
  final bool isCurrent;

  /// User note for the medicine.
  final String? note;

  /// Original source payload stored in jsonb.
  final dynamic sourcePayload;

  /// Created time in ISO 8601 format.
  final String createdAt;

  /// Updated time in ISO 8601 format.
  final String updatedAt;

  Map<String, Object?> toJson() => _$UserCurrentMedicineItemDtoToJson(this);
}
