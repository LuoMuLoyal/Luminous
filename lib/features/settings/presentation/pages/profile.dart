import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';
import 'package:luminous/core/widgets/common/avatar/avatar_action_view.dart';
import 'package:luminous/core/widgets/common/avatar/avatar_actions.dart';
import 'package:luminous/core/widgets/common/avatar/avatar_draft.dart';
import 'package:luminous/core/widgets/common/avatar/avatar_viewer.dart';
import 'package:luminous/core/widgets/common/control/tile_value.dart';
import 'package:luminous/core/widgets/common/dialog/edit_sheet.dart';
import 'package:luminous/core/widgets/common/dialog/sheet_drag_handle.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/auth/presentation/providers/account.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/health_context/domain/entities/write_inputs.dart';
import 'package:luminous/features/health_context/domain/services/unit_conversion.dart';
import 'package:luminous/features/mine/presentation/providers/health_edit_forms.dart';
import 'package:luminous/features/settings/presentation/widgets/shared/quantity_sheet.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 头像上传前的本地字节上限，与 Lucent 的 `maxSizeBytes` 一致，超限提前反馈。
const _maxAvatarBytes = 5 * 1024 * 1024;

/// 个人信息页。
///
/// 列表行是读侧(左标签 / 右当前值 / 箭头),写入只发生在点击后弹出的底部编辑
/// sheet;页面不再内联常驻输入框,也没有整体提交按钮。健康字段每行单独提交,
/// 只发送被改动的那个字段,其余用 [healthContextNoChange] 保持服务端现值。
class ProfilePage extends HookConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(authSessionProvider);
    final user = session.user;
    final avatarDraft = useState<AvatarDraft?>(null);
    final avatarRemoved = useState(false);

    final Widget content;

    if (!session.canAccessProtectedData) {
      final width = MediaQuery.sizeOf(context).width;
      content = ResponsiveContentFrame(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: width < Breakpoints.mobile ? Spacing.xl2 : Spacing.xl3,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              session.isLoading
                  ? const ProfilePageLoading()
                  : AuthRequiredDialogGate(
                      onLogin: () => Navigator.of(context).pop(),
                    ),
            ],
          ),
        ),
      );
    } else {
      final snapshot = ref.watch(healthContextSnapshotProvider);

      Future<void> editAvatar() async {
        final action = await showAvatarActionsDialog(
          context,
          avatarUrl: avatarRemoved.value ? null : user?.avatar,
        );
        if (!context.mounted || action == null) return;

        if (action == AvatarAction.view) {
          final draft = avatarDraft.value;
          if (draft != null) {
            await showAvatarBytesViewer(context, bytes: draft.bytes);
          } else {
            final url = user?.avatar;
            if (url != null && url.isNotEmpty) {
              await showAvatarViewer(context, avatarUrl: url);
            }
          }
          return;
        }

        final notifier = ref.read(authAccountProvider.notifier);
        if (action == AvatarAction.remove) {
          final ok = await notifier.updateProfile(
            nickname: user?.nickname,
            avatar: null,
          );
          if (!context.mounted) return;
          await Toast.show(
            context,
            ok ? l10n.mineEditSavedToast : l10n.profileAvatarSaveFailed,
          );
          if (ok) {
            avatarDraft.value = null;
            avatarRemoved.value = true;
          }
          return;
        }

        final draft = await pickAvatarDraft(context, action: action);
        if (!context.mounted || draft == null) return;
        if (draft.bytes.lengthInBytes > _maxAvatarBytes) {
          await Toast.show(context, l10n.profileAvatarTooLarge);
          return;
        }
        final ok = await notifier.uploadAvatar(
          bytes: draft.bytes,
          fileName: draft.fileName,
          contentType: draft.contentType,
          nickname: user?.nickname,
        );
        if (!context.mounted) return;
        await Toast.show(
          context,
          ok ? l10n.mineEditSavedToast : l10n.profileAvatarSaveFailed,
        );
        if (ok) {
          avatarDraft.value = draft;
          avatarRemoved.value = false;
        }
      }

      Future<void> editNickname() async {
        final value = await showTextEditSheet(
          context: context,
          // 标题已是「昵称」,字段内不再重复 label。
          title: l10n.profileNicknameLabel,
          hint: l10n.profileNicknameHint,
          initialValue: user?.nickname ?? '',
        );
        if (!context.mounted || value == null || value == user?.nickname) {
          return;
        }

        final ok = await ref
            .read(authAccountProvider.notifier)
            .updateProfile(nickname: value, avatar: user?.avatar);
        if (ok && context.mounted) {
          await Toast.show(context, l10n.mineEditSavedToast);
        }
      }

      final width = MediaQuery.sizeOf(context).width;
      content = ResponsiveContentFrame(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: width < Breakpoints.mobile ? Spacing.xl2 : Spacing.xl3,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionLabel(label: l10n.profileUserSectionTitle),
              const SizedBox(height: Spacing.sm),
              FTileGroup(
                physics: const NeverScrollableScrollPhysics(),
                divider: FItemDivider.full,
                children: [
                  FTile(
                    key: const Key('profile-avatar-row'),
                    // 左文字右头像:头像作为 suffix,后面跟跳转箭头。
                    title: Text(l10n.profileAvatarRowTitle),
                    suffix: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AvatarActionView(
                          avatarUrl: avatarRemoved.value ? null : user?.avatar,
                          bytes: avatarDraft.value?.bytes,
                          size: 40,
                          iconSize: 20,
                          showEditBadge: false,
                        ),
                        const SizedBox(width: Spacing.sm),
                        const Icon(SemanticIcons.actionNext),
                      ],
                    ),
                    onPress: () => unawaited(editAvatar()),
                  ),
                  FTile(
                    key: const Key('profile-nickname-row'),
                    title: Text(l10n.profileNicknameLabel),
                    details: AppTileValue(
                      user?.nickname?.trim().isNotEmpty == true
                          ? user!.nickname!.trim()
                          : l10n.profileEmptyValue,
                    ),
                    suffix: const Icon(SemanticIcons.actionNext),
                    onPress: () => unawaited(editNickname()),
                  ),
                  FTile(
                    key: const Key('profile-email-row'),
                    title: Text(l10n.authAccountManageEmail),
                    details: AppTileValue(user?.email ?? l10n.authEmailMissing),
                    // 邮箱走改邮箱页(验证码 + 密码),不是就地编辑。
                    suffix: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (user?.emailVerifiedAt != null) ...[
                          Icon(
                            SemanticIcons.statusSuccess,
                            size: IconSizeTokens.md,
                            color: SemanticColor.success.solid(context),
                          ),
                          const SizedBox(width: Spacing.sm),
                        ],
                        const Icon(SemanticIcons.actionNext),
                      ],
                    ),
                    onPress: () =>
                        unawaited(context.push(Routes.accountChangeEmail)),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.xl2),

              _SectionLabel(label: l10n.profileHealthSectionTitle),
              const SizedBox(height: Spacing.sm),
              snapshot.when(
                // 每次行内提交都会 emit healthContext 主题,快照 provider 因依赖
                // 变化 reload——重取期间保留既有内容,不让整卡掉回骨架屏闪一下。
                skipLoadingOnReload: true,
                skipLoadingOnRefresh: true,
                data: (ctx) => _HealthProfileCard(
                  profile: ctx.profile,
                  onChanged: () =>
                      unawaited(Toast.show(context, l10n.mineEditSavedToast)),
                ),
                loading: () => const ProfilePageLoading(),
                error: (_, __) => StateErrorView(
                  title: l10n.mineErrorTitle,
                  description: l10n.mineErrorDescription,
                  icon: SemanticIcons.reportAdherence,
                  actionLabel: l10n.todayRetryAction,
                  onAction: () => ref
                      .read(dataChangeBusProvider.notifier)
                      .emit(DataChangeTopic.healthContext),
                  tone: StateTone.warning,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return PageScaffold(
      title: l10n.profilePageTitle,
      child: SingleChildScrollView(child: content),
    );
  }
}

