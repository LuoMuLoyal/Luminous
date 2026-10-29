import 'package:flutter/material.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/design/tokens/lucide_icon_bridge.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';
import 'package:luminous/shared/design/review_dashboard.dart';

/// Design tokens for the review dashboard view models.
///
/// Icons and semantic colors are a presentation concern: the review repository
/// maps wire data and reads its tokens from here instead of importing
/// `core/design` from `data/`.
final class ReviewDashboardStyle implements ReviewDashboardTokens {
  const ReviewDashboardStyle();

  @override
  IconData metricIcon(ReviewDataKind kind) {
    return switch (kind) {
      ReviewDataKind.medication => SemanticIcons.recordMedicine,
      ReviewDataKind.water => SemanticIcons.recordWater,
      ReviewDataKind.sleep => SemanticIcons.recordSleep,
      ReviewDataKind.general => SemanticIcons.profileCondition,
    };
  }

  @override
  SemanticColor metricColor(ReviewDataKind kind) {
    return switch (kind) {
      ReviewDataKind.medication => SemanticColor.primary,
      ReviewDataKind.water => SemanticColor.info,
      ReviewDataKind.sleep => SemanticColor.warning,
      ReviewDataKind.general => SemanticColor.success,
    };
  }

  @override
  IconData insightIcon(ReviewInsightKind kind) {
    return switch (kind) {
      ReviewInsightKind.medication => SemanticIcons.reportInsightAdherence,
      ReviewInsightKind.hydration => SemanticIcons.recordWater,
      ReviewInsightKind.sleep => SemanticIcons.recordSleep,
      ReviewInsightKind.general => SemanticIcons.reportChart,
    };
  }

  @override
  SemanticColor insightColor(ReviewInsightKind kind) {
    return switch (kind) {
      ReviewInsightKind.medication => SemanticColor.primary,
      ReviewInsightKind.hydration => SemanticColor.info,
      ReviewInsightKind.sleep => SemanticColor.warning,
      ReviewInsightKind.general => SemanticColor.success,
    };
  }

  @override
  List<ReviewExportAction> get exportActions => <ReviewExportAction>[
    ReviewExportAction(
      kind: ReviewExportKind.hospital,
      iconName: LucideIconBridge.nameOf(SemanticIcons.medicineKit)!,
      color: SemanticColor.primary,
    ),
    ReviewExportAction(
      kind: ReviewExportKind.monthly,
      iconName: LucideIconBridge.nameOf(SemanticIcons.reportMonthlyExport)!,
      color: SemanticColor.primary,
    ),
    ReviewExportAction(
      kind: ReviewExportKind.print,
      iconName: LucideIconBridge.nameOf(SemanticIcons.actionExport)!,
      color: SemanticColor.primary,
    ),
    ReviewExportAction(
      kind: ReviewExportKind.clinicShare,
      iconName: LucideIconBridge.nameOf(SemanticIcons.actionShare)!,
      color: SemanticColor.primary,
    ),
  ];
}
