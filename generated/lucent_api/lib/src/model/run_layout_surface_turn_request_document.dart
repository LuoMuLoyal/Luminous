//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'run_layout_surface_turn_request_document.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RunLayoutSurfaceTurnRequestDocument {
  /// Returns a new [RunLayoutSurfaceTurnRequestDocument] instance.
  RunLayoutSurfaceTurnRequestDocument({required this.messages, this.dataModel});

  /// Agent-to-renderer messages, in arrival order.
  @JsonKey(name: r'messages', required: true, includeIfNull: false)
  final List<Map<String, Object>> messages;

  /// Data model snapshot, present when a surface was created with sendDataModel.
  @JsonKey(name: r'dataModel', required: false, includeIfNull: false)
  final Map<String, Object>? dataModel;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RunLayoutSurfaceTurnRequestDocument &&
          other.messages == messages &&
          other.dataModel == dataModel;

  @override
  int get hashCode => messages.hashCode + dataModel.hashCode;

  factory RunLayoutSurfaceTurnRequestDocument.fromJson(
    Map<String, dynamic> json,
  ) => _$RunLayoutSurfaceTurnRequestDocumentFromJson(json);

  Map<String, dynamic> toJson() =>
      _$RunLayoutSurfaceTurnRequestDocumentToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
