import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ReportReferenceNotice extends StatelessWidget {
  const ReportReferenceNotice({super.key, required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return FCard.raw(
      child: Container(
        decoration: BoxDecoration(
          color: AppColorTokens.warning.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
          border: Border.all(
            color: AppColorTokens.warning.withValues(alpha: 0.16),
          ),
        ),
        padding: const EdgeInsets.all(AppSpacingTokens.md),
        child: Row(
          children: [
            const Icon(
              FLucideIcons.triangleAlert,
              color: AppColorTokens.warning,
              size: AppSpacingTokens.lg,
            ),
            const SizedBox(width: AppSpacingTokens.sm),
            Expanded(
              child: Text(
                l10n.reportReferenceNotice,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColorTokens.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
