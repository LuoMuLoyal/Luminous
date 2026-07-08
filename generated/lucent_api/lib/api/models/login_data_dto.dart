// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'tokens_dto.dart';
import 'user_full_dto.dart';

part 'login_data_dto.g.dart';

@JsonSerializable()
class LoginDataDto {
  const LoginDataDto({required this.user, required this.tokens});

  factory LoginDataDto.fromJson(Map<String, Object?> json) =>
      _$LoginDataDtoFromJson(json);

  final UserFullDto user;
  final TokensDto tokens;

  Map<String, Object?> toJson() => _$LoginDataDtoToJson(this);
}
