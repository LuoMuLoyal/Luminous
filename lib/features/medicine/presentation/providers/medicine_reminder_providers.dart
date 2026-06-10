import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/health_context/data/providers/health_context_data_providers.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_snapshot.dart';
import 'package:luminous/features/medicine/data/datasources/dose_log_remote_data_source.dart';
import 'package:luminous/features/medicine/data/datasources/medicine_reminder_remote_data_source.dart';
import 'package:luminous/features/medicine/data/repositories/mock_medicine_workspace_repository.dart';
import 'package:luminous/features/medicine/presentation/providers/medicine_workspace_provider.dart';
import 'package:luminous/features/today/presentation/providers/today_dashboard_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

enum MedicineReminderSoundPreference {
  defaultTone('default'),
  gentle('gentle'),
  silent('silent');

  const MedicineReminderSoundPreference(this.storageValue);

  final String storageValue;

  static MedicineReminderSoundPreference fromStorage(String? value) {
    return MedicineReminderSoundPreference.values.firstWhere(
      (item) => item.storageValue == value,
      orElse: () => MedicineReminderSoundPreference.defaultTone,
    );
  }
}

class MedicineReminderSoundController
    extends AsyncNotifier<MedicineReminderSoundPreference> {
  static const _storageKey = 'medicine.reminder.sound';

  @override
  Future<MedicineReminderSoundPreference> build() async {
    final preferences = await SharedPreferences.getInstance();
    return MedicineReminderSoundPreference.fromStorage(
      preferences.getString(_storageKey),
    );
  }

  Future<void> setSound(MedicineReminderSoundPreference preference) async {
    state = AsyncData(preference);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_storageKey, preference.storageValue);
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

final medicineReminderListProvider = FutureProvider<List<MedicineReminderItem>>(
  (ref) {
    final session = ref.watch(authSessionProvider);
    if (session.isLoading) {
      return pendingAuthSessionResolution();
    }
    if (!session.canAccessProtectedData) {
      throw const AuthRequiredException();
    }
    return ref.watch(medicineReminderRemoteDataSourceProvider).fetchAll();
  },
);

final medicineTodayDoseLogsProvider = FutureProvider<List<DoseLogItem>>((ref) {
  final session = ref.watch(authSessionProvider);
  if (session.isLoading) {
    return pendingAuthSessionResolution();
  }
  if (!session.canAccessProtectedData) {
    throw const AuthRequiredException();
  }

  final today = DateTime.now();
  final date =
      '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
  return ref.watch(doseLogRemoteDataSourceProvider).fetchForDate(date);
});

final medicineReminderDeliveryLogProvider =
    FutureProvider<List<ReminderDeliveryItem>>((ref) {
      final session = ref.watch(authSessionProvider);
      if (session.isLoading) {
        return pendingAuthSessionResolution();
      }
      if (!session.canAccessProtectedData) {
        throw const AuthRequiredException();
      }

      return ref
          .watch(medicineReminderRemoteDataSourceProvider)
          .fetchDeliveries(limit: 20);
    });

final medicineReminderDetailProvider =
    FutureProvider.family<MedicineReminderDetailData, String>((
      ref,
      currentMedicineId,
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
            ..sort(_compareReminderTime);
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
    });

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
      final existing = [...existingReminders]..sort(_compareReminderTime);
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
      state = MedicineReminderFormState(errorMessage: error.toString());
      return false;
    }
  }

  void _invalidateReminderSurfaces() {
    ref.invalidate(medicineReminderListProvider);
    ref.invalidate(medicineTodayDoseLogsProvider);
    ref.invalidate(medicineReminderDeliveryLogProvider);
    ref.invalidate(medicineWorkspaceProvider);
    ref.invalidate(todayDashboardProvider);
  }
}

final medicineReminderFormProvider =
    NotifierProvider<MedicineReminderFormNotifier, MedicineReminderFormState>(
      MedicineReminderFormNotifier.new,
    );

int _compareReminderTime(
  MedicineReminderItem left,
  MedicineReminderItem right,
) {
  final hour = left.scheduledHour.compareTo(right.scheduledHour);
  if (hour != 0) return hour;
  return left.scheduledMinute.compareTo(right.scheduledMinute);
}
