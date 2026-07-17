import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/core/providers/auth_guarded.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/medicine/data/datasources/dose_log_cached.dart';
import 'package:luminous/features/medicine/data/datasources/reminder_local_preferences.dart';
import 'package:luminous/features/medicine/data/datasources/reminder_remote.dart';
import 'package:luminous/features/medicine/domain/entities/reminder_sound_preference.dart';
import 'package:luminous/features/medicine/presentation/utils/reminder_formatters.dart';
import 'package:luminous/features/medicine/data/providers/workspace.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:luminous/features/medicine/domain/entities/reminder_sound_preference.dart';

part 'reminders.g.dart';

class MedicineReminderDetailData {
  const MedicineReminderDetailData({
    required this.medicine,
    required this.reminders,
    required this.todayLogs,
    required this.deliveryLogs,
  });

  final CurrentMedicineItem medicine;
  final List<MedicineReminderItem> reminders;
  final List<DoseLogItem> todayLogs;
  final List<ReminderDeliveryItem> deliveryLogs;
}

class MedicineReminderSoundController
    extends AsyncNotifier<MedicineReminderSoundPreference> {
  final _prefs = const MedicineReminderLocalPreferences();

  @override
  Future<MedicineReminderSoundPreference> build() async {
    return _prefs.readSound();
  }

  Future<void> setSound(MedicineReminderSoundPreference preference) async {
    state = AsyncData(preference);
    await _prefs.writeSound(preference);
  }
}

class MedicineReminderTimeInput {
  const MedicineReminderTimeInput({required this.hour, required this.minute});

  final int hour;
  final int minute;

  String get label {
    final hh = hour.toString().padLeft(2, '0');
    final mm = minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  static MedicineReminderTimeInput fromTimeOfDay(TimeOfDay value) {
    return MedicineReminderTimeInput(hour: value.hour, minute: value.minute);
  }
}

class MedicineReminderGroupWriteInput {
  const MedicineReminderGroupWriteInput({
    required this.currentMedicineId,
    required this.label,
    required this.times,
    required this.daysOfWeek,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.note,
  });

  final String currentMedicineId;
  final String? label;
  final List<MedicineReminderTimeInput> times;
  final List<int>? daysOfWeek;
  final String? startDate;
  final String? endDate;
  final bool isActive;
  final String? note;
}

class MedicineReminderFormState {
  const MedicineReminderFormState({
    this.isSaving = false,
    this.errorMessage,
    this.saved = false,
    this.deleted = false,
  });

  final bool isSaving;
  final String? errorMessage;
  final bool saved;
  final bool deleted;
}

@Riverpod(keepAlive: true)
Future<List<MedicineReminderItem>> medicineReminderList(Ref ref) {
  return authGuarded(
    ref: ref,
    fetch: () => ref.watch(medicineReminderRemoteDataSourceProvider).fetchAll(),
  );
}

@Riverpod(keepAlive: true)
Future<List<DoseLogItem>> medicineTodayDoseLogs(Ref ref) {
  return authGuarded(
    ref: ref,
    fetch: () {
      final today = clock.now();
      final date =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      return ref.watch(cachedDoseLogDataSourceProvider).fetchForDate(date);
    },
  );
}

@Riverpod(keepAlive: true)
Future<List<ReminderDeliveryItem>> medicineReminderDeliveryLog(Ref ref) {
  return authGuarded(
    ref: ref,
    fetch: () => ref
        .watch(medicineReminderRemoteDataSourceProvider)
        .fetchDeliveries(limit: 20),
  );
}

@Riverpod(keepAlive: true)
Future<MedicineReminderDetailData> medicineReminderDetail(
  Ref ref,
  String currentMedicineId,
) async {
  final snapshot = await ref.watch(healthContextSnapshotProvider.future);
  final medicine = snapshot.currentMedicines
      .where((item) => item.id == currentMedicineId)
      .firstOrNull;
  if (medicine == null) {
    throw StateError('Medicine not found.');
  }

  final reminders = await ref.watch(medicineReminderListProvider.future);
  final todayLogs = await ref.watch(medicineTodayDoseLogsProvider.future);
  final deliveryLogs = await ref.watch(
    medicineReminderDeliveryLogProvider.future,
  );
  final medicineReminders =
      reminders
          .where((item) => item.currentMedicineId == currentMedicineId)
          .toList()
        ..sort(compareReminderTime);
  final medicineLogs = todayLogs
      .where((item) => item.currentMedicineId == currentMedicineId)
      .toList(growable: false);
  final reminderIds = medicineReminders.map((item) => item.id).toSet();
  final medicineDeliveryLogs = deliveryLogs
      .where((item) {
        final reminderId = item.reminderId;
        return reminderId != null && reminderIds.contains(reminderId);
      })
      .toList(growable: false);

  return MedicineReminderDetailData(
    medicine: medicine,
    reminders: medicineReminders,
    todayLogs: medicineLogs,
    deliveryLogs: medicineDeliveryLogs,
  );
}

final medicineReminderSoundProvider =
    AsyncNotifierProvider<
      MedicineReminderSoundController,
      MedicineReminderSoundPreference
    >(MedicineReminderSoundController.new);

class MedicineReminderFormNotifier extends Notifier<MedicineReminderFormState> {
  @override
  MedicineReminderFormState build() => const MedicineReminderFormState();

