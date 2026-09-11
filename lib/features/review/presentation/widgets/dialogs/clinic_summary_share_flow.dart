import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/utils/date_format.dart';
import 'package:luminous/features/review/presentation/widgets/shared/components.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Share flow step shown inside the dialog after tapping [Share summary].
enum ClinicSummaryShareStep {
  /// Ask for confirmation, showing the expiry and the
  /// "anyone with the link can view" notice before creating.
  confirm,

  /// Link created — offer copy and revoke.
  created,

  /// Share revoked — the link no longer works.
  revoked,
}

/// Pre-creation confirmation: expiry + "anyone with the link can view".
class ClinicSummaryShareConfirmPanel extends StatelessWidget {
  const ClinicSummaryShareConfirmPanel({
    super.key,
    required this.isCreating,
    required this.hasNotes,
    required this.onCancel,
    required this.onConfirm,
  });

  final bool isCreating;

  /// Whether the notes field is currently selected — when true, an extra
  /// privacy warning is shown because notes appear in plain text to anyone
  /// with the share link (R-2).
  final bool hasNotes;

  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.reviewShareConfirmTitle,
          style: context.theme.typography.body.lg.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: Spacing.lg),
        ClinicSummaryNoticeRow(
          icon: SemanticIcons.safetyTiming,
          iconColor: SemanticColor.neutral.solid(context),
          text: l10n.reviewShareConfirmExpiryHint(7),
        ),
        const SizedBox(height: Spacing.md),
        ClinicSummaryNoticeRow(
          icon: SemanticIcons.safetySafe,
          iconColor: SemanticColor.primary.solid(context),
          text: l10n.reviewShareConfirmNotice,
        ),
        if (hasNotes) ...[
          const SizedBox(height: Spacing.md),
          ClinicSummaryNoticeRow(
            icon: SemanticIcons.statusWarning,
            iconColor: SemanticColor.warning.solid(context),
            text: l10n.reviewClinicSummaryNotesPrivacyWarning,
          ),
        ],
        const SizedBox(height: Spacing.xl),
        Row(
          children: [
            Expanded(
              child: FButton(
                variant: FButtonVariant.outline,
                onPress: isCreating ? null : onCancel,
                child: Text(l10n.commonCancel),
              ),
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: FButton(
                variant: FButtonVariant.primary,
                onPress: isCreating ? null : onConfirm,
                child: isCreating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: FCircularProgress(),
                      )
                    : Text(l10n.reviewShareConfirmAction),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Post-creation: the link itself with COPY and REVOKE actions.
class ClinicSummaryShareCreatedPanel extends StatelessWidget {
  const ClinicSummaryShareCreatedPanel({
    super.key,
    required this.response,
    required this.isRevoking,
    required this.onCopy,
    required this.onRevoke,
    required this.onClose,
  });

  final ClinicSummaryShareResponse response;
  final bool isRevoking;
  final VoidCallback onCopy;
  final VoidCallback onRevoke;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final typography = context.theme.typography;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.reviewShareCreatedTitle,
          style: typography.body.lg.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: Spacing.md),
        MetaRow(
          label: l10n.reviewShareCreatedExpiresAt,
          value: formatDateTimeFull(response.expiresAt, locale),
        ),
        const SizedBox(height: Spacing.lg),
        FCard(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Text(
              response.shareUrl,
              style: typography.body.xs.copyWith(
                color: SemanticColor.neutral.solid(context),
              ),
            ),
          ),
        ),
        const SizedBox(height: Spacing.lg),
        Row(
          children: [
            Expanded(
              child: FButton(
                variant: FButtonVariant.outline,
                onPress: isRevoking ? null : onCopy,
                child: Text(l10n.reviewShareCopyAction),
              ),
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: FButton(
                variant: FButtonVariant.outline,
                onPress: isRevoking ? null : onRevoke,
                child: isRevoking
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: FCircularProgress(),
                      )
                    : Text(l10n.reviewShareRevokeAction),
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.md),
        FButton(
          variant: FButtonVariant.ghost,
          onPress: isRevoking ? null : onClose,
          child: Text(l10n.commonClose),
        ),
      ],
    );
  }
}

/// Terminal state after revocation: the link no longer works.
class ClinicSummaryShareRevokedPanel extends StatelessWidget {
  const ClinicSummaryShareRevokedPanel({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typography = context.theme.typography;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          SemanticIcons.statusWarning,
          size: 28,
          color: SemanticColor.neutral.solid(context),
        ),
        const SizedBox(height: Spacing.md),
        Text(
          l10n.reviewShareRevokedTitle,
          style: typography.body.lg.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: Spacing.sm),
        Text(
          l10n.reviewShareRevokedBody,
          style: typography.body.xs.copyWith(
            color: SemanticColor.neutral.solid(context),
          ),
        ),
        const SizedBox(height: Spacing.xl),
        FButton(
          variant: FButtonVariant.primary,
          onPress: onClose,
          child: Text(l10n.commonClose),
        ),
      ],
    );
  }
}

class ClinicSummaryNoticeRow extends StatelessWidget {
  const ClinicSummaryNoticeRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  final IconData icon;
  final Color iconColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: Spacing.md),
        Expanded(child: Text(text, style: context.theme.typography.body.xs)),
      ],
    );
  }
}
