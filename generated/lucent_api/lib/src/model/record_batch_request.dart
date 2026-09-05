//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/record_batch_request_events.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'record_batch_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RecordBatchRequest {
  /// Returns a new [RecordBatchRequest] instance.
  RecordBatchRequest({required this.events});

  /// 1..50 events per request.
  @JsonKey(name: r'events', required: true, includeIfNull: false)
  final List<RecordBatchRequestEvents> events;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecordBatchRequest && other.events == events;

  @override
  int get hashCode => events.hashCode;

  factory RecordBatchRequest.fromJson(Map<String, dynamic> json) =>
      _$RecordBatchRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RecordBatchRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
