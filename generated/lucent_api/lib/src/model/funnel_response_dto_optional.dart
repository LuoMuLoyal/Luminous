//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'funnel_response_dto_optional.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class FunnelResponseDtoOptional {
  /// Returns a new [FunnelResponseDtoOptional] instance.
  FunnelResponseDtoOptional({
    required this.visitSummaryPreviewed,

    required this.visitSummaryExported,

    required this.visitSummaryShareCreated,

    required this.visitSummaryShareOpened,
  });

  /// visit_summary_previewed count.
  @JsonKey(name: r'visitSummaryPreviewed', required: true, includeIfNull: false)
  final num visitSummaryPreviewed;

  /// visit_summary_exported count.
  @JsonKey(name: r'visitSummaryExported', required: true, includeIfNull: false)
  final num visitSummaryExported;

  /// visit_summary_share_created count.
  @JsonKey(
    name: r'visitSummaryShareCreated',
    required: true,
    includeIfNull: false,
  )
  final num visitSummaryShareCreated;

  /// visit_summary_share_opened count.
  @JsonKey(
    name: r'visitSummaryShareOpened',
    required: true,
    includeIfNull: false,
  )
  final num visitSummaryShareOpened;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunnelResponseDtoOptional &&
          other.visitSummaryPreviewed == visitSummaryPreviewed &&
          other.visitSummaryExported == visitSummaryExported &&
          other.visitSummaryShareCreated == visitSummaryShareCreated &&
          other.visitSummaryShareOpened == visitSummaryShareOpened;

  @override
  int get hashCode =>
      visitSummaryPreviewed.hashCode +
      visitSummaryExported.hashCode +
      visitSummaryShareCreated.hashCode +
      visitSummaryShareOpened.hashCode;

  factory FunnelResponseDtoOptional.fromJson(Map<String, dynamic> json) =>
      _$FunnelResponseDtoOptionalFromJson(json);

  Map<String, dynamic> toJson() => _$FunnelResponseDtoOptionalToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
