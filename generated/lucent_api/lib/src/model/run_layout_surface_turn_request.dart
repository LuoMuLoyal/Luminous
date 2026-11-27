//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/run_layout_surface_turn_request_document.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'run_layout_surface_turn_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RunLayoutSurfaceTurnRequest {
  /// Returns a new [RunLayoutSurfaceTurnRequest] instance.
  RunLayoutSurfaceTurnRequest({
    required this.messages,

    required this.document,

    this.capabilities,
  });

  /// Renderer-to-agent messages (action / callAgentFunction / rendererFunctionResponse / error) that the user interaction produced.
  @JsonKey(name: r'messages', required: true, includeIfNull: false)
  final List<Map<String, Object>> messages;

  @JsonKey(name: r'document', required: true, includeIfNull: false)
  final RunLayoutSurfaceTurnRequestDocument document;

  /// The renderer capabilities document the client advertised (A2UI v1.0). Its inline catalogs define the component vocabulary the model may use.
  @JsonKey(name: r'capabilities', required: false, includeIfNull: false)
  final Map<String, Object>? capabilities;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RunLayoutSurfaceTurnRequest &&
          other.messages == messages &&
          other.document == document &&
          other.capabilities == capabilities;

  @override
  int get hashCode =>
      messages.hashCode + document.hashCode + capabilities.hashCode;

  factory RunLayoutSurfaceTurnRequest.fromJson(Map<String, dynamic> json) =>
      _$RunLayoutSurfaceTurnRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RunLayoutSurfaceTurnRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
