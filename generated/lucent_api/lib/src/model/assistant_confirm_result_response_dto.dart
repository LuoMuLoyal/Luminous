//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/assistant_confirm_result_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assistant_confirm_result_response_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssistantConfirmResultResponseDto {
  /// Returns a new [AssistantConfirmResultResponseDto] instance.
  AssistantConfirmResultResponseDto({
    required this.code,
    required this.message,
    required this.data,
  });

  /// Result code.
  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final num code;

  /// Message.
  @JsonKey(name: r'message', required: true, includeIfNull: false)
  final String message;

  @JsonKey(name: r'data', required: true, includeIfNull: false)
  final AssistantConfirmResultDto data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssistantConfirmResultResponseDto &&
          other.code == code &&
          other.message == message &&
          other.data == data;

  @override
  int get hashCode => code.hashCode + message.hashCode + data.hashCode;

  factory AssistantConfirmResultResponseDto.fromJson(
    Map<String, dynamic> json,
  ) => _$AssistantConfirmResultResponseDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$AssistantConfirmResultResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