  Future<bool> saveGroup({
    required List<MedicineReminderItem> existingReminders,
    required MedicineReminderGroupWriteInput input,
  }) async {
    state = const MedicineReminderFormState(isSaving: true);

    try {
      final dataSource = ref.read(medicineReminderRemoteDataSourceProvider);
      final existing = [...existingReminders]..sort(compareReminderTime);
      final times = [...input.times]
        ..sort((left, right) {
          final hour = left.hour.compareTo(right.hour);
          if (hour != 0) return hour;
          return left.minute.compareTo(right.minute);
        });

      for (var index = 0; index < times.length; index += 1) {
        final time = times[index];
        final writeInput = MedicineReminderWriteInput(
          currentMedicineId: input.currentMedicineId,
          label: input.label,
          scheduledHour: time.hour,
          scheduledMinute: time.minute,
          daysOfWeek: input.daysOfWeek,
          startDate: input.startDate,
          endDate: input.endDate,
          isActive: input.isActive,
          note: input.note,
        );
        if (index < existing.length) {
          await dataSource.update(existing[index].id, writeInput);
        } else {
          await dataSource.create(writeInput);
        }
      }

      for (var index = times.length; index < existing.length; index += 1) {
        await dataSource.delete(existing[index].id);
      }

      _invalidateReminderSurfaces();
      state = const MedicineReminderFormState(saved: true);
      return true;
    } catch (error) {
      ref
          .read(talkerProvider)
          .error('MedicineReminderFormNotifier.saveGroup: failed: $error');
      state = MedicineReminderFormState(errorMessage: error.toString());
      return false;
    }
  }

  Future<bool> deleteGroup(List<MedicineReminderItem> reminders) async {
    state = const MedicineReminderFormState(isSaving: true);

    try {
      final dataSource = ref.read(medicineReminderRemoteDataSourceProvider);
      for (final reminder in reminders) {
        await dataSource.delete(reminder.id);
      }
      _invalidateReminderSurfaces();
      state = const MedicineReminderFormState(saved: true, deleted: true);
      return true;
    } catch (error) {
      ref
          .read(talkerProvider)
          .error('MedicineReminderFormNotifier.deleteGroup: failed: $error');
      state = MedicineReminderFormState(errorMessage: error.toString());
      return false;
    }
  }

  void _invalidateReminderSurfaces() {
    ref.invalidate(medicineReminderListProvider);
    ref.invalidate(medicineTodayDoseLogsProvider);
    ref.invalidate(medicineReminderDeliveryLogProvider);
    ref
        .read(dataChangeBusProvider.notifier)
        .emit(DataChangeTopic.medicineReminders);
  }
}

final medicineReminderFormProvider =
    NotifierProvider<MedicineReminderFormNotifier, MedicineReminderFormState>(
      MedicineReminderFormNotifier.new,
    );
