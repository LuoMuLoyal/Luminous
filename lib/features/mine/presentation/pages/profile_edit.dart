import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/widgets/common/app_state_views.dart';
import 'package:luminous/core/widgets/layout/page_scaffold_shell.dart';
import 'package:luminous/features/auth/presentation/providers/session/auth_session_provider.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_required_dialog.dart';
import 'package:luminous/features/health_context/data/providers/health_context_data_providers.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_snapshot.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_write_inputs.dart';
import 'package:luminous/features/mine/presentation/providers/health_edit_forms.dart';
import 'package:luminous/core/widgets/common/app_back_button.dart';
import 'package:luminous/l10n/app_localizations.dart';

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

    if (!session.canAccessProtectedData) {
      return PageScaffoldShell(
        title: l10n.mineEditProfileTitle,
        centerTitle: true,
        leading: const AppBackButton(),
        children: [
          session.isLoading
              ? const _MineEditFormLoading()
              : AuthRequiredDialogGate(
                  onLogin: () =>
                      context.push(loginRouteForCurrentLocation(context)),
                ),
        ],
      );
    }

    ref.listen<HealthProfileFormState>(healthProfileFormProvider, (_, next) {
      if (next.saved) {
        AppToast.show(context, l10n.mineEditSavedToast);
        if (context.mounted) context.pop();
      }
    });

    final snapshot = ref.watch(healthContextSnapshotProvider);

    return PageScaffoldShell(
      title: l10n.mineEditProfileTitle,
      centerTitle: true,
      leading: const AppBackButton(),
      children: [
        snapshot.when(
          data: (ctx) {
            initFromSnapshot(ctx.profile);
            return Padding(
              padding: const EdgeInsets.all(AppSpacingTokens.level4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: birthDateController,
                    decoration: InputDecoration(
                      labelText: l10n.mineEditFieldBirthDate,
                    ),
                  ),
                  const SizedBox(height: AppSpacingTokens.level3),
                  TextField(
                    controller: heightCmController,
                    decoration: InputDecoration(
                      labelText: l10n.mineEditFieldHeightCm,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: AppSpacingTokens.level3),
                  TextField(
                    controller: bloodTypeController,
                    decoration: InputDecoration(
                      labelText: l10n.mineEditFieldBloodType,
                    ),
                  ),
                  const SizedBox(height: AppSpacingTokens.level3),
                  _enumDropdown<HealthUnitSystem>(
                    label: l10n.mineEditFieldUnitSystem,
                    value: unitSystem.value,
                    values: HealthUnitSystem.values,
                    onChanged: (v) => unitSystem.value = v,
                  ),
                  const SizedBox(height: AppSpacingTokens.level3),
                  SwitchListTile(
                    title: Text(l10n.mineEditFieldOnboardingCompleted),
                    value: onboardingCompleted.value ?? false,
                    onChanged: (v) => onboardingCompleted.value = v,
                  ),
                  const SizedBox(height: AppSpacingTokens.level5),
                  ElevatedButton(
                    onPressed: onSave,
                    child: Text(l10n.mineEditSaveAction),
                  ),
                ],
              ),
            );
          },
          loading: () => const _MineEditFormLoading(),
          error: (_, __) => AppStateErrorView(
            title: l10n.mineErrorTitle,
            description: l10n.mineErrorDescription,
            icon: Icons.badge_outlined,
            actionLabel: l10n.todayRetryAction,
            onAction: () => ref.invalidate(healthContextSnapshotProvider),
            tone: AppStateTone.warning,
          ),
        ),
      ],
    );
  }
}

class _MineEditFormLoading extends StatelessWidget {
  const _MineEditFormLoading();

  @override
  Widget build(BuildContext context) {
    return const AppInlineSkeletonSection(
      children: [
        AppInlineSkeletonBlock(height: 56),
        AppInlineSkeletonBlock(height: 56),
        AppInlineSkeletonBlock(height: 56),
        AppInlineSkeletonBlock(height: 56),
        AppInlineSkeletonBlock(height: 96),
        AppInlineSkeletonBlock(height: 56),
      ],
    );
  }
}

Widget _enumDropdown<T extends HealthContextWireEnum>({
  required String label,
  required T? value,
  required List<T> values,
  required ValueChanged<T?> onChanged,
}) {
  return DropdownButtonFormField<T>(
    initialValue: value,
    decoration: InputDecoration(labelText: label),
    items: values
        .map((v) => DropdownMenuItem(value: v, child: Text(v.value)))
        .toList(),
    onChanged: onChanged,
  );
}
