//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'recognize_medicine_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RecognizeMedicineDto {
  /// Returns a new [RecognizeMedicineDto] instance.
  RecognizeMedicineDto({required this.imageUrl});

  /// Public URL of the medicine box image
  @JsonKey(name: r'imageUrl', required: true, includeIfNull: false)
  final String imageUrl;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecognizeMedicineDto && other.imageUrl == imageUrl;

  @override
  int get hashCode => imageUrl.hashCode;

  factory RecognizeMedicineDto.fromJson(Map<String, dynamic> json) =>
      _$RecognizeMedicineDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RecognizeMedicineDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
