import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/widgets/page_scaffold_shell.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_write_inputs.dart';
import 'package:luminous/features/mine/presentation/providers/health_edit_forms.dart';
import 'package:luminous/features/settings/presentation/widgets/settings_components.dart';
import 'package:luminous/l10n/app_localizations.dart';

class CurrentMedicineEditPage extends ConsumerStatefulWidget {
  const CurrentMedicineEditPage({super.key, this.medicineId});

  final String? medicineId;

  @override
  ConsumerState<CurrentMedicineEditPage> createState() =>
      _CurrentMedicineEditPageState();
}

class _CurrentMedicineEditPageState
    extends ConsumerState<CurrentMedicineEditPage> {
  final _sourceRefIdController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _strengthTextController = TextEditingController();
  final _doseTextController = TextEditingController();
  final _routeController = TextEditingController();
  final _startedAtController = TextEditingController();
  final _noteController = TextEditingController();

  HealthMedicineSource _source = HealthMedicineSource.manual;

  @override
  void dispose() {
    _sourceRefIdController.dispose();
    _displayNameController.dispose();
    _strengthTextController.dispose();
    _doseTextController.dispose();
    _routeController.dispose();
    _startedAtController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isNew = widget.medicineId == null;

    ref.listen<CurrentMedicineFormState>(
      currentMedicineFormProvider,
      (_, next) {
        if (next.saved) {
          AppToast.show(context, l10n.mineEditSavedToast);
          if (context.mounted) context.pop();
        }
      },
    );

    return PageScaffoldShell(
      title:
          isNew
              ? l10n.mineEditMedicineNewTitle
              : l10n.mineEditMedicineTitle,
      centerTitle: true,
      leading: const SettingsBackButton(),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _enumDropdown<HealthMedicineSource>(
                label: l10n.mineEditFieldSource,
                value: _source,
                values: HealthMedicineSource.values,
                onChanged: (v) => setState(() => _source = v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _sourceRefIdController,
                decoration: InputDecoration(
                  labelText: l10n.mineEditFieldSourceRefId,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _displayNameController,
                decoration: InputDecoration(
                  labelText: l10n.mineEditFieldDisplayName,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _strengthTextController,
                decoration: InputDecoration(
                  labelText: l10n.mineEditFieldStrengthText,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _doseTextController,
                decoration: InputDecoration(
                  labelText: l10n.mineEditFieldDoseText,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _routeController,
                decoration: InputDecoration(labelText: l10n.mineEditFieldRoute),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _startedAtController,
                decoration: InputDecoration(
                  labelText: l10n.mineEditFieldStartedAt,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _noteController,
                decoration: InputDecoration(labelText: l10n.mineEditFieldNote),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _onSave,
                child: Text(l10n.mineEditSaveAction),
              ),
              if (!isNew) ...[
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _onDelete,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: Text(l10n.mineEditDeleteAction),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _onSave() {
    if (widget.medicineId != null) {
      ref.read(currentMedicineFormProvider.notifier).save(
        create: CurrentMedicineWriteInput(
          source: HealthMedicineSource.manual,
          displayName: '',
        ),
        id: widget.medicineId,
        update: CurrentMedicineUpdateInput(
          source: _source,
          sourceRefId:
              _sourceRefIdController.text.isEmpty
                  ? null
                  : _sourceRefIdController.text,
          displayName: _displayNameController.text,
          strengthText:
              _strengthTextController.text.isEmpty
                  ? null
                  : _strengthTextController.text,
          doseText:
              _doseTextController.text.isEmpty
                  ? null
                  : _doseTextController.text,
          route:
              _routeController.text.isEmpty ? null : _routeController.text,
          startedAt:
              _startedAtController.text.isEmpty
                  ? null
                  : _startedAtController.text,
          note:
              _noteController.text.isEmpty ? null : _noteController.text,
        ),
      );
    } else {
      ref.read(currentMedicineFormProvider.notifier).save(
        create: CurrentMedicineWriteInput(
          source: _source,
          sourceRefId:
              _sourceRefIdController.text.isEmpty
                  ? null
                  : _sourceRefIdController.text,
          displayName: _displayNameController.text,
          strengthText:
              _strengthTextController.text.isEmpty
                  ? null
                  : _strengthTextController.text,
          doseText:
              _doseTextController.text.isEmpty
                  ? null
                  : _doseTextController.text,
          route:
              _routeController.text.isEmpty ? null : _routeController.text,
          startedAt:
              _startedAtController.text.isEmpty
                  ? null
                  : _startedAtController.text,
          note:
              _noteController.text.isEmpty ? null : _noteController.text,
        ),
      );
    }
  }

  void _onDelete() {
    if (widget.medicineId != null) {
      ref.read(currentMedicineFormProvider.notifier).delete(
        widget.medicineId!,
      );
    }
  }
}

Widget _enumDropdown<T extends HealthContextWireEnum>({
  required String label,
  required T value,
  required List<T> values,
  required ValueChanged<T> onChanged,
}) {
  return DropdownButtonFormField<T>(
    initialValue: value,
    decoration: InputDecoration(labelText: label),
    items:
        values
            .map((v) => DropdownMenuItem(value: v, child: Text(v.value)))
            .toList(),
    onChanged: (v) {
      if (v != null) onChanged(v);
    },
  );
}
