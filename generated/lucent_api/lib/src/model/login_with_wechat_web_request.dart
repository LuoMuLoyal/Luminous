//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'login_with_wechat_web_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LoginWithWechatWebRequest {
  /// Returns a new [LoginWithWechatWebRequest] instance.
  LoginWithWechatWebRequest({required this.code, required this.state});

  /// OAuth 授权码
  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final String code;

  /// 授权时生成的 state
  @JsonKey(name: r'state', required: true, includeIfNull: false)
  final String state;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoginWithWechatWebRequest &&
          other.code == code &&
          other.state == state;

  @override
  int get hashCode => code.hashCode + state.hashCode;

  factory LoginWithWechatWebRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginWithWechatWebRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginWithWechatWebRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
