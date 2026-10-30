import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/features/medicine/presentation/providers/surface.dart';
import 'package:luminous/features/medicine/presentation/widgets/sections/drug_box.dart';
import 'package:luminous/features/medicine/presentation/widgets/sections/quick_operation.dart';
import 'package:luminous/features/medicine/presentation/widgets/sections/records.dart';
import 'package:luminous/features/medicine/presentation/widgets/sections/safety_engine.dart';

/// `medicine` 表面的组件。
///
/// 每个组件直接渲染一个已在用的区块；id 是 `<domain>.<view>`，**不含 tab 名**——
/// 同一个组件要能挂到别的表面上（例如把 `dose.safety_engine` 放到 today）。
///
/// `build` 返回 `null` 表示「现在没什么可显示」，宿主会连同间距一起移除；
/// 这也取代了手写页面里那些 `SizedBox.shrink()` 占位。
const medicineDrugBoxId = ComponentId('drug_box.inventory');
const medicineRecordsId = ComponentId('dose.records');
const medicineSafetyEngineId = ComponentId('dose.safety_engine');
const medicineQuickOperationId = ComponentId('quick_action.medicine');

/// 表面定义：`medicine` 可挂哪些组件、默认顺序是什么。
///
/// 默认布局等于改造前的移动端渲染顺序（药箱 → 今日计划 → 安全引擎 → 快捷操作），
/// 所以从不编辑布局的用户看到的页面与之前一致。
const medicineSurfaceDefinition = SurfaceDefinition(
  surface: SurfaceId.medicine,
  available: [
    medicineDrugBoxId,
    medicineRecordsId,
    medicineSafetyEngineId,
    medicineQuickOperationId,
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
