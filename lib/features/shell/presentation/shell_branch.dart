import 'package:luminous/features/shell/presentation/shell_tab.dart';

/// Branch indices used by [StatefulShellRoute].
///
/// The first five branches correspond 1:1 to the visible [ShellTab] entries and
/// are rendered in the mobile bottom navigation. The remaining branches are
/// hidden from the bottom bar and reachable only via sidebar actions or
/// deep-links; on mobile they render full-screen without the bottom navigation.
enum ShellBranch {
  today,
  record,
  medicine,
  report,
  mine,
  settings,
  assistant,
  notifications;

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
