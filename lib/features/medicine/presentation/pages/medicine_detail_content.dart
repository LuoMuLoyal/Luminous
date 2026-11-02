import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/app/composition/health_context/health_context.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/errors/user_message.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/providers/instrumentation/data_change_bus.dart';
import 'package:luminous/core/providers/session/session_snapshot.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';
import 'package:luminous/core/widgets/common/control/divider.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/health_context/domain/entities/write_inputs.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_detail.dart';
import 'package:luminous/features/medicine/presentation/pages/detail_section_view.dart';
import 'package:luminous/features/medicine/presentation/pages/detail_sections.dart';
import 'package:luminous/features/medicine/presentation/pages/medicine_detail_shared.dart';
import 'package:luminous/features/medicine/presentation/routes.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Core content widget for medicine detail page.
class MedicineDetailContent extends ConsumerStatefulWidget {
  const MedicineDetailContent({
    super.key,
    required this.detail,
    required this.source,
  });

  final MedicineDetail detail;
  final String source;

  @override
  ConsumerState<MedicineDetailContent> createState() =>
      _MedicineDetailContentState();
}

class _MedicineDetailContentState extends ConsumerState<MedicineDetailContent> {
  /// Accordion items the user has opened.
  ///
  /// Lifted out of the accordion because a collapsed item's child is still
  /// built — without this, the sequence section would fire its request on page
  /// load instead of on demand.
  ///
  /// Held in a notifier rather than widget state on purpose: rebuilding the
  /// accordion on every toggle makes Forui re-run each item's
  /// `didChangeDependencies`, which resets the item to `initiallyExpanded` and
  /// collapses the section the user just opened. Only the sequence child
  /// listens, so the accordion itself is never rebuilt.
  final ValueNotifier<Set<int>> _expandedSections = ValueNotifier(const {});

  late final FAccordionControl _accordionControl;

  @override
  void initState() {
    super.initState();
    // Created once (not per build) so the accordion keeps its expanded state
    // across rebuilds.
    _accordionControl = FAccordionManagedControl(
      onChange: (expanded) => _expandedSections.value = expanded,
    );
  }

