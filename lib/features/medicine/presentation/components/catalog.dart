import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/features/medicine/presentation/providers/surface.dart';
import 'package:luminous/features/medicine/presentation/widgets/sections/drug_box.dart';
import 'package:luminous/features/medicine/presentation/widgets/sections/graph/drug_set_sections.dart';
import 'package:luminous/features/medicine/presentation/widgets/sections/graph/selector_sections.dart';
import 'package:luminous/features/medicine/presentation/widgets/sections/quick_operation.dart';
import 'package:luminous/features/medicine/presentation/widgets/sections/records.dart';
import 'package:luminous/features/medicine/presentation/widgets/sections/safety_engine.dart';

/// `medicine` 表面的组件。
///
/// 每个组件直接渲染一个区块；id 是 `<domain>.<view>`，**不含 tab 名**——
/// 同一个组件要能挂到别的表面上（例如把 `dose.safety_engine` 放到 today）。
///
/// `build` 返回 `null` 表示「现在没什么可显示」，宿主会连同间距一起移除；
/// 这也取代了手写页面里那些 `SizedBox.shrink()` 占位。
const medicineDrugBoxId = ComponentId('drug_box.inventory');
const medicineRecordsId = ComponentId('dose.records');
const medicineSafetyEngineId = ComponentId('dose.safety_engine');
const medicineQuickOperationId = ComponentId('quick_action.medicine');

// ── 药理关系图组件（A5-1：接通 10 个此前未调用的端点）────────────────
//
// 前五个只依赖「我的用药组合」，无额外入参；后五个需要一个选择
// （要避开的酶 / 起止药 / 靶点基因）。后者进目录但**不进默认布局**：
// 它们的入参无法从现有数据派生，默认挂上去只会得到一排空态卡片。
const medicineMedicationOverviewId = ComponentId('dose.medication_overview');
const medicineMechanismPathsId = ComponentId('dose.mechanism_paths');
const medicineSharedTargetsId = ComponentId('dose.shared_targets');
const medicineCascadePathsId = ComponentId('dose.cascade_paths');
const medicineEnzymeDuelsId = ComponentId('dose.enzyme_duels');
const medicineDrugActionsId = ComponentId('dose.drug_actions');
const medicineTransportRoutesId = ComponentId('dose.transport_routes');
const medicineSubstitutesId = ComponentId('dose.substitutes');
const medicineShortestRoutesId = ComponentId('dose.shortest_routes');
const medicineTargetDrugsId = ComponentId('dose.target_drugs');

/// 表面定义：`medicine` 可挂哪些组件、默认顺序是什么。
///
/// ## 关系图组件为什么全部不进默认布局
///
/// 十个关系图组件进目录、**不进**默认布局，理由有三条：
///
/// 1. **依赖是一条额外链**。它们要先拿到用药组合（health_context 快照）才能问
///    知识库。默认挂上去等于让每次打开用药页都多一次快照依赖，而药箱 / 今日计划 /
///    风险检查这三张主干卡片本身已经在了——补充信息不该拖住主干。
/// 2. **五个需要入参**。替代候选要指定「避开哪个酶」、最短路径要指定起止药、
///    靶点用药要指定基因。默认挂上去只会渲染一排「请选择…」的空态。
/// 3. **「用药安全工作台」是用户编排出的一页**，不是开发者预设的一页。计划 §0
///    第 4 条要的正是「用户可自建工作台」；把十张知识库卡片硬塞进默认布局，
///    等于替用户做了他正想自己做的决定。
///
/// 因此默认布局与改造前**完全一致**（药箱 → 今日计划 → 安全引擎 → 快捷操作），
/// 老用户升级后看到的页面不变，想要的人从「＋ 添加组件」里自己挂。
const medicineSurfaceDefinition = SurfaceDefinition(
  surface: SurfaceId.medicine,
  owned: [
    medicineDrugBoxId,
    medicineRecordsId,
    medicineSafetyEngineId,
    medicineQuickOperationId,
    medicineMedicationOverviewId,
    medicineMechanismPathsId,
    medicineSharedTargetsId,
    medicineCascadePathsId,
    medicineEnzymeDuelsId,
    medicineDrugActionsId,
    medicineTransportRoutesId,
    medicineSubstitutesId,
    medicineShortestRoutesId,
    medicineTargetDrugsId,
  ],
  defaultLayout: SurfaceLayout(
    placements: [
      ComponentPlacement(id: medicineDrugBoxId),
      ComponentPlacement(id: medicineRecordsId),
      ComponentPlacement(id: medicineSafetyEngineId),
      ComponentPlacement(id: medicineQuickOperationId),
    ],
  ),
);

/// Registers every `medicine` component into [registry].
void registerMedicineComponents(ComponentRegistry registry) {
  registry.registerDescriptor(const _DrugBoxComponent());
  registry.registerDescriptor(const _RecordsComponent());
  registry.registerDescriptor(const _SafetyEngineComponent());
  registry.registerDescriptor(const _QuickOperationComponent());
  registry.registerDescriptor(const _MedicationOverviewComponent());
  registry.registerDescriptor(const _MechanismPathsComponent());
  registry.registerDescriptor(const _SharedTargetsComponent());
  registry.registerDescriptor(const _CascadePathsComponent());
  registry.registerDescriptor(const _EnzymeDuelsComponent());
  registry.registerDescriptor(const _DrugActionsComponent());
  registry.registerDescriptor(const _TransportRoutesComponent());
  registry.registerDescriptor(const _SubstitutesComponent());
  registry.registerDescriptor(const _ShortestRoutesComponent());
  registry.registerDescriptor(const _TargetDrugsComponent());
}

