// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'unread_count_response_dto.g.dart';

@JsonSerializable()
class UnreadCountResponseDto {
  const UnreadCountResponseDto({
    required this.code,
    required this.message,
    required this.count,
  });

  factory UnreadCountResponseDto.fromJson(Map<String, Object?> json) =>
      _$UnreadCountResponseDtoFromJson(json);

  /// Result code.
  final num code;

  /// Message.
  final String message;

  /// Number of unread notifications.
  final num count;

  Map<String, Object?> toJson() => _$UnreadCountResponseDtoToJson(this);
}
