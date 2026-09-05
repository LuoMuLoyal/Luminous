//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'funnel_response_window.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class FunnelResponseWindow {
  /// Returns a new [FunnelResponseWindow] instance.
  FunnelResponseWindow({
    required this.dateFrom,

    required this.dateTo,

    required this.generatedAt,

    required this.detailsSuppressed,
  });

  /// Window start (inclusive), UTC calendar day (YYYY-MM-DD).
  @JsonKey(name: r'dateFrom', required: true, includeIfNull: false)
  final String dateFrom;

  /// Window end (inclusive), UTC calendar day (YYYY-MM-DD).
  @JsonKey(name: r'dateTo', required: true, includeIfNull: false)
  final String dateTo;

  /// Response generation time (ISO 8601).
  @JsonKey(name: r'generatedAt', required: true, includeIfNull: false)
  final String generatedAt;

  /// True when the window core-funnel total is below the fixed small-sample threshold — per-day group details are suppressed (daily is empty), window totals are still returned so the admin UI knows the sample is too small to break down.
  @JsonKey(name: r'detailsSuppressed', required: true, includeIfNull: false)
  final bool detailsSuppressed;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunnelResponseWindow &&
          other.dateFrom == dateFrom &&
          other.dateTo == dateTo &&
          other.generatedAt == generatedAt &&
          other.detailsSuppressed == detailsSuppressed;

  @override
  int get hashCode =>
      dateFrom.hashCode +
      dateTo.hashCode +
      generatedAt.hashCode +
      detailsSuppressed.hashCode;

  factory FunnelResponseWindow.fromJson(Map<String, dynamic> json) =>
      _$FunnelResponseWindowFromJson(json);

  Map<String, dynamic> toJson() => _$FunnelResponseWindowToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
