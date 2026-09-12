import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';
import 'package:luminous/core/widgets/common/avatar/avatar_view.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
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

/// 个人信息页面 - 集成头像、昵称、健康档案编辑
class ProfilePage extends HookConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(authSessionProvider);
    final user = session.user;

    // 用户资料控制器
    final nicknameController = useTextEditingController(
      text: user?.nickname ?? '',
    );
    final avatarController = useTextEditingController(text: user?.avatar ?? '');
    final formUserId = useRef<String?>(null);

    // 健康档案控制器
    final heightCmController = useTextEditingController();
    final weightKgController = useTextEditingController();
    final birthDate = useState<DateTime?>(null);
    final bloodType = useState<String?>(null);
    final unitSystem = useState<HealthUnitSystem?>(null);
    final sexAtBirth = useState<HealthSexAtBirth?>(null);
    final emergencyContactNameController = useTextEditingController();
    final emergencyContactPhoneController = useTextEditingController();
    final initialized = useRef(false);

    // 同步控制器当用户变化时
    useEffect(() {
      if (user == null || formUserId.value == user.id) return null;
      formUserId.value = user.id;
      nicknameController.text = user.nickname ?? '';
      avatarController.text = user.avatar ?? '';
      return null;
    }, [user?.id]);

    // 从快照初始化健康档案数据
    void initFromSnapshot(HealthProfile profile) {
      if (initialized.value) return;
      initialized.value = true;

      heightCmController.text = profile.heightCm?.toString() ?? '';
      weightKgController.text = profile.weightKg?.toString() ?? '';
      birthDate.value = _tryParseDate(profile.birthDate);
      bloodType.value = profile.bloodType;
      unitSystem.value = HealthUnitSystem.fromValue(profile.unitSystem);
      sexAtBirth.value = HealthSexAtBirth.fromValue(profile.sexAtBirth);
      emergencyContactNameController.text = profile.emergencyContactName ?? '';
      emergencyContactPhoneController.text =
          profile.emergencyContactPhone ?? '';
    }

    // 保存用户资料
    Future<void> saveUserProfile() async {
      final accountNotifier = ref.read(authAccountProvider.notifier);
      final ok = await accountNotifier.updateProfile(
        nickname: nicknameController.text,
        avatar: avatarController.text,
      );
      if (ok && context.mounted) {
        await Toast.show(context, l10n.authProfileSaveSuccess);
      }
    }

    // 保存健康档案
    void saveHealthProfile() {
      final input = HealthProfileUpdateInput(
        birthDate: birthDate.value != null
            ? _formatDate(birthDate.value!)
            : null,
        heightCm: num.tryParse(heightCmController.text),
        weightKg: num.tryParse(weightKgController.text),
        bloodType: bloodType.value,
        unitSystem: unitSystem.value,
        sexAtBirth: sexAtBirth.value,
        emergencyContactName: emergencyContactNameController.text.trim(),
        emergencyContactPhone: emergencyContactPhoneController.text.trim(),
      );

      unawaited(ref.read(healthProfileFormProvider.notifier).save(input));
    }

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
      final formState = ref.watch(healthProfileFormProvider);

      ref.listen<HealthProfileFormState>(healthProfileFormProvider, (
        prev,
        next,
      ) {
        if (next.saved && prev?.saved != true) {
          unawaited(Toast.show(context, l10n.mineEditSavedToast));
          if (context.mounted) Navigator.of(context).pop();
        }
        final error = next.errorMessage;
        if (error != null && error != prev?.errorMessage) {
          unawaited(Toast.show(context, error));
        }
      });

      final snapshot = ref.watch(healthContextSnapshotProvider);

      final width = MediaQuery.sizeOf(context).width;
      content = ResponsiveContentFrame(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: width < Breakpoints.mobile ? Spacing.xl2 : Spacing.xl3,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 用户资料部分
              _UserProfileSection(
                nicknameController: nicknameController,
                avatarController: avatarController,
                user: user,
                l10n: l10n,
                onSave: saveUserProfile,
              ),
              const SizedBox(height: Spacing.xl2),

              // 健康档案部分
              snapshot.when(
                data: (ctx) {
                  initFromSnapshot(ctx.profile);
                  return _HealthProfileSection(
                    heightCmController: heightCmController,
                    weightKgController: weightKgController,
                    birthDate: birthDate,
                    bloodType: bloodType,
                    unitSystem: unitSystem,
                    sexAtBirth: sexAtBirth,
                    emergencyContactNameController:
                        emergencyContactNameController,
                    emergencyContactPhoneController:
                        emergencyContactPhoneController,
                    l10n: l10n,
                    isSaving: formState.isSaving,
                    onSave: saveHealthProfile,
                  );
                },
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

/// 用户资料部分
class _UserProfileSection extends StatelessWidget {
  const _UserProfileSection({
    required this.nicknameController,
    required this.avatarController,
    required this.user,
    required this.l10n,
    required this.onSave,
  });

  final TextEditingController nicknameController;
  final TextEditingController avatarController;
  final AuthUser? user;
  final AppLocalizations l10n;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.profileUserSectionTitle,
          style: typography.body.md.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: Spacing.lg),
        // 头像编辑
        _AvatarEditSection(
          avatarUrl: user?.avatar,
          avatarController: avatarController,
          l10n: l10n,
        ),
        const SizedBox(height: Spacing.lg),
        // 昵称编辑
        FTextField(
          key: const Key('profile-nickname-field'),
          control: FTextFieldControl.managed(controller: nicknameController),
          label: Text(l10n.profileNicknameLabel),
        ),
        const SizedBox(height: Spacing.lg),
        FButton(
          key: const Key('profile-user-save-button'),
          onPress: onSave,
          child: Text(l10n.profileUserSaveAction),
        ),
      ],
    );
  }
}

