import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luminous/components/app_canvas.dart';
import 'package:luminous/shared/widgets/app_surface.dart';
import 'package:luminous/shared/widgets/tinted_status_chip.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/pages/Reminders/controllers/reminder_list_controller.dart';
import 'package:luminous/pages/Reminders/reminder_edit.dart';
import 'package:luminous/viewmodels/reminder.dart';

/// 用药提醒列表页。
///
/// 页面只负责展示列表、页面跳转和删除确认，业务状态由 controller 承接。
class ReminderListPage extends StatelessWidget {
  /// 创建用药提醒列表页组件。
  const ReminderListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReminderListController>(
      init: ReminderListController(),
      global: false,
      builder: (controller) {
        final l10n = AppLocalizations.of(context);
        return AppCanvasPageScaffold(
          appBar: AppBar(
            title: Text(l10n?.reminderListTitle ?? '用药提醒'),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            foregroundColor: const Color(0xFF0F172A),
            actions: [
              IconButton(
                onPressed: controller.isLoggedIn && !controller.loading
                    ? controller.sync
                    : null,
                icon: controller.loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          appBarSpacing: 30,
          accentColor: const Color(0xFF10B981),
          secondaryAccentColor: const Color(0xFF0EA5E9),
          floatingActionButton: controller.isLoggedIn
              ? FloatingActionButton.extended(
                  onPressed: controller.loading
                      ? null
                      : () => _openCreate(context, controller),
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l10n?.reminderAddButton ?? '新增提醒'),
                )
              : null,
          child: !controller.isLoggedIn
              ? _buildNeedLogin(context)
              : RefreshIndicator(
                  onRefresh: controller.sync,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
                    children: [
                      _buildHeroCard(context, controller),
                      const SizedBox(height: 10),
                      if (controller.error != null)
                        _buildErrorBanner(context, controller.error!),
                      if (controller.items.isEmpty && !controller.loading)
                        _buildEmpty(context),
                      ...controller.items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index == controller.items.length - 1
                                ? 0
                                : 8,
                          ),
                          child: _ReminderCard(
                            item: item,
                            busy: controller.isBusy(item.id),
                            onTap: () => _openEdit(context, controller, item),
                            onToggle: (value) =>
                                controller.toggleEnabled(item, value),
                            onDelete: () =>
                                _confirmAndDelete(context, controller, item),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
        );
      },
    );
  }

  String _itemsCountLabel(AppLocalizations? l10n, int count) {
    return l10n?.reminderListCountLabel(count) ?? '$count 条提醒';
  }

  Widget _buildHeroCard(
    BuildContext context,
    ReminderListController controller,
  ) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return AppSectionCard(
      accentColor: const Color(0xFF10B981),
      secondaryColor: const Color(0xFF38BDF8),
      ornamentKey: 'reminders.list.hero',
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n?.reminderListTitle ?? '用药提醒',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            l10n?.reminderEmptySubtitle ?? '点击右下角“新增提醒”开始设置',
            style: TextStyle(
              fontSize: 12.8,
              height: 1.45,
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              TintedStatusChip(
                icon: Icons.library_books_rounded,
                text: _itemsCountLabel(l10n, controller.items.length),
                color: const Color(0xFF0EA5E9),
              ),
              TintedStatusChip(
                icon: Icons.notifications_active_rounded,
                text:
                    l10n?.reminderListEnabledCountLabel(
                      controller.enabledCount,
                    ) ??
                    '${controller.enabledCount} 启用',
                color: const Color(0xFF10B981),
              ),
              TintedStatusChip(
                icon: Icons.notifications_off_rounded,
                text:
                    l10n?.reminderListDisabledCountLabel(
                      controller.disabledCount,
                    ) ??
                    '${controller.disabledCount} 关闭',
                color: const Color(0xFF64748B),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建未登录时的引导视图。
  Widget _buildNeedLogin(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = Theme.of(context).colorScheme;
    final iconAccent = Color.lerp(scheme.primary, scheme.tertiary, 0.4)!;
    final iconBackground = appTintedSurface(
      context,
      iconAccent,
      lightAlpha: 0.12,
      darkAlpha: 0.24,
      baseColor: theme.cardTheme.color ?? scheme.surface,
    );
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: AppSectionCard(
          accentColor: Color.lerp(scheme.primary, scheme.tertiary, 0.32)!,
          secondaryColor: Color.lerp(scheme.tertiary, scheme.secondary, 0.4)!,
          ornamentKey: 'reminders.need-login',
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
          radius: 18,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: iconBackground,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: appTintedBorder(
                      context,
                      iconAccent,
                      lightAlpha: 0.16,
                      darkAlpha: 0.26,
                    ),
                  ),
                ),
                child: Icon(Icons.alarm_rounded, color: iconAccent, size: 30),
              ),
              const SizedBox(height: 12),
              Text(
                l10n?.reminderNeedLoginTitle ?? '请先登录',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n?.reminderNeedLoginSubtitle ?? '登录后可同步提醒计划，并在到点收到系统通知。',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  style: FilledButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    minimumSize: const Size(double.infinity, 46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(l10n?.reminderNeedLoginAction ?? '去登录'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建错误提示 banner。
  Widget _buildErrorBanner(BuildContext context, String text) {
    final scheme = Theme.of(context).colorScheme;
    return AppSectionCard(
      accentColor: const Color(0xFFF59E0B),
      secondaryColor: Color.lerp(const Color(0xFFF59E0B), scheme.error, 0.25)!,
      ornamentKey: 'reminders.list.error',
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: scheme.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.45,
                color: scheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建空状态占位视图。
  Widget _buildEmpty(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return AppSectionCard(
      accentColor: Color.lerp(scheme.primary, scheme.tertiary, 0.32)!,
      secondaryColor: Color.lerp(scheme.tertiary, scheme.secondary, 0.4)!,
      ornamentKey: 'reminders.empty',
      padding: const EdgeInsets.symmetric(vertical: 42),
      radius: 18,
      child: Column(
        children: [
          const Icon(
            Icons.alarm_off_rounded,
            size: 42,
            color: Color(0xFF94A3B8),
          ),
          const SizedBox(height: 10),
          Text(
            l10n?.reminderEmptyTitle ?? '暂无提醒',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n?.reminderEmptySubtitle ?? '点击右下角“新增提醒”开始设置',
            style: TextStyle(
              fontSize: 13,
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// 打开“新增提醒”页并接住编辑结果。
  Future<void> _openCreate(
    BuildContext context,
    ReminderListController controller,
  ) async {
    final plan = await Navigator.of(context).push<ReminderPlan>(
      MaterialPageRoute<ReminderPlan>(builder: (_) => const ReminderEditPage()),
    );
    if (!context.mounted || plan == null) {
      return;
    }
    await controller.applySavedPlan(plan);
  }

  /// 打开“编辑提醒”页并接住更新结果。
  Future<void> _openEdit(
    BuildContext context,
    ReminderListController controller,
    ReminderPlan plan,
  ) async {
    final next = await Navigator.of(context).push<ReminderPlan>(
      MaterialPageRoute<ReminderPlan>(
        builder: (_) => ReminderEditPage(initial: plan),
      ),
    );
    if (!context.mounted || next == null) {
      return;
    }
    await controller.applySavedPlan(next);
  }

  Future<void> _confirmAndDelete(
    BuildContext context,
    ReminderListController controller,
    ReminderPlan plan,
  ) async {
    final confirmed = await _confirmDeletePlan(context, plan);
    if (!context.mounted || !confirmed) {
      return;
    }
    await controller.deletePlan(plan);
  }

  Future<bool> _confirmDeletePlan(
    BuildContext context,
    ReminderPlan plan,
  ) async {
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final scheme = Theme.of(dialogContext).colorScheme;
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 22),
          child: AppSectionCard(
            accentColor: const Color(0xFFF59E0B),
            secondaryColor: const Color(0xFFEF4444),
            ornamentKey: 'reminders.list.delete-dialog',
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: appTintedSurface(
                          dialogContext,
                          scheme.error,
                          lightAlpha: 0.12,
                          darkAlpha: 0.22,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: scheme.error,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n?.reminderDeleteDialogTitle ?? '删除提醒',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  l10n?.reminderDeleteDialogContent(
                        plan.productName,
                        plan.time,
                      ) ??
                      '确定要删除“${plan.productName} ${plan.time}”吗？',
                  style: TextStyle(
                    fontSize: 13.2,
                    height: 1.5,
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 44),
                          side: BorderSide(
                            color: scheme.outline.withValues(alpha: 0.7),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(l10n?.reminderDeleteCancel ?? '取消'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(l10n?.reminderDeleteConfirm ?? '删除'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    return result == true;
  }
}

/// 提醒计划列表中的单条卡片。
///
/// 负责展示时间、药品名、启用状态和删除入口，不直接访问接口。
class _ReminderCard extends StatelessWidget {
  /// 创建提醒计划卡片。
  const _ReminderCard({
    required this.item,
    required this.busy,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  /// 当前提醒计划条目。
  final ReminderPlan item;

  /// 当前条目是否正在执行变更操作。
  final bool busy;

  /// 点击卡片回调（进入编辑）。
  final VoidCallback onTap;

  /// 开关切换回调。
  final ValueChanged<bool> onToggle;

  /// 删除回调。
  final VoidCallback onDelete;

  /// 构建提醒计划卡片 UI。
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final accent = item.enabled
        ? const Color(0xFF10B981)
        : const Color(0xFF64748B);
    final rangeText = _formatDateRange(
      item.startDate,
      item.endDate,
      l10n: l10n,
    );
    return AppSectionCard(
      accentColor: accent,
      secondaryColor: Color.lerp(accent, scheme.primary, 0.36)!,
      ornamentKey: 'reminders.list.item',
      radius: 18,
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: busy ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: appTintedSurface(
                        context,
                        accent,
                        lightAlpha: 0.12,
                        darkAlpha: 0.22,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.alarm_rounded, color: accent, size: 19),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.productName.trim().isEmpty
                          ? (l10n?.reminderListTitle ?? '用药提醒')
                          : item.productName.trim(),
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  SizedBox(
                    height: 28,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Switch(
                        value: item.enabled,
                        onChanged: busy ? null : onToggle,
                      ),
                    ),
                  ),
                ],
              ),
              if (busy)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: scheme.primary,
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                _buildScheduleLine(item, l10n),
                style: TextStyle(
                  fontSize: 12.2,
                  height: 1.35,
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                _buildExtraContentLine(item, l10n),
                style: TextStyle(
                  fontSize: 12.3,
                  height: 1.4,
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n?.reminderRangeLabel(rangeText) ?? '生效区间: $rangeText',
                      style: TextStyle(
                        fontSize: 11.8,
                        height: 1.35,
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: appTintedSurface(
                        context,
                        scheme.error,
                        lightAlpha: 0.06,
                        darkAlpha: 0.14,
                      ),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: appTintedBorder(
                          context,
                          scheme.error,
                          lightAlpha: 0.11,
                          darkAlpha: 0.2,
                        ),
                      ),
                    ),
                    child: IconButton(
                      onPressed: busy ? null : onDelete,
                      constraints: const BoxConstraints.tightFor(
                        width: 34,
                        height: 34,
                      ),
                      padding: EdgeInsets.zero,
                      splashRadius: 18,
                      tooltip: l10n?.reminderDeleteConfirm ?? '删除',
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        size: 18,
                        color: busy
                            ? scheme.error.withValues(alpha: 0.34)
                            : scheme.error.withValues(alpha: 0.78),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateRange(
    String startDate,
    String endDate, {
    AppLocalizations? l10n,
  }) {
    final start = startDate.trim();
    final end = endDate.trim();
    if (start.isEmpty && end.isEmpty) {
      return l10n?.reminderRangeUnlimited ?? '不限制';
    }
    if (start.isNotEmpty && end.isNotEmpty) {
      return l10n?.reminderRangeBetween(start, end) ?? '$start 至 $end';
    }
    if (start.isNotEmpty) {
      return l10n?.reminderRangeFrom(start) ?? '$start 起';
    }
    return l10n?.reminderRangeUntil(end) ?? '截止 $end';
  }

  String _buildScheduleLine(ReminderPlan item, AppLocalizations? l10n) {
    final dosage = item.dosage.trim();
    final parts = <String>[];
    if (item.time.trim().isNotEmpty) {
      parts.add(item.time.trim());
    }
    if (dosage.isNotEmpty) {
      parts.add(
        l10n?.reminderDosePrefix(dosage) ??
            ((l10n?.localeName ?? 'zh').toLowerCase().startsWith('zh')
                ? '剂量: $dosage'
                : 'Dose: $dosage'),
      );
    }
    if (parts.isEmpty) {
      return l10n?.reminderSystemNotificationSubtitle ?? '系统通知提醒';
    }
    return parts.join(' · ');
  }

  String _buildExtraContentLine(ReminderPlan item, AppLocalizations? l10n) {
    final extra = item.subtitle.trim();
    if (extra.isNotEmpty) {
      return extra;
    }
    return l10n?.reminderNoExtraContent ??
        ((l10n?.localeName ?? 'zh').toLowerCase().startsWith('zh')
            ? '未设置额外提醒内容'
            : 'No extra reminder content');
  }
}
