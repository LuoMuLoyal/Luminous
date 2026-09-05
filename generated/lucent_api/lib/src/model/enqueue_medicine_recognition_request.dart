//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'enqueue_medicine_recognition_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EnqueueMedicineRecognitionRequest {
  /// Returns a new [EnqueueMedicineRecognitionRequest] instance.
  EnqueueMedicineRecognitionRequest({required this.imageUrl});

  /// Public URL of the medicine box image
  @JsonKey(name: r'imageUrl', required: true, includeIfNull: false)
  final String imageUrl;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnqueueMedicineRecognitionRequest && other.imageUrl == imageUrl;

  @override
  int get hashCode => imageUrl.hashCode;

  factory EnqueueMedicineRecognitionRequest.fromJson(
    Map<String, dynamic> json,
  ) => _$EnqueueMedicineRecognitionRequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$EnqueueMedicineRecognitionRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
