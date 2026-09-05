//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/suggestion_explanation_job_response_result.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'suggestion_explanation_job_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SuggestionExplanationJobResponse {
  /// Returns a new [SuggestionExplanationJobResponse] instance.
  SuggestionExplanationJobResponse({this.jobId, this.result});

  /// Queued explanation job identifier.
  @JsonKey(name: r'jobId', required: false, includeIfNull: false)
  final String? jobId;

  @JsonKey(name: r'result', required: false, includeIfNull: false)
  final SuggestionExplanationJobResponseResult? result;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SuggestionExplanationJobResponse &&
          other.jobId == jobId &&
          other.result == result;

  @override
  int get hashCode => jobId.hashCode + result.hashCode;

  factory SuggestionExplanationJobResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$SuggestionExplanationJobResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$SuggestionExplanationJobResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
