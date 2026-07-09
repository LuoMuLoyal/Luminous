// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'suggestion_action_dto.g.dart';

@JsonSerializable()
class SuggestionActionDto {
  const SuggestionActionDto({
    required this.actionId,
    required this.label,
    required this.route,
    required this.authRequired,
  });

  factory SuggestionActionDto.fromJson(Map<String, Object?> json) =>
      _$SuggestionActionDtoFromJson(json);

  /// Unique action id
  final String actionId;

  /// Localized action label
  final String label;

  /// Deep-link route for navigation
  final String route;

  /// Whether authentication is required
  final bool authRequired;

  Map<String, Object?> toJson() => _$SuggestionActionDtoToJson(this);
}
