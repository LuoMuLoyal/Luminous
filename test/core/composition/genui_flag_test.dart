import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/app/composition/components/registry.dart';
import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/core/config/feature_flags.dart';
import 'package:luminous/core/network/config/env_reader.dart';
import 'package:luminous/core/network/config/pref_keys.dart';
import 'package:luminous/features/generative/presentation/components/catalog.dart'
    show generativeSurfaces;

import '../../helpers/kv_test_store.dart';

/// 生成式 UI 的实验开关必须真的控制「组件是否注册」。
///
/// 这条是端到端的行为断言，不是常量检查：它走真实的
/// `compositionProviderOverrides()` + `FeatureFlagsController`，验证
/// 1. 默认（关闭）时组件不存在；
/// 2. 用户在 settings 打开后，**不重启 app** 就会注册出来。
///
/// 第 2 点是这个实现最容易写错的地方：`componentRegistryProvider` 若用
/// `overrideWithValue` 写死成启动那一刻的值，开关就只是个装饰——整个进程都
/// 不会响应。所以这里必须验证「改写后能立刻读到新值」。
void main() {
  setUp(() {
    EnvReader.clearTestValues();
  });

  tearDown(() {
    EnvReader.clearTestValues();
    KvTestStore.reset();
  });

  ProviderContainer buildContainer({Map<String, Object>? seed}) {
    KvTestStore.install(seed: seed ?? const <String, Object>{});
    final container = ProviderContainer(
      overrides: compositionProviderOverrides(),
    );
    addTearDown(container.dispose);
    return container;
  }

  /// 当前 registry 里注册的生成式 id。
  Set<String> generativeIds(ProviderContainer container) {
    final registry = container.read(componentRegistryProvider);
    return {
      for (final component in registry.components)
        if (component.id.value.startsWith('generative.')) component.id.value,
    };
  }

  test('默认关闭：生成式组件不注册，编排页因此列不出它', () async {
    final container = buildContainer();

    // 等 flag 从 KvStore 读出来（异步）。
    await container.read(featureFlagsControllerProvider.future);

    expect(container.read(genUiEnabledProvider), isFalse);
    expect(
      generativeIds(container),
      isEmpty,
      reason: '实验性功能默认关闭时不应注册任何 generative.<surface>',
    );
    // 其他组件不受影响。
    expect(container.read(componentRegistryProvider).length, greaterThan(0));
  });

  test('打开开关后无需重启即注册出来', () async {
    final container = buildContainer();
    await container.read(featureFlagsControllerProvider.future);
    expect(generativeIds(container), isEmpty);

    // 用户在 settings → advanced → 实验开关里打开。
    await container
        .read(featureFlagsControllerProvider.notifier)
        .setGenUiEnabled(true);
    // `overrideWith` 的回调依赖 genUiEnabledProvider，状态变化后重建。
    await container.read(featureFlagsControllerProvider.future);

    expect(container.read(genUiEnabledProvider), isTrue);
    expect(
      generativeIds(container),
      isNotEmpty,
      reason: '开关打开后必须立刻注册，否则用户要重启 app 才能用',
    );
  });

  test('关闭开关后组件重新消失', () async {
    final container = buildContainer();
    await container.read(featureFlagsControllerProvider.future);

    final notifier = container.read(featureFlagsControllerProvider.notifier);
    await notifier.setGenUiEnabled(true);
    await container.read(featureFlagsControllerProvider.future);
    expect(generativeIds(container), isNotEmpty);

    await notifier.setGenUiEnabled(false);
    await container.read(featureFlagsControllerProvider.future);
    expect(generativeIds(container), isEmpty);
  });

  test('持久化的开启状态在下次启动生效', () async {
    // 先写一份「已开启」的偏好，模拟用户上次打开过。
    final container = buildContainer(
      seed: {PrefKeys.featureFlagsGenUiEnabled: true},
    );
    await container.read(featureFlagsControllerProvider.future);

    expect(container.read(genUiEnabledProvider), isTrue);
    expect(generativeIds(container), isNotEmpty);
  });

  // 编排页的候选集来自 `SurfaceDefinition.owned`（见
  // `customizer/presentation/widgets/palette.dart`）。只注册组件而不进
  // `owned`，组件能用但永远不出现在面板里——所以这两件事必须一起验证。
  group('编排页候选集', () {
    Set<String> offeredGenerative(ProviderContainer container) {
      final catalog = container.read(surfaceCatalogProvider);
      return {
        for (final surface in generativeSurfaces)
          for (final id in catalog.ownedBy(surface))
            if (id.value.startsWith('generative.')) id.value,
      };
    }

    test('关闭时 owned 里没有任何生成式 id', () async {
      final container = buildContainer();
      await container.read(featureFlagsControllerProvider.future);
      expect(offeredGenerative(container), isEmpty);
    });

    test('开启后每个可生成 surface 的 owned 都含它', () async {
      final container = buildContainer(
        seed: {PrefKeys.featureFlagsGenUiEnabled: true},
      );
      await container.read(featureFlagsControllerProvider.future);

      final offered = offeredGenerative(container);
      expect(offered, hasLength(generativeSurfaces.length));
      for (final surface in generativeSurfaces) {
        expect(
          offered,
          contains('generative.${surface.wireValue}'),
          reason: '${surface.wireValue} 的编排候选集里应有生成式入口',
        );
      }

      // 候选集里的 id 必须真的注册了，否则面板会列出一个点了没用的东西。
      final registry = container.read(componentRegistryProvider);
      for (final id in offered) {
        expect(
          registry.components.any((component) => component.id.value == id),
          isTrue,
          reason: '$id 出现在候选集里，但没有任何实现注册它',
        );
      }
    });
  });
}
