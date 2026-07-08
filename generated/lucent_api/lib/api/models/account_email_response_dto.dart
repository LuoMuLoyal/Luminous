// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'account_email_data_dto.dart';

part 'account_email_response_dto.g.dart';

@JsonSerializable()
class AccountEmailResponseDto {
  const AccountEmailResponseDto({
    required this.code,
    required this.message,
    required this.data,
  });

  factory AccountEmailResponseDto.fromJson(Map<String, Object?> json) =>
      _$AccountEmailResponseDtoFromJson(json);

  /// Result code.
  final num code;

  /// Message.
  final String message;
  final AccountEmailDataDto data;

  Map<String, Object?> toJson() => _$AccountEmailResponseDtoToJson(this);
}
