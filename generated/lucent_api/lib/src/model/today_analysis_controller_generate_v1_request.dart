//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'today_analysis_controller_generate_v1_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TodayAnalysisControllerGenerateV1Request {
  /// Returns a new [TodayAnalysisControllerGenerateV1Request] instance.
  TodayAnalysisControllerGenerateV1Request({this.date});

  /// Target date in YYYY-MM-DD format. Defaults to backend current day when omitted.
  @JsonKey(name: r'date', required: false, includeIfNull: false)
  final String? date;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodayAnalysisControllerGenerateV1Request && other.date == date;

  @override
  int get hashCode => date.hashCode;

  factory TodayAnalysisControllerGenerateV1Request.fromJson(
    Map<String, dynamic> json,
  ) => _$TodayAnalysisControllerGenerateV1RequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$TodayAnalysisControllerGenerateV1RequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
