//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_detail_response_external_links.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineDetailResponseExternalLinks {
  /// Returns a new [MedicineDetailResponseExternalLinks] instance.
  MedicineDetailResponseExternalLinks({
    required this.resource,

    required this.url,
  });

  /// Source resource label.
  @JsonKey(name: r'resource', required: true, includeIfNull: false)
  final String resource;

  /// Outbound URL for that resource.
  @JsonKey(name: r'url', required: true, includeIfNull: false)
  final String url;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineDetailResponseExternalLinks &&
          other.resource == resource &&
          other.url == url;

  @override
  int get hashCode => resource.hashCode + url.hashCode;

  factory MedicineDetailResponseExternalLinks.fromJson(
    Map<String, dynamic> json,
  ) => _$MedicineDetailResponseExternalLinksFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MedicineDetailResponseExternalLinksToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
