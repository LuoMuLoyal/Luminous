//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/product_events_controller_record_batch_v1_request_events_inner.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'product_events_controller_record_batch_v1_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ProductEventsControllerRecordBatchV1Request {
  /// Returns a new [ProductEventsControllerRecordBatchV1Request] instance.
  ProductEventsControllerRecordBatchV1Request({required this.events});

  /// 1..50 events per request.
  @JsonKey(name: r'events', required: true, includeIfNull: false)
  final List<ProductEventsControllerRecordBatchV1RequestEventsInner> events;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductEventsControllerRecordBatchV1Request &&
          other.events == events;

  @override
  int get hashCode => events.hashCode;

  factory ProductEventsControllerRecordBatchV1Request.fromJson(
    Map<String, dynamic> json,
  ) => _$ProductEventsControllerRecordBatchV1RequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ProductEventsControllerRecordBatchV1RequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
