import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/shell/presentation/branch.dart';
import 'package:luminous/features/shell/presentation/tab.dart';

void main() {
  group('ShellBranch', () {
    test('has 5 branches in correct order', () {
      expect(ShellBranch.values, hasLength(5));
      expect(ShellBranch.values[0], ShellBranch.today);
      expect(ShellBranch.values[1], ShellBranch.record);
      expect(ShellBranch.values[2], ShellBranch.medicine);
      expect(ShellBranch.values[3], ShellBranch.report);
      expect(ShellBranch.values[4], ShellBranch.mine);
    });

    test('isVisible returns true for all branches (5 tabs ≤ 5 branches)', () {
      for (final branch in ShellBranch.values) {
        expect(branch.isVisible, isTrue, reason: '$branch should be visible');
      }
    });

    test('index matches enum position', () {
      expect(ShellBranch.today.index, 0);
      expect(ShellBranch.record.index, 1);
      expect(ShellBranch.medicine.index, 2);
      expect(ShellBranch.report.index, 3);
      expect(ShellBranch.mine.index, 4);
    });
  });

  group('ShellBranch.indexForTab', () {
    test('returns correct index for each tab', () {
      expect(ShellBranch.indexForTab(ShellTab.today), 0);
      expect(ShellBranch.indexForTab(ShellTab.record), 1);
      expect(ShellBranch.indexForTab(ShellTab.medicine), 2);
      expect(ShellBranch.indexForTab(ShellTab.review), 3);
      expect(ShellBranch.indexForTab(ShellTab.mine), 4);
    });
  });

  group('ShellTabBranchX', () {
    test('branchIndex matches tab index', () {
      expect(ShellTab.today.branchIndex, 0);
      expect(ShellTab.record.branchIndex, 1);
      expect(ShellTab.medicine.branchIndex, 2);
      expect(ShellTab.review.branchIndex, 3);
      expect(ShellTab.mine.branchIndex, 4);
    });

    test('branchIndex equals indexForTab for all tabs', () {
      for (final tab in ShellTab.values) {
        expect(tab.branchIndex, ShellBranch.indexForTab(tab));
      }
    });
  });
}
