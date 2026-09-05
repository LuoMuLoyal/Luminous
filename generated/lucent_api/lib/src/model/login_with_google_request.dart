//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'login_with_google_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LoginWithGoogleRequest {
  /// Returns a new [LoginWithGoogleRequest] instance.
  LoginWithGoogleRequest({required this.code, required this.state});

  /// OAuth 授权码
  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final String code;

  /// 授权时生成的 state
  @JsonKey(name: r'state', required: true, includeIfNull: false)
  final String state;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoginWithGoogleRequest &&
          other.code == code &&
          other.state == state;

  @override
  int get hashCode => code.hashCode + state.hashCode;

  factory LoginWithGoogleRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginWithGoogleRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginWithGoogleRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
