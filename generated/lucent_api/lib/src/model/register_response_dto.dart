//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/user_brief_dto.dart';
import 'package:lucent_api/src/model/tokens_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'register_response_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RegisterResponseDto {
  /// Returns a new [RegisterResponseDto] instance.
  RegisterResponseDto({required this.user, required this.tokens});

  @JsonKey(name: r'user', required: true, includeIfNull: false)
  final UserBriefDto user;

  @JsonKey(name: r'tokens', required: true, includeIfNull: false)
  final TokensDto tokens;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegisterResponseDto &&
          other.user == user &&
          other.tokens == tokens;

  @override
  int get hashCode => user.hashCode + tokens.hashCode;

  factory RegisterResponseDto.fromJson(Map<String, dynamic> json) =>
      _$RegisterResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
