//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'send_verification_code_response_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SendVerificationCodeResponseDto {
  /// Returns a new [SendVerificationCodeResponseDto] instance.
  SendVerificationCodeResponseDto({
    required this.cooldown,

    required this.message,
  });

  /// 冷却时间（秒）
  @JsonKey(name: r'cooldown', required: true, includeIfNull: false)
  final num cooldown;

  /// 提示消息
  @JsonKey(name: r'message', required: true, includeIfNull: false)
  final String message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SendVerificationCodeResponseDto &&
          other.cooldown == cooldown &&
          other.message == message;

  @override
  int get hashCode => cooldown.hashCode + message.hashCode;

  factory SendVerificationCodeResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SendVerificationCodeResponseDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$SendVerificationCodeResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
