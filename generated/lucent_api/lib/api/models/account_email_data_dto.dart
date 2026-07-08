// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'account_email_data_dto.g.dart';

@JsonSerializable()
class AccountEmailDataDto {
  const AccountEmailDataDto({
    required this.email,
    required this.emailVerifiedAt,
  });

  factory AccountEmailDataDto.fromJson(Map<String, Object?> json) =>
      _$AccountEmailDataDtoFromJson(json);

  /// New email address.
  final String email;

  /// Email verification time in ISO 8601.
  final String emailVerifiedAt;

  Map<String, Object?> toJson() => _$AccountEmailDataDtoToJson(this);
}
