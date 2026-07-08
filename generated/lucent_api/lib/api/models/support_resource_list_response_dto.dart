// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'support_resource_list_data_dto.dart';

part 'support_resource_list_response_dto.g.dart';

@JsonSerializable()
class SupportResourceListResponseDto {
  const SupportResourceListResponseDto({
    required this.code,
    required this.message,
    required this.data,
  });

  factory SupportResourceListResponseDto.fromJson(Map<String, Object?> json) =>
      _$SupportResourceListResponseDtoFromJson(json);

  /// Result code.
  final num code;

  /// Message.
  final String message;
  final SupportResourceListDataDto data;

  Map<String, Object?> toJson() => _$SupportResourceListResponseDtoToJson(this);
}
