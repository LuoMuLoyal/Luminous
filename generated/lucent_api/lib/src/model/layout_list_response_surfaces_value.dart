//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'layout_list_response_surfaces_value.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LayoutListResponseSurfacesValue {
  /// Returns a new [LayoutListResponseSurfacesValue] instance.
  LayoutListResponseSurfacesValue({
    required this.surface,

    required this.version,

    required this.schemaVersion,

    required this.payload,

    required this.updatedAt,
  });

  /// Surface identifier this layout belongs to.
  @JsonKey(name: r'surface', required: true, includeIfNull: false)
  final String surface;

  /// Optimistic-concurrency token. Send it back as `ifVersion` on the next write.
  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'version', required: true, includeIfNull: false)
  final int version;

  /// Shape version of `payload`, owned by the client.
  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'schemaVersion', required: true, includeIfNull: false)
  final int schemaVersion;

  /// Client-owned layout document. The server stores it verbatim and never interprets it.
  @JsonKey(name: r'payload', required: true, includeIfNull: true)
  final Object? payload;

  /// ISO-8601 timestamp of the last write.
  @JsonKey(name: r'updatedAt', required: true, includeIfNull: false)
  final String updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LayoutListResponseSurfacesValue &&
          other.surface == surface &&
          other.version == version &&
          other.schemaVersion == schemaVersion &&
          other.payload == payload &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode =>
      surface.hashCode +
      version.hashCode +
      schemaVersion.hashCode +
      (payload == null ? 0 : payload.hashCode) +
      updatedAt.hashCode;

  factory LayoutListResponseSurfacesValue.fromJson(Map<String, dynamic> json) =>
      _$LayoutListResponseSurfacesValueFromJson(json);

  Map<String, dynamic> toJson() =>
      _$LayoutListResponseSurfacesValueToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
