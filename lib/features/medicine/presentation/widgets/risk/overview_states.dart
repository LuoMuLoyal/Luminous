import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Stale banner (LLM only, when data is stale).
class StaleBanner extends StatelessWidget {
  const StaleBanner({super.key, required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: SemanticColor.warning.subtle(context),
        shape: RoundedSuperellipseBorder(
          borderRadius: context.theme.style.borderRadius.md,
          side: BorderSide(color: SemanticColor.warning.border(context)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level4),
        child: Row(
          children: [
            Icon(
              SemanticIcons.statusError,
              color: SemanticColor.warning.solid(context),
              size: IconSizeTokens.md,
            ),
            const SizedBox(width: Spacing.level3),
            Expanded(
              child: Text(
                l10n.medicineRiskCheckStaleBanner,
                style: context.theme.typography.body.xs.copyWith(
                  color: context.theme.colors.foreground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// LLM empty state — shown when LLM check has not been run yet.
class LlmEmptyState extends StatelessWidget {
  const LlmEmptyState({
    super.key,
    required this.l10n,
    required this.onRun,
    required this.isRunning,
  });

  final AppLocalizations l10n;
  final VoidCallback onRun;
  final bool isRunning;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    return Padding(
      padding: const EdgeInsets.all(Spacing.level6),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              SemanticIcons.aiEntry,
              size: IconSizeTokens.xl2,
              color: SemanticColor.neutral.solid(context),
            ),
            const SizedBox(height: Spacing.level4),
            Text(
              l10n.medicineRiskCheckLlmEmptyTitle,
              style: typography.body.md.copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.level2),
            Text(
              l10n.medicineRiskCheckLlmEmptyBody,
              style: typography.body.xs.copyWith(
                color: SemanticColor.neutral.solid(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.level5),
            FButton(
              onPress: isRunning ? null : onRun,
              child: isRunning
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox.square(
                          dimension: IconSizeTokens.sm,
                          child: FCircularProgress.loader(size: .sm),
                        ),
                        const SizedBox(width: Spacing.level2),
                        Text(l10n.medicineRiskCheckRunLlm),
                      ],
                    )
                  : Text(l10n.medicineRiskCheckRunLlm),
            ),
          ],
        ),
      ),
    );
  }
}

/// Never checked state (static tab) — shown when static check has not been run.
class NeverCheckedState extends StatelessWidget {
  const NeverCheckedState({
    super.key,
    required this.l10n,
    required this.onRun,
    required this.isRunning,
  });

  final AppLocalizations l10n;
  final VoidCallback onRun;
  final bool isRunning;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Spacing.level6),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              SemanticIcons.safetySafe,
              size: IconSizeTokens.xl2,
              color: SemanticColor.neutral.solid(context),
            ),
            const SizedBox(height: Spacing.level4),
            Text(
              l10n.medicineRiskCheckNeverChecked,
              style: context.theme.typography.body.md.copyWith(
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.level5),
            FButton(
              onPress: isRunning ? null : onRun,
              child: isRunning
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox.square(
                          dimension: IconSizeTokens.sm,
                          child: FCircularProgress.loader(size: .sm),
                        ),
                        const SizedBox(width: Spacing.level2),
                        Text(l10n.medicineRiskCheckRunStatic),
                      ],
                    )
                  : Text(l10n.medicineRiskCheckRunStatic),
            ),
          ],
        ),
      ),
    );
  }
}

/// LLM unavailable state — shown when LLM service is not configured.
class LlmUnavailableState extends StatelessWidget {
  const LlmUnavailableState({super.key, required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Spacing.level6),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              SemanticIcons.statusSkipped,
              size: IconSizeTokens.xl2,
              color: SemanticColor.neutral.solid(context),
            ),
            const SizedBox(height: Spacing.level4),
            Text(
              l10n.medicineRiskCheckLlmUnavailable,
              style: context.theme.typography.body.md.copyWith(
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
