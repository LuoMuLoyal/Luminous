// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'environment_snapshot_dto.dart';

part 'environment_snapshot_response_dto.g.dart';

@JsonSerializable()
class EnvironmentSnapshotResponseDto {
  const EnvironmentSnapshotResponseDto({
    required this.code,
    required this.message,
    required this.data,
  });

  factory EnvironmentSnapshotResponseDto.fromJson(Map<String, Object?> json) =>
      _$EnvironmentSnapshotResponseDtoFromJson(json);

  final num code;
  final String message;
  final EnvironmentSnapshotDto data;

  Map<String, Object?> toJson() => _$EnvironmentSnapshotResponseDtoToJson(this);
}
