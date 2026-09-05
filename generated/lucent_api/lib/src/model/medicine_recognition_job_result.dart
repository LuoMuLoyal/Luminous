//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_recognition_job_result.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineRecognitionJobResult {
  /// Returns a new [MedicineRecognitionJobResult] instance.
  MedicineRecognitionJobResult({
    required this.name,

    required this.approvalNumber,

    required this.specification,

    required this.manufacturer,
  });

  @JsonKey(name: r'name', required: true, includeIfNull: true)
  final String? name;

  @JsonKey(name: r'approvalNumber', required: true, includeIfNull: true)
  final String? approvalNumber;

  @JsonKey(name: r'specification', required: true, includeIfNull: true)
  final String? specification;

  @JsonKey(name: r'manufacturer', required: true, includeIfNull: true)
  final String? manufacturer;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineRecognitionJobResult &&
          other.name == name &&
          other.approvalNumber == approvalNumber &&
          other.specification == specification &&
          other.manufacturer == manufacturer;

  @override
  int get hashCode =>
      (name == null ? 0 : name.hashCode) +
      (approvalNumber == null ? 0 : approvalNumber.hashCode) +
      (specification == null ? 0 : specification.hashCode) +
      (manufacturer == null ? 0 : manufacturer.hashCode);

  factory MedicineRecognitionJobResult.fromJson(Map<String, dynamic> json) =>
      _$MedicineRecognitionJobResultFromJson(json);

  Map<String, dynamic> toJson() => _$MedicineRecognitionJobResultToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
