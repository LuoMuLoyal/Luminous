import 'package:dio/dio.dart';
import 'package:lucent_openapi/lucent_openapi.dart';

class MedicineReminderItem {
  const MedicineReminderItem({
    required this.id,
    this.currentMedicineId,
    this.label,
    required this.scheduledHour,
    required this.scheduledMinute,
    this.daysOfWeek,
    required this.isActive,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String? currentMedicineId;
  final String? label;
  final int scheduledHour;
  final int scheduledMinute;
  final List<int>? daysOfWeek;
  final bool isActive;
  final String? note;
  final String createdAt;
  final String updatedAt;

  String get timeLabel {
    final hour = scheduledHour.toString().padLeft(2, '0');
    final minute = scheduledMinute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  bool matchesDate(DateTime date) {
    final days = daysOfWeek;
    if (days == null) return true;
    final weekday = date.weekday % 7;
    return days.contains(weekday);
  }
}

class MedicineReminderRemoteDataSource {
  MedicineReminderRemoteDataSource({required this.api, required this.dio});

  final MedicineRemindersApi api;
  final Dio dio;

  Future<List<MedicineReminderItem>> fetchActive() async {
    final response = await api.medicineRemindersControllerListV1(
      activeOnly: 'true',
    );
    return response.data?.data.items.map(_fromDto).toList(growable: false) ??
        const <MedicineReminderItem>[];
  }

  MedicineReminderItem _fromDto(MedicineReminderItemDto dto) {
    return MedicineReminderItem(
      id: dto.id,
      currentMedicineId: _optionalString(dto.currentMedicineId),
      label: _optionalString(dto.label),
      scheduledHour: dto.scheduledHour.toInt(),
      scheduledMinute: dto.scheduledMinute.toInt(),
      daysOfWeek: dto.daysOfWeek
          ?.map((day) => day.toInt())
          .toList(growable: false),
      isActive: dto.isActive,
      note: _optionalString(dto.note),
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  String? _optionalString(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}
