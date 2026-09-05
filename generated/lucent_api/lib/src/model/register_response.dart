//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/register_response_user.dart';
import 'package:lucent_api/src/model/register_response_tokens.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'register_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RegisterResponse {
  /// Returns a new [RegisterResponse] instance.
  RegisterResponse({required this.user, required this.tokens});

  @JsonKey(name: r'user', required: true, includeIfNull: false)
  final RegisterResponseUser user;

  @JsonKey(name: r'tokens', required: true, includeIfNull: false)
  final RegisterResponseTokens tokens;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegisterResponse && other.user == user && other.tokens == tokens;

  @override
  int get hashCode => user.hashCode + tokens.hashCode;

  factory RegisterResponse.fromJson(Map<String, dynamic> json) =>
      _$RegisterResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