class _DrugBoxComponent extends ComponentDescriptor<NoComponentConfig> {
  const _DrugBoxComponent();

  @override
  ComponentId get id => medicineDrugBoxId;

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Widget? build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    // 数据未就绪（首帧加载或加载失败）时不占位：页面级状态机负责骨架与错误态。
    // 区块在这里因 error 而消失会被误读成「没有药品」。
    if (ref.watch(medicineSurfaceStateProvider).dataOrNull == null) {
      return null;
    }
    return const DrugBoxSection();
  }
}

class _RecordsComponent extends ComponentDescriptor<NoComponentConfig> {
  const _RecordsComponent();

  @override
  ComponentId get id => medicineRecordsId;

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Widget? build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    if (ref.watch(medicineSurfaceStateProvider).dataOrNull == null) {
      return null;
    }
    return const MedicineRecordsSection();
  }
}

class _SafetyEngineComponent extends ComponentDescriptor<NoComponentConfig> {
  const _SafetyEngineComponent();

  @override
  ComponentId get id => medicineSafetyEngineId;

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Widget? build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    if (ref.watch(medicineSurfaceStateProvider).dataOrNull == null) {
      return null;
    }
    return const SafetyEngineSection();
  }
}

class _QuickOperationComponent extends ComponentDescriptor<NoComponentConfig> {
  const _QuickOperationComponent();

  @override
  ComponentId get id => medicineQuickOperationId;

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Widget? build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    // 快捷操作只是入口，不依赖工作区数据，加载中/失败时仍然可用。
    return const QuickOperationSection();
  }
}

// ── 关系图组件 ────────────────────────────────────────────────
//
// 这些组件**不**因数据未就绪而返回 null：关系图区块消失会被读成「没有相互作用」，
// 是这组组件最不能出的错。它们自己渲染加载/降级态（见 `graph_card.dart`）。

/// 关系图组件的基础：支持 compact / regular / wide 三档。
///
/// 关系图是这页最需要跨列的内容（通路、靶点清单一行放不下），所以三档都声明支持。
abstract class _GraphComponent extends ComponentDescriptor<NoComponentConfig> {
  const _GraphComponent();

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Set<ComponentSize> get supportedSizes => const {
    ComponentSize.compact,
    ComponentSize.regular,
    ComponentSize.wide,
  };
}

class _MedicationOverviewComponent extends _GraphComponent {
  const _MedicationOverviewComponent();

  @override
  ComponentId get id => medicineMedicationOverviewId;

  @override
  Widget? build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    return MedicationOverviewSection(compact: _isCompact(context));
  }
}

class _MechanismPathsComponent extends _GraphComponent {
  const _MechanismPathsComponent();

  @override
  ComponentId get id => medicineMechanismPathsId;

  @override
  Widget? build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    return MechanismPathsSection(compact: _isCompact(context));
  }
}

class _SharedTargetsComponent extends _GraphComponent {
  const _SharedTargetsComponent();

  @override
  ComponentId get id => medicineSharedTargetsId;

  @override
  Widget? build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    return const SharedTargetsSection();
  }
}

class _CascadePathsComponent extends _GraphComponent {
  const _CascadePathsComponent();

  @override
  ComponentId get id => medicineCascadePathsId;

  @override
  Widget? build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    return const CascadePathsSection();
  }
}

class _EnzymeDuelsComponent extends _GraphComponent {
  const _EnzymeDuelsComponent();

  @override
  ComponentId get id => medicineEnzymeDuelsId;

  @override
  Widget? build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    return const EnzymeDuelsSection();
  }
}

class _DrugActionsComponent extends _GraphComponent {
  const _DrugActionsComponent();

  @override
  ComponentId get id => medicineDrugActionsId;

  @override
  Widget? build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    return const DrugActionsSection();
  }
}

class _TransportRoutesComponent extends _GraphComponent {
  const _TransportRoutesComponent();

  @override
  ComponentId get id => medicineTransportRoutesId;

  @override
  Widget? build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    return const TransportRoutesSection();
  }
}

class _SubstitutesComponent extends _GraphComponent {
  const _SubstitutesComponent();

  @override
  ComponentId get id => medicineSubstitutesId;

  @override
  Widget? build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    return const SubstitutesSection();
  }
}

class _ShortestRoutesComponent extends _GraphComponent {
  const _ShortestRoutesComponent();

  @override
  ComponentId get id => medicineShortestRoutesId;

  @override
  Widget? build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    return const ShortestRoutesSection();
  }
}

class _TargetDrugsComponent extends _GraphComponent {
  const _TargetDrugsComponent();

  @override
  ComponentId get id => medicineTargetDrugsId;

  @override
  Widget? build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    return const TargetDrugsSection();
  }
}

/// 组件在渲染时是否处于窄屏单列。
///
/// 尺寸档由宿主的网格决定（`compact` 在 3 列布局里也占 1 列），而组件需要知道
/// 「我现在只有一列宽」来决定要不要省掉次要信息。用视口宽度判断与网格的档位
/// 语义一致：单列 ⇔ 手机。
bool _isCompact(BuildContext context) {
  return MediaQuery.sizeOf(context).width < 600;
}
