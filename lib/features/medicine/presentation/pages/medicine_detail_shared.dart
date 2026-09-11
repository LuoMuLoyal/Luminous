import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Source badge widget displaying 'cn' or 'drugbank' label.
class SourceBadge extends StatelessWidget {
  const SourceBadge({super.key, required this.source, required this.l10n});

  final String source;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return FBadge(
      variant: FBadgeVariant.primary,
      style: .delta(
        decoration: .boxDelta(
          borderRadius: context.theme.style.borderRadius.xs,
        ),
      ),
      child: Text(
        source == 'drugbank'
            ? l10n.medicineSearchSourceDrugbank
            : l10n.medicineSearchSourceCn,
      ),
    );
  }
}

/// Reference notice widget with info icon and text.
class ReferenceNotice extends StatelessWidget {
  const ReferenceNotice({super.key, required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.sm,
      ),
      decoration: BoxDecoration(
        color: SemanticColor.info.muted(context),
        borderRadius: context.theme.style.borderRadius.xs,
      ),
      child: Row(
        children: [
          Icon(
            SemanticIcons.statusInfo,
            size: Spacing.lg,
            color: SemanticColor.info.solid(context),
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(
              l10n.medicineReferenceNoticeTitle,
              style: context.theme.typography.body.xs.copyWith(
                color: colors.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Risk check entry widget with navigation arrow.
class RiskCheckEntry extends StatelessWidget {
  const RiskCheckEntry({super.key, required this.l10n, required this.onTap});

  final AppLocalizations l10n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return FTappable(
      onPress: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
        child: Row(
          children: [
            Icon(
              SemanticIcons.safetyCaution,
              size: Spacing.lg,
              color: SemanticColor.primary.solid(context),
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: Text(
                l10n.medicineDetailRiskCheckEntry,
                style: context.theme.typography.body.xs.copyWith(
                  color: colors.foreground,
                ),
              ),
            ),
            Icon(
              SemanticIcons.actionNext,
              size: Spacing.lg,
              color: SemanticColor.neutral.solid(context),
            ),
          ],
        ),
      ),
    );
  }
}
