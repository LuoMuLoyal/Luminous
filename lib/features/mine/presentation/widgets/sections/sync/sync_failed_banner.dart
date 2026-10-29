import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/database/sync/worker.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/mine/presentation/routes.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// A warning banner shown in the Mine page when there are permanently
/// failed sync items.
///
/// Displays the count of failed items and a call-to-action. Tapping the
/// action opens the sync failures page, which owns the entry list and the
/// retry controls.
class MineSyncFailedBanner extends ConsumerWidget {
  const MineSyncFailedBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final failedCountAsync = ref.watch(syncFailedCountProvider);

    return failedCountAsync.maybeWhen(
      data: (count) {
        if (count <= 0) return const SizedBox.shrink();
        return _Banner(
          message: l10n.mineSyncFailedWarning(count),
          actionLabel: l10n.mineSyncFailedAction,
          onTap: () => const MineSyncFailuresRoute().push(context),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({
    required this.message,
    required this.actionLabel,
    required this.onTap,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return FCard(
      child: FTappable(
        onPress: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: SemanticColor.warning.subtle(context),
            borderRadius: context.theme.style.borderRadius.sm,
            border: Border.all(color: SemanticColor.warning.border(context)),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.lg,
            vertical: Spacing.md,
          ),
          child: Row(
            children: [
              Icon(
                SemanticIcons.statusWarning,
                size: 20,
                color: SemanticColor.warning.solid(context),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Text(
                  message,
                  style: typography.body.sm.copyWith(color: colors.foreground),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: Spacing.md),
              Text(
                actionLabel,
                style: typography.body.sm.copyWith(
                  color: SemanticColor.warning.solid(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
