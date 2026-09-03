//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reminder_deliveries_controller_report_local_capability_v1_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReminderDeliveriesControllerReportLocalCapabilityV1Request {
  /// Returns a new [ReminderDeliveriesControllerReportLocalCapabilityV1Request] instance.
  ReminderDeliveriesControllerReportLocalCapabilityV1Request({
    required this.state,
  });

  /// Local scheduling capability state.
  @JsonKey(
    name: r'state',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        ReminderDeliveriesControllerReportLocalCapabilityV1RequestStateEnum
            .unknownDefaultOpenApi,
  )
  final ReminderDeliveriesControllerReportLocalCapabilityV1RequestStateEnum
  state;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderDeliveriesControllerReportLocalCapabilityV1Request &&
          other.state == state;

  @override
  int get hashCode => state.hashCode;

  factory ReminderDeliveriesControllerReportLocalCapabilityV1Request.fromJson(
    Map<String, dynamic> json,
  ) => _$ReminderDeliveriesControllerReportLocalCapabilityV1RequestFromJson(
    json,
  );

  Map<String, dynamic> toJson() =>
      _$ReminderDeliveriesControllerReportLocalCapabilityV1RequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Local scheduling capability state.
enum ReminderDeliveriesControllerReportLocalCapabilityV1RequestStateEnum {
  @JsonValue(r'active')
  active(r'active'),
  @JsonValue(r'unavailable')
  unavailable(r'unavailable'),
  @JsonValue(r'disabled')
  disabled(r'disabled'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const ReminderDeliveriesControllerReportLocalCapabilityV1RequestStateEnum(
    this.value,
  );

  final String value;

  @override
  String toString() => value;
}
