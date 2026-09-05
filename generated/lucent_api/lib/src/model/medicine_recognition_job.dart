//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/medicine_recognition_job_result.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_recognition_job.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineRecognitionJob {
  /// Returns a new [MedicineRecognitionJob] instance.
  MedicineRecognitionJob({this.jobId, this.result});

  /// Queued recognition job identifier.
  @JsonKey(name: r'jobId', required: false, includeIfNull: false)
  final String? jobId;

  @JsonKey(name: r'result', required: false, includeIfNull: false)
  final MedicineRecognitionJobResult? result;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineRecognitionJob &&
          other.jobId == jobId &&
          other.result == result;

  @override
  int get hashCode => jobId.hashCode + result.hashCode;

  factory MedicineRecognitionJob.fromJson(Map<String, dynamic> json) =>
      _$MedicineRecognitionJobFromJson(json);

  Map<String, dynamic> toJson() => _$MedicineRecognitionJobToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
