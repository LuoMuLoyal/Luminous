import 'package:flutter/material.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MedicineErrorView extends StatelessWidget {
  const MedicineErrorView({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return StateErrorView(
      title: l10n.medicineErrorTitle,
      description: l10n.medicineErrorDescription,
      icon: SemanticIcons.medicineBottle,
      actionLabel: l10n.todayRetryAction,
      onAction: onRetry,
      tone: StateTone.warning,
    );
  }
}
