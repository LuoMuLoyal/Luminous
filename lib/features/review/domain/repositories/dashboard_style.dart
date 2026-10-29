/// Design tokens the review dashboard repository needs, as an injectable
/// seam.
///
/// `data/` may not import `application/`, so the repository takes a token
/// table through its constructor; `application/mappers/dashboard_style.dart`
/// supplies the real one from `core/design`, and the composition root wires
/// the two together.
library;

import 'package:flutter/widgets.dart' show IconData;
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';

/// Resolves the presentation tokens for review dashboard view models.
abstract interface class ReviewDashboardTokens {
  IconData metricIcon(ReviewDataKind kind);

  SemanticColor metricColor(ReviewDataKind kind);

  IconData insightIcon(ReviewInsightKind kind);

  SemanticColor insightColor(ReviewInsightKind kind);

  List<ReviewExportAction> get exportActions;
}
