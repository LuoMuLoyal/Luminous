//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/admin_metrics_overview_users.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'admin_metrics_overview.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdminMetricsOverview {
  /// Returns a new [AdminMetricsOverview] instance.
  AdminMetricsOverview({
    required this.generatedAt,

    required this.users,

    required this.productEventLogLast24Hours,
  });

  @JsonKey(name: r'generatedAt', required: true, includeIfNull: false)
  final DateTime generatedAt;

  @JsonKey(name: r'users', required: true, includeIfNull: false)
  final AdminMetricsOverviewUsers users;

  // minimum: 0
  // maximum: 9007199254740991
  @JsonKey(
    name: r'productEventLogLast24Hours',
    required: true,
    includeIfNull: false,
  )
  final int productEventLogLast24Hours;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminMetricsOverview &&
          other.generatedAt == generatedAt &&
          other.users == users &&
          other.productEventLogLast24Hours == productEventLogLast24Hours;

  @override
  int get hashCode =>
      generatedAt.hashCode +
      users.hashCode +
      productEventLogLast24Hours.hashCode;

  factory AdminMetricsOverview.fromJson(Map<String, dynamic> json) =>
      _$AdminMetricsOverviewFromJson(json);

  Map<String, dynamic> toJson() => _$AdminMetricsOverviewToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
