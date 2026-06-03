import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/widgets/page_scaffold_shell.dart';
import 'package:luminous/features/health_context/data/providers/health_context_data_providers.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_snapshot.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_write_inputs.dart';
import 'package:luminous/features/mine/presentation/providers/health_edit_forms.dart';
import 'package:luminous/features/settings/presentation/widgets/settings_components.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ProfileEditPage extends ConsumerStatefulWidget {
  const ProfileEditPage({super.key});

  @override
  ConsumerState<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<ProfileEditPage> {
  final _birthDateController = TextEditingController();
  final _heightCmController = TextEditingController();
  final _bloodTypeController = TextEditingController();

  HealthSexAtBirth? _sexAtBirth;
  HealthPregnancyState? _pregnancyState;
  HealthLactationState? _lactationState;
  HealthUnitSystem? _unitSystem;
  bool? _onboardingCompleted;

  bool _initialized = false;

  @override
  void dispose() {
    _birthDateController.dispose();
    _heightCmController.dispose();
    _bloodTypeController.dispose();
    super.dispose();
  }

  void _initFromSnapshot(HealthProfile profile) {
    if (_initialized) return;
    _initialized = true;

    _birthDateController.text = profile.birthDate ?? '';
    _heightCmController.text = profile.heightCm?.toString() ?? '';
    _bloodTypeController.text = profile.bloodType ?? '';
    _sexAtBirth = HealthSexAtBirth.fromValue(profile.sexAtBirth);
    _pregnancyState = HealthPregnancyState.fromValue(profile.pregnancyState);
    _lactationState = HealthLactationState.fromValue(profile.lactationState);
    _unitSystem = HealthUnitSystem.fromValue(profile.unitSystem);
    _onboardingCompleted = profile.onboardingCompletedAt != null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final snapshot = ref.watch(healthContextSnapshotProvider);

    ref.listen<HealthProfileFormState>(healthProfileFormProvider, (_, next) {
      if (next.saved) {
        AppToast.show(context, l10n.mineEditSavedToast);
        if (context.mounted) context.pop();
      }
    });

    return PageScaffoldShell(
      title: l10n.mineEditProfileTitle,
      centerTitle: true,
      leading: const SettingsBackButton(),
      children: [
        snapshot.when(
          data: (ctx) {
            _initFromSnapshot(ctx.profile);
            return _buildForm(context, l10n);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Center(
            child: Text(l10n.mineErrorDescription),
          ),
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _birthDateController,
            decoration: InputDecoration(labelText: l10n.mineEditFieldBirthDate),
          ),
          const SizedBox(height: 12),
          _enumDropdown<HealthSexAtBirth>(
            label: l10n.mineEditFieldSexAtBirth,
            value: _sexAtBirth,
            values: HealthSexAtBirth.values,
            onChanged: (v) => setState(() => _sexAtBirth = v),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _heightCmController,
            decoration: InputDecoration(labelText: l10n.mineEditFieldHeightCm),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          _enumDropdown<HealthPregnancyState>(
            label: l10n.mineEditFieldPregnancyState,
            value: _pregnancyState,
            values: HealthPregnancyState.values,
            onChanged: (v) => setState(() => _pregnancyState = v),
          ),
          const SizedBox(height: 12),
          _enumDropdown<HealthLactationState>(
            label: l10n.mineEditFieldLactationState,
            value: _lactationState,
            values: HealthLactationState.values,
            onChanged: (v) => setState(() => _lactationState = v),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bloodTypeController,
            decoration: InputDecoration(labelText: l10n.mineEditFieldBloodType),
          ),
          const SizedBox(height: 12),
          _enumDropdown<HealthUnitSystem>(
            label: l10n.mineEditFieldUnitSystem,
            value: _unitSystem,
            values: HealthUnitSystem.values,
            onChanged: (v) => setState(() => _unitSystem = v),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: Text(l10n.mineEditFieldOnboardingCompleted),
            value: _onboardingCompleted ?? false,
            onChanged: (v) => setState(() => _onboardingCompleted = v),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _onSave,
            child: Text(l10n.mineEditSaveAction),
          ),
        ],
      ),
    );
  }

  void _onSave() {
    final input = HealthProfileUpdateInput(
      birthDate:
          _birthDateController.text.isEmpty
              ? null
              : _birthDateController.text,
      sexAtBirth: _sexAtBirth,
      heightCm: int.tryParse(_heightCmController.text),
      pregnancyState: _pregnancyState,
      lactationState: _lactationState,
      bloodType:
          _bloodTypeController.text.isEmpty
              ? null
              : _bloodTypeController.text,
      unitSystem: _unitSystem,
      onboardingCompleted: _onboardingCompleted,
    );

    ref.read(healthProfileFormProvider.notifier).save(input);
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
    items:
        values.map(
          (v) => DropdownMenuItem(value: v, child: Text(v.value)),
        ).toList(),
    onChanged: onChanged,
  );
}
