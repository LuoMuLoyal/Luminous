//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'verify_email_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class VerifyEmailResponse {
  /// Returns a new [VerifyEmailResponse] instance.
  VerifyEmailResponse({required this.emailVerified});

  /// 邮箱是否已验证
  @JsonKey(name: r'emailVerified', required: true, includeIfNull: false)
  final bool emailVerified;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VerifyEmailResponse && other.emailVerified == emailVerified;

  @override
  int get hashCode => emailVerified.hashCode;

  factory VerifyEmailResponse.fromJson(Map<String, dynamic> json) =>
      _$VerifyEmailResponseFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyEmailResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
