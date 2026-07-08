// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'tokens_dto.dart';
import 'user_brief_dto.dart';

part 'register_data_dto.g.dart';

@JsonSerializable()
class RegisterDataDto {
  const RegisterDataDto({required this.user, required this.tokens});

  factory RegisterDataDto.fromJson(Map<String, Object?> json) =>
      _$RegisterDataDtoFromJson(json);

  final UserBriefDto user;
  final TokensDto tokens;

  Map<String, Object?> toJson() => _$RegisterDataDtoToJson(this);
}
