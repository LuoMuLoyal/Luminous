import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/features/today/domain/entities/dashboard.dart';
import 'package:luminous/features/today/presentation/widgets/shared/view_models.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// A lightweight alert banner shown at the top of Today when the user has
/// no records yet. It nudges them toward logging their first entry.
class TodayRecordHintSection extends StatelessWidget {
  const TodayRecordHintSection({super.key, required this.dashboard});

  final TodayDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (!shouldShowRecordHint(dashboard)) {
      return const SizedBox.shrink();
    }

    return FAlert(
      variant: FAlertVariant.primary,
      icon: const Icon(FLucideIcons.info),
      title: Text(l10n.todayRecordHintTitle),
      subtitle: Text(l10n.todayRecordHintBody),
    );
  }
}
