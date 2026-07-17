import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/auth/presentation/providers/session.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/health_context/domain/entities/write_inputs.dart';
import 'package:luminous/features/mine/presentation/providers/health_edit_forms.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/core/widgets/common/shared_widgets.dart';

class ProfileEditPage extends HookConsumerWidget {
  const ProfileEditPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(authSessionProvider);

    final birthDateController = useTextEditingController();
    final heightCmController = useTextEditingController();
    final bloodTypeController = useTextEditingController();
    final unitSystem = useState<HealthUnitSystem?>(null);
    final onboardingCompleted = useState<bool?>(null);
    final initialized = useRef(false);

    void initFromSnapshot(HealthProfile profile) {
      if (initialized.value) return;
      initialized.value = true;

      birthDateController.text = profile.birthDate ?? '';
      heightCmController.text = profile.heightCm?.toString() ?? '';
      bloodTypeController.text = profile.bloodType ?? '';
      unitSystem.value = HealthUnitSystem.fromValue(profile.unitSystem);
      onboardingCompleted.value = profile.onboardingCompletedAt != null;
    }

    void onSave() {
      final input = HealthProfileUpdateInput(
        birthDate: birthDateController.text.isEmpty
            ? null
            : birthDateController.text,
        heightCm: int.tryParse(heightCmController.text),
        bloodType: bloodTypeController.text.isEmpty
            ? null
            : bloodTypeController.text,
        unitSystem: unitSystem.value,
        onboardingCompleted: onboardingCompleted.value,
      );

      ref.read(healthProfileFormProvider.notifier).save(input);
    }

    final Widget content;

    if (!session.canAccessProtectedData) {
      final width = MediaQuery.sizeOf(context).width;
      content = ResponsiveContentFrame(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: width < Breakpoints.mobile ? 24 : 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              session.isLoading
                  ? const MineEditFormLoading()
                  : AuthRequiredDialogGate(
                      onLogin: () =>
                          context.push(loginRouteForCurrentLocation(context)),
                    ),
            ],
          ),
        ),
      );
    } else {
      ref.listen<HealthProfileFormState>(healthProfileFormProvider, (_, next) {
        if (next.saved) {
          AppToast.show(context, l10n.mineEditSavedToast);
          if (context.mounted) context.pop();
        }
      });

      final snapshot = ref.watch(healthContextSnapshotProvider);

      final width = MediaQuery.sizeOf(context).width;
      content = ResponsiveContentFrame(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: width < Breakpoints.mobile ? 24 : 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              snapshot.when(
                data: (ctx) {
                  initFromSnapshot(ctx.profile);
                  return Padding(
                    padding: const EdgeInsets.all(Spacing.level4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FTextField(
                          control: FTextFieldControl.managed(
                            controller: birthDateController,
                          ),
                          label: Text(l10n.mineEditFieldBirthDate),
                        ),
                        const SizedBox(height: Spacing.level3),
                        FTextField(
                          control: FTextFieldControl.managed(
                            controller: heightCmController,
                          ),
                          label: Text(l10n.mineEditFieldHeightCm),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: Spacing.level3),
                        FTextField(
                          control: FTextFieldControl.managed(
                            controller: bloodTypeController,
                          ),
                          label: Text(l10n.mineEditFieldBloodType),
                        ),
                        const SizedBox(height: Spacing.level3),
                        _enumDropdown<HealthUnitSystem>(
                          label: l10n.mineEditFieldUnitSystem,
                          value: unitSystem.value,
                          values: HealthUnitSystem.values,
                          onChanged: (v) => unitSystem.value = v,
                        ),
                        const SizedBox(height: Spacing.level3),
                        FSwitch(
                          label: Text(l10n.mineEditFieldOnboardingCompleted),
                          value: onboardingCompleted.value ?? false,
                          onChange: (v) => onboardingCompleted.value = v,
                        ),
                        const SizedBox(height: Spacing.level5),
                        FButton(
                          onPress: onSave,
                          child: Text(l10n.mineEditSaveAction),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const MineEditFormLoading(),
                error: (_, __) => AppStateErrorView(
                  title: l10n.mineErrorTitle,
                  description: l10n.mineErrorDescription,
                  icon: FLucideIcons.badge,
                  actionLabel: l10n.todayRetryAction,
                  onAction: () => ref
                      .read(dataChangeBusProvider.notifier)
                      .emit(DataChangeTopic.healthContext),
                  tone: AppStateTone.warning,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return PageScaffold(
      title: l10n.mineEditProfileTitle,
      child: SingleChildScrollView(child: content),
    );
  }
}

Widget _enumDropdown<T extends HealthContextWireEnum>({
  required String label,
  required T? value,
  required List<T> values,
  required ValueChanged<T?> onChanged,
}) {
  return FSelect<T>.rich(
    label: Text(label),
    hint: label,
    format: (value) => value.value,
    control: FSelectControl.lifted(value: value, onChange: onChanged),
    children: values
        .map((v) => FSelectItem.item(title: Text(v.value), value: v))
        .toList(),
  );
}
