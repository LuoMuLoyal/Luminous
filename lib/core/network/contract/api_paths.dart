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

  /// `GET /api/v1/auth/sessions` — the generated AuthApi currently declares
  /// this response as void, while the account-security UI needs its payload.
  static const authSessions = '/api/v1/auth/sessions';

  /// `DELETE /api/v1/auth/sessions/{sessionId}` — see [authSessions].
  static String authSession(String sessionId) =>
      '/api/v1/auth/sessions/$sessionId';

  /// `POST /api/v1/user/today-analysis/generate/stream`
  static const todayAnalysisGenerateStream =
      '/api/v1/user/today-analysis/generate/stream';

  /// `POST /api/v1/user/today-analysis/refresh` — the generated client merges
  /// the oneOf response variants into a single DTO with all fields required,
  /// so callers parse the direct resource and dispatch on `status`/`analysis`.
  static const todayAnalysisRefresh = '/api/v1/user/today-analysis/refresh';

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
  /// [UpdateUserHealthContextProfileRequest] requires 8 fields; callers need to send
  /// only changed fields.
  static const healthContextProfile = '/api/v1/user/health-context/profile';

  /// `PATCH /api/v1/user/notification-preferences` — raw fallback is used
  /// when a nullable sleep time must be explicitly cleared.
  static const notificationPreferences =
      '/api/v1/user/notification-preferences';

  /// `POST /api/v1/user/daily-records` — used for partial create with
  /// optional fields.
  static const dailyRecords = '/api/v1/user/daily-records';

  /// `PATCH /api/v1/user/daily-records/{id}` — partial PATCH semantics
  /// incompatible with [UpdateDailyRecordRequest].
  static String dailyRecord(String id) => '/api/v1/user/daily-records/$id';

  /// `POST /api/v1/user/medicine-reminders` — raw create with custom JSON.
  static const medicineReminders = '/api/v1/user/medicine-reminders';

  /// `PATCH /api/v1/user/medicine-reminders/{id}` — raw update with custom JSON.
  static String medicineReminder(String id) =>
      '/api/v1/user/medicine-reminders/$id';

  /// `GET /api/v1/user/reminder-deliveries` — raw GET for deliveries.
  static const reminderDeliveries = '/api/v1/user/reminder-deliveries';

  /// `POST /api/v1/user/reminder-deliveries/receipts` — records a local
  /// notification delivery receipt (idempotent).
  static const reminderDeliveryReceipts =
      '/api/v1/user/reminder-deliveries/receipts';

  /// `PUT /api/v1/user/reminder-deliveries/local-capability` — reports the
  /// client local scheduling capability (`active`/`unavailable`/`disabled`).
  static const reminderDeliveryLocalCapability =
      '/api/v1/user/reminder-deliveries/local-capability';

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
