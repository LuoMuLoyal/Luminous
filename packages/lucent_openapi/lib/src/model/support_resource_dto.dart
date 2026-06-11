//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/support_resource_action_type.dart';
import 'package:lucent_openapi/src/model/support_resource_scope.dart';
import 'package:json_annotation/json_annotation.dart';

part 'support_resource_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SupportResourceDto {
  /// Returns a new [SupportResourceDto] instance.
  SupportResourceDto({
    required this.id,

    required this.scope,

    required this.title,

    this.titleKey,

    this.subtitle,

    this.subtitleKey,

    this.icon,

    this.actionUrl,

    this.actionType,

    required this.available,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(
    name: r'scope',
    required: true,
    includeIfNull: false,
    unknownEnumValue: SupportResourceScope.unknownDefaultOpenApi,
  )
  final SupportResourceScope scope;

  @JsonKey(name: r'title', required: true, includeIfNull: false)
  final String title;

  @JsonKey(name: r'titleKey', required: false, includeIfNull: false)
  final String? titleKey;

  @JsonKey(name: r'subtitle', required: false, includeIfNull: false)
  final String? subtitle;

  @JsonKey(name: r'subtitleKey', required: false, includeIfNull: false)
  final String? subtitleKey;

  @JsonKey(name: r'icon', required: false, includeIfNull: false)
  final String? icon;

  @JsonKey(name: r'actionUrl', required: false, includeIfNull: false)
  final String? actionUrl;

  @JsonKey(
    name: r'actionType',
    required: false,
    includeIfNull: false,
    unknownEnumValue: SupportResourceActionType.unknownDefaultOpenApi,
  )
  final SupportResourceActionType? actionType;

  /// Whether the resource is currently available.
  @JsonKey(name: r'available', required: true, includeIfNull: false)
  final bool available;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupportResourceDto &&
          other.id == id &&
          other.scope == scope &&
          other.title == title &&
          other.titleKey == titleKey &&
          other.subtitle == subtitle &&
          other.subtitleKey == subtitleKey &&
          other.icon == icon &&
          other.actionUrl == actionUrl &&
          other.actionType == actionType &&
          other.available == available;

  @override
  int get hashCode =>
      id.hashCode +
      scope.hashCode +
      title.hashCode +
      (titleKey == null ? 0 : titleKey.hashCode) +
      (subtitle == null ? 0 : subtitle.hashCode) +
      (subtitleKey == null ? 0 : subtitleKey.hashCode) +
      (icon == null ? 0 : icon.hashCode) +
      (actionUrl == null ? 0 : actionUrl.hashCode) +
      (actionType == null ? 0 : actionType.hashCode) +
      available.hashCode;

  factory SupportResourceDto.fromJson(Map<String, dynamic> json) =>
      _$SupportResourceDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SupportResourceDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
