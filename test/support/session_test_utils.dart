import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/auth/providers/user_session_provider.dart';
import 'package:luminous/core/providers/shared_preferences_provider.dart';
import 'package:luminous/features/auth/presentation/models/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 最近一次 [createTestProviderContainer] 创建的容器，供同测试内
/// [setTestSessionUser] 等辅助函数使用。
ProviderContainer? _lastTestContainer;

Future<ProviderContainer> createTestProviderContainer({UserSafe? user}) async {
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  _lastTestContainer = container;
  addTearDown(() {
    _lastTestContainer = null;
    container.dispose();
  });

  if (user != null) {
    await container.read(userSessionProvider.notifier).setUser(user);
  }

  return container;
}

Future<void> setTestSessionUser(UserSafe user) async {
  final container = _lastTestContainer;
  assert(container != null, 'call createTestProviderContainer() first');
  await container!.read(userSessionProvider.notifier).setUser(user);
}
