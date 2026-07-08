// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'support_resource_action_type.dart';
import 'support_resource_scope.dart';

part 'support_resource_dto.g.dart';

@JsonSerializable()
class SupportResourceDto {
  const SupportResourceDto({
    required this.id,
    required this.scope,
    required this.title,
    required this.available,
    this.titleKey,
    this.subtitle,
    this.subtitleKey,
    this.icon,
    this.actionUrl,
    this.actionType,
  });

  factory SupportResourceDto.fromJson(Map<String, Object?> json) =>
      _$SupportResourceDtoFromJson(json);

  final String id;
  final SupportResourceScope scope;
  final String title;
  final String? titleKey;
  final String? subtitle;
  final String? subtitleKey;
  final String? icon;
  final String? actionUrl;
  final SupportResourceActionType? actionType;

  /// Whether the resource is currently available.
  final bool available;

  Map<String, Object?> toJson() => _$SupportResourceDtoToJson(this);
}