/// 健康档案卡片:每行点击后弹出单字段编辑 sheet。
class _HealthProfileCard extends ConsumerWidget {
  const _HealthProfileCard({required this.profile, required this.onChanged});

  final HealthProfile profile;
  final VoidCallback onChanged;

  /// 弹出单字段 sheet,确认后只提交该字段。
  Future<void> _submit({
    required BuildContext context,
    required WidgetRef ref,
    required HealthProfileUpdateInput input,
  }) async {
    if (!context.mounted) return;
    final state = ref.read(healthProfileFormProvider);
    if (state.isSaving) return;
    final l10n = AppLocalizations.of(context)!;
    final saved = await ref
        .read(healthProfileFormProvider.notifier)
        .save(input);
    if (!context.mounted) return;
    // 失败时不能走「已保存」提示——写入错误已进 state.errorMessage,
    // 如实反馈失败,避免用户以为改动已落库。
    await Toast.show(
      context,
      saved ? l10n.mineEditSavedToast : l10n.mineEditSaveFailedToast,
    );
    if (saved) onChanged();
  }

  /// 弹出一个由 [slot] 承载当前值的 sheet,确认后把值交给 [buildInput]。
  Future<void> _edit<T>({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required SheetValueSlot<T> slot,
    required Widget Function(BuildContext context, SheetValueSlot<T> slot) body,
    required HealthProfileUpdateInput Function(T value) buildInput,
  }) async {
    final value = await showValueEditSheet<T>(
      context: context,
      title: title,
      slot: slot,
      body: body,
    );
    if (value == null || !context.mounted) return;
    await _submit(context: context, ref: ref, input: buildInput(value));
  }

