import 'dart:async';

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
import 'package:luminous/core/widgets/common/control/divider.dart';
import 'package:luminous/core/widgets/common/control/value_row.dart';
import 'package:luminous/core/widgets/common/dialog/edit_sheet.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/auth/presentation/providers/account.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/health_context/domain/entities/write_inputs.dart';
import 'package:luminous/features/mine/presentation/providers/health_edit_forms.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 常用血型选项
const _bloodTypeOptions = <String>[
  'A+',
  'A-',
  'B+',
  'B-',
  'AB+',
  'AB-',
  'O+',
  'O-',
];

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
          if (ok) {
            avatarDraft.value = null;
            avatarRemoved.value = true;
            await Toast.show(context, l10n.mineEditSavedToast);
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
        if (ok) {
          avatarDraft.value = draft;
          avatarRemoved.value = false;
          await Toast.show(context, l10n.mineEditSavedToast);
        }
      }

      Future<void> editNickname() async {
        final value = await showTextEditSheet(
          context: context,
          title: l10n.profileNicknameLabel,
          label: l10n.profileNicknameLabel,
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
              _ValueCard(
                children: [
                  AppValueRow(
                    key: const Key('profile-avatar-row'),
                    label: l10n.profileAvatarRowTitle,
                    value: '',
                    onPress: () => unawaited(editAvatar()),
                    leading: AvatarActionView(
                      avatarUrl: avatarRemoved.value ? null : user?.avatar,
                      bytes: avatarDraft.value?.bytes,
                      size: 40,
                      iconSize: 20,
                      showEditBadge: false,
                    ),
                  ),
                  const AppDivider(),
                  AppValueRow(
                    key: const Key('profile-nickname-row'),
                    label: l10n.profileNicknameLabel,
                    value: user?.nickname?.trim().isNotEmpty == true
                        ? user!.nickname!.trim()
                        : l10n.profileEmptyValue,
                    isPlaceholder: user?.nickname?.trim().isNotEmpty != true,
                    onPress: () => unawaited(editNickname()),
                  ),
                  const AppDivider(),
                  AppValueRow(
                    key: const Key('profile-email-row'),
                    label: l10n.authAccountManageEmail,
                    value: user?.email ?? l10n.authEmailMissing,
                    isPlaceholder: user?.email == null,
                    // 邮箱走改邮箱页(验证码 + 密码),不是就地编辑。
                    onPress: () =>
                        unawaited(context.push(Routes.accountChangeEmail)),
                    trailing: user?.emailVerifiedAt != null
                        ? Icon(
                            SemanticIcons.statusSuccess,
                            size: IconSizeTokens.md,
                            color: SemanticColor.success.solid(context),
                          )
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: Spacing.xl2),

              _SectionLabel(label: l10n.profileHealthSectionTitle),
              const SizedBox(height: Spacing.sm),
              snapshot.when(
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
    await ref.read(healthProfileFormProvider.notifier).save(input);
    onChanged();
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

  /// 文本型单字段 sheet:sheet 自己持有 controller,返回值或 null。
  Future<void> _editText({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required HealthProfileUpdateInput Function(String value) buildInput,
    String? hint,
    String? initialValue,
    TextInputType? keyboardType,
  }) async {
    final value = await showTextEditSheet(
      context: context,
      title: title,
      hint: hint,
      initialValue: initialValue,
      keyboardType: keyboardType,
    );
    if (value == null || !context.mounted) return;
    await _submit(context: context, ref: ref, input: buildInput(value));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final sex = HealthSexAtBirth.fromValue(profile.sexAtBirth);
    final unit = HealthUnitSystem.fromValue(profile.unitSystem);

    return _ValueCard(
      children: [
        AppValueRow(
          key: const Key('profile-birthdate-row'),
          label: l10n.mineEditFieldBirthDate,
          value: profile.birthDate ?? l10n.profileEmptyValue,
          isPlaceholder: profile.birthDate == null,
          onPress: () {
            unawaited(
              _edit<DateTime>(
                context: context,
                ref: ref,
                title: l10n.mineEditFieldBirthDate,
                slot: SheetValueSlot<DateTime>(
                  _tryParseDate(profile.birthDate) ?? DateTime.now(),
                ),
                body: (sheetContext, slot) => FDateField.calendar(
                  key: const Key('profile-birthdate-sheet-field'),
                  label: Text(l10n.mineEditFieldBirthDate),
                  selectionControl: FDateSelectionControl.managedSingle(
                    initial: slot.value,
                    onChange: (value) {
                      if (value != null) slot.value = value;
                    },
                  ),
                ),
                buildInput: (value) =>
                    HealthProfileUpdateInput(birthDate: _formatDate(value)),
              ),
            );
          },
        ),
        const AppDivider(),
        AppValueRow(
          key: const Key('profile-sex-row'),
          label: l10n.mineEditFieldSexAtBirth,
          value: sex == null ? l10n.profileEmptyValue : _sexLabel(l10n, sex),
          isPlaceholder: sex == null,
          onPress: () {
            unawaited(
              _edit<HealthSexAtBirth>(
                context: context,
                ref: ref,
                title: l10n.mineEditFieldSexAtBirth,
                slot: SheetValueSlot<HealthSexAtBirth>(
                  sex ?? HealthSexAtBirth.unknown,
                ),
                body: (sheetContext, slot) => _EnumSheet<HealthSexAtBirth>(
                  fieldKey: const Key('profile-sex-sheet-field'),
                  label: l10n.mineEditFieldSexAtBirth,
                  hint: l10n.mineEditFieldSexAtBirth,
                  value: slot.value,
                  values: HealthSexAtBirth.values,
                  labelBuilder: (v) => _sexLabel(l10n, v),
                  onChanged: (v) {
                    if (v != null) slot.value = v;
                  },
                ),
                buildInput: (value) =>
                    HealthProfileUpdateInput(sexAtBirth: value),
              ),
            );
          },
        ),
        const AppDivider(),
        AppValueRow(
          key: const Key('profile-height-row'),
          label: l10n.mineEditFieldHeightCm,
          value: profile.heightCm == null
              ? l10n.profileEmptyValue
              : profile.heightCm!.toStringAsFixed(0),
          isPlaceholder: profile.heightCm == null,
          onPress: () {
            unawaited(
              _editText(
                context: context,
                ref: ref,
                title: l10n.mineEditFieldHeightCm,
                hint: l10n.profileHeightHint,
                initialValue: profile.heightCm?.toStringAsFixed(0) ?? '',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                buildInput: (value) =>
                    HealthProfileUpdateInput(heightCm: num.tryParse(value)),
              ),
            );
          },
        ),
        const AppDivider(),
        AppValueRow(
          key: const Key('profile-weight-row'),
          label: l10n.mineEditFieldWeightKg,
          value: profile.weightKg == null
              ? l10n.profileEmptyValue
              : profile.weightKg!.toStringAsFixed(0),
          isPlaceholder: profile.weightKg == null,
          onPress: () {
            unawaited(
              _editText(
                context: context,
                ref: ref,
                title: l10n.mineEditFieldWeightKg,
                hint: l10n.profileWeightHint,
                initialValue: profile.weightKg?.toStringAsFixed(0) ?? '',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                buildInput: (value) =>
                    HealthProfileUpdateInput(weightKg: num.tryParse(value)),
              ),
            );
          },
        ),
        const AppDivider(),
        AppValueRow(
          key: const Key('profile-blood-type-row'),
          label: l10n.mineEditFieldBloodType,
          value: profile.bloodType ?? l10n.profileEmptyValue,
          isPlaceholder: profile.bloodType == null,
          onPress: () {
            unawaited(
              _edit<String>(
                context: context,
                ref: ref,
                title: l10n.mineEditFieldBloodType,
                slot: SheetValueSlot<String>(
                  profile.bloodType ?? _bloodTypeOptions.first,
                ),
                body: (sheetContext, slot) => _EnumSheet<String>(
                  fieldKey: const Key('profile-blood-type-sheet-field'),
                  label: l10n.mineEditFieldBloodType,
                  hint: l10n.profileBloodTypeHint,
                  value: slot.value,
                  values: _bloodTypeOptions,
                  labelBuilder: (v) => v,
                  onChanged: (v) {
                    if (v != null) slot.value = v;
                  },
                ),
                buildInput: (value) =>
                    HealthProfileUpdateInput(bloodType: value),
              ),
            );
          },
        ),
        const AppDivider(),
        AppValueRow(
          key: const Key('profile-unit-system-row'),
          label: l10n.mineEditFieldUnitSystem,
          value: unit == null
              ? l10n.profileEmptyValue
              : unit == HealthUnitSystem.metric
              ? l10n.mineEditUnitSystemMetric
              : l10n.mineEditUnitSystemImperial,
          isPlaceholder: unit == null,
          onPress: () {
            unawaited(
              _edit<HealthUnitSystem>(
                context: context,
                ref: ref,
                title: l10n.mineEditFieldUnitSystem,
                slot: SheetValueSlot<HealthUnitSystem>(
                  unit ?? HealthUnitSystem.metric,
                ),
                body: (sheetContext, slot) => _EnumSheet<HealthUnitSystem>(
                  fieldKey: const Key('profile-unit-system-sheet-field'),
                  label: l10n.mineEditFieldUnitSystem,
                  hint: l10n.mineEditFieldUnitSystemHint,
                  value: slot.value,
                  values: HealthUnitSystem.values,
                  labelBuilder: (v) => v == HealthUnitSystem.metric
                      ? l10n.mineEditUnitSystemMetric
                      : l10n.mineEditUnitSystemImperial,
                  onChanged: (v) {
                    if (v != null) slot.value = v;
                  },
                ),
                buildInput: (value) =>
                    HealthProfileUpdateInput(unitSystem: value),
              ),
            );
          },
        ),
        const AppDivider(),
        AppValueRow(
          key: const Key('profile-emergency-name-row'),
          label: l10n.mineEditFieldEmergencyContactName,
          value: profile.emergencyContactName ?? l10n.profileEmptyValue,
          isPlaceholder: profile.emergencyContactName == null,
          onPress: () {
            unawaited(
              _editText(
                context: context,
                ref: ref,
                title: l10n.mineEditFieldEmergencyContactName,
                hint: l10n.profileEmergencyNameHint,
                initialValue: profile.emergencyContactName ?? '',
                buildInput: (value) =>
                    HealthProfileUpdateInput(emergencyContactName: value),
              ),
            );
          },
        ),
        const AppDivider(),
        AppValueRow(
          key: const Key('profile-emergency-phone-row'),
          label: l10n.mineEditFieldEmergencyContactPhone,
          value: profile.emergencyContactPhone ?? l10n.profileEmptyValue,
          isPlaceholder: profile.emergencyContactPhone == null,
          onPress: () {
            unawaited(
              _editText(
                context: context,
                ref: ref,
                title: l10n.mineEditFieldEmergencyContactPhone,
                hint: l10n.profileEmergencyPhoneHint,
                initialValue: profile.emergencyContactPhone ?? '',
                keyboardType: TextInputType.phone,
                buildInput: (value) =>
                    HealthProfileUpdateInput(emergencyContactPhone: value),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// 下拉型单字段编辑器。
class _EnumSheet<T> extends StatelessWidget {
  const _EnumSheet({
    required this.fieldKey,
    required this.label,
    required this.hint,
    required this.value,
    required this.values,
    required this.labelBuilder,
    required this.onChanged,
  });

  final Key fieldKey;
  final String label;
  final String hint;
  final T? value;
  final List<T> values;
  final String Function(T value) labelBuilder;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return FSelect<T>.rich(
      key: fieldKey,
      label: Text(label),
      hint: hint,
      format: labelBuilder,
      control: FSelectControl.lifted(value: value, onChange: onChanged),
      children: values
          .map((v) => FSelectItem.item(title: Text(labelBuilder(v)), value: v))
          .toList(),
    );
  }
}

/// 数值单字段编辑器。

String _sexLabel(AppLocalizations l10n, HealthSexAtBirth sex) {
  return switch (sex) {
    HealthSexAtBirth.female => l10n.mineEditSexAtBirthFemale,
    HealthSexAtBirth.male => l10n.mineEditSexAtBirthMale,
    HealthSexAtBirth.intersex => l10n.mineEditSexAtBirthIntersex,
    HealthSexAtBirth.unknown => l10n.mineEditSexAtBirthUnknown,
  };
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

/// 分组块:内容区用**纯白**,页面背景是 #FAFAFA 灰白,靠这个色差把分组浮起来。
///
/// 不画外边框;分隔线只出现在组内行与行之间。
class _ValueCard extends StatelessWidget {
  const _ValueCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      decoration: BoxDecoration(
        color: context.theme.colors.card,
        borderRadius: context.theme.style.borderRadius.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
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
