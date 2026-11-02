import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard.freezed.dart';
part 'dashboard.g.dart';

/// Everything the「我的」tab renders.
///
/// The entities here are pure data: icons and accent colors are presentation
/// concerns and live in `presentation/utils/mine_visuals.dart`, which keeps the
/// whole graph JSON-serializable so the dashboard can be cached.
@freezed
abstract class MineDashboard with _$MineDashboard {
  const MineDashboard._();

  const factory MineDashboard({
    required MineAccount account,
    required MineCompletion completion,
    required MineProfileSnapshot profile,
    required List<MineStatusCard> alerts,
    required List<MineArchiveEntry> archiveEntries,
    required MinePrivacyNotice privacyNotice,
  }) = _MineDashboard;

  factory MineDashboard.fromJson(Map<String, dynamic> json) =>
      _$MineDashboardFromJson(json);

  /// A minimal dashboard for signed-out users with no real or mock data.
  static MineDashboard signedOut() => const MineDashboard(
    account: MineAccount(
      isAuthenticated: false,
      displayNameKey: MineCopyKey.accountGuestDisplayName,
      email: '',
      statusKey: MineCopyKey.accountSignedOut,
      roleKey: MineCopyKey.accountStudentRole,
    ),
    completion: MineCompletion(
      progress: 0,
      percentLabel: '0%',
      titleKey: MineCopyKey.completionTitle,
    ),
    profile: MineProfileSnapshot(
      age: null,
      heightCm: null,
      weightKg: null,
      sexAtBirth: null,
      unitSystem: null,
      allergyCount: 0,
      conditionCount: 0,
      currentMedicineCount: 0,
      basicInfoCompleted: false,
    ),
    alerts: <MineStatusCard>[],
    archiveEntries: <MineArchiveEntry>[],
    privacyNotice: MinePrivacyNotice(
      titleKey: MineCopyKey.privacyNoticeTitle,
      actionKey: MineCopyKey.privacyNoticeAction,
    ),
  );
}

@freezed
abstract class MineProfileSnapshot with _$MineProfileSnapshot {
  const factory MineProfileSnapshot({
    required int? age,
    required double? heightCm,
    required double? weightKg,
    required String? sexAtBirth,

    /// 档案单位制（`metric` | `imperial`），仅用于展示换算；null 按公制。
    required String? unitSystem,
    required int allergyCount,
    required int conditionCount,
    required int currentMedicineCount,
    required bool basicInfoCompleted,
  }) = _MineProfileSnapshot;

  factory MineProfileSnapshot.fromJson(Map<String, dynamic> json) =>
      _$MineProfileSnapshotFromJson(json);
}

@freezed
abstract class MineAccount with _$MineAccount {
  const factory MineAccount({
    required bool isAuthenticated,
    required MineCopyKey displayNameKey,
    String? displayName,
    String? avatar,
    required String email,
    required MineCopyKey statusKey,
    required MineCopyKey roleKey,
    @Default(false) bool emailVerified,
    @Default(false) bool hasPassword,
    @Default(0) int linkedIdentityCount,
    DateTime? lastLoginAt,
  }) = _MineAccount;

  factory MineAccount.fromJson(Map<String, dynamic> json) =>
      _$MineAccountFromJson(json);
}

@freezed
abstract class MineCompletion with _$MineCompletion {
  const factory MineCompletion({
    required double progress,
    required String percentLabel,
    required MineCopyKey titleKey,
  }) = _MineCompletion;

  factory MineCompletion.fromJson(Map<String, dynamic> json) =>
      _$MineCompletionFromJson(json);
}

/// The kind of a Mine「档案提醒」status card; drives how the presentation
/// layer composes localized subtitle/badge text from [MineStatusCard.items]
/// and [MineStatusCard.count] (see `presentation/widgets/sections/status_alerts.dart`).
enum MineStatusCardKind { allergy, medicine, privacy }

@freezed
abstract class MineStatusCard with _$MineStatusCard {
  const factory MineStatusCard({
    required MineCopyKey titleKey,
    required MineStatusCardKind kind,

    /// Key-based subtitle (resolved via [MineCopyKey]); kept for cards whose
    /// copy is static (privacy card).
    MineCopyKey? subtitleKey,
    MineCopyKey? badgeKey,

    /// Real labels (allergy) / display names (medicine), full list — the
    /// presentation layer truncates for display. Defaults to empty.
    @Default(<String>[]) List<String> items,

    /// Authoritative Lucent count for the card (allergy / medicine); the
    /// presentation layer renders it as the badge and the「等 N 项/种」suffix.
    int? count,
  }) = _MineStatusCard;

  factory MineStatusCard.fromJson(Map<String, dynamic> json) =>
      _$MineStatusCardFromJson(json);
}

@freezed
abstract class MineArchiveEntry with _$MineArchiveEntry {
  const factory MineArchiveEntry({
    required MineCopyKey titleKey,
    required MineCopyKey subtitleKey,
    MineCopyKey? statusKey,
    String? route,
  }) = _MineArchiveEntry;

  factory MineArchiveEntry.fromJson(Map<String, dynamic> json) =>
      _$MineArchiveEntryFromJson(json);
}

@freezed
abstract class MinePrivacyNotice with _$MinePrivacyNotice {
  const factory MinePrivacyNotice({
    required MineCopyKey titleKey,
    required MineCopyKey actionKey,
  }) = _MinePrivacyNotice;

  factory MinePrivacyNotice.fromJson(Map<String, dynamic> json) =>
      _$MinePrivacyNoticeFromJson(json);
}

enum MineCopyKey {
  accountDisplayName,
  accountGuestDisplayName,
  accountSignedIn,
  accountSignedOut,
  accountStudentRole,
  signedOutNoticeTitle,
  signedOutNoticeDescription,
  completionTitle,
  alertAllergyTitle,
  alertMedicineTitle,
  alertPrivacyTitle,
  alertPrivacySubtitle,
  alertPrivacyBadge,
  archiveBasicTitle,
  archiveBasicSubtitle,
  archiveAllergyTitle,
  archiveAllergySubtitle,
  archiveConditionTitle,
  archiveConditionSubtitle,
  archiveMedicineTitle,
  archiveMedicineSubtitle,
  archiveEmergencyTitle,
  archiveEmergencySubtitle,
  archiveCompleted,
  archiveNeedsFill,
  privacyNoticeTitle,
  privacyNoticeAction,
  archiveAddNewAction,
}
