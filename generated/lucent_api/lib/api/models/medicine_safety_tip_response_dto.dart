// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'medicine_safety_tip_response_dto.g.dart';

@JsonSerializable()
class MedicineSafetyTipResponseDto {
  const MedicineSafetyTipResponseDto({
    required this.id,
    required this.text,
    required this.category,
  });

  factory MedicineSafetyTipResponseDto.fromJson(Map<String, Object?> json) =>
      _$MedicineSafetyTipResponseDtoFromJson(json);

  final String id;
  final String text;
  final String category;

  Map<String, Object?> toJson() => _$MedicineSafetyTipResponseDtoToJson(this);
}
