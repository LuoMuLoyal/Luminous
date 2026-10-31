import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:luminous/app/composition/generative/catalog.dart'
    show buildGenerativeCatalog;
import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/core/config/feature_flags.dart'
    show genUiEnabledProvider;
import 'package:luminous/features/customizer/presentation/providers/layout_store.dart'
    show storedSurfaceLayoutProvider;
import 'package:luminous/features/customizer/presentation/widgets/title/entry.dart'
    show openSurfaceCustomizer;
import 'package:luminous/features/generative/presentation/components/catalog.dart'
    show generativeSurfaceComponentId, registerGenerativeComponents;
import 'package:luminous/features/generative/presentation/providers/surface_state.dart'
    show generativeCatalogProvider;
import 'package:luminous/features/medicine/presentation/components/catalog.dart';
import 'package:luminous/features/mine/presentation/components/catalog.dart';
import 'package:luminous/features/record/presentation/components/catalog.dart';
import 'package:luminous/features/review/presentation/components/catalog.dart';
import 'package:luminous/features/today/presentation/components/catalog.dart';

/// Composition root for the component system.
///
/// `lib/core/composition/` defines the mechanisms (ids, layout model, registry,
/// host) but may not import features — that is the layering gate. Registering
/// concrete components therefore happens here, where `app/` is allowed to know
/// both core and features.
///
/// This file is the single aggregation point: each feature owns its own
/// `components/catalog.dart` (registration function + surface definition), and
/// wiring a new surface is one line here. Component implementations never go in
/// this file.
///
/// **生成式 UI 是实验性功能，默认关闭。** `registerGenerative` 为假的构建里
/// 根本不注册 `generative.<surface>`，于是：
/// - 编排页的候选面板列不出它（候选集来自已注册组件）；
/// - 已存的布局即使提到它，`ComponentHost` 也按「未知 id」跳过——
///   这是组件系统对任何未注册 id 的既有降级行为，不需要额外分支。
///
/// 开关在 settings → advanced 的实验开关页（`genUiEnabled`，默认 false）。
ComponentRegistry buildComponentRegistry({bool registerGenerative = false}) {
  final registry = ComponentRegistry();
  registerTodayComponents(registry);
  registerRecordComponents(registry);
  registerMedicineComponents(registry);
  registerReviewComponents(registry);
  registerMineComponents(registry);
  if (registerGenerative) {
    registerGenerativeComponents(registry);
  }
  return registry;
}

/// Surface definitions for the whole app.
///
/// [registerGenerative] 为真时，把 `generative.<surface>` 追加进每个可生成
/// surface 的 `owned` 列表。
///
/// **为什么必须加进 `owned`**：编排页的候选面板只列 `definition.owned` 里的
/// id（见 `customizer/presentation/widgets/palette.dart`）。只注册组件而不进
/// `owned`，组件虽然能用、却永远不会出现在面板里——用户看不到也就够不到。
///
/// 追加在**末尾**：`owned` 也决定默认顺序与面板分组，生成式组件是实验性功能，
/// 不该插到既有组件前面改变默认观感。
SurfaceCatalog buildSurfaceCatalog({bool registerGenerative = false}) {
  const bases = [
    todaySurfaceDefinition,
    recordSurfaceDefinition,
    medicineSurfaceDefinition,
    reviewSurfaceDefinition,
    mineSurfaceDefinition,
  ];
  if (!registerGenerative) return SurfaceCatalog(bases);

  return SurfaceCatalog([
    for (final base in bases)
      SurfaceDefinition(
        surface: base.surface,
        owned: [
          ...base.owned,
          if (base.surface != SurfaceId.tabChrome)
            generativeSurfaceComponentId(base.surface),
        ],
        defaultLayout: base.defaultLayout,
      ),
  ]);
}

/// Provider overrides that install the composition root into the app container.
///
/// Three seams are swapped here:
///
/// - **layout**: the static default becomes the stateful store, so every
///   `ComponentHost` renders the user's layout once one is stored and that
///   surface's `defaultLayout` otherwise. Nothing else in the app reads storage.
/// - **customizer entry**: the tab title button routes through an injected
///   action instead of importing the customizer feature, which is what keeps
///   `core/` and the sibling features free of a dependency on it.
/// - **generative catalog**: the empty default becomes the one carrying the
///   domain items (`metric_card` / `trend_chart` / `finding`). `CatalogItem` is
///   a `genui` type, so it may only be constructed here — this override is the
///   whole reason the feature can stay free of the render engine.
List<Override> compositionProviderOverrides() {
  final store = storedSurfaceLayoutProvider;
  final defaultLayout = surfaceLayoutProvider;
  final catalog = generativeCatalogProvider;

  return [
    // **必须是 `overrideWith` 而不是 `overrideWithValue`。**
    //
    // 生成式 UI 由实验开关控制（`genUiEnabled`，默认 false）。`overrideWith`
    // 的回调在 provider 首次读取时求值并 `watch` 开关，所以用户在 settings
    // 里一打开，registry 就会重建、编排页的候选面板随即出现生成式组件；
    // 写死成值则整个进程生命周期只有启动那一刻的判断，用户必须重启 app。
    //
    // 这不违反 `appProviderOverrides` 的约束：那条说的是 overrides **列表**
    // 必须在 `ProviderContainer(overrides: ...)` 时给全，而单个 override 内部
    // 用 `overrideWith` 是允许的（下面的 layout / catalog 就是这样）。
    componentRegistryProvider.overrideWith(
      (ref) => buildComponentRegistry(
        registerGenerative: ref.watch(genUiEnabledProvider),
      ),
    ),
    surfaceCatalogProvider.overrideWith(
      (ref) => buildSurfaceCatalog(
        registerGenerative: ref.watch(genUiEnabledProvider),
      ),
    ),
    defaultLayout.overrideWith((ref, surface) => ref.watch(store(surface))),
    surfaceCustomizerOpenerProvider.overrideWithValue(openSurfaceCustomizer),
    // A `family` override replaces the builder for **every** key: the callback
    // receives the key, so one entry covers all surfaces (tab chrome included —
    // it never renders a generative component, and an empty catalog is the
    // correct answer there anyway).
    catalog.overrideWith((ref, surface) => buildGenerativeCatalog(surface)),
  ];
}
