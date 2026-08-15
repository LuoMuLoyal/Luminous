//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/notification_list_item_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'notification_list_data_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class NotificationListDataDto {
  /// Returns a new [NotificationListDataDto] instance.
  NotificationListDataDto({required this.items, required this.total});

  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<NotificationListItemDto> items;

  /// Total count of notifications for the user.
  @JsonKey(name: r'total', required: true, includeIfNull: false)
  final num total;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationListDataDto &&
          other.items == items &&
          other.total == total;

  @override
  int get hashCode => items.hashCode + total.hashCode;

  factory NotificationListDataDto.fromJson(Map<String, dynamic> json) =>
      _$NotificationListDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationListDataDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
