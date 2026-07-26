//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/medicines_controller_recognize_async_v1200_response_data.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicines_controller_recognize_async_v1200_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicinesControllerRecognizeAsyncV1200Response {
  /// Returns a new [MedicinesControllerRecognizeAsyncV1200Response] instance.
  MedicinesControllerRecognizeAsyncV1200Response({this.code, this.data});

  @JsonKey(name: r'code', required: false, includeIfNull: false)
  final num? code;

  @JsonKey(name: r'data', required: false, includeIfNull: false)
  final MedicinesControllerRecognizeAsyncV1200ResponseData? data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicinesControllerRecognizeAsyncV1200Response &&
          other.code == code &&
          other.data == data;

  @override
  int get hashCode => code.hashCode + data.hashCode;

  factory MedicinesControllerRecognizeAsyncV1200Response.fromJson(
    Map<String, dynamic> json,
  ) => _$MedicinesControllerRecognizeAsyncV1200ResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MedicinesControllerRecognizeAsyncV1200ResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
