//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicines_controller_recognize_v1_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicinesControllerRecognizeV1Request {
  /// Returns a new [MedicinesControllerRecognizeV1Request] instance.
  MedicinesControllerRecognizeV1Request({required this.imageUrl});

  /// Public URL of the medicine box image
  @JsonKey(name: r'imageUrl', required: true, includeIfNull: false)
  final String imageUrl;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicinesControllerRecognizeV1Request &&
          other.imageUrl == imageUrl;

  @override
  int get hashCode => imageUrl.hashCode;

  factory MedicinesControllerRecognizeV1Request.fromJson(
    Map<String, dynamic> json,
  ) => _$MedicinesControllerRecognizeV1RequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MedicinesControllerRecognizeV1RequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
