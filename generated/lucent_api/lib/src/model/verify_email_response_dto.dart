//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'verify_email_response_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class VerifyEmailResponseDto {
  /// Returns a new [VerifyEmailResponseDto] instance.
  VerifyEmailResponseDto({required this.emailVerified});

  /// 邮箱是否已验证
  @JsonKey(name: r'emailVerified', required: true, includeIfNull: false)
  final bool emailVerified;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VerifyEmailResponseDto && other.emailVerified == emailVerified;

  @override
  int get hashCode => emailVerified.hashCode;

  factory VerifyEmailResponseDto.fromJson(Map<String, dynamic> json) =>
      _$VerifyEmailResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyEmailResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
