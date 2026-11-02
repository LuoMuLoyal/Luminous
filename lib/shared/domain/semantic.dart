/// Shared domain kernel: the presentation-agnostic vocabulary that domain
/// entities use to describe colour and icon identity.
///
/// Both are pure Dart value types. Resolving them to an actual `Color` or
/// `IconData` is a presentation concern: see
/// `core/design/color/semantic_color.dart` (tonal palette) and each feature's
/// `presentation/` icon mapping.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

/// Semantic colour token used by domain/data layers to stay theme-agnostic.
///
/// Replaces the former `AppColors` enum. The actual palette (10 pre-computed
/// tones per colour) is resolved in the presentation layer against the current
/// Forui theme.
///
/// [neutral] covers entities that previously used `AppColors.secondary`,
/// `.muted`, `.foreground`, `.background`, or `.border` — i.e. "no particular
/// semantic meaning".
@JsonEnum()
enum SemanticColor { primary, success, warning, info, destructive, neutral }

/// Icon identity for a domain entity, resolvable to an `IconData` in the
/// presentation layer.
///
/// Domain entities used to carry a raw `IconData`, which cannot be
/// JSON-encoded and drags `flutter/material` into the pure layer. They carry a
/// [SemanticIcon] (or a feature-local icon enum) instead; a feature's
/// `presentation/` maps it to the concrete glyph.
enum SemanticIcon {
  add,
  alert,
  calendar,
  camera,
  chart,
  check,
  clock,
  close,
  download,
  edit,
  heart,
  home,
  info,
  medicine,
  moon,
  notifications,
  person,
  search,
  settings,
  share,
  sleep,
  sparkles,
  sun,
  trash,
  trendDown,
  trendUp,
  water,
}
