// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'o_auth_authorize_data_dto.dart';

part 'o_auth_authorize_response_dto.g.dart';

@JsonSerializable()
class OAuthAuthorizeResponseDto {
  const OAuthAuthorizeResponseDto({
    required this.code,
    required this.message,
    required this.data,
  });

  factory OAuthAuthorizeResponseDto.fromJson(Map<String, Object?> json) =>
      _$OAuthAuthorizeResponseDtoFromJson(json);

  /// 结果码
  final num code;

  /// 提示消息
  final String message;
  final OAuthAuthorizeDataDto data;

  Map<String, Object?> toJson() => _$OAuthAuthorizeResponseDtoToJson(this);
}
