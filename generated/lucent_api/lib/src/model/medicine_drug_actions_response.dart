//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/medicine_drug_actions_response_actions.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_drug_actions_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineDrugActionsResponse {
  /// Returns a new [MedicineDrugActionsResponse] instance.
  MedicineDrugActionsResponse({required this.status, this.actions});

  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        MedicineDrugActionsResponseStatusEnum.unknownDefaultOpenApi,
  )
  final MedicineDrugActionsResponseStatusEnum status;

  @JsonKey(name: r'actions', required: false, includeIfNull: false)
  final List<MedicineDrugActionsResponseActions>? actions;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineDrugActionsResponse &&
          other.status == status &&
          other.actions == actions;

  @override
  int get hashCode => status.hashCode + actions.hashCode;

  factory MedicineDrugActionsResponse.fromJson(Map<String, dynamic> json) =>
      _$MedicineDrugActionsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MedicineDrugActionsResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum MedicineDrugActionsResponseStatusEnum {
  @JsonValue(r'ok')
  ok(r'ok'),
  @JsonValue(r'notConfigured')
  notConfigured(r'notConfigured'),
  @JsonValue(r'unavailable')
  unavailable(r'unavailable'),
  @JsonValue(r'timeout')
  timeout(r'timeout'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const MedicineDrugActionsResponseStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
