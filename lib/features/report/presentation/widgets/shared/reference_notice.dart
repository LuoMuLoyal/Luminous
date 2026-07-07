import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ReportReferenceNotice extends StatelessWidget {
  const ReportReferenceNotice({super.key, required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return FCard.raw(
      child: Container(
        decoration: BoxDecoration(
          color: context.theme.colors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadiusTokens.level4),
          border: Border.all(
            color: context.theme.colors.primary.withValues(alpha: 0.16),
          ),
        ),
        padding: const EdgeInsets.all(AppSpacingTokens.level4),
        child: Row(
          children: [
            Icon(
              FLucideIcons.triangleAlert,
              color: context.theme.colors.primary,
              size: AppSpacingTokens.level5,
            ),
            const SizedBox(width: AppSpacingTokens.level3),
            Expanded(
              child: Text(
                l10n.reportReferenceNotice,
                style: AppTypographyToken.level3
                    .body(context)
                    .copyWith(
                      color: context.theme.colors.primary,
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
