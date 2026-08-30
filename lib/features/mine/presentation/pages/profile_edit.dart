import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/health_context/domain/entities/write_inputs.dart';
import 'package:luminous/features/mine/presentation/providers/health_edit_forms.dart';
import 'package:luminous/features/mine/presentation/widgets/shared/mine_edit_form_loading.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Common blood type options offered in the profile editor.
///
/// The backend stores [bloodType] as a free-text string, but constraining the
/// UI to a standard list avoids typos and makes the field easier to scan.
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

class ProfileEditPage extends HookConsumerWidget {
  const ProfileEditPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(authSessionProvider);

    final heightCmController = useTextEditingController();
    final weightKgController = useTextEditingController();
    final birthDate = useState<DateTime?>(null);
    final bloodType = useState<String?>(null);
    final unitSystem = useState<HealthUnitSystem?>(null);
    final sexAtBirth = useState<HealthSexAtBirth?>(null);
    final emergencyContactNameController = useTextEditingController();
    final emergencyContactPhoneController = useTextEditingController();
    final initialized = useRef(false);
    final typography = context.theme.typography;

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

    void onSave() {
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
            vertical: width < Breakpoints.mobile
                ? Spacing.level6
                : Spacing.level7,
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
      final formState = ref.watch(healthProfileFormProvider);

      ref.listen<HealthProfileFormState>(healthProfileFormProvider, (
        prev,
        next,
      ) {
        if (next.saved && prev?.saved != true) {
          unawaited(Toast.show(context, l10n.mineEditSavedToast));
          if (context.mounted) context.pop();
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
            vertical: width < Breakpoints.mobile
                ? Spacing.level6
                : Spacing.level7,
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
                        FDateField.calendar(
                          key: const Key('profile-birthdate-field'),
                          label: Text(l10n.mineEditFieldBirthDate),
                          selectionControl: FDateSelectionControl.managedSingle(
                            initial: birthDate.value,
                            toggleable: true,
                            onChange: (value) => birthDate.value = value,
                          ),
                        ),
                        const SizedBox(height: Spacing.level3),
                        _enumDropdown<HealthSexAtBirth>(
                          label: l10n.mineEditFieldSexAtBirth,
                          value: sexAtBirth.value,
                          values: HealthSexAtBirth.values,
                          onChanged: (v) => sexAtBirth.value = v,
                          labelBuilder: (v) => switch (v) {
                            HealthSexAtBirth.female =>
                              l10n.mineEditSexAtBirthFemale,
                            HealthSexAtBirth.male =>
                              l10n.mineEditSexAtBirthMale,
                            HealthSexAtBirth.intersex =>
                              l10n.mineEditSexAtBirthIntersex,
                            HealthSexAtBirth.unknown =>
                              l10n.mineEditSexAtBirthUnknown,
                          },
                        ),
                        const SizedBox(height: Spacing.level3),
                        FTextField(
                          key: const Key('profile-height-field'),
                          control: FTextFieldControl.managed(
                            controller: heightCmController,
                          ),
                          label: Text(l10n.mineEditFieldHeightCm),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: Spacing.level3),
                        FTextField(
                          key: const Key('profile-weight-field'),
                          control: FTextFieldControl.managed(
                            controller: weightKgController,
                          ),
                          label: Text(l10n.mineEditFieldWeightKg),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: Spacing.level3),
                        FSelect<String>.rich(
                          label: Text(l10n.mineEditFieldBloodType),
                          hint: l10n.mineEditFieldBloodTypeHint,
                          format: (value) => value,
                          control: FSelectControl.lifted(
                            value: bloodType.value,
                            onChange: (v) => bloodType.value = v,
                          ),
                          children: _bloodTypeOptions
                              .map(
                                (v) =>
                                    FSelectItem.item(title: Text(v), value: v),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: Spacing.level3),
                        _enumDropdown<HealthUnitSystem>(
                          label: l10n.mineEditFieldUnitSystem,
                          value: unitSystem.value,
                          values: HealthUnitSystem.values,
                          onChanged: (v) => unitSystem.value = v,
                          labelBuilder: (v) => v == HealthUnitSystem.metric
                              ? l10n.mineEditUnitSystemMetric
                              : l10n.mineEditUnitSystemImperial,
                        ),
                        const SizedBox(height: Spacing.level5),
                        Text(
                          l10n.mineEditFieldEmergencyContactName,
                          style: typography.body.sm.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: Spacing.level2),
                        FTextField(
                          key: const Key('profile-emergency-contact-name'),
                          control: FTextFieldControl.managed(
                            controller: emergencyContactNameController,
                          ),
                        ),
                        const SizedBox(height: Spacing.level3),
                        Text(
                          l10n.mineEditFieldEmergencyContactPhone,
                          style: typography.body.sm.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: Spacing.level2),
                        FTextField(
                          key: const Key('profile-emergency-contact-phone'),
                          control: FTextFieldControl.managed(
                            controller: emergencyContactPhoneController,
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: Spacing.level5),
                        FButton(
                          key: const Key('profile-save-button'),
                          onPress: formState.isSaving ? null : onSave,
                          prefix: formState.isSaving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: FCircularProgress(),
                                )
                              : null,
                          child: Text(l10n.mineEditSaveAction),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const MineEditFormLoading(),
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
      title: l10n.mineEditProfileTitle,
      child: SingleChildScrollView(child: content),
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
