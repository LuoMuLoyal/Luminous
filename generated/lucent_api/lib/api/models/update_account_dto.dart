// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'update_account_dto.g.dart';

@JsonSerializable()
class UpdateAccountDto {
  const UpdateAccountDto({this.nickname, this.avatar});

  factory UpdateAccountDto.fromJson(Map<String, Object?> json) =>
      _$UpdateAccountDtoFromJson(json);

  /// Display nickname. Send an empty string to clear it.
  final String? nickname;

  /// Avatar URL. Send an empty string to clear it.
  final String? avatar;

  Map<String, Object?> toJson() => _$UpdateAccountDtoToJson(this);
}
