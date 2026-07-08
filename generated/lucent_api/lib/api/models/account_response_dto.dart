// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'account_dto.dart';

part 'account_response_dto.g.dart';

@JsonSerializable()
class AccountResponseDto {
  const AccountResponseDto({
    required this.code,
    required this.message,
    required this.data,
  });

  factory AccountResponseDto.fromJson(Map<String, Object?> json) =>
      _$AccountResponseDtoFromJson(json);

  /// Result code.
  final num code;

  /// Message.
  final String message;
  final AccountDto data;

  Map<String, Object?> toJson() => _$AccountResponseDtoToJson(this);
}
