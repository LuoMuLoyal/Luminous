//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicines_controller_recognize_async_v1200_response_data.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicinesControllerRecognizeAsyncV1200ResponseData {
  /// Returns a new [MedicinesControllerRecognizeAsyncV1200ResponseData] instance.
  MedicinesControllerRecognizeAsyncV1200ResponseData({this.jobId});

  @JsonKey(name: r'jobId', required: false, includeIfNull: false)
  final String? jobId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicinesControllerRecognizeAsyncV1200ResponseData &&
          other.jobId == jobId;

  @override
  int get hashCode => jobId.hashCode;

  factory MedicinesControllerRecognizeAsyncV1200ResponseData.fromJson(
    Map<String, dynamic> json,
  ) => _$MedicinesControllerRecognizeAsyncV1200ResponseDataFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MedicinesControllerRecognizeAsyncV1200ResponseDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
