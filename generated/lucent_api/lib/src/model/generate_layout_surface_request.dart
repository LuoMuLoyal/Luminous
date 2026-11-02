//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'generate_layout_surface_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GenerateLayoutSurfaceRequest {
  /// Returns a new [GenerateLayoutSurfaceRequest] instance.
  GenerateLayoutSurfaceRequest({required this.prompt, this.range});

  /// Natural-language instruction describing what to show, in the user's own words.
  @JsonKey(name: r'prompt', required: true, includeIfNull: false)
  final String prompt;

  /// Preferred time range; the model may ignore it.
  @JsonKey(
    name: r'range',
    required: false,
    includeIfNull: false,
    unknownEnumValue:
        GenerateLayoutSurfaceRequestRangeEnum.unknownDefaultOpenApi,
  )
  final GenerateLayoutSurfaceRequestRangeEnum? range;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenerateLayoutSurfaceRequest &&
          other.prompt == prompt &&
          other.range == range;

  @override
  int get hashCode => prompt.hashCode + range.hashCode;

  factory GenerateLayoutSurfaceRequest.fromJson(Map<String, dynamic> json) =>
      _$GenerateLayoutSurfaceRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GenerateLayoutSurfaceRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Preferred time range; the model may ignore it.
enum GenerateLayoutSurfaceRequestRangeEnum {
  @JsonValue(r'7d')
  n7d(r'7d'),
  @JsonValue(r'30d')
  n30d(r'30d'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const GenerateLayoutSurfaceRequestRangeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
