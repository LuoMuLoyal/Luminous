//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'o_auth_controller_login_with_apple_v1_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class OAuthControllerLoginWithAppleV1Request {
  /// Returns a new [OAuthControllerLoginWithAppleV1Request] instance.
  OAuthControllerLoginWithAppleV1Request({
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
      other is OAuthControllerLoginWithAppleV1Request &&
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

  factory OAuthControllerLoginWithAppleV1Request.fromJson(
    Map<String, dynamic> json,
  ) => _$OAuthControllerLoginWithAppleV1RequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$OAuthControllerLoginWithAppleV1RequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
