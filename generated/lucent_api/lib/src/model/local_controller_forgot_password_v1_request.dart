//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'local_controller_forgot_password_v1_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LocalControllerForgotPasswordV1Request {
  /// Returns a new [LocalControllerForgotPasswordV1Request] instance.
  LocalControllerForgotPasswordV1Request({required this.email});

  /// 邮箱地址
  @JsonKey(name: r'email', required: true, includeIfNull: false)
  final String email;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalControllerForgotPasswordV1Request && other.email == email;

  @override
  int get hashCode => email.hashCode;

  factory LocalControllerForgotPasswordV1Request.fromJson(
    Map<String, dynamic> json,
  ) => _$LocalControllerForgotPasswordV1RequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$LocalControllerForgotPasswordV1RequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
