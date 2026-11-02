//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'save_layout_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SaveLayoutRequest {
  /// Returns a new [SaveLayoutRequest] instance.
  SaveLayoutRequest({
    this.ifVersion,

    required this.schemaVersion,

    required this.payload,
  });

  /// Version the client last read. Omit or send null for an unconditional write.
  // minimum: 1
  // maximum: 9007199254740991
  @JsonKey(name: r'ifVersion', required: false, includeIfNull: false)
  final int? ifVersion;

  /// Shape version of `payload`; must be within the server-supported range.
  // minimum: 1
  // maximum: 9007199254740991
  @JsonKey(name: r'schemaVersion', required: true, includeIfNull: false)
  final int schemaVersion;

  /// Client-owned layout document. Stored verbatim; the server never interprets it. An object for page layouts, an array for tab_chrome.
  @JsonKey(name: r'payload', required: true, includeIfNull: true)
  final Object? payload;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaveLayoutRequest &&
          other.ifVersion == ifVersion &&
          other.schemaVersion == schemaVersion &&
          other.payload == payload;

  @override
  int get hashCode =>
      (ifVersion == null ? 0 : ifVersion.hashCode) +
      schemaVersion.hashCode +
      (payload == null ? 0 : payload.hashCode);

  factory SaveLayoutRequest.fromJson(Map<String, dynamic> json) =>
      _$SaveLayoutRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SaveLayoutRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
