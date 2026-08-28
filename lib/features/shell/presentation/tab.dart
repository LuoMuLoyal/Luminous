import 'package:flutter/widgets.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/l10n/app_localizations.dart';

enum ShellTab {
  today(SemanticIcons.tabToday, SemanticIcons.tabToday),
  record(SemanticIcons.tabRecord, SemanticIcons.tabRecord),
  medicine(SemanticIcons.tabMedicine, SemanticIcons.tabMedicine),
  review(SemanticIcons.tabReview, SemanticIcons.tabReview),
  mine(SemanticIcons.tabMine, SemanticIcons.tabMine);

  const ShellTab(this.icon, this.activeIcon);

  final IconData icon;
  final IconData activeIcon;

  /// Returns a stable test key for this tab.
  ///
  /// The `review` tab keeps the legacy `shell-tab-report` key for backward
  /// compatibility — it was renamed from "report" to "review" but existing
  /// tests and integration code still reference the old key.
  ValueKey<String> testKey() =>
      ValueKey<String>(this == ShellTab.review ? 'shell-tab-report' : 'shell-tab-$name');

  String label(AppLocalizations l10n) {
    return switch (this) {
      ShellTab.today => l10n.tabToday,
      ShellTab.record => l10n.tabRecord,
      ShellTab.medicine => l10n.tabMedicine,
      ShellTab.review => l10n.tabReview,
      ShellTab.mine => l10n.tabMine,
    };
  }
}
