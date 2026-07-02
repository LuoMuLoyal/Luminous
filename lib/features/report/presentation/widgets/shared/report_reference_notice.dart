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
          color: Color(0xFFF59E0B).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
          border: Border.all(color: Color(0xFFF59E0B).withValues(alpha: 0.16)),
        ),
        padding: const EdgeInsets.all(AppSpacingTokens.md),
        child: Row(
          children: [
            const Icon(
              FLucideIcons.triangleAlert,
              color: Color(0xFFF59E0B),
              size: AppSpacingTokens.lg,
            ),
            const SizedBox(width: AppSpacingTokens.sm),
            Expanded(
              child: Text(
                l10n.reportReferenceNotice,
                style: textTheme.bodySmall?.copyWith(
                  color: Color(0xFFF59E0B),
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
