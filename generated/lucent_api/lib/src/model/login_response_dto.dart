//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/login_response_dto_user.dart';
import 'package:lucent_api/src/model/register_response_dto_tokens.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'login_response_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LoginResponseDto {
  /// Returns a new [LoginResponseDto] instance.
  LoginResponseDto({required this.user, required this.tokens});

  @JsonKey(name: r'user', required: true, includeIfNull: false)
  final LoginResponseDtoUser user;

  @JsonKey(name: r'tokens', required: true, includeIfNull: false)
  final RegisterResponseDtoTokens tokens;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoginResponseDto && other.user == user && other.tokens == tokens;

  @override
  int get hashCode => user.hashCode + tokens.hashCode;

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
