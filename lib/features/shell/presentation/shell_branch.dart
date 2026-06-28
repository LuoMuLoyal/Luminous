import 'package:luminous/features/shell/presentation/shell_tab.dart';

/// Branch indices used by [StatefulShellRoute].
///
/// Each branch corresponds 1:1 to a visible [ShellTab] entry and is rendered
/// in the mobile bottom navigation and desktop sidebar.
enum ShellBranch {
  today,
  record,
  medicine,
  report,
  mine;

  /// Whether this branch should appear in the mobile [NavigationBar].
  bool get isVisible => index < ShellTab.values.length;

  /// The index to pass to [StatefulNavigationShell.goBranch] for the matching
  /// visible [ShellTab].
  static int indexForTab(ShellTab tab) => tab.index;
}

extension ShellTabBranchX on ShellTab {
  /// The [ShellBranch] index for this visible tab.
  int get branchIndex => index;
}
