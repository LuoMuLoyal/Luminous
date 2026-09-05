//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'end_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EndRequest {
  /// Returns a new [EndRequest] instance.
  EndRequest({required this.outcome});

  /// User-confirmed outcome when ending the event.
  @JsonKey(
    name: r'outcome',
    required: true,
    includeIfNull: false,
    unknownEnumValue: EndRequestOutcomeEnum.unknownDefaultOpenApi,
  )
  final EndRequestOutcomeEnum outcome;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is EndRequest && other.outcome == outcome;

  @override
  int get hashCode => outcome.hashCode;

  factory EndRequest.fromJson(Map<String, dynamic> json) =>
      _$EndRequestFromJson(json);

  Map<String, dynamic> toJson() => _$EndRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// User-confirmed outcome when ending the event.
enum EndRequestOutcomeEnum {
  @JsonValue(r'improved')
  improved(r'improved'),
  @JsonValue(r'unchanged')
  unchanged(r'unchanged'),
  @JsonValue(r'worsened')
  worsened(r'worsened'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const EndRequestOutcomeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
