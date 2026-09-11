import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/control/icon_action_button.dart';
import 'package:luminous/core/widgets/common/dialog/dialog_shell.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Panel header with the section title and the quick-entry help action.
class QuickEntryHeader extends StatelessWidget {
  const QuickEntryHeader({super.key, required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.recordQuickSectionTitle,
            style: context.theme.typography.display.xl.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        IconActionButton(
          key: const Key('record-quick-help-action'),
          tooltip: l10n.recordQuickHelpTooltip,
          icon: SemanticIcons.actionHelp,
          onTap: () => _showQuickHelp(context, l10n),
        ),
      ],
    );
  }

  Future<void> _showQuickHelp(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    await showAppDialog<void>(
      context: context,
      maxWidth: LayoutScaleResolver.dialogStandardMaxWidth,
      scrollable: false,
      builder: (dialogContext) => Column(
        key: const Key('record-quick-help-dialog'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.recordQuickHelpTooltip,
            style: dialogContext.theme.typography.body.lg,
          ),
          const SizedBox(height: Spacing.level4),
          HelpLine(text: l10n.recordQuickSettingsMedicationRule),
          HelpLine(text: l10n.recordQuickSettingsMealRule),
          HelpLine(text: l10n.recordQuickSettingsSymptomRule),
          HelpLine(text: l10n.recordQuickSettingsMoodRule),
          HelpLine(text: l10n.recordQuickSettingsSleepRule),
          HelpLine(text: l10n.recordQuickHelpLongPressRule),
          const SizedBox(height: Spacing.level5),
          Align(
            alignment: Alignment.centerRight,
            child: FButton(
              variant: FButtonVariant.ghost,
              onPress: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.commonConfirm),
            ),
          ),
        ],
      ),
    );
  }
}

/// A single help line: info icon + text.
class HelpLine extends StatelessWidget {
  const HelpLine({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.level2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(SemanticIcons.statusInfo, size: IconSizeTokens.sm),
          ),
          const SizedBox(width: Spacing.level2),
          Expanded(child: Text(text, style: context.theme.typography.body.sm)),
        ],
      ),
    );
  }
}
