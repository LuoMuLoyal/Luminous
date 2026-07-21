// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'medicines_controller_recognize_async_v1_response_data.dart';

part 'medicines_controller_recognize_async_v1_response.g.dart';

@JsonSerializable()
class MedicinesControllerRecognizeAsyncV1Response {
  const MedicinesControllerRecognizeAsyncV1Response({this.code, this.data});

  factory MedicinesControllerRecognizeAsyncV1Response.fromJson(
    Map<String, Object?> json,
  ) => _$MedicinesControllerRecognizeAsyncV1ResponseFromJson(json);

  final num? code;
  final MedicinesControllerRecognizeAsyncV1ResponseData? data;

  Map<String, Object?> toJson() =>
      _$MedicinesControllerRecognizeAsyncV1ResponseToJson(this);
}
