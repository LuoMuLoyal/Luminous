//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicines_controller_run_risk_check_v1_request_candidate.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicinesControllerRunRiskCheckV1RequestCandidate {
  /// Returns a new [MedicinesControllerRunRiskCheckV1RequestCandidate] instance.
  MedicinesControllerRunRiskCheckV1RequestCandidate({
    required this.source_,

    required this.id,
  });

  /// 候选药品所在的可信药品库来源
  @JsonKey(
    name: r'source',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        MedicinesControllerRunRiskCheckV1RequestCandidateSource_Enum
            .unknownDefaultOpenApi,
  )
  final MedicinesControllerRunRiskCheckV1RequestCandidateSource_Enum source_;

  /// 候选药品在可信药品库中的 id
  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicinesControllerRunRiskCheckV1RequestCandidate &&
          other.source_ == source_ &&
          other.id == id;

  @override
  int get hashCode => source_.hashCode + id.hashCode;

  factory MedicinesControllerRunRiskCheckV1RequestCandidate.fromJson(
    Map<String, dynamic> json,
  ) => _$MedicinesControllerRunRiskCheckV1RequestCandidateFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MedicinesControllerRunRiskCheckV1RequestCandidateToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// 候选药品所在的可信药品库来源
enum MedicinesControllerRunRiskCheckV1RequestCandidateSource_Enum {
  @JsonValue(r'cn')
  cn(r'cn'),
  @JsonValue(r'drugbank')
  drugbank(r'drugbank'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const MedicinesControllerRunRiskCheckV1RequestCandidateSource_Enum(
    this.value,
  );

  final String value;

  @override
  String toString() => value;
}
