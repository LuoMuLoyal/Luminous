//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'o_auth_controller_login_with_qq_v1_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class OAuthControllerLoginWithQqV1Request {
  /// Returns a new [OAuthControllerLoginWithQqV1Request] instance.
  OAuthControllerLoginWithQqV1Request({
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
      other is OAuthControllerLoginWithQqV1Request &&
          other.code == code &&
          other.state == state;

  @override
  int get hashCode => code.hashCode + state.hashCode;

  factory OAuthControllerLoginWithQqV1Request.fromJson(
    Map<String, dynamic> json,
  ) => _$OAuthControllerLoginWithQqV1RequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$OAuthControllerLoginWithQqV1RequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
