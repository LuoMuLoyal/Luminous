//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'generate_candidates_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GenerateCandidatesRequest {
  /// Returns a new [GenerateCandidatesRequest] instance.
  GenerateCandidatesRequest({
    required this.text,

    required this.occurredAt,

    this.timezone,
  });

  /// Natural-language note to be parsed into candidate daily records.
  @JsonKey(name: r'text', required: true, includeIfNull: false)
  final String text;

  /// Wake date in YYYY-MM-DD format used as the candidate record date baseline.
  @JsonKey(name: r'occurredAt', required: true, includeIfNull: false)
  final String occurredAt;

  /// Optional user timezone hint used only for interpretation wording. No server timezone conversion is persisted.
  @JsonKey(name: r'timezone', required: false, includeIfNull: false)
  final String? timezone;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenerateCandidatesRequest &&
          other.text == text &&
          other.occurredAt == occurredAt &&
          other.timezone == timezone;

  @override
  int get hashCode => text.hashCode + occurredAt.hashCode + timezone.hashCode;

  factory GenerateCandidatesRequest.fromJson(Map<String, dynamic> json) =>
      _$GenerateCandidatesRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GenerateCandidatesRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