  @override
  void dispose() {
    _expandedSections.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detail = widget.detail;
    final source = widget.source;
    final l10n = AppLocalizations.of(context)!;

    final snapshotAsync = ref.watch(healthContextSnapshotProvider);
    // Extract the current-medicine record for this medicine (if any) so we
    // can both check membership and navigate to the reminder detail page.
    final currentMedicine = snapshotAsync.maybeWhen(
      data: (snapshot) {
        for (final m in snapshot.currentMedicines) {
          if (m.isCurrent && m.sourceRefId == detail.id && m.source == source) {
            return m;
          }
        }
        return null;
      },
      orElse: () => null,
    );
    final isAdded = currentMedicine != null;

    final sections = MedicineDetailSections(detail, l10n).build();

    // 滚动视图必须在 ResponsiveContentFrame **外面**：Frame 是 Center，套在
    // 外面会给 SingleChildScrollView 松约束，滚动视图收缩到内容高度后被垂直
    // 居中，详情就落在屏幕中间而不是页头下方。桌面端尤其明显。
    return SingleChildScrollView(
      child: ResponsiveContentFrame(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.lg,
            Spacing.lg,
            Spacing.lg,
            Spacing.xl6,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 整页是一个平面：没有卡片底，层级只靠字号 / 字重 / 分隔线。
              HeaderCard(detail: detail, source: source),
              const SizedBox(height: Spacing.lg),
              const AppDivider(),
              const SizedBox(height: Spacing.md),
              // 免责声明与风险入口是同「元信息」层，做成紧凑的一簇：
              // 声明是一条浅底提示，风险入口是一条可点行，两者之间不留大间隙。
              ReferenceNotice(l10n: l10n),
              const SizedBox(height: Spacing.xs),
              RiskCheckEntry(
                l10n: l10n,
                onTap: () => const MedicineRiskCheckRoute().push(context),
              ),
              const SizedBox(height: Spacing.lg),
              if (sections.isNotEmpty)
                FAccordion(
                  control: _accordionControl,
                  children: [
                    for (var index = 0; index < sections.length; index += 1)
                      FAccordionItem(
                        title: _SectionHeader(section: sections[index]),
                        // Only the highest-frequency section opens by default;
                        // everything below is opt-in so the page stays short.
                        initiallyExpanded: sections[index].tier == Tier.primary,
                        child: _SectionBody(
                          section: sections[index],
                          l10n: l10n,
                          index: index,
                          expandedSections: _expandedSections,
                          medicineId: detail.id,
                          source: source,
                        ),
                      ),
                  ],
                )
              else
                StateMessageView(
                  title: l10n.medicineDetailNoContentTitle,
                  icon: SemanticIcons.statusNoContent,
                ),
              const SizedBox(height: Spacing.lg),
              FButton(
                onPress: isAdded
                    ? null
                    : () => _addToCurrentMedicines(ref, context, l10n),
                variant: isAdded
                    ? FButtonVariant.outline
                    : FButtonVariant.primary,
                child: Text(
                  isAdded
                      ? l10n.medicineSearchAlreadyAddedLabel
                      : l10n.medicineSearchAddToBoxAction,
                ),
              ),
              if (isAdded) ...[
                const SizedBox(height: Spacing.sm),
                FButton(
                  variant: FButtonVariant.outline,
                  onPress: () => MedicineReminderDetailRoute(
                    medicineId: currentMedicine.id,
                  ).push(context),
                  child: Text(l10n.medicineDetailOpenReminderAction),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addToCurrentMedicines(
    WidgetRef ref,
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final authSession = ref.read(authSessionProvider);
    if (!authSession.canAccessProtectedData) {
      if (authSession.isLoading) return;
      if (context.mounted) {
        await showAuthRequiredDialog(
          context,
          onLogin: () => requestSignIn(context),
        );
      }
      return;
    }

    final repository = ref.read(healthContextRepositoryProvider);
    final medicineSource = widget.source == 'drugbank'
        ? HealthMedicineSource.drugbank
        : HealthMedicineSource.cn;

    final input = CurrentMedicineWriteInput(
      source: medicineSource,
      sourceRefId: widget.detail.id,
      displayName: widget.detail.name,
    );

    try {
      final result = await repository.createCurrentMedicine(input).run();
      final updatedSnapshot = result.fold(
        (failure) => throw failure,
        (snapshot) => snapshot,
      );
      ref
          .read(dataChangeBusProvider.notifier)
          .emit(DataChangeTopic.currentMedicines);

      if (context.mounted) {
        final newMedicine = updatedSnapshot.currentMedicines.firstWhereOrNull(
          (m) =>
              m.sourceRefId == widget.detail.id &&
              m.source == medicineSource.name,
        );
        if (newMedicine == null) return;
        unawaited(
          Toast.showWithAction(
            context,
            l10n.medicineSearchAddedToBoxToast,
            l10n.medicineSearchGoToReminderAction,
            // The toast action fires on a later user tap; the page may have
            // been popped in between, so guard the push (deactivated context
            // would trip the `_dependents.isEmpty` assertion).
            () {
              if (!context.mounted) return;
              unawaited(
                MedicineRemindersNewRoute(
                  medicineId: newMedicine.id,
                ).push(context),
              );
            },
          ),
        );
      }
    } catch (e) {
      ref
          .read(talkerProvider)
          .error('MedicineDetailContent._addToCurrentMedicines: failed: $e');
      if (context.mounted) {
        unawaited(
          Toast.show(
            context,
            userMessageFromError(
              e,
              fallback: l10n.medicineSearchPrecheckFailedToast,
              l10n: l10n,
            ),
          ),
        );
      }
    }
  }
}

/// Renders one accordion body.
///
/// Only sections that fetch their own data (sequences) subscribe to the
/// expanded-set notifier; every other section renders straight through so a
/// long page is not rebuilt on each toggle.
class _SectionBody extends StatelessWidget {
  const _SectionBody({
    required this.section,
    required this.l10n,
    required this.index,
    required this.expandedSections,
    required this.medicineId,
    required this.source,
  });

  final MedicineDetailSection section;
  final AppLocalizations l10n;
  final int index;
  final ValueNotifier<Set<int>> expandedSections;
  final String medicineId;
  final String source;

  @override
  Widget build(BuildContext context) {
    if (section.body is! SequencesSectionBody) {
      return DetailSectionView(section: section, l10n: l10n);
    }

    return ValueListenableBuilder<Set<int>>(
      valueListenable: expandedSections,
      builder: (context, expanded, _) => DetailSectionView(
        section: section,
        l10n: l10n,
        shouldLoad: expanded.contains(index),
        medicineId: medicineId,
        source: source,
      ),
    );
  }
}

/// Accordion header showing the section title plus, when the payload has more
/// than one entry, a count badge so the user can judge whether to expand.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.section});

  final MedicineDetailSection section;

  @override
  Widget build(BuildContext context) {
    final count = section.count;
    if (count == null) {
      return Text(section.title);
    }

    // 数量徽标是固有宽度组件(FBadge 内部 IntrinsicWidth):放进 Row 会先占满
    // 固有宽度,把标题挤成多行;Wrap + spaceBetween 保持左标题右徽标的形态,
    // 放不下时徽标换到下一行。
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      spacing: Spacing.xs,
      runSpacing: Spacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(section.title),
        FBadge(
          variant: FBadgeVariant.secondary,
          child: Text('$count', maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

/// Header block: medicine name, source badge, and metadata rows.
///
/// 不带卡片底：本页是「读说明书」的连续长文，整页只有折叠区一个视觉层级。
/// 头部曾经是 `FCard`（白底圆角），而下方通知 / 风险入口 / 折叠区都直接铺在
/// `#FAFAFA` 页面上——于是顶部一张孤零零的白卡，下面全是裸底，接缝处特别割裂。
/// 现在整页统一为一个平面：靠字号、字重与分隔线建立层级，不再用容器底。
///
/// 信息只出现在一个地方。后端的 `subtitle` 是给搜索结果列表用的单行摘要
/// （形如「5mg（按氨氯地平计）· 国药准字 H20051487」），里面已经含了规格与批准
/// 文号；详情页下方又把 `approvalNumber` 单列一行，于是同一串国药准字出现两次。
/// 详情页的规范是：标题行只放药名 + 来源，下面用一个规整的键值块统一承载
/// 批准文号 / 生产企业 / 规格 / 商品名，`subtitle` 不再整串照搬。
class HeaderCard extends StatelessWidget {
  const HeaderCard({super.key, required this.detail, required this.source});

  final MedicineDetail detail;
  final String source;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typography = context.theme.typography;

    // 从 subtitle 里剥掉已经单独成行的批准文号，避免同一串编号出现两次。
    // 只做「去掉与 approvalNumber 相同的那一段」，其余（规格、剂型说明）保留。
    final subtitle = _subtitleWithoutApprovalNumber(detail);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题行：药名左、来源徽标右。徽标是固有宽度组件，所以药名必须放进
        // `Expanded`——否则 `Row` 会先给徽标无界约束、把药名挤成多行。
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                detail.name,
                style: typography.display.sm.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Padding(
              // 徽标与药名首行在视觉中线上对齐。
              padding: const EdgeInsets.only(top: Spacing.xs),
              child: SourceBadge(source: source, l10n: l10n),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: Spacing.xs),
          Text(
            subtitle,
            style: typography.body.sm.copyWith(
              color: SemanticColor.neutral.solid(context),
            ),
          ),
        ],
        if (source == 'cn') ...[
          const SizedBox(height: Spacing.lg),
          if (detail.approvalNumber != null)
            MetaRow(
              label: l10n.medicineDetailApprovalNumber,
              value: detail.approvalNumber!,
            ),
          if (detail.manufacturer != null)
            MetaRow(
              label: l10n.medicineDetailManufacturer,
              value: detail.manufacturer!,
            ),
          if (detail.packageSpec != null)
            MetaRow(
              label: l10n.medicineDetailPackageSpec,
              value: detail.packageSpec!,
            ),
          if (detail.brandName != null)
            MetaRow(
              label: l10n.medicineDetailBrandName,
              value: detail.brandName!,
            ),
        ],
      ],
    );
  }

  /// [MedicineDetail.subtitle] 去掉与 [MedicineDetail.approvalNumber] 重复的部分。
  ///
  /// 返回 `null` 表示去掉后什么都不剩——此时整行副标题都不显示，而不是留一个空行。
  static String? _subtitleWithoutApprovalNumber(MedicineDetail detail) {
    final raw = detail.subtitle?.trim();
    if (raw == null || raw.isEmpty) return null;

    final approval = detail.approvalNumber?.trim();
    if (approval == null || approval.isEmpty) return raw;

    // 后端两种写法都用过：带空格的「国药准字 H20051487」与紧排的
    // 「国药准字H20051487」。归一化空白后再比，避免漏掉其中一种。
    String squash(String value) => value.replaceAll(RegExp(r'\s+'), '');

    final parts = raw
        .split(RegExp(r'[·•]'))
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .where((part) => squash(part) != squash(approval))
        .toList();

    if (parts.isEmpty) return null;
    return parts.join(' · ');
  }
}

/// Metadata row: a muted label followed by its value.
///
/// 标签宽度改成**按内容自适应**（`IntrinsicWidth` 撑起整列的固定宽度）而不是
/// 写死 `Spacing.xl4`：中文标签「批准文号」在写死宽度下会折成两行（截图里的
/// 「批准 / 文号」），而英文标签又用不满，两种语言都没对齐。这里让同一次
/// 渲染里的所有 `MetaRow` 共享一个由最长标签决定的列宽，标签单行、值左对齐。
class MetaRow extends StatelessWidget {
  const MetaRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  /// 标签列宽：足够放下常见中文标签，同时不至于把值挤到换行。
  static const double _labelWidth = 64;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: _labelWidth,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: typography.body.xs.copyWith(
                color: SemanticColor.neutral.solid(context),
              ),
            ),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(child: Text(value, style: typography.body.xs)),
        ],
      ),
    );
  }
}
