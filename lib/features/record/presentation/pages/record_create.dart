import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/widgets/page_scaffold_shell.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/record/data/providers/daily_record_providers.dart';
import 'package:luminous/features/record/domain/entities/daily_record.dart';
import 'package:luminous/features/record/domain/entities/daily_record_inputs.dart';
import 'package:luminous/features/record/presentation/providers/record_dashboard_provider.dart';
import 'package:luminous/features/settings/presentation/widgets/settings_components.dart';
import 'package:luminous/features/today/presentation/providers/today_dashboard_provider.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordCreatePage extends ConsumerStatefulWidget {
  const RecordCreatePage({super.key});

  @override
  ConsumerState<RecordCreatePage> createState() => _RecordCreatePageState();
}

class _RecordCreatePageState extends ConsumerState<RecordCreatePage> {
  DailyRecordKind _kind = DailyRecordKind.water;
  final _valueController = TextEditingController();
  final _unitController = TextEditingController();
  final _noteController = TextEditingController();
  final _titleController = TextEditingController();

  bool _saving = false;

  @override
  void dispose() {
    _valueController.dispose();
    _unitController.dispose();
    _noteController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(authSessionProvider);

    // Signed-out users see login prompt
    if (!session.isAuthenticated) {
      return PageScaffoldShell(
        title: l10n.recordAddAction,
        centerTitle: true,
        leading: const SettingsBackButton(),
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.authNotSignedIn),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.push('/login'),
                    child: Text(l10n.authGoLogin),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    final today = DateTime.now();
    final dateStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    return PageScaffoldShell(
      title: l10n.recordAddAction,
      centerTitle: true,
      leading: const SettingsBackButton(),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<DailyRecordKind>(
                initialValue: _kind,
                decoration: InputDecoration(
                  labelText: l10n.recordCreateFieldKind,
                ),
                items: DailyRecordKind.values
                    .map(
                      (k) => DropdownMenuItem(
                        value: k,
                        child: Text(_kindLabel(l10n, k)),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _kind = v);
                },
              ),
              const SizedBox(height: 12),
              if (_kind != DailyRecordKind.mood) ...[
                TextField(
                  controller: _valueController,
                  decoration: InputDecoration(
                    labelText: _valueLabel(l10n, _kind),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (_kind == DailyRecordKind.vital ||
                  _kind == DailyRecordKind.water) ...[
                TextField(
                  controller: _unitController,
                  decoration: InputDecoration(
                    labelText: l10n.recordCreateFieldUnit,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (_kind != DailyRecordKind.water) ...[
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: l10n.recordCreateFieldTitleOptional,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: l10n.recordCreateFieldNote,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saving ? null : () => _onSave(dateStr),
                child: Text(_saving ? '...' : l10n.mineEditSaveAction),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _kindLabel(AppLocalizations l10n, DailyRecordKind kind) {
    return switch (kind) {
      DailyRecordKind.water => l10n.recordTypeWater,
      DailyRecordKind.meal => l10n.recordTypeMeal,
      DailyRecordKind.vital => l10n.recordTypeVitals,
      DailyRecordKind.mood => l10n.recordTypeMood,
      DailyRecordKind.symptom => l10n.recordTypeSymptom,
      DailyRecordKind.activity => l10n.recordTypeActivity,
      DailyRecordKind.note => l10n.recordCreateKindNote,
    };
  }

  String _valueLabel(AppLocalizations l10n, DailyRecordKind kind) {
    return switch (kind) {
      DailyRecordKind.water => l10n.recordCreateValueWater,
      DailyRecordKind.meal => l10n.recordCreateValueMeal,
      DailyRecordKind.vital => l10n.recordCreateValueVital,
      DailyRecordKind.mood => l10n.recordTypeMood,
      DailyRecordKind.symptom => l10n.recordTypeSymptom,
      DailyRecordKind.activity => l10n.recordTypeActivity,
      DailyRecordKind.note => l10n.recordCreateFieldNote,
    };
  }

  Future<void> _onSave(String dateStr) async {
    setState(() => _saving = true);
    try {
      final repo = ref.read(dailyRecordRepositoryProvider);
      await repo.create(
        DailyRecordCreateInput(
          kind: _kind,
          occurredAt: dateStr,
          title: _titleController.text.isEmpty ? null : _titleController.text,
          value: _valueController.text.isEmpty ? null : _valueController.text,
          unit: _unitController.text.isEmpty ? null : _unitController.text,
          note: _noteController.text.isEmpty ? null : _noteController.text,
        ),
      );
      ref.invalidate(recordDashboardProvider);
      ref.invalidate(todayDashboardProvider);
      if (mounted) {
        AppToast.show(
          context,
          AppLocalizations.of(context)!.mineEditSavedToast,
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(
          context,
          AppLocalizations.of(context)!.recordCreateFailedToast,
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
