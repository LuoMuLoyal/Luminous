import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 全局 Riverpod 容器，作为 GetX -> Riverpod 迁移过程中的过渡桥梁。
///
/// 仅允许旧有无法直接使用 `ConsumerWidget`/`ref` 的 GetX Controller 访问。
/// 新代码和组件请勿依赖此容器，应使用 `ConsumerWidget` 或 `ConsumerStatefulWidget`。
ProviderContainer? _globalProviderContainer;

ProviderContainer get globalProviderContainer {
  final container = _globalProviderContainer;
  if (container == null) {
    throw StateError('globalProviderContainer has not been registered.');
  }
  return container;
}

void setGlobalProviderContainer(ProviderContainer container) {
  _globalProviderContainer = container;
}

void resetGlobalProviderContainerForTest() {
  _globalProviderContainer = null;
}
