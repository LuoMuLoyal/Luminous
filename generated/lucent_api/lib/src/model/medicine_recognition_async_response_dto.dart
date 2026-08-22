//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/medicine_recognition_result_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_recognition_async_response_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineRecognitionAsyncResponseDto {
  /// Returns a new [MedicineRecognitionAsyncResponseDto] instance.
  MedicineRecognitionAsyncResponseDto({this.jobId, this.result});

  /// Queued recognition job identifier.
  @JsonKey(name: r'jobId', required: false, includeIfNull: false)
  final String? jobId;

  /// Inline recognition resource when queue processing is unavailable.
  @JsonKey(name: r'result', required: false, includeIfNull: false)
  final MedicineRecognitionResultDto? result;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineRecognitionAsyncResponseDto &&
          other.jobId == jobId &&
          other.result == result;

  @override
  int get hashCode => jobId.hashCode + result.hashCode;

  factory MedicineRecognitionAsyncResponseDto.fromJson(
    Map<String, dynamic> json,
  ) => _$MedicineRecognitionAsyncResponseDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MedicineRecognitionAsyncResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
