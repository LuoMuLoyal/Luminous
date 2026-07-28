import 'package:flutter/widgets.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/l10n/app_localizations.dart';

enum ShellTab {
  today(SemanticIcons.tabToday, SemanticIcons.tabToday),
  record(SemanticIcons.tabRecord, SemanticIcons.tabRecord),
  medicine(SemanticIcons.tabMedicine, SemanticIcons.tabMedicine),
  report(SemanticIcons.tabReport, SemanticIcons.tabReport),
  mine(SemanticIcons.tabMine, SemanticIcons.tabMine);

  const ShellTab(this.icon, this.activeIcon);

  final IconData icon;
  final IconData activeIcon;

  ValueKey<String> testKey() => ValueKey<String>('shell-tab-$name');

  String label(AppLocalizations l10n) {
    return switch (this) {
      ShellTab.today => l10n.tabToday,
      ShellTab.record => l10n.tabRecord,
      ShellTab.medicine => l10n.tabMedicine,
      ShellTab.report => l10n.tabReport,
      ShellTab.mine => l10n.tabMine,
    };
  }
}
