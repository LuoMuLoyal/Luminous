//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'o_auth_controller_create_qq_authorize_url_v1_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class OAuthControllerCreateQqAuthorizeUrlV1Request {
  /// Returns a new [OAuthControllerCreateQqAuthorizeUrlV1Request] instance.
  OAuthControllerCreateQqAuthorizeUrlV1Request({this.callbackUri});

  /// QQ 授权完成后的客户端回跳地址
  @JsonKey(name: r'callbackUri', required: false, includeIfNull: false)
  final String? callbackUri;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OAuthControllerCreateQqAuthorizeUrlV1Request &&
          other.callbackUri == callbackUri;

  @override
  int get hashCode => callbackUri.hashCode;

  factory OAuthControllerCreateQqAuthorizeUrlV1Request.fromJson(
    Map<String, dynamic> json,
  ) => _$OAuthControllerCreateQqAuthorizeUrlV1RequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$OAuthControllerCreateQqAuthorizeUrlV1RequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
