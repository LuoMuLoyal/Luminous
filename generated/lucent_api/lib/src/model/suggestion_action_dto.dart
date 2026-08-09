//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'suggestion_action_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SuggestionActionDto {
  /// Returns a new [SuggestionActionDto] instance.
  SuggestionActionDto({
    required this.actionId,
    required this.label,
    required this.route,
    required this.authRequired,
  });

  /// Unique action id
  @JsonKey(name: r'actionId', required: true, includeIfNull: false)
  final String actionId;

  /// Localized action label
  @JsonKey(name: r'label', required: true, includeIfNull: false)
  final String label;

  /// Deep-link route for navigation
  @JsonKey(name: r'route', required: true, includeIfNull: false)
  final String route;

  /// Whether authentication is required
  @JsonKey(name: r'authRequired', required: true, includeIfNull: false)
  final bool authRequired;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SuggestionActionDto &&
          other.actionId == actionId &&
          other.label == label &&
          other.route == route &&
          other.authRequired == authRequired;

  @override
  int get hashCode =>
      actionId.hashCode +
      label.hashCode +
      route.hashCode +
      authRequired.hashCode;

  factory SuggestionActionDto.fromJson(Map<String, dynamic> json) =>
      _$SuggestionActionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SuggestionActionDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