/// 头像编辑部分
class _AvatarEditSection extends StatelessWidget {
  const _AvatarEditSection({
    required this.avatarUrl,
    required this.avatarController,
    required this.l10n,
  });

  final String? avatarUrl;
  final TextEditingController avatarController;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 头像预览
        AvatarView(
          avatarUrl: avatarUrl,
          size: 64,
          iconSize: 32,
          semanticLabel: l10n.profileAvatarLabel,
        ),
        const SizedBox(width: Spacing.lg),
        // 头像URL输入框
        Expanded(
          child: FTextField(
            key: const Key('profile-avatar-field'),
            control: FTextFieldControl.managed(controller: avatarController),
            label: Text(l10n.profileAvatarLabel),
          ),
        ),
      ],
    );
  }
}

/// 健康档案部分
class _HealthProfileSection extends StatelessWidget {
  const _HealthProfileSection({
    required this.heightCmController,
    required this.weightKgController,
    required this.birthDate,
    required this.bloodType,
    required this.unitSystem,
    required this.sexAtBirth,
    required this.emergencyContactNameController,
    required this.emergencyContactPhoneController,
    required this.l10n,
    required this.isSaving,
    required this.onSave,
  });

  final TextEditingController heightCmController;
  final TextEditingController weightKgController;
  final ValueNotifier<DateTime?> birthDate;
  final ValueNotifier<String?> bloodType;
  final ValueNotifier<HealthUnitSystem?> unitSystem;
  final ValueNotifier<HealthSexAtBirth?> sexAtBirth;
  final TextEditingController emergencyContactNameController;
  final TextEditingController emergencyContactPhoneController;
  final AppLocalizations l10n;
  final bool isSaving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.profileHealthSectionTitle,
          style: typography.body.md.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: Spacing.lg),
        FDateField.calendar(
          key: const Key('profile-birthdate-field'),
          label: Text(l10n.mineEditFieldBirthDate),
          selectionControl: FDateSelectionControl.managedSingle(
            initial: birthDate.value,
            toggleable: true,
            onChange: (value) => birthDate.value = value,
          ),
        ),
        const SizedBox(height: Spacing.md),
        _enumDropdown<HealthSexAtBirth>(
          label: l10n.mineEditFieldSexAtBirth,
          value: sexAtBirth.value,
          values: HealthSexAtBirth.values,
          onChanged: (v) => sexAtBirth.value = v,
          labelBuilder: (v) => switch (v) {
            HealthSexAtBirth.female => l10n.mineEditSexAtBirthFemale,
            HealthSexAtBirth.male => l10n.mineEditSexAtBirthMale,
            HealthSexAtBirth.intersex => l10n.mineEditSexAtBirthIntersex,
            HealthSexAtBirth.unknown => l10n.mineEditSexAtBirthUnknown,
          },
        ),
        const SizedBox(height: Spacing.md),
        FTextField(
          key: const Key('profile-height-field'),
          control: FTextFieldControl.managed(controller: heightCmController),
          label: Text(l10n.mineEditFieldHeightCm),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: Spacing.md),
        FTextField(
          key: const Key('profile-weight-field'),
          control: FTextFieldControl.managed(controller: weightKgController),
          label: Text(l10n.mineEditFieldWeightKg),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: Spacing.md),
        FSelect<String>.rich(
          label: Text(l10n.mineEditFieldBloodType),
          hint: l10n.mineEditFieldBloodTypeHint,
          format: (value) => value,
          control: FSelectControl.lifted(
            value: bloodType.value,
            onChange: (v) => bloodType.value = v,
          ),
          children: _bloodTypeOptions
              .map((v) => FSelectItem.item(title: Text(v), value: v))
              .toList(),
        ),
        const SizedBox(height: Spacing.md),
        _enumDropdown<HealthUnitSystem>(
          label: l10n.mineEditFieldUnitSystem,
          value: unitSystem.value,
          values: HealthUnitSystem.values,
          onChanged: (v) => unitSystem.value = v,
          labelBuilder: (v) => v == HealthUnitSystem.metric
              ? l10n.mineEditUnitSystemMetric
              : l10n.mineEditUnitSystemImperial,
        ),
        const SizedBox(height: Spacing.xl),
        Text(
          l10n.mineEditFieldEmergencyContactName,
          style: typography.body.sm.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: Spacing.sm),
        FTextField(
          key: const Key('profile-emergency-contact-name'),
          control: FTextFieldControl.managed(
            controller: emergencyContactNameController,
          ),
        ),
        const SizedBox(height: Spacing.md),
        Text(
          l10n.mineEditFieldEmergencyContactPhone,
          style: typography.body.sm.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: Spacing.sm),
        FTextField(
          key: const Key('profile-emergency-contact-phone'),
          control: FTextFieldControl.managed(
            controller: emergencyContactPhoneController,
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: Spacing.xl),
        FButton(
          key: const Key('profile-health-save-button'),
          onPress: isSaving ? null : onSave,
          prefix: isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: FCircularProgress(),
                )
              : null,
          child: Text(l10n.mineEditSaveAction),
        ),
      ],
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

Widget _enumDropdown<T extends HealthContextWireEnum>({
  required String label,
  required T? value,
  required List<T> values,
  required ValueChanged<T?> onChanged,
  String Function(T)? labelBuilder,
}) {
  final formatLabel = labelBuilder ?? (T v) => v.value;
  return FSelect<T>.rich(
    label: Text(label),
    hint: label,
    format: formatLabel,
    control: FSelectControl.lifted(value: value, onChange: onChanged),
    children: values
        .map((v) => FSelectItem.item(title: Text(formatLabel(v)), value: v))
        .toList(),
  );
}
