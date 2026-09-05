//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'enqueue_analysis_generation_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EnqueueAnalysisGenerationRequest {
  /// Returns a new [EnqueueAnalysisGenerationRequest] instance.
  EnqueueAnalysisGenerationRequest({this.date});

  /// Target date in YYYY-MM-DD format. Defaults to backend current day when omitted.
  @JsonKey(name: r'date', required: false, includeIfNull: false)
  final String? date;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnqueueAnalysisGenerationRequest && other.date == date;

  @override
  int get hashCode => date.hashCode;

  factory EnqueueAnalysisGenerationRequest.fromJson(
    Map<String, dynamic> json,
  ) => _$EnqueueAnalysisGenerationRequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$EnqueueAnalysisGenerationRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
