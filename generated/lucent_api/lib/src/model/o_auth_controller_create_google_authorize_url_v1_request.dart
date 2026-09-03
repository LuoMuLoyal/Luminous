//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'o_auth_controller_create_google_authorize_url_v1_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class OAuthControllerCreateGoogleAuthorizeUrlV1Request {
  /// Returns a new [OAuthControllerCreateGoogleAuthorizeUrlV1Request] instance.
  OAuthControllerCreateGoogleAuthorizeUrlV1Request({this.callbackUri});

  /// Google 授权完成后的客户端回跳地址
  @JsonKey(name: r'callbackUri', required: false, includeIfNull: false)
  final String? callbackUri;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OAuthControllerCreateGoogleAuthorizeUrlV1Request &&
          other.callbackUri == callbackUri;

  @override
  int get hashCode => callbackUri.hashCode;

  factory OAuthControllerCreateGoogleAuthorizeUrlV1Request.fromJson(
    Map<String, dynamic> json,
  ) => _$OAuthControllerCreateGoogleAuthorizeUrlV1RequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$OAuthControllerCreateGoogleAuthorizeUrlV1RequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
