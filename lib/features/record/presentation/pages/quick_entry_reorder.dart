import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/l10n/app_localizations.dart';

class QuickEntryReorderPage extends StatelessWidget {
  const QuickEntryReorderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PageScaffold(
      title: l10n.recordQuickSettingsManualOrder,
      child: ResponsiveContentFrame(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.level4),
            child: Text(
              l10n.recordQuickSettingsManualOrderHint,
              textAlign: TextAlign.center,
              style: context.theme.typography.body.md,
            ),
          ),
        ),
      ),
    );
  }
}
