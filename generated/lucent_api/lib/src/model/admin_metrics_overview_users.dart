//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'admin_metrics_overview_users.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdminMetricsOverviewUsers {
  /// Returns a new [AdminMetricsOverviewUsers] instance.
  AdminMetricsOverviewUsers({
    required this.total,

    required this.active,

    required this.suspended,

    required this.newLast30Days,
  });

  // minimum: 0
  // maximum: 9007199254740991
  @JsonKey(name: r'total', required: true, includeIfNull: false)
  final int total;

  // minimum: 0
  // maximum: 9007199254740991
  @JsonKey(name: r'active', required: true, includeIfNull: false)
  final int active;

  // minimum: 0
  // maximum: 9007199254740991
  @JsonKey(name: r'suspended', required: true, includeIfNull: false)
  final int suspended;

  // minimum: 0
  // maximum: 9007199254740991
  @JsonKey(name: r'newLast30Days', required: true, includeIfNull: false)
  final int newLast30Days;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminMetricsOverviewUsers &&
          other.total == total &&
          other.active == active &&
          other.suspended == suspended &&
          other.newLast30Days == newLast30Days;

  @override
  int get hashCode =>
      total.hashCode +
      active.hashCode +
      suspended.hashCode +
      newLast30Days.hashCode;

  factory AdminMetricsOverviewUsers.fromJson(Map<String, dynamic> json) =>
      _$AdminMetricsOverviewUsersFromJson(json);

  Map<String, dynamic> toJson() => _$AdminMetricsOverviewUsersToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
