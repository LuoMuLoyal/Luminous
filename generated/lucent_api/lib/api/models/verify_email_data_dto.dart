// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'verify_email_data_dto.g.dart';

@JsonSerializable()
class VerifyEmailDataDto {
  const VerifyEmailDataDto({required this.emailVerified});

  factory VerifyEmailDataDto.fromJson(Map<String, Object?> json) =>
      _$VerifyEmailDataDtoFromJson(json);

  /// 邮箱是否已验证
  final bool emailVerified;

  Map<String, Object?> toJson() => _$VerifyEmailDataDtoToJson(this);
}
