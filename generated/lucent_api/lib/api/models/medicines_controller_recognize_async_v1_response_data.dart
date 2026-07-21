// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'medicines_controller_recognize_async_v1_response_data.g.dart';

@JsonSerializable()
class MedicinesControllerRecognizeAsyncV1ResponseData {
  const MedicinesControllerRecognizeAsyncV1ResponseData({this.jobId});

  factory MedicinesControllerRecognizeAsyncV1ResponseData.fromJson(
    Map<String, Object?> json,
  ) => _$MedicinesControllerRecognizeAsyncV1ResponseDataFromJson(json);

  final String? jobId;

  Map<String, Object?> toJson() =>
      _$MedicinesControllerRecognizeAsyncV1ResponseDataToJson(this);
}
