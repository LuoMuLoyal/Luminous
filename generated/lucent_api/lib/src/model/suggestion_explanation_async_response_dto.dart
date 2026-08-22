//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/suggestion_explanation_data_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'suggestion_explanation_async_response_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SuggestionExplanationAsyncResponseDto {
  /// Returns a new [SuggestionExplanationAsyncResponseDto] instance.
  SuggestionExplanationAsyncResponseDto({this.jobId, this.result});

  /// Queued explanation job identifier.
  @JsonKey(name: r'jobId', required: false, includeIfNull: false)
  final String? jobId;

  /// Inline explanation resource when queue processing is unavailable.
  @JsonKey(name: r'result', required: false, includeIfNull: false)
  final SuggestionExplanationDataDto? result;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SuggestionExplanationAsyncResponseDto &&
          other.jobId == jobId &&
          other.result == result;

  @override
  int get hashCode => jobId.hashCode + result.hashCode;

  factory SuggestionExplanationAsyncResponseDto.fromJson(
    Map<String, dynamic> json,
  ) => _$SuggestionExplanationAsyncResponseDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$SuggestionExplanationAsyncResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
