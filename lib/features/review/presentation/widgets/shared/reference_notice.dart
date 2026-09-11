import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ReviewReferenceNotice extends StatelessWidget {
  const ReviewReferenceNotice({super.key, required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return FCard(
      child: Container(
        decoration: BoxDecoration(
          color: SemanticColor.primary.muted(context),
          borderRadius: context.theme.style.borderRadius.md,
          border: Border.all(color: SemanticColor.primary.border(context)),
        ),
        padding: const EdgeInsets.all(Spacing.lg),
        child: Row(
          children: [
            Icon(
              SemanticIcons.statusWarning,
              color: SemanticColor.primary.solid(context),
              size: Spacing.xl,
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Text(
                l10n.reviewReferenceNotice,
                style: context.theme.typography.body.xs.copyWith(
                  color: SemanticColor.primary.solid(context),
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
