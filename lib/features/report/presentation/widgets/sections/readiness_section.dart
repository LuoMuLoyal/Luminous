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
    this.onSignIn,
    this.onContinueRecord,
    this.onGenerate,
    this.onSync,
  });

  final ReportReadinessStatus status;
  final String generatedAtLabel;
  final AppLocalizations l10n;
  final int insufficientMetricCount;
  final VoidCallback? onSignIn;
  final VoidCallback? onContinueRecord;
  final VoidCallback? onGenerate;
  final VoidCallback? onSync;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return FCard.raw(
      key: const Key('report-readiness-card'),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FAvatar.raw(
                  size: Spacing.level8,
                  child: Icon(
                    _statusIcon,
                    color: colors.primary,
                    size: Spacing.level5,
                  ),
                ),
                const SizedBox(width: Spacing.level3),
                _StatusBadge(label: _badgeLabel),
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
                  Icon(
                    FLucideIcons.clock3,
                    color: colors.mutedForeground,
                    size: 16,
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
            if (status == ReportReadinessStatus.insufficient &&
                insufficientMetricCount > 0) ...[
              const SizedBox(height: Spacing.level3),
              Text(
                l10n.reportReadinessMissingMetricsHint(insufficientMetricCount),
                style: TypographyToken.level3
                    .body(context)
                    .copyWith(color: colors.mutedForeground),
              ),
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
                      key: const Key('report-top-sync-action'),
                      onPress: onSync,
                      variant: FButtonVariant.outline,
                      prefix: const Icon(FLucideIcons.refreshCw, size: 16),
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

  IconData get _statusIcon => switch (status) {
    ReportReadinessStatus.signedOut => FLucideIcons.lock,
    ReportReadinessStatus.insufficient => FLucideIcons.circleAlert,
    ReportReadinessStatus.ready => FLucideIcons.badgeCheck,
  };

  String get _badgeLabel => switch (status) {
    ReportReadinessStatus.signedOut => l10n.reportReadinessPreviewBadge,
    ReportReadinessStatus.insufficient => l10n.reportReadinessInsufficientBadge,
    ReportReadinessStatus.ready => l10n.reportReadinessReadyBadge,
  };

  String get _title => switch (status) {
    ReportReadinessStatus.signedOut => l10n.reportReadinessSignedOutTitle,
    ReportReadinessStatus.insufficient => l10n.reportReadinessInsufficientTitle,
    ReportReadinessStatus.ready => l10n.reportReadinessReadyTitle,
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
        prefix: const Icon(FLucideIcons.lockKeyhole, size: 16),
        child: Text(section.l10n.authGoLogin),
      ),
      ReportReadinessStatus.insufficient => FButton(
        key: const Key('report-readiness-record-action'),
        onPress: section.onContinueRecord,
        prefix: const Icon(FLucideIcons.notebookPen, size: 16),
        child: Text(section.l10n.reportContinueRecordAction),
      ),
      ReportReadinessStatus.ready => FButton(
        key: const Key('report-top-generate-action'),
        onPress: section.onGenerate,
        prefix: const Icon(FLucideIcons.sparkles, size: 16),
        child: Text(section.l10n.reportGenerateAction),
      ),
    };
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return FBadge.raw(
      style: .delta(
        decoration: .shapeDelta(
          color: colors.secondary.withValues(alpha: 0.12),
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
              .copyWith(color: colors.secondary, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
