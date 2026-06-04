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
                decoration: const InputDecoration(labelText: 'Kind'),
                items: DailyRecordKind.values
                    .map((k) => DropdownMenuItem(value: k, child: Text(k.name)))
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
                    labelText: _valueLabel(_kind),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (_kind == DailyRecordKind.vital || _kind == DailyRecordKind.water) ...[
                TextField(
                  controller: _unitController,
                  decoration: const InputDecoration(labelText: 'Unit'),
                ),
                const SizedBox(height: 12),
              ],
              if (_kind != DailyRecordKind.water) ...[
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title (optional)'),
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: 'Note'),
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

  String _valueLabel(DailyRecordKind kind) {
    return switch (kind) {
      DailyRecordKind.water => 'Cups',
      DailyRecordKind.meal => 'Name / description',
      DailyRecordKind.vital => 'Value (e.g. 120/80)',
      DailyRecordKind.mood => 'Mood',
      DailyRecordKind.symptom => 'Symptom',
      DailyRecordKind.activity => 'Activity',
      DailyRecordKind.note => 'Note',
    };
  }

  Future<void> _onSave(String dateStr) async {
    setState(() => _saving = true);
    try {
      final repo = ref.read(dailyRecordRepositoryProvider);
      await repo.create(DailyRecordCreateInput(
        kind: _kind,
        occurredAt: dateStr,
        title: _titleController.text.isEmpty ? null : _titleController.text,
        value: _valueController.text.isEmpty ? null : _valueController.text,
        unit: _unitController.text.isEmpty ? null : _unitController.text,
        note: _noteController.text.isEmpty ? null : _noteController.text,
      ));
      ref.invalidate(recordDashboardProvider);
      if (mounted) {
        AppToast.show(context, AppLocalizations.of(context)!.mineEditSavedToast);
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(context, 'Error: $e');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
