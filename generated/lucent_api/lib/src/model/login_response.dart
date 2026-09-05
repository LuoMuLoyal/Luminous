//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/login_response_tokens.dart';
import 'package:lucent_api/src/model/login_response_user.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'login_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LoginResponse {
  /// Returns a new [LoginResponse] instance.
  LoginResponse({required this.user, required this.tokens});

  @JsonKey(name: r'user', required: true, includeIfNull: false)
  final LoginResponseUser user;

  @JsonKey(name: r'tokens', required: true, includeIfNull: false)
  final LoginResponseTokens tokens;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoginResponse && other.user == user && other.tokens == tokens;

  @override
  int get hashCode => user.hashCode + tokens.hashCode;

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
