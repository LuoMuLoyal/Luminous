//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'login_with_apple_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LoginWithAppleRequest {
  /// Returns a new [LoginWithAppleRequest] instance.
  LoginWithAppleRequest({
    required this.identityToken,

    this.authorizationCode,

    this.givenName,

    this.familyName,
  });

  /// Apple 登录返回的 identityToken (JWT)
  @JsonKey(name: r'identityToken', required: true, includeIfNull: false)
  final String identityToken;

  /// Apple 登录返回的 authorizationCode（可选）
  @JsonKey(name: r'authorizationCode', required: false, includeIfNull: false)
  final String? authorizationCode;

  /// Apple 返回的 givenName（首次登录时返回）
  @JsonKey(name: r'givenName', required: false, includeIfNull: false)
  final String? givenName;

  /// Apple 返回的 familyName（首次登录时返回）
  @JsonKey(name: r'familyName', required: false, includeIfNull: false)
  final String? familyName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoginWithAppleRequest &&
          other.identityToken == identityToken &&
          other.authorizationCode == authorizationCode &&
          other.givenName == givenName &&
          other.familyName == familyName;

  @override
  int get hashCode =>
      identityToken.hashCode +
      authorizationCode.hashCode +
      givenName.hashCode +
      familyName.hashCode;

  factory LoginWithAppleRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginWithAppleRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginWithAppleRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
