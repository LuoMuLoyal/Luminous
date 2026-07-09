// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'evidence_item_dto_kind_kind.dart';

part 'evidence_item_dto.g.dart';

@JsonSerializable()
class EvidenceItemDto {
  const EvidenceItemDto({
    required this.kind,
    required this.label,
    required this.value,
    this.recordId,
    this.medicineId,
  });

  factory EvidenceItemDto.fromJson(Map<String, Object?> json) =>
      _$EvidenceItemDtoFromJson(json);

  final EvidenceItemDtoKindKind kind;

  /// Human-readable label
  final String label;

  /// Human-readable value
  final String value;

  /// Related record id for navigation
  final dynamic recordId;

  /// Related medicine id for navigation
  final dynamic medicineId;

  Map<String, Object?> toJson() => _$EvidenceItemDtoToJson(this);
}
