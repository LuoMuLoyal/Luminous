//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_recognition_result_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineRecognitionResultDto {
  /// Returns a new [MedicineRecognitionResultDto] instance.
  MedicineRecognitionResultDto({
    required this.name,

    required this.approvalNumber,

    required this.specification,

    required this.manufacturer,
  });

  @JsonKey(name: r'name', required: true, includeIfNull: true)
  final Object? name;

  @JsonKey(name: r'approvalNumber', required: true, includeIfNull: true)
  final Object? approvalNumber;

  @JsonKey(name: r'specification', required: true, includeIfNull: true)
  final Object? specification;

  @JsonKey(name: r'manufacturer', required: true, includeIfNull: true)
  final Object? manufacturer;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineRecognitionResultDto &&
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

  factory MedicineRecognitionResultDto.fromJson(Map<String, dynamic> json) =>
      _$MedicineRecognitionResultDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MedicineRecognitionResultDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
