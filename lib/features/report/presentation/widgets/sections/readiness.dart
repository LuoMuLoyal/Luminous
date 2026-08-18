import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/l10n/app_localizations.dart';

enum ReportReadinessStatus { signedOut, insufficient, ready }

class ReportReadinessSection extends StatelessWidget {
  const ReportReadinessSection({
    super.key,
    required this.status,
    required this.generatedAtLabel,
    required this.l10n,
    this.insufficientMetricCount = 0,
    this.needsAttentionMetricCount = 0,
    this.rangeLabel = '',
    this.onSignIn,
    this.onContinueRecord,
    this.onGenerate,
    this.onSync,
    this.isGenerating = false,
  });

  final ReportReadinessStatus status;
  final String generatedAtLabel;
  final AppLocalizations l10n;
  final int insufficientMetricCount;
  final int needsAttentionMetricCount;

  /// Localized label for the selected date range (e.g. "近 7 天").
  /// Used in the ready title so it reflects the actual selected range.
  final String rangeLabel;

  final VoidCallback? onSignIn;
  final VoidCallback? onContinueRecord;
  final VoidCallback? onGenerate;
  final VoidCallback? onSync;
  final bool isGenerating;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return FCard(
      key: const Key('report-readiness-card'),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ExcludeSemantics(
                  child: FAvatar.raw(
                    size: Spacing.level8,
                    child: Icon(
                      _statusIcon,
                      color: _statusColor.solid(context),
                      size: Spacing.level5,
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.level3),
                _StatusBadge(label: _badgeLabel, color: _statusColor),
              ],
            ),
            const SizedBox(height: Spacing.level4),
            Text(
              _title,
              style: TypographyToken.level6
                  .display(context)
                  .copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: Spacing.level2),
            Text(
              _description,
              style: TypographyToken.level4
                  .body(context)
                  .copyWith(color: colors.mutedForeground),
            ),
            if (generatedAtLabel.isNotEmpty) ...[
              const SizedBox(height: Spacing.level3),
              Row(
                children: [
                  ExcludeSemantics(
                    child: Icon(
                      SemanticIcons.statusPending,
                      color: colors.mutedForeground,
                      size: Spacing.level5,
                    ),
                  ),
                  const SizedBox(width: Spacing.level2),
                  Expanded(
                    child: Text(
                      l10n.reportReadinessUpdatedAt(generatedAtLabel),
                      style: TypographyToken.level3
                          .body(context)
                          .copyWith(color: colors.mutedForeground),
                    ),
                  ),
                ],
              ),
            ],
            if (status == ReportReadinessStatus.insufficient) ...[
              if (insufficientMetricCount > 0) ...[
                const SizedBox(height: Spacing.level3),
                Text(
                  l10n.reportReadinessMissingMetricsHint(
                    insufficientMetricCount,
                  ),
                  style: TypographyToken.level3
                      .body(context)
                      .copyWith(color: colors.mutedForeground),
                ),
              ],
              if (needsAttentionMetricCount > 0) ...[
                const SizedBox(height: Spacing.level3),
                Text(
                  l10n.reportReadinessNeedsAttentionMetricsHint(
                    needsAttentionMetricCount,
                  ),
                  style: TypographyToken.level3
                      .body(context)
                      .copyWith(color: colors.mutedForeground),
                ),
              ],
            ],
            const SizedBox(height: Spacing.level4),
            Row(
              children: [
                Expanded(
                  child: _PrimaryAction(status: status, section: this),
                ),
                if (_showSecondaryAction) ...[
                  const SizedBox(width: Spacing.level3),
                  Expanded(
                    child: FButton(
                      key: const Key('report-readiness-sync-action'),
                      onPress: onSync,
                      variant: FButtonVariant.outline,
                      prefix: const Icon(
                        SemanticIcons.actionRefresh,
                        size: IconSizeTokens.level2,
                      ),
                      child: Text(l10n.reportSyncAction),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool get _showSecondaryAction => status != ReportReadinessStatus.signedOut;

  SemanticColor get _statusColor => switch (status) {
    ReportReadinessStatus.signedOut => SemanticColor.primary,
    ReportReadinessStatus.insufficient => SemanticColor.warning,
    ReportReadinessStatus.ready => SemanticColor.success,
  };

  IconData get _statusIcon => switch (status) {
    ReportReadinessStatus.signedOut => SemanticIcons.statusBlocked,
    ReportReadinessStatus.insufficient => SemanticIcons.statusError,
    ReportReadinessStatus.ready => SemanticIcons.reportAdherence,
  };

  String get _badgeLabel => switch (status) {
    ReportReadinessStatus.signedOut => l10n.reportReadinessPreviewBadge,
    ReportReadinessStatus.insufficient => l10n.reportReadinessInsufficientBadge,
    ReportReadinessStatus.ready => l10n.reportReadinessReadyBadge,
  };

  String get _title => switch (status) {
    ReportReadinessStatus.signedOut => l10n.reportReadinessSignedOutTitle,
    ReportReadinessStatus.insufficient => l10n.reportReadinessInsufficientTitle,
    ReportReadinessStatus.ready =>
      rangeLabel.isNotEmpty
          ? l10n.reportReadinessReadyTitleRange(rangeLabel)
          : l10n.reportReadinessReadyTitle,
  };

  String get _description => switch (status) {
    ReportReadinessStatus.signedOut => l10n.reportReadinessSignedOutDescription,
    ReportReadinessStatus.insufficient =>
      l10n.reportReadinessInsufficientDescription,
    ReportReadinessStatus.ready => l10n.reportReadinessReadyDescription,
  };
}

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({required this.status, required this.section});

  final ReportReadinessStatus status;
  final ReportReadinessSection section;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      ReportReadinessStatus.signedOut => FButton(
        key: const Key('report-readiness-sign-in-action'),
        onPress: section.onSignIn,
        prefix: const Icon(
          SemanticIcons.statusBlocked,
          size: IconSizeTokens.level2,
        ),
        child: Text(section.l10n.authGoLogin),
      ),
      ReportReadinessStatus.insufficient => FButton(
        key: const Key('report-readiness-record-action'),
        onPress: section.onContinueRecord,
        prefix: const Icon(
          SemanticIcons.tabRecord,
          size: IconSizeTokens.level2,
        ),
        child: Text(section.l10n.reportContinueRecordAction),
      ),
      ReportReadinessStatus.ready => FButton(
        key: const Key('report-readiness-generate-action'),
        onPress: section.isGenerating ? null : section.onGenerate,
        prefix: section.isGenerating
            ? const SizedBox(
                width: Spacing.level5,
                height: Spacing.level5,
                child: FCircularProgress(),
              )
            : const Icon(SemanticIcons.aiEntry, size: Spacing.level5),
        child: Text(section.l10n.reportGenerateAction),
      ),
    };
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final SemanticColor color;

  @override
  Widget build(BuildContext context) {
    return FBadge.raw(
      style: .delta(
        decoration: .shapeDelta(
          color: color.muted(context),
          shape: RoundedSuperellipseBorder(
            borderRadius: context.theme.style.borderRadius.pill,
          ),
        ),
      ),
      builder: (context, style) => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.level3,
          vertical: Spacing.level1,
        ),
        child: Text(
          label,
          style: TypographyToken.level3
              .body(context)
              .copyWith(
                color: color.solid(context),
                fontWeight: FontWeight.w800,
              ),
        ),
      ),
    );
  }
}
