import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:luminous/l10n/app_localizations.dart';

enum ShellTab {
  today(FLucideIcons.house, FLucideIcons.house),
  record(FLucideIcons.notebookPen, FLucideIcons.notebookPen),
  medicine(FLucideIcons.pill, FLucideIcons.pill),
  report(FLucideIcons.chartColumn, FLucideIcons.chartColumn),
  mine(FLucideIcons.userRound, FLucideIcons.userRound);

  const ShellTab(this.icon, this.activeIcon);

  final IconData icon;
  final IconData activeIcon;

  ValueKey<String> testKey() => ValueKey<String>('shell-tab-$name');

  String label(AppLocalizations? l10n) {
    return switch (this) {
      ShellTab.today => l10n?.tabToday ?? 'Today',
      ShellTab.record => l10n?.tabRecord ?? 'Record',
      ShellTab.medicine => l10n?.tabMedicine ?? 'Medicine',
      ShellTab.report => l10n?.tabReport ?? 'Report',
      ShellTab.mine => l10n?.tabMine ?? 'Mine',
    };
  }
}
