import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/dialog/dialog_shell.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Shows a password confirmation dialog for sensitive operations and returns
/// the trimmed password when the user confirms.
///
/// Returns `null` when the user cancels or dismisses the dialog. The caller is
/// responsible for validating the returned password length and forwarding it
/// to the backend.
///
/// Use this as a drop-in replacement for the legacy Security PIN elevation
/// dialog (Task 8). The backend now requires password re-authentication for
/// sensitive actions such as changing email, unlinking identities, deleting
/// the account, and requesting data exports.
Future<String?> requestPasswordForSensitiveAction(
  BuildContext context, {
  String? title,
  String? message,
  String? label,
}) async {
  return showAppDialog<String?>(
    context: context,
    maxWidth: 400,
    barrierDismissible: true,
    builder: (dialogContext) => _SensitiveActionPasswordDialogContent(
      title: title,
      message: message,
      label: label,
    ),
  );
}

class _SensitiveActionPasswordDialogContent extends HookConsumerWidget {
  const _SensitiveActionPasswordDialogContent({
    this.title,
    this.message,
    this.label,
  });

  final String? title;
  final String? message;
  final String? label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final controller = useTextEditingController();
    final errorMessage = useState<String?>(null);
    final typography = context.theme.typography;
    Future<void> handleConfirm() async {
      final value = controller.text.trim();
      if (value.isEmpty) {
        errorMessage.value = l10n.authCurrentPasswordRequiredToast;
        return;
      }
      if (!context.mounted) return;
      Navigator.of(context).pop(value);
    }

    return Material(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title ?? l10n.authSensitiveActionPasswordDialogTitle,
            style: typography.body.lg,
          ),
          const SizedBox(height: Spacing.level2),
          Text(
            message ?? l10n.authSensitiveActionPasswordDialogMessage,
            style: typography.body.xs.copyWith(
              color: SemanticColor.neutral.solid(context),
            ),
          ),
          const SizedBox(height: Spacing.level4),
          FTextFormField.password(
            key: const Key('sensitive-action-password-field'),
            control: FTextFieldControl.managed(controller: controller),
            label: Text(label ?? l10n.authSensitiveActionPasswordDialogLabel),
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmit: (_) => handleConfirm(),
          ),
          if (errorMessage.value != null) ...[
            const SizedBox(height: Spacing.level2),
            Text(
              errorMessage.value!,
              style: typography.body.xs.copyWith(
                color: SemanticColor.destructive.solid(context),
              ),
            ),
          ],
          const SizedBox(height: Spacing.level5),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FButton(
                variant: FButtonVariant.ghost,
                onPress: () => Navigator.of(context).pop(),
                child: Text(l10n.authCancelAction),
              ),
              const SizedBox(width: Spacing.level3),
              FButton(
                key: const Key('sensitive-action-password-confirm'),
                onPress: handleConfirm,
                child: Text(l10n.authSensitiveActionPasswordDialogConfirm),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
