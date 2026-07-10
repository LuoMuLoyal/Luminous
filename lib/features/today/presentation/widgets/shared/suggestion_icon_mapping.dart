import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// Maps backend suggestion icon strings to Flutter [IconData].
///
/// When the backend introduces a new icon name not listed here, the fallback
/// [FLucideIcons.sparkles] is used. To add support for a new icon, simply add
/// an entry to [_mapping].
class SuggestionIconMapping {
  SuggestionIconMapping._();

  static const IconData _fallback = FLucideIcons.sparkles;

  /// Canonical mapping from backend icon string → [IconData].
  static const Map<String, IconData> _mapping = {
    'droplets': FLucideIcons.droplets,
    'moon': FLucideIcons.moon,
    'activity': FLucideIcons.activity,
    'coffee': FLucideIcons.coffee,
    'user': FLucideIcons.userRound,
    'clipboard': FLucideIcons.clipboardList,
    'alert-triangle': FLucideIcons.triangleAlert,
    'pill': FLucideIcons.pill,
    'trending-up': FLucideIcons.trendingUp,
    'lightbulb': FLucideIcons.lightbulb,
    'info': FLucideIcons.info,
  };

  /// Resolves a backend icon string to [IconData].
  ///
  /// Returns [_fallback] when [icon] is not recognised.
  static IconData resolve(String icon) {
    return _mapping[icon] ?? _fallback;
  }
}