  /// 出生日期:直接弹出裸日历 sheet,选中日期即弹回并提交,无确认按钮。
  Future<void> _editBirthDate(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final picked = await showFSheet<DateTime>(
      context: context,
      side: FLayout.btt,
      useSafeArea: true,
      builder: (sheetContext) => SheetSurface(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            Spacing.xl,
            0,
            Spacing.xl,
            Spacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SheetDragHandle(),
              Text(
                l10n.mineEditFieldBirthDate,
                textAlign: TextAlign.center,
                style: sheetContext.theme.typography.body.lg.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: Spacing.lg),
              FCalendar.grid(
                key: const Key('profile-birthdate-calendar'),
                selectionControl: FDateSelectionControl.managedSingle(
                  initial: _tryParseDate(profile.birthDate),
                  onChange: (value) {
                    if (value != null) Navigator.pop(sheetContext, value);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (picked == null || !context.mounted) return;
    await _submit(
      context: context,
      ref: ref,
      input: HealthProfileUpdateInput(birthDate: _formatDate(picked)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final sex = HealthSexAtBirth.fromValue(profile.sexAtBirth);
    final unit = HealthUnitSystem.fromValue(profile.unitSystem);
    final imperial = isImperialUnitSystem(profile.unitSystem);
    final activity = HealthActivityLevel.fromValue(profile.activityLevel);
    final diets = profile.dietaryPreferences
        ?.map(HealthDietaryPreference.fromValue)
        .whereType<HealthDietaryPreference>()
        .toList();

    return FTileGroup(
      physics: const NeverScrollableScrollPhysics(),
      divider: FItemDivider.full,
      children: [
        FTile(
          key: const Key('profile-birthdate-row'),
          title: Text(l10n.mineEditFieldBirthDate),
          details: AppTileValue(profile.birthDate ?? l10n.profileEmptyValue),
          suffix: const Icon(SemanticIcons.actionNext),
          // 直接弹出裸日历 sheet:选中日期即弹回并提交,无确认按钮。
          onPress: () => unawaited(_editBirthDate(context, ref)),
        ),
        FSelectMenuTile<HealthSexAtBirth>(
          key: const Key('profile-sex-row'),
          title: Text(l10n.mineEditFieldSexAtBirth),
          details: AppTileValue(
            sex == null ? l10n.profileEmptyValue : _sexLabel(l10n, sex),
          ),
          selectControl: FMultiValueControl<HealthSexAtBirth>.managedRadio(
            initial: sex,
            onChange: (selection) {
              if (selection.isEmpty) return;
              unawaited(
                _submit(
                  context: context,
                  ref: ref,
                  input: HealthProfileUpdateInput(sexAtBirth: selection.first),
                ),
              );
            },
          ),
          menu: [
            for (final value in HealthSexAtBirth.values)
              FSelectTile<HealthSexAtBirth>(
                title: Text(_sexLabel(l10n, value)),
                value: value,
              ),
          ],
        ),
        FTile(
          key: const Key('profile-height-row'),
          title: Text(l10n.profileFieldHeight),
          details: AppTileValue(_heightLabel(l10n, profile.heightCm, imperial)),
          suffix: const Icon(SemanticIcons.actionNext),
          onPress: () {
            unawaited(
              _edit<double>(
                context: context,
                ref: ref,
                title: l10n.profileFieldHeight,
                slot: SheetValueSlot<double>(profile.heightCm ?? 170),
                body: (sheetContext, slot) => HeightPickerSheetBody(
                  slot: slot,
                  imperial: imperial,
                  suffixes: imperial
                      ? [l10n.profileUnitFt, l10n.profileUnitIn]
                      : [l10n.profileUnitCm],
                ),
                buildInput: (value) =>
                    HealthProfileUpdateInput(heightCm: value.round()),
              ),
            );
          },
        ),
        FTile(
          key: const Key('profile-weight-row'),
          title: Text(l10n.profileFieldWeight),
          details: AppTileValue(_weightLabel(l10n, profile.weightKg, imperial)),
          suffix: const Icon(SemanticIcons.actionNext),
          onPress: () {
            unawaited(
              _edit<double>(
                context: context,
                ref: ref,
                title: l10n.profileFieldWeight,
                slot: SheetValueSlot<double>(profile.weightKg ?? 65),
                body: (sheetContext, slot) => WeightPickerSheetBody(
                  slot: slot,
                  imperial: imperial,
                  suffixes: [
                    imperial ? l10n.profileUnitLb : l10n.profileUnitKg,
                  ],
                ),
                buildInput: (value) =>
                    HealthProfileUpdateInput(weightKg: value.round()),
              ),
            );
          },
        ),
        FSelectMenuTile<HealthActivityLevel>(
          key: const Key('profile-activity-level-row'),
          title: Text(l10n.profileFieldActivityLevel),
          details: AppTileValue(
            activity == null
                ? l10n.profileEmptyValue
                : _activityLabel(l10n, activity),
          ),
          selectControl: FMultiValueControl<HealthActivityLevel>.managedRadio(
            initial: activity,
            onChange: (selection) {
              if (selection.isEmpty) return;
              unawaited(
                _submit(
                  context: context,
                  ref: ref,
                  input: HealthProfileUpdateInput(
                    activityLevel: selection.first,
                  ),
                ),
              );
            },
          ),
          menu: [
            for (final value in HealthActivityLevel.values)
              FSelectTile<HealthActivityLevel>(
                title: Text(_activityLabel(l10n, value)),
                value: value,
              ),
          ],
        ),
        FSelectMenuTile<HealthUnitSystem>(
          key: const Key('profile-unit-system-row'),
          title: Text(l10n.mineEditFieldUnitSystem),
          details: AppTileValue(
            unit == null
                ? l10n.profileEmptyValue
                : unit == HealthUnitSystem.metric
                ? l10n.mineEditUnitSystemMetric
                : l10n.mineEditUnitSystemImperial,
          ),
          selectControl: FMultiValueControl<HealthUnitSystem>.managedRadio(
            initial: unit,
            onChange: (selection) {
              if (selection.isEmpty) return;
              unawaited(
                _submit(
                  context: context,
                  ref: ref,
                  input: HealthProfileUpdateInput(unitSystem: selection.first),
                ),
              );
            },
          ),
          menu: [
            for (final value in HealthUnitSystem.values)
              FSelectTile<HealthUnitSystem>(
                // 菜单项右侧标注该单位制对应的度量单位,便于用户按习惯选择。
                title: Text(
                  value == HealthUnitSystem.metric
                      ? l10n.mineEditUnitSystemMetric
                      : l10n.mineEditUnitSystemImperial,
                ),
                details: Text(
                  value == HealthUnitSystem.metric
                      ? '${l10n.profileUnitCm} · ${l10n.profileUnitKg}'
                      : '${l10n.profileUnitFt} · ${l10n.profileUnitIn} · '
                            '${l10n.profileUnitLb}',
                  style: context.theme.typography.body.sm.copyWith(
                    color: SemanticColor.neutral.solid(context),
                  ),
                ),
                value: value,
              ),
          ],
        ),
        // 饮食偏好:菜单内连续勾选只更新 pending 集合,菜单收起时一次性提交。
        _DietaryPreferencesRow(
          diets: diets,
          onCommit: (value) {
            unawaited(
              _submit(
                context: context,
                ref: ref,
                input: HealthProfileUpdateInput(
                  dietaryPreferences: value.toList(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// 数值/枚举单字段编辑器组件在 `widgets/shared/`（quantity_sheet /
/// enum_select_sheet）；本页只负责行展示与提交。

String _sexLabel(AppLocalizations l10n, HealthSexAtBirth sex) {
  return switch (sex) {
    HealthSexAtBirth.female => l10n.mineEditSexAtBirthFemale,
    HealthSexAtBirth.male => l10n.mineEditSexAtBirthMale,
    HealthSexAtBirth.intersex => l10n.mineEditSexAtBirthIntersex,
    HealthSexAtBirth.unknown => l10n.mineEditSexAtBirthUnknown,
  };
}

String _activityLabel(AppLocalizations l10n, HealthActivityLevel level) {
  return switch (level) {
    HealthActivityLevel.sedentary => l10n.profileActivitySedentary,
    HealthActivityLevel.lightlyActive => l10n.profileActivityLightlyActive,
    HealthActivityLevel.moderatelyActive =>
      l10n.profileActivityModeratelyActive,
    HealthActivityLevel.veryActive => l10n.profileActivityVeryActive,
    HealthActivityLevel.extremelyActive => l10n.profileActivityExtremelyActive,
  };
}

String _dietLabel(AppLocalizations l10n, HealthDietaryPreference pref) {
  return switch (pref) {
    HealthDietaryPreference.vegetarian => l10n.profileDietVegetarian,
    HealthDietaryPreference.vegan => l10n.profileDietVegan,
    HealthDietaryPreference.lowCarb => l10n.profileDietLowCarb,
    HealthDietaryPreference.lowSalt => l10n.profileDietLowSalt,
    HealthDietaryPreference.lowFat => l10n.profileDietLowFat,
    HealthDietaryPreference.highProtein => l10n.profileDietHighProtein,
    HealthDietaryPreference.keto => l10n.profileDietKeto,
    HealthDietaryPreference.halal => l10n.profileDietHalal,
    HealthDietaryPreference.other => l10n.profileDietOther,
  };
}

/// 身高展示:英制 `5'7"`，公制 `170 cm`。
String _heightLabel(AppLocalizations l10n, double? cm, bool imperial) {
  if (cm == null) return l10n.profileEmptyValue;
  if (imperial) {
    final converted = cmToFeetInches(cm);
    return '${converted.feet}\'${converted.inches}"';
  }
  return '${cm.round()} ${l10n.profileUnitCm}';
}

/// 体重展示:英制 lb，公制 kg。
String _weightLabel(AppLocalizations l10n, double? kg, bool imperial) {
  if (kg == null) return l10n.profileEmptyValue;
  if (imperial) return '${kgToLb(kg).round()} ${l10n.profileUnitLb}';
  return '${kg.round()} ${l10n.profileUnitKg}';
}

/// 饮食偏好行:菜单内连续勾选只累积 pending 集合(勾选期间 cutout 下 details
/// 原地更新),菜单收起时一次性提交——避免每勾一项就 PATCH + 快照重取一次。
class _DietaryPreferencesRow extends StatefulWidget with FTileMixin {
  const _DietaryPreferencesRow({required this.diets, required this.onCommit});

  /// 服务端当前值(null = 未设置)。
  final List<HealthDietaryPreference>? diets;
  final ValueChanged<Set<HealthDietaryPreference>> onCommit;

  @override
  State<_DietaryPreferencesRow> createState() => _DietaryPreferencesRowState();
}

class _DietaryPreferencesRowState extends State<_DietaryPreferencesRow> {
  Set<HealthDietaryPreference>? _pending;

  @override
  void didUpdateWidget(_DietaryPreferencesRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 新快照落地后以服务端现值为准,清掉未决集合。
    // List 逐元素比较（const ListEquality）：服务端每次 PATCH 都返回新数组引用，
    // 若按 `!=` 引用比较，任何一次刷新都会被当成"值变化"而清掉未决勾选。
    if (!const ListEquality<HealthDietaryPreference>().equals(
      widget.diets,
      oldWidget.diets,
    )) {
      _pending = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final current = _pending ?? widget.diets;
    return FSelectMenuTile<HealthDietaryPreference>(
      key: const Key('profile-dietary-preferences-row'),
      title: Text(l10n.profileFieldDietaryPreferences),
      details: AppTileValue(
        current == null || current.isEmpty
            ? l10n.profileEmptyValue
            : current.map((d) => _dietLabel(l10n, d)).join(', '),
      ),
      selectControl: FMultiValueControl<HealthDietaryPreference>.managed(
        initial: widget.diets?.toSet() ?? <HealthDietaryPreference>{},
        max: 5,
        onChange: (selection) => setState(() => _pending = Set.of(selection)),
      ),
      autoHide: false,
      menuOnTapHide: () {
        final pending = _pending;
        if (pending == null) return;
        _pending = null;
        widget.onCommit(pending);
      },
      menu: [
        for (final value in HealthDietaryPreference.values)
          FSelectTile<HealthDietaryPreference>(
            title: Text(_dietLabel(l10n, value)),
            value: value,
          ),
      ],
    );
  }
}

DateTime? _tryParseDate(String? value) {
  if (value == null || value.isEmpty) return null;
  return DateTime.tryParse(value);
}

String _formatDate(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
      child: Text(
        label,
        style: context.theme.typography.body.md.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// 页面加载状态
class ProfilePageLoading extends StatelessWidget {
  const ProfilePageLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const InlineSkeleton(
      children: [
        InlineSkeletonBlock(height: 96),
        InlineSkeletonBlock(height: 132),
        InlineSkeletonBlock(height: 96),
        InlineSkeletonBlock(height: 116),
      ],
    );
  }
}
