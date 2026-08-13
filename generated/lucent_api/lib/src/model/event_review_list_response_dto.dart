//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/event_review_list_data_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_review_list_response_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EventReviewListResponseDto {
  /// Returns a new [EventReviewListResponseDto] instance.
  EventReviewListResponseDto({
    required this.code,

    required this.message,

    required this.data,
  });

  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final num code;

  @JsonKey(name: r'message', required: true, includeIfNull: false)
  final String message;

  @JsonKey(name: r'data', required: true, includeIfNull: false)
  final EventReviewListDataDto data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventReviewListResponseDto &&
          other.code == code &&
          other.message == message &&
          other.data == data;

  @override
  int get hashCode => code.hashCode + message.hashCode + data.hashCode;

  factory EventReviewListResponseDto.fromJson(Map<String, dynamic> json) =>
      _$EventReviewListResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$EventReviewListResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
