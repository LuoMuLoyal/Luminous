/// Centralized Lucent API path constants.
///
/// Endpoints that use the generated retrofit client ([LucentClient]) don't
/// need entries here — their paths are baked into the generated code.
///
/// This file covers only the paths used by raw [Dio] calls that bypass the
/// generated client, typically because:
///   - The endpoint returns SSE (Server-Sent Events), which retrofit can't
///     represent.
///   - The generated client declares the response as `void`, discarding the
///     response body that the caller actually needs.
///   - The generated DTO requires all fields while the caller needs partial
///     PATCH semantics.
abstract final class LucentApiPaths {
  // ── SSE stream endpoints (retrofit can't represent streams) ─────────────

  /// `POST /api/v1/auth/refresh` — uses a separate Dio instance
  /// ([AuthInterceptor._refreshDio]) to avoid interceptor recursion.
  static const authRefresh = '/api/v1/auth/refresh';

  /// `POST /api/v1/user/today-analysis/generate/stream`
  static const todayAnalysisGenerateStream =
      '/api/v1/user/today-analysis/generate/stream';

  /// `POST /api/v1/user/reports/summary/generate/stream`
  static const reportSummaryGenerateStream =
      '/api/v1/user/reports/summary/generate/stream';

  // ── Void-return endpoints (generated client discards response body) ────

  /// `POST /api/v1/user/files/upload` — returns presigned upload URL data
  /// in the response body, but the generated [FilesApi] declares it as
  /// `Future<void>`.
  static const filesUpload = '/api/v1/user/files/upload';

  /// `POST /api/v1/medicines/recognize` — returns recognized medicine data
  /// in the response body, but the generated [MedicinesApi] declares it as
  /// `Future<void>`.
  static const medicinesRecognize = '/api/v1/medicines/recognize';

  // ── Partial-PATCH endpoints (generated DTO requires all fields) ────────

  /// `PATCH /api/v1/user/health-context/profile` — the generated
  /// [UpdateHealthContextProfileDto] requires 8 fields; callers need to send
  /// only changed fields.
  static const healthContextProfile = '/api/v1/user/health-context/profile';

  /// `POST /api/v1/user/daily-records` — used for partial create with
  /// optional fields.
  static const dailyRecords = '/api/v1/user/daily-records';

  /// `PATCH /api/v1/user/daily-records/{id}` — partial PATCH semantics
  /// incompatible with [UpdateDailyRecordDto].
  static String dailyRecord(String id) => '/api/v1/user/daily-records/$id';

  /// `POST /api/v1/user/medicine-reminders` — raw create with custom JSON.
  static const medicineReminders = '/api/v1/user/medicine-reminders';

  /// `PATCH /api/v1/user/medicine-reminders/{id}` — raw update with custom JSON.
  static String medicineReminder(String id) =>
      '/api/v1/user/medicine-reminders/$id';

  /// `GET /api/v1/user/reminder-deliveries` — raw GET for deliveries.
  static const reminderDeliveries = '/api/v1/user/reminder-deliveries';

  /// `POST /api/v1/user/medicine-dose-logs/mark` — raw mark with custom JSON.
  static const medicineDoseLogsMark = '/api/v1/user/medicine-dose-logs/mark';

  /// `POST /api/v1/user/medicine-dose-logs` — raw create with custom JSON.
  static const medicineDoseLogs = '/api/v1/user/medicine-dose-logs';

  /// `PATCH /api/v1/user/medicine-dose-logs/{id}` — raw update.
  static String medicineDoseLog(String id) =>
      '/api/v1/user/medicine-dose-logs/$id';

  // ── Binary-response endpoints (generated client declares void) ──────────

  /// `GET /api/v1/user/reports/clinic-summary/preview/pdf` —
  /// Downloads the authenticated user's clinic summary as PDF (binary).
  /// The generated [ReportsApi] declares this as `Future<void>`, so the
  /// caller must use raw [Dio] with `ResponseType.bytes`.
  static const clinicSummaryPreviewPdf =
      '/api/v1/user/reports/clinic-summary/preview/pdf';

  /// `GET /api/v1/user/reports/clinic-summary/shared/{token}/pdf` —
  /// Downloads a shared clinic summary as PDF (no auth required).
  static String clinicSummarySharedPdf(String token) =>
      '/api/v1/user/reports/clinic-summary/shared/$token/pdf';
}
