//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'today_analysis_controller_refresh_v1_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TodayAnalysisControllerRefreshV1Request {
  /// Returns a new [TodayAnalysisControllerRefreshV1Request] instance.
  TodayAnalysisControllerRefreshV1Request({this.date});

  /// Target date in YYYY-MM-DD format. Defaults to backend current day when omitted.
  @JsonKey(name: r'date', required: false, includeIfNull: false)
  final String? date;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodayAnalysisControllerRefreshV1Request && other.date == date;

  @override
  int get hashCode => date.hashCode;

  factory TodayAnalysisControllerRefreshV1Request.fromJson(
    Map<String, dynamic> json,
  ) => _$TodayAnalysisControllerRefreshV1RequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$TodayAnalysisControllerRefreshV1RequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
