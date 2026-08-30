import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/database/connection_providers.dart';
import 'package:luminous/core/database/sync/worker.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/l10n/app_localizations.dart';

import 'sync_failed_details.dart';

/// A warning banner shown in the Mine page when there are permanently
/// failed sync items.
///
/// Displays the count of failed items and a call-to-action. Tapping the
/// action opens the local failure details and retry controls.
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
          onTap: () async {
            final entries = await ref
                .read(pendingSyncDaoProvider)
                .fetchPermanentlyFailed();
            if (!context.mounted) return;
            await showMineSyncFailedDetailsDialog(
              context: context,
              entries: entries,
            );
          },
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
            horizontal: Spacing.level4,
            vertical: Spacing.level3,
          ),
          child: Row(
            children: [
              Icon(
                SemanticIcons.statusWarning,
                size: 20,
                color: SemanticColor.warning.solid(context),
              ),
              const SizedBox(width: Spacing.level3),
              Expanded(
                child: Text(
                  message,
                  style: TypographyToken.level4
                      .body(context)
                      .copyWith(color: colors.foreground),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: Spacing.level3),
              Text(
                actionLabel,
                style: TypographyToken.level4
                    .body(context)
                    .copyWith(
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
