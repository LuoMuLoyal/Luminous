//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_risk_check_records_response_llm_result_findings.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineRiskCheckRecordsResponseLlmResultFindings {
  /// Returns a new [MedicineRiskCheckRecordsResponseLlmResultFindings] instance.
  MedicineRiskCheckRecordsResponseLlmResultFindings({
    required this.type,

    required this.severity,

    required this.context,

    required this.primaryMedicineName,

    this.secondaryMedicineName,

    this.relatedLabel,

    this.evidence,

    this.recommendation,
  });

  /// Finding kind.
  @JsonKey(
    name: r'type',
    required: true,
    includeIfNull: false,
    unknownEnumValue: MedicineRiskCheckRecordsResponseLlmResultFindingsTypeEnum
        .unknownDefaultOpenApi,
  )
  final MedicineRiskCheckRecordsResponseLlmResultFindingsTypeEnum type;

  /// Finding severity.
  @JsonKey(
    name: r'severity',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        MedicineRiskCheckRecordsResponseLlmResultFindingsSeverityEnum
            .unknownDefaultOpenApi,
  )
  final MedicineRiskCheckRecordsResponseLlmResultFindingsSeverityEnum severity;

  /// Finding context.
  @JsonKey(
    name: r'context',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        MedicineRiskCheckRecordsResponseLlmResultFindingsContextEnum
            .unknownDefaultOpenApi,
  )
  final MedicineRiskCheckRecordsResponseLlmResultFindingsContextEnum context;

  /// Medicine the finding is about.
  @JsonKey(name: r'primaryMedicineName', required: true, includeIfNull: false)
  final String primaryMedicineName;

  /// Second medicine involved.
  @JsonKey(
    name: r'secondaryMedicineName',
    required: false,
    includeIfNull: false,
  )
  final String? secondaryMedicineName;

  /// Related label (e.g. allergen).
  @JsonKey(name: r'relatedLabel', required: false, includeIfNull: false)
  final String? relatedLabel;

  /// Supporting evidence.
  @JsonKey(name: r'evidence', required: false, includeIfNull: false)
  final String? evidence;

  /// LLM check only
  @JsonKey(name: r'recommendation', required: false, includeIfNull: false)
  final String? recommendation;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineRiskCheckRecordsResponseLlmResultFindings &&
          other.type == type &&
          other.severity == severity &&
          other.context == context &&
          other.primaryMedicineName == primaryMedicineName &&
          other.secondaryMedicineName == secondaryMedicineName &&
          other.relatedLabel == relatedLabel &&
          other.evidence == evidence &&
          other.recommendation == recommendation;

  @override
  int get hashCode =>
      type.hashCode +
      severity.hashCode +
      context.hashCode +
      primaryMedicineName.hashCode +
      secondaryMedicineName.hashCode +
      relatedLabel.hashCode +
      evidence.hashCode +
      recommendation.hashCode;

  factory MedicineRiskCheckRecordsResponseLlmResultFindings.fromJson(
    Map<String, dynamic> json,
  ) => _$MedicineRiskCheckRecordsResponseLlmResultFindingsFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MedicineRiskCheckRecordsResponseLlmResultFindingsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Finding kind.
enum MedicineRiskCheckRecordsResponseLlmResultFindingsTypeEnum {
  @JsonValue(r'interaction')
  interaction(r'interaction'),
  @JsonValue(r'duplicateIngredient')
  duplicateIngredient(r'duplicateIngredient'),
  @JsonValue(r'allergy')
  allergy(r'allergy'),
  @JsonValue(r'foodInteraction')
  foodInteraction(r'foodInteraction'),
  @JsonValue(r'longTermUse')
  longTermUse(r'longTermUse'),
  @JsonValue(r'schedulingConflict')
  schedulingConflict(r'schedulingConflict'),
  @JsonValue(r'specialGroup')
  specialGroup(r'specialGroup'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const MedicineRiskCheckRecordsResponseLlmResultFindingsTypeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// Finding severity.
enum MedicineRiskCheckRecordsResponseLlmResultFindingsSeverityEnum {
  @JsonValue(r'high')
  high(r'high'),
  @JsonValue(r'medium')
  medium(r'medium'),
  @JsonValue(r'info')
  info(r'info'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const MedicineRiskCheckRecordsResponseLlmResultFindingsSeverityEnum(
    this.value,
  );

  final String value;

  @override
  String toString() => value;
}

/// Finding context.
enum MedicineRiskCheckRecordsResponseLlmResultFindingsContextEnum {
  @JsonValue(r'none')
  none(r'none'),
  @JsonValue(r'alcohol')
  alcohol(r'alcohol'),
  @JsonValue(r'caffeine')
  caffeine(r'caffeine'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const MedicineRiskCheckRecordsResponseLlmResultFindingsContextEnum(
    this.value,
  );

  final String value;

  @override
  String toString() => value;
}
