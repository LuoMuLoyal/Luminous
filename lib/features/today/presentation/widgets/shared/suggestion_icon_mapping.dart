import 'package:luminous/core/design/design.dart';
import 'package:material_ui/material_ui.dart';

/// Maps backend suggestion icon strings to Flutter [IconData].
///
/// When the backend introduces a new icon name not listed here, the fallback
/// [SemanticIcons.assistantEntry] is used. To add support for a new icon, simply add
/// an entry to [_mapping].
class SuggestionIconMapping {
  SuggestionIconMapping._();

  static const IconData _fallback = SemanticIcons.assistantFallbackIcon;

  /// Canonical mapping from backend icon string → [IconData].
  static const Map<String, IconData> _mapping = {
    'droplets': SemanticIcons.recordWater,
    'moon': SemanticIcons.recordSleep,
    'activity': SemanticIcons.recordActivity,
    'utensils': SemanticIcons.recordMeal,
    'user': SemanticIcons.profileUser,
    'clipboard': SemanticIcons.recordClipboard,
    'alert-triangle': SemanticIcons.statusWarning,
    'pill': SemanticIcons.recordMedicine,
    'trending-up': SemanticIcons.reportTrend,
    'lightbulb': SemanticIcons.assistantTip,
    'info': SemanticIcons.statusInfo,
  };

  /// Resolves a backend icon string to [IconData].
  ///
  /// Returns [_fallback] when [icon] is not recognised.
  static IconData resolve(String icon) {
    return _mapping[icon] ?? _fallback;
  }
}
