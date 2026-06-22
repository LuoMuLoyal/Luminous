import 'package:flutter/material.dart';
import 'package:luminous/features/record/domain/entities/record_dashboard.dart';
import 'package:luminous/features/record/domain/entities/daily_record.dart';

/// Centralized color definitions for all record entry types.
///
/// Used by [MockRecordRepository], [LucentRecordRepository], record detail
/// pages, and dashboard overview widgets to produce consistent per-type
/// foreground/background color pairs.
class RecordTypeColors {
  const RecordTypeColors._();

  // -- water ----------------------------------------------------------------
  static const Color water = Color(0xFF428BFF);
  static const Color waterSoft = Color(0xFFEFF5FF);

  // -- meal ----------------------------------------------------------------
  static const Color meal = Color(0xFFFF8A00);
  static const Color mealSoft = Color(0xFFFFF2E0);

  // -- vital ----------------------------------------------------------------
  static const Color vital = Color(0xFFFF4D57);
  static const Color vitalSoft = Color(0xFFFFEEEE);

  // -- mood ----------------------------------------------------------------
  static const Color mood = Color(0xFF7D67E8);
  static const Color moodSoft = Color(0xFFF0ECFF);

  // -- symptom -------------------------------------------------------------
  static const Color symptom = Color(0xFFFF8A00);
  static const Color symptomSoft = Color(0xFFFFF2E0);

  // -- medication ----------------------------------------------------------
  static const Color medication = Color(0xFFFF7A1A);
  static const Color medicationSoft = Color(0xFFFFF0E6);

  // -- sleep ---------------------------------------------------------------
  static const Color sleep = Color(0xFF7D67E8);
  static const Color sleepSoft = Color(0xFFF0ECFF);

  // -- activity ------------------------------------------------------------
  static const Color activity = Color(0xFF16A66A);
  static const Color activitySoft = Color(0xFFEAF9F1);

  // -- note ----------------------------------------------------------------
  static const Color note = Color(0xFF428BFF);
  static const Color noteSoft = Color(0xFFEFF5FF);

  // -- heartRate -----------------------------------------------------------
  static const Color heartRate = Color(0xFFFF4D57);
  static const Color heartRateSoft = Color(0xFFFFEEEE);

  // -- weight --------------------------------------------------------------
  static const Color weight = Color(0xFF0761D1);
  static const Color weightSoft = Color(0xFFD3E5FF);

  /// Returns the (foreground, background) color pair for a [DailyRecordKind].
  static (Color, Color) forKind(DailyRecordKind kind) => switch (kind) {
    DailyRecordKind.water => (water, waterSoft),
    DailyRecordKind.meal => (meal, mealSoft),
    DailyRecordKind.vital => (vital, vitalSoft),
    DailyRecordKind.mood => (mood, moodSoft),
    DailyRecordKind.symptom => (symptom, symptomSoft),
    DailyRecordKind.activity => (activity, activitySoft),
    DailyRecordKind.note => (note, noteSoft),
    DailyRecordKind.sleep => (sleep, sleepSoft),
  };

  /// Returns the foreground color for a [RecordEntryType].
  static Color foreground(RecordEntryType type) => switch (type) {
    RecordEntryType.water => water,
    RecordEntryType.meal => meal,
    RecordEntryType.vitals => vital,
    RecordEntryType.mood => mood,
    RecordEntryType.symptom => symptom,
    RecordEntryType.medication => medication,
    RecordEntryType.activity => activity,
    RecordEntryType.sleep => sleep,
    RecordEntryType.note => note,
    RecordEntryType.heartRate => heartRate,
    RecordEntryType.weight => weight,
  };
}
