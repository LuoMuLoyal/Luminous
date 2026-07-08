// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'recognize_medicine_dto.g.dart';

@JsonSerializable()
class RecognizeMedicineDto {
  const RecognizeMedicineDto({required this.imageUrl});

  factory RecognizeMedicineDto.fromJson(Map<String, Object?> json) =>
      _$RecognizeMedicineDtoFromJson(json);

  /// Public URL of the medicine box image
  final String imageUrl;

  Map<String, Object?> toJson() => _$RecognizeMedicineDtoToJson(this);
}
