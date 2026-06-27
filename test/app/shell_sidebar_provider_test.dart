import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/shell/providers/shell_sidebar_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ShellSidebarNotifier', () {
    ProviderContainer buildContainer({Map<String, Object>? initialValues}) {
      SharedPreferences.setMockInitialValues(
        initialValues ?? const <String, Object>{},
      );
      final container = ProviderContainer.test();
      addTearDown(container.dispose);
      return container;
    }

    test('defaults to expanded when no preference is stored', () async {
      final container = buildContainer();

      final state = await container.read(shellSidebarProvider.future);

      expect(state.collapsed, isFalse);
      expect(state.width, ShellSidebarDimensions.expandedWidth);
    });

    test('restores collapsed state from shared preferences', () async {
      final container = buildContainer(
        initialValues: const <String, Object>{
          'luminous_desktop_sidebar_collapsed': true,
        },
      );

      final state = await container.read(shellSidebarProvider.future);

      expect(state.collapsed, isTrue);
      expect(state.width, ShellSidebarDimensions.collapsedWidth);
    });

    test('toggle switches from expanded to collapsed and persists', () async {
      final container = buildContainer();

      await container.read(shellSidebarProvider.future);

      await container.read(shellSidebarProvider.notifier).toggle();

      expect(
        container.read(shellSidebarProvider).requireValue.collapsed,
        isTrue,
      );
      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getBool('luminous_desktop_sidebar_collapsed'), isTrue);
    });

    test('toggle switches back from collapsed to expanded', () async {
      final container = buildContainer(
        initialValues: const <String, Object>{
          'luminous_desktop_sidebar_collapsed': true,
        },
      );

      await container.read(shellSidebarProvider.future);

      await container.read(shellSidebarProvider.notifier).toggle();

      expect(
        container.read(shellSidebarProvider).requireValue.collapsed,
        isFalse,
      );
      final preferences = await SharedPreferences.getInstance();
      expect(
        preferences.getBool('luminous_desktop_sidebar_collapsed'),
        isFalse,
      );
    });

    test('setCollapsed updates state and persists', () async {
      final container = buildContainer();

      await container.read(shellSidebarProvider.future);

      await container.read(shellSidebarProvider.notifier).setCollapsed(true);

      expect(
        container.read(shellSidebarProvider).requireValue.collapsed,
        isTrue,
      );
      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getBool('luminous_desktop_sidebar_collapsed'), isTrue);

      await container.read(shellSidebarProvider.notifier).setCollapsed(false);

      expect(
        container.read(shellSidebarProvider).requireValue.collapsed,
        isFalse,
      );
      expect(
        preferences.getBool('luminous_desktop_sidebar_collapsed'),
        isFalse,
      );
    });
  });
}
