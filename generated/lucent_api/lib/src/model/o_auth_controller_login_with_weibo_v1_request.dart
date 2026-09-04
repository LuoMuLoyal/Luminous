//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'o_auth_controller_login_with_weibo_v1_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class OAuthControllerLoginWithWeiboV1Request {
  /// Returns a new [OAuthControllerLoginWithWeiboV1Request] instance.
  OAuthControllerLoginWithWeiboV1Request({
    required this.code,

    required this.state,
  });

  /// OAuth 授权码
  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final String code;

  /// 授权时生成的 state
  @JsonKey(name: r'state', required: true, includeIfNull: false)
  final String state;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OAuthControllerLoginWithWeiboV1Request &&
          other.code == code &&
          other.state == state;

  @override
  int get hashCode => code.hashCode + state.hashCode;

  factory OAuthControllerLoginWithWeiboV1Request.fromJson(
    Map<String, dynamic> json,
  ) => _$OAuthControllerLoginWithWeiboV1RequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$OAuthControllerLoginWithWeiboV1RequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
