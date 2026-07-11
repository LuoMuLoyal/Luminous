// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart' hide Headers;

import 'clients/health_api.dart';
import 'clients/auth_api.dart';
import 'clients/notifications_api.dart';
import 'clients/account_api.dart';
import 'clients/medicines_api.dart';
import 'clients/user_health_context_api.dart';
import 'clients/daily_records_api.dart';
import 'clients/medicine_dose_logs_api.dart';
import 'clients/medicine_reminders_api.dart';
import 'clients/reminder_deliveries_api.dart';
import 'clients/environment_api.dart';
import 'clients/reports_api.dart';
import 'clients/assistant_api.dart';
import 'clients/user_settings_api.dart';
import 'clients/today_analysis_api.dart';
import 'clients/today_suggestion_api.dart';
import 'clients/support_resources_api.dart';
import 'clients/legal_documents_api.dart';
import 'clients/data_export_api.dart';
import 'clients/files_api.dart';

/// Lucent API `v1.0`.
///
/// Lucent 后端 API 文档.
class LucentClient {
  LucentClient(Dio dio, {String? baseUrl}) : _dio = dio, _baseUrl = baseUrl;

  final Dio _dio;
  final String? _baseUrl;

  static String get version => '1.0';

  HealthApi? _health;
  AuthApi? _auth;
  NotificationsApi? _notifications;
  AccountApi? _account;
  MedicinesApi? _medicines;
  UserHealthContextApi? _userHealthContext;
  DailyRecordsApi? _dailyRecords;
  MedicineDoseLogsApi? _medicineDoseLogs;
  MedicineRemindersApi? _medicineReminders;
  ReminderDeliveriesApi? _reminderDeliveries;
  EnvironmentApi? _environment;
  ReportsApi? _reports;
  AssistantApi? _assistant;
  UserSettingsApi? _userSettings;
  TodayAnalysisApi? _todayAnalysis;
  TodaySuggestionApi? _todaySuggestion;
  SupportResourcesApi? _supportResources;
  LegalDocumentsApi? _legalDocuments;
  DataExportApi? _dataExport;
  FilesApi? _files;

  HealthApi get health => _health ??= HealthApi(_dio, baseUrl: _baseUrl);

  AuthApi get auth => _auth ??= AuthApi(_dio, baseUrl: _baseUrl);

  NotificationsApi get notifications =>
      _notifications ??= NotificationsApi(_dio, baseUrl: _baseUrl);

  AccountApi get account => _account ??= AccountApi(_dio, baseUrl: _baseUrl);

  MedicinesApi get medicines =>
      _medicines ??= MedicinesApi(_dio, baseUrl: _baseUrl);

  UserHealthContextApi get userHealthContext =>
      _userHealthContext ??= UserHealthContextApi(_dio, baseUrl: _baseUrl);

  DailyRecordsApi get dailyRecords =>
      _dailyRecords ??= DailyRecordsApi(_dio, baseUrl: _baseUrl);

  MedicineDoseLogsApi get medicineDoseLogs =>
      _medicineDoseLogs ??= MedicineDoseLogsApi(_dio, baseUrl: _baseUrl);

  MedicineRemindersApi get medicineReminders =>
      _medicineReminders ??= MedicineRemindersApi(_dio, baseUrl: _baseUrl);

  ReminderDeliveriesApi get reminderDeliveries =>
      _reminderDeliveries ??= ReminderDeliveriesApi(_dio, baseUrl: _baseUrl);

  EnvironmentApi get environment =>
      _environment ??= EnvironmentApi(_dio, baseUrl: _baseUrl);

  ReportsApi get reports => _reports ??= ReportsApi(_dio, baseUrl: _baseUrl);

  AssistantApi get assistant =>
      _assistant ??= AssistantApi(_dio, baseUrl: _baseUrl);

  UserSettingsApi get userSettings =>
      _userSettings ??= UserSettingsApi(_dio, baseUrl: _baseUrl);

  TodayAnalysisApi get todayAnalysis =>
      _todayAnalysis ??= TodayAnalysisApi(_dio, baseUrl: _baseUrl);

  TodaySuggestionApi get todaySuggestion =>
      _todaySuggestion ??= TodaySuggestionApi(_dio, baseUrl: _baseUrl);

  SupportResourcesApi get supportResources =>
      _supportResources ??= SupportResourcesApi(_dio, baseUrl: _baseUrl);

  LegalDocumentsApi get legalDocuments =>
      _legalDocuments ??= LegalDocumentsApi(_dio, baseUrl: _baseUrl);

  DataExportApi get dataExport =>
      _dataExport ??= DataExportApi(_dio, baseUrl: _baseUrl);

  FilesApi get files => _files ??= FilesApi(_dio, baseUrl: _baseUrl);
}
