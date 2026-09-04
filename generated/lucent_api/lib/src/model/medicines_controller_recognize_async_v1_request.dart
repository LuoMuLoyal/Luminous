//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicines_controller_recognize_async_v1_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicinesControllerRecognizeAsyncV1Request {
  /// Returns a new [MedicinesControllerRecognizeAsyncV1Request] instance.
  MedicinesControllerRecognizeAsyncV1Request({required this.imageUrl});

  /// Public URL of the medicine box image
  @JsonKey(name: r'imageUrl', required: true, includeIfNull: false)
  final String imageUrl;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicinesControllerRecognizeAsyncV1Request &&
          other.imageUrl == imageUrl;

  @override
  int get hashCode => imageUrl.hashCode;

  factory MedicinesControllerRecognizeAsyncV1Request.fromJson(
    Map<String, dynamic> json,
  ) => _$MedicinesControllerRecognizeAsyncV1RequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MedicinesControllerRecognizeAsyncV1RequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
