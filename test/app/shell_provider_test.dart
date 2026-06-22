import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/shell/providers/shell_provider.dart';

void main() {
  test('initial currentIndex is 0', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    expect(c.read(shellProvider).currentIndex, 0);
  });

  test('selectTab changes index', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(shellProvider.notifier).selectTab(2);
    expect(c.read(shellProvider).currentIndex, 2);
    c.read(shellProvider.notifier).selectTab(4);
    expect(c.read(shellProvider).currentIndex, 4);
  });
}
