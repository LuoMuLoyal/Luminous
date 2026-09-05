//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/funnel_response_totals.dart';
import 'package:lucent_api/src/model/funnel_response_optional.dart';
import 'package:lucent_api/src/model/funnel_response_window.dart';
import 'package:lucent_api/src/model/funnel_response_daily.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'funnel_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class FunnelResponse {
  /// Returns a new [FunnelResponse] instance.
  FunnelResponse({
    required this.daily,

    required this.optional,

    required this.totals,

    required this.window,
  });

  /// Per-UTC-day core funnel counts, ascending by date; empty when detailsSuppressed is true.
  @JsonKey(name: r'daily', required: true, includeIfNull: false)
  final List<FunnelResponseDaily> daily;

  @JsonKey(name: r'optional', required: true, includeIfNull: false)
  final FunnelResponseOptional optional;

  @JsonKey(name: r'totals', required: true, includeIfNull: false)
  final FunnelResponseTotals totals;

  @JsonKey(name: r'window', required: true, includeIfNull: false)
  final FunnelResponseWindow window;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunnelResponse &&
          other.daily == daily &&
          other.optional == optional &&
          other.totals == totals &&
          other.window == window;

  @override
  int get hashCode =>
      daily.hashCode + optional.hashCode + totals.hashCode + window.hashCode;

  factory FunnelResponse.fromJson(Map<String, dynamic> json) =>
      _$FunnelResponseFromJson(json);

  Map<String, dynamic> toJson() => _$FunnelResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
