//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'local_controller_verify_email_v1_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LocalControllerVerifyEmailV1Request {
  /// Returns a new [LocalControllerVerifyEmailV1Request] instance.
  LocalControllerVerifyEmailV1Request({required this.token});

  /// Better Auth 邮件验证 token
  @JsonKey(name: r'token', required: true, includeIfNull: false)
  final String token;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalControllerVerifyEmailV1Request && other.token == token;

  @override
  int get hashCode => token.hashCode;

  factory LocalControllerVerifyEmailV1Request.fromJson(
    Map<String, dynamic> json,
  ) => _$LocalControllerVerifyEmailV1RequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$LocalControllerVerifyEmailV1RequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
