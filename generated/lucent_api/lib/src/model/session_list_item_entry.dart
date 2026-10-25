//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'session_list_item_entry.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SessionListItemEntry {
  /// Returns a new [SessionListItemEntry] instance.
  SessionListItemEntry({
    required this.id,

    required this.lastUsedAt,

    required this.createdAt,

    required this.expiresAt,

    required this.isCurrent,
  });

  /// 会话 ID
  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  /// 最近使用时间 (ISO-8601)
  @JsonKey(name: r'lastUsedAt', required: true, includeIfNull: true)
  final String? lastUsedAt;

  /// 创建时间 (ISO-8601)
  @JsonKey(name: r'createdAt', required: true, includeIfNull: false)
  final String createdAt;

  /// 过期时间 (ISO-8601)
  @JsonKey(name: r'expiresAt', required: true, includeIfNull: false)
  final String expiresAt;

  /// 是否为发起本次请求的会话（Bearer 客户端恒为 false）
  @JsonKey(name: r'isCurrent', required: true, includeIfNull: false)
  final bool isCurrent;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionListItemEntry &&
          other.id == id &&
          other.lastUsedAt == lastUsedAt &&
          other.createdAt == createdAt &&
          other.expiresAt == expiresAt &&
          other.isCurrent == isCurrent;

  @override
  int get hashCode =>
      id.hashCode +
      (lastUsedAt == null ? 0 : lastUsedAt.hashCode) +
      createdAt.hashCode +
      expiresAt.hashCode +
      isCurrent.hashCode;

  factory SessionListItemEntry.fromJson(Map<String, dynamic> json) =>
      _$SessionListItemEntryFromJson(json);

  Map<String, dynamic> toJson() => _$SessionListItemEntryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
