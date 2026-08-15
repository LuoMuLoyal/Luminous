//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'unread_count_data_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UnreadCountDataDto {
  /// Returns a new [UnreadCountDataDto] instance.
  UnreadCountDataDto({required this.count});

  /// Number of unread notifications.
  @JsonKey(name: r'count', required: true, includeIfNull: false)
  final num count;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnreadCountDataDto && other.count == count;

  @override
  int get hashCode => count.hashCode;

  factory UnreadCountDataDto.fromJson(Map<String, dynamic> json) =>
      _$UnreadCountDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UnreadCountDataDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
