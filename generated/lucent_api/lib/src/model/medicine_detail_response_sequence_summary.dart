//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_detail_response_sequence_summary.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineDetailResponseSequenceSummary {
  /// Returns a new [MedicineDetailResponseSequenceSummary] instance.
  MedicineDetailResponseSequenceSummary({
    required this.drugChainCount,

    required this.targetSequenceCount,
  });

  /// Number of sequences belonging to the drug itself.
  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'drugChainCount', required: true, includeIfNull: false)
  final int drugChainCount;

  /// Number of target sequences reachable from this drug.
  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'targetSequenceCount', required: true, includeIfNull: false)
  final int targetSequenceCount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineDetailResponseSequenceSummary &&
          other.drugChainCount == drugChainCount &&
          other.targetSequenceCount == targetSequenceCount;

  @override
  int get hashCode => drugChainCount.hashCode + targetSequenceCount.hashCode;

  factory MedicineDetailResponseSequenceSummary.fromJson(
    Map<String, dynamic> json,
  ) => _$MedicineDetailResponseSequenceSummaryFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MedicineDetailResponseSequenceSummaryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
