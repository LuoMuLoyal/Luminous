//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/medicines_controller_run_risk_check_v1_request_candidate.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicines_controller_run_risk_check_v1_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicinesControllerRunRiskCheckV1Request {
  /// Returns a new [MedicinesControllerRunRiskCheckV1Request] instance.
  MedicinesControllerRunRiskCheckV1Request({
    required this.type,

    this.candidate,
  });

  /// Type of risk check to run
  @JsonKey(
    name: r'type',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        MedicinesControllerRunRiskCheckV1RequestTypeEnum.unknownDefaultOpenApi,
  )
  final MedicinesControllerRunRiskCheckV1RequestTypeEnum type;

  @JsonKey(name: r'candidate', required: false, includeIfNull: false)
  final MedicinesControllerRunRiskCheckV1RequestCandidate? candidate;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicinesControllerRunRiskCheckV1Request &&
          other.type == type &&
          other.candidate == candidate;

  @override
  int get hashCode => type.hashCode + candidate.hashCode;

  factory MedicinesControllerRunRiskCheckV1Request.fromJson(
    Map<String, dynamic> json,
  ) => _$MedicinesControllerRunRiskCheckV1RequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MedicinesControllerRunRiskCheckV1RequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Type of risk check to run
enum MedicinesControllerRunRiskCheckV1RequestTypeEnum {
  @JsonValue(r'static')
  static_(r'static'),
  @JsonValue(r'llm')
  llm(r'llm'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const MedicinesControllerRunRiskCheckV1RequestTypeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
