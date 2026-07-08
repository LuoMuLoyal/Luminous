// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'notification_detail_dto.dart';

part 'notification_detail_response_dto.g.dart';

@JsonSerializable()
class NotificationDetailResponseDto {
  const NotificationDetailResponseDto({
    required this.code,
    required this.message,
    required this.data,
  });

  factory NotificationDetailResponseDto.fromJson(Map<String, Object?> json) =>
      _$NotificationDetailResponseDtoFromJson(json);

  /// Result code.
  final num code;

  /// Message.
  final String message;
  final NotificationDetailDto data;

  Map<String, Object?> toJson() => _$NotificationDetailResponseDtoToJson(this);
}
