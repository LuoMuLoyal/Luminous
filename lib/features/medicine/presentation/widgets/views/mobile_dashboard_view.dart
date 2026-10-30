import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/medicine/domain/entities/workspace.dart';
import 'package:luminous/features/medicine/presentation/widgets/sections/drug_box.dart';
import 'package:luminous/features/medicine/presentation/widgets/sections/quick_operation.dart';
import 'package:luminous/features/medicine/presentation/widgets/sections/records.dart';
import 'package:luminous/features/medicine/presentation/widgets/sections/safety_engine.dart';

/// 用药页内容区。
///
/// 移动端交给 [ComponentHost]：页面不再知道该页有哪些区块，加组件 /
/// 换顺序都不用改这个文件。桌面端保留手写双栏——多栏布局需要每个区块的静态
/// 类型参与 `Expanded` 分栏，组件化的单列布局模型表达不了。
class MedicineMobileDashboardView extends StatelessWidget {
  const MedicineMobileDashboardView({super.key, required this.workspace});

  final MedicineWorkspace workspace;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= Breakpoints.desktop;

    if (!isDesktop) return const _MobileLayout();
    return _DesktopLayout(
      workspace: workspace,
      isWide: width >= Breakpoints.wide,
    );
  }
}

/// 移动端：按 `medicine` 表面的布局渲染组件。
class _MobileLayout extends ConsumerWidget {
  const _MobileLayout();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = ref.watch(surfaceLayoutProvider(SurfaceId.medicine));
    return ComponentHost(
      surface: SurfaceId.medicine,
      layout: layout,
      spacing: Spacing.lg,
    );
  }
}

/// 桌面端：手写双栏 / 三栏。
class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({required this.workspace, required this.isWide});

  final MedicineWorkspace workspace;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    // Wide screens (≥1400): three columns — drugbox | records+safety | quick ops
    if (isWide) {
      return const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: drug box.
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [DrugBoxSection()],
            ),
          ),
          SizedBox(width: Spacing.xl),
          // Center: records + safety.
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MedicineRecordsSection(),
                SizedBox(height: Spacing.xl),
                SafetyEngineSection(),
              ],
            ),
          ),
          SizedBox(width: Spacing.xl),
          // Right: quick operations.
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [QuickOperationSection()],
            ),
          ),
        ],
      );
    }

    // Standard desktop (1200–1400): two columns — drugbox+records | safety+ops
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DrugBoxSection(),
              SizedBox(height: Spacing.xl),
              MedicineRecordsSection(),
            ],
          ),
        ),
        SizedBox(width: Spacing.xl),
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SafetyEngineSection(),
              SizedBox(height: Spacing.xl),
              QuickOperationSection(),
            ],
          ),
        ),
      ],
    );
  }
}
