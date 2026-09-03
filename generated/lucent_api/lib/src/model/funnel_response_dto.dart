//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/funnel_response_dto_daily_inner.dart';
import 'package:lucent_api/src/model/funnel_response_dto_optional.dart';
import 'package:lucent_api/src/model/funnel_response_dto_totals.dart';
import 'package:lucent_api/src/model/funnel_response_dto_window.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'funnel_response_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class FunnelResponseDto {
  /// Returns a new [FunnelResponseDto] instance.
  FunnelResponseDto({
    required this.daily,

    required this.optional,

    required this.totals,

    required this.window,
  });

  /// Per-UTC-day core funnel counts, ascending by date; empty when detailsSuppressed is true.
  @JsonKey(name: r'daily', required: true, includeIfNull: false)
  final List<FunnelResponseDtoDailyInner> daily;

  @JsonKey(name: r'optional', required: true, includeIfNull: false)
  final FunnelResponseDtoOptional optional;

  @JsonKey(name: r'totals', required: true, includeIfNull: false)
  final FunnelResponseDtoTotals totals;

  @JsonKey(name: r'window', required: true, includeIfNull: false)
  final FunnelResponseDtoWindow window;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunnelResponseDto &&
          other.daily == daily &&
          other.optional == optional &&
          other.totals == totals &&
          other.window == window;

  @override
  int get hashCode =>
      daily.hashCode + optional.hashCode + totals.hashCode + window.hashCode;

  factory FunnelResponseDto.fromJson(Map<String, dynamic> json) =>
      _$FunnelResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$FunnelResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
