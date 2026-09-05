//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'refresh_today_analysis_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RefreshTodayAnalysisRequest {
  /// Returns a new [RefreshTodayAnalysisRequest] instance.
  RefreshTodayAnalysisRequest({this.date});

  /// Target date in YYYY-MM-DD format. Defaults to backend current day when omitted.
  @JsonKey(name: r'date', required: false, includeIfNull: false)
  final String? date;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RefreshTodayAnalysisRequest && other.date == date;

  @override
  int get hashCode => date.hashCode;

  factory RefreshTodayAnalysisRequest.fromJson(Map<String, dynamic> json) =>
      _$RefreshTodayAnalysisRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RefreshTodayAnalysisRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
