import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Error state shown when the clinic summary preview fails to load.
class ClinicSummaryErrorView extends StatelessWidget {
  const ClinicSummaryErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(Spacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            SemanticIcons.statusWarning,
            size: 32,
            color: SemanticColor.warning.solid(context),
          ),
          const SizedBox(height: Spacing.md),
          Text(
            message,
            style: context.theme.typography.body.sm,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Spacing.lg),
          FButton(
            variant: FButtonVariant.outline,
            onPress: onRetry,
            child: Text(l10n.todayRetryAction),
          ),
        ],
      ),
    );
  }
}
