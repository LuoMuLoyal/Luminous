import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/dialog/dialog_shell.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Skeleton loading placeholder for the record edit page.
class RecordEditLoading extends StatelessWidget {
  const RecordEditLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const InlineSkeletonSection(
      children: [
        InlineSkeletonBlock(height: 56),
        InlineSkeletonBlock(height: 56),
        InlineSkeletonBlock(height: 56),
        InlineSkeletonBlock(height: 96),
        InlineSkeletonBlock(height: 56),
        InlineSkeletonBlock(height: 44),
      ],
    );
  }
}

/// Status hint above the edit form.
///
/// Shows a subtle "changes take effect after saving" hint by default, and
/// switches to a warning pill while the form is dirty, echoing the
/// discard-confirmation dialog shown on back navigation.
class RecordEditStatusHint extends StatelessWidget {
  const RecordEditStatusHint({
    super.key,
    required this.dirty,
    required this.l10n,
  });

  final bool dirty;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    const warning = SemanticColor.warning;
    final background = dirty ? warning.subtle(context) : colors.muted;
    final foreground = dirty
        ? warning.solid(context)
        : SemanticColor.neutral.solid(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: context.theme.style.borderRadius.xs,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
        child: Row(
          key: Key(
            dirty ? 'record-edit-unsaved-hint' : 'record-edit-save-hint',
          ),
          children: [
            Icon(
              dirty ? SemanticIcons.statusWarning : SemanticIcons.statusInfo,
              color: foreground,
              size: IconSizeTokens.sm,
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: Text(
                dirty
                    ? l10n.recordEditUnsavedWarning
                    : l10n.recordEditUnsavedHint,
                style: context.theme.typography.body.xs.copyWith(
                  color: foreground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pops the edit page, falling back to the home route when there is no
/// navigation history to pop.
void popEditOrGoHome(BuildContext context) {
  if (GoRouter.of(context).canPop()) {
    context.pop();
  } else {
    context.go(Routes.home);
  }
}

/// Shows a discard-confirmation dialog; returns `true` when the user agrees
/// to leave without saving.
Future<bool?> confirmDiscardEdit(BuildContext context, AppLocalizations l10n) {
  return showAppDialog<bool>(
    context: context,
    scrollable: false,
    builder: (dialogContext) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.recordEditDiscardTitle,
          style: dialogContext.theme.dialogStyle.titleTextStyle,
        ),
        const SizedBox(height: Spacing.sm),
        Text(
          l10n.recordEditDiscardMessage,
          style: dialogContext.theme.dialogStyle.bodyTextStyle,
        ),
        const SizedBox(height: Spacing.xl),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FButton(
              variant: FButtonVariant.ghost,
              onPress: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.recordEditKeepEditingAction),
            ),
            const SizedBox(width: Spacing.md),
            FButton(
              key: const Key('record-edit-discard-confirm'),
              variant: FButtonVariant.destructive,
              onPress: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.recordEditDiscardAction),
            ),
          ],
        ),
      ],
    ),
  );
}
