import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/today/domain/entities/dashboard.dart';
import 'package:luminous/features/today/presentation/widgets/shared/view_models.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// A lightweight alert banner shown at the top of Today when the user has
/// no records yet. It nudges them toward logging their first entry.
///
/// This is the official "empty state" pattern for Today — rather than a
/// full-page empty view that hides the dashboard structure, we keep the
/// full dashboard visible (suggestions, quick actions, etc.) and surface
/// a prominent hint banner with a CTA button.
class TodayRecordHintSection extends StatelessWidget {
  const TodayRecordHintSection({super.key, required this.dashboard});

  final TodayDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (!shouldShowRecordHint(dashboard)) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FAlert(
          variant: FAlertVariant.primary,
          icon: const Icon(FLucideIcons.info),
          title: Text(l10n.todayRecordHintTitle),
          subtitle: Text(l10n.todayRecordHintBody),
        ),
        const SizedBox(height: Spacing.level2),
        FButton(
          variant: FButtonVariant.ghost,
          size: FButtonSizeVariant.sm,
          mainAxisSize: MainAxisSize.min,
          onPress: () => context.push(AppRoutes.recordCreate),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.todayRecordHintAction),
              const SizedBox(width: Spacing.level1),
              const Icon(FLucideIcons.arrowRight, size: 16),
            ],
          ),
        ),
      ],
    );
  }
}
