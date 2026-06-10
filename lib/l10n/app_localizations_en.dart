// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Luminous';

  @override
  String get tabToday => 'Today';

  @override
  String get tabRecord => 'Record';

  @override
  String get tabMedicine => 'Medicine';

  @override
  String get tabReport => 'Report';

  @override
  String get tabMine => 'Mine';

  @override
  String get desktopSidebarSettings => 'Settings';

  @override
  String get desktopSidebarHelp => 'Help';

  @override
  String get desktopSidebarHelpToast => 'This will open help and support.';

  @override
  String get recordPageDescription =>
      'Calendar, timeline, and multi-type daily records will grow here.';

  @override
  String get recordSectionTitle => 'Daily timeline';

  @override
  String get recordSectionSubtitle =>
      'The first rebuild step for Record is structure, not logic.';

  @override
  String get recordTodayAction => 'Today';

  @override
  String get recordPreviousDayAction => 'Previous day';

  @override
  String get recordNextDayAction => 'Next day';

  @override
  String get recordPickDateAction => 'Pick date';

  @override
  String get recordSearchAction => 'Search';

  @override
  String get recordFilterAction => 'Filter';

  @override
  String get recordSwitchDateAction => 'Switch date';

  @override
  String recordDatePillLabel(int month, int day, String weekday) {
    return '$month/$day · $weekday';
  }

  @override
  String recordTodayEntriesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Today entries · $count',
      one: 'Today entry · 1',
      zero: 'Today entries · 0',
    );
    return '$_temp0';
  }

  @override
  String recordQuickActionLabel(String type) {
    return 'Log $type';
  }

  @override
  String get recordAddAction => 'Record';

  @override
  String get recordAddCompactAction => 'Record';

  @override
  String get recordCreateFieldKind => 'Kind';

  @override
  String get recordCreateFieldUnit => 'Unit';

  @override
  String get recordWaterUnitMl => 'ml';

  @override
  String get recordWaterUnitCup => 'cup';

  @override
  String get recordWaterUnitTimes => 'times';

  @override
  String get recordCreateFieldTitleOptional => 'Title (optional)';

  @override
  String get recordCreateFieldNote => 'Note';

  @override
  String get recordCreateKindNote => 'Note';

  @override
  String get recordCreateValueWater => 'Water amount';

  @override
  String get recordCreateValueMeal => 'Name / description';

  @override
  String get recordCreateValueVital => 'Value (e.g. 120/80)';

  @override
  String get recordCreateValueSymptom => 'Severity / feeling';

  @override
  String get recordCreateFailedToast => 'Record was not saved.';

  @override
  String get recordImageSectionTitle => 'Image attachment';

  @override
  String get recordImageEmptyLabel => 'No image attached';

  @override
  String get recordImageAttachedLabel => 'Image attached';

  @override
  String get recordImagePickAction => 'Choose image';

  @override
  String get recordImageReplaceAction => 'Replace image';

  @override
  String get recordImageRemoveAction => 'Remove';

  @override
  String get recordImageUnsupportedToast =>
      'Only JPG, PNG, WEBP, or GIF images are supported.';

  @override
  String get recordImagePickFailedToast => 'Image was not selected.';

  @override
  String get recordQuickSectionTitle => 'Quick record';

  @override
  String get recordAiInputHint =>
      'My stomach feels a bit bloated after eating...';

  @override
  String get recordAiBadge => 'AI';

  @override
  String get recordSummarySectionTitle => 'Day summary';

  @override
  String get recordSummaryDateLabel => 'May 15, 2025 (Thu)';

  @override
  String get recordTimelineSectionTitle => 'Timeline';

  @override
  String get recordTrendsSectionTitle => 'Trends';

  @override
  String get recordNewEntrySectionTitle => 'New record';

  @override
  String get recordFilterSectionTitle => 'Record types';

  @override
  String get recordFilterMobileTitle => 'Record filter';

  @override
  String get recordFilterAllAction => 'All';

  @override
  String get recordFilterSelectAll => 'Select all';

  @override
  String get recordAllTypesAction => 'All types';

  @override
  String get recordTodayOverviewTitle => 'Today overview';

  @override
  String get recordTodayOverviewEvents => 'Events';

  @override
  String recordTodayOverviewEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: '0 items',
    );
    return '$_temp0';
  }

  @override
  String get recordVoiceInputTitle => 'Voice input';

  @override
  String get recordGuideHint =>
      'Tip: steady records help you understand your health better';

  @override
  String get recordGuideAction => 'View record guide';

  @override
  String get recordDetailTitle => 'Record details';

  @override
  String get recordDetailErrorTitle => 'Record details did not load this time';

  @override
  String get recordDetailValueLabel => 'Value';

  @override
  String get recordDetailSourceLabel => 'Source';

  @override
  String get recordDetailUpdatedAtLabel => 'Updated at';

  @override
  String get recordEditAction => 'Edit';

  @override
  String get recordDeleteAction => 'Delete';

  @override
  String get recordDeleteConfirmMessage =>
      'Delete this record? This action cannot be undone.';

  @override
  String get recordMonthLabel => 'May 2025';

  @override
  String get recordOpenDateAction => 'Open date';

  @override
  String get recordNotEnabledLabel => 'Off';

  @override
  String get recordVoiceAction => 'Voice record (hold to talk)';

  @override
  String recordActionToast(String action) {
    return '$action: this will open the related action later.';
  }

  @override
  String get recordErrorTitle => 'Record did not load this time';

  @override
  String get recordErrorDescription =>
      'The mock data boundary is wired, so try fetching it again.';

  @override
  String get recordWeekdaySun => 'Sun';

  @override
  String get recordWeekdayMon => 'Mon';

  @override
  String get recordWeekdayTue => 'Tue';

  @override
  String get recordWeekdayWed => 'Wed';

  @override
  String get recordWeekdayThu => 'Thu';

  @override
  String get recordWeekdayFri => 'Fri';

  @override
  String get recordWeekdaySat => 'Sat';

  @override
  String get recordTypeMeal => 'Meal';

  @override
  String get recordTypeVitals => 'Vitals';

  @override
  String get recordTypeWater => 'Water';

  @override
  String get recordTypeMood => 'Mood';

  @override
  String get recordTypeSymptom => 'Symptom';

  @override
  String get recordTypeActivity => 'Activity';

  @override
  String get recordTypeMedication => 'Medication';

  @override
  String get recordTypeSleep => 'Sleep';

  @override
  String get recordTypeHeartRate => 'Heart rate';

  @override
  String get recordTypeWeight => 'Weight';

  @override
  String get recordSummaryMealTitle => 'Meal records';

  @override
  String get recordSummaryWaterTitle => 'Water progress';

  @override
  String get recordSummaryLatestVitalTitle => 'Latest vital';

  @override
  String get recordSummaryMoodTitle => 'Mood record';

  @override
  String get recordSummaryTimesUnit => 'times';

  @override
  String get recordSummaryCupsUnit => 'cups';

  @override
  String get recordSummaryRecorded => 'Recorded';

  @override
  String get recordSummaryNormal => 'Normal';

  @override
  String get recordTimelineMealLunch => 'Meal · Lunch';

  @override
  String get recordTimelineMealName => 'Chicken quinoa salad';

  @override
  String get recordTimelineMealNutrition =>
      'About 520 kcal · protein 32g · carbs 45g · fat 12g';

  @override
  String get recordTimelineAiBadge => 'AI read';

  @override
  String get recordTimelineBloodPressure => 'Blood pressure';

  @override
  String get recordTimelineBloodPressureDetail =>
      'Source: manual entry · normal';

  @override
  String get recordTimelineManualBadge => 'Manual';

  @override
  String get recordTimelineWaterAmount => '1 cup 250ml';

  @override
  String get recordTimelineWaterProgress => 'Cup 4 / 8';

  @override
  String get recordTimelineMedicationName => 'Atorvastatin 20mg';

  @override
  String get recordTimelineMedicationDetail =>
      'Taken · synced with medication plan';

  @override
  String get recordTimelineMoodCalm => 'Mood · Calm';

  @override
  String get recordTimelineMoodDetail => 'Mood is steady, sleep was okay';

  @override
  String get recordTimelineSymptomRecord => 'Symptom record';

  @override
  String get recordTimelineSymptomDetail => 'Headache · pain score 3/5';

  @override
  String get recordTimelineSleepRecord => 'Sleep record';

  @override
  String get recordTimelineSleepDetail =>
      'Bedtime 23:30 · sleep duration 7.0 h';

  @override
  String get recordTimelineHeartRateDetail => '72 bpm · source: watch · normal';

  @override
  String get recordTimelineWeightDetail => 'Source: smart scale · BMI 22.5';

  @override
  String get recordTrendBloodSugarTitle => 'Meal-blood sugar';

  @override
  String get recordTrendBloodSugarLegend => 'Post-meal glucose (mmol/L)';

  @override
  String get recordTrendHydrationTitle => 'Water completion';

  @override
  String get recordRange7Days => 'Last 7 days';

  @override
  String get recordRange30Days => 'Last 30 days';

  @override
  String get recordFoodImagePlaceholder => 'Meal image placeholder';

  @override
  String get recordSymptomTrackingSectionTitle => 'Symptom tracking';

  @override
  String get recordSymptomHeadache => 'Headache';

  @override
  String recordSymptomLoggedAt(String time) {
    return 'Logged today at $time';
  }

  @override
  String get recordBodyPartLabel => 'Body part';

  @override
  String get recordBodyPartForehead => 'Head (forehead)';

  @override
  String get recordAccompanyingSymptomsLabel => 'Other symptoms';

  @override
  String get recordSymptomNausea => 'Mild nausea';

  @override
  String get recordSymptomLightSensitive => 'Light sensitive';

  @override
  String get recordPainRatingLabel => 'Pain rating';

  @override
  String get recordPainModerate => 'Moderate';

  @override
  String get recordViewTrendAction => 'View trend';

  @override
  String get recordDietTitle => 'Meal records';

  @override
  String recordMealCountValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meals today',
      one: '1 meal today',
      zero: '0 meals today',
    );
    return '$_temp0';
  }

  @override
  String get recordMealLogging => 'Logging';

  @override
  String get recordDietRecordAction => 'Log meal';

  @override
  String get recordDentalRecordTitle => 'Dental';

  @override
  String get recordEyeRecordTitle => 'Eye';

  @override
  String get recordHearingRecordTitle => 'Hearing';

  @override
  String get recordZeroCountLabel => '0 records';

  @override
  String get medicineHeaderAddToast =>
      'This will open medicine addition and recognition.';

  @override
  String get medicineSafetyGuardLabel => 'Safe guard';

  @override
  String get medicineNotificationsTooltip => 'Medication reminders';

  @override
  String get medicineHomeSearchHint => 'Search medicine or symptom';

  @override
  String get medicineManageMedicinesAction => 'Manage meds';

  @override
  String get medicineDrugboxTitle => 'My drugbox';

  @override
  String get medicineDrugboxSubtitle => 'Manage my medicines';

  @override
  String get medicineDrugboxTotalPrefix => 'Medicine total';

  @override
  String medicineDrugboxTotal(int count) {
    return '$count meds';
  }

  @override
  String get medicineNextDoseReminderTitle => 'Next dose reminder';

  @override
  String medicineNextDoseTodayTime(String time) {
    return 'Today $time';
  }

  @override
  String get medicineDoseDueStatus => 'Due';

  @override
  String get medicineNoMedicineTitle => 'No medicines yet';

  @override
  String get medicineNoMedicineBody => 'Add medicine to show reminders';

  @override
  String get medicineSafetyEngineTitle => 'Safety check preview';

  @override
  String get medicineSafetyAllRecordsAction => 'Source notes';

  @override
  String get medicineQuickOperationTitle => 'Medication actions';

  @override
  String get medicineQuickAddTitle => 'Add med';

  @override
  String get medicineQuickAddSubtitle => 'Manual add';

  @override
  String get medicineQuickRecordTitle => 'Log dose';

  @override
  String get medicineQuickRecordSubtitle => 'Track use';

  @override
  String get medicineQuickSafetyCheckTitle => 'Risk check';

  @override
  String get medicineQuickSafetyCheckSubtitle =>
      'Interactions and contraindications';

  @override
  String get medicineQuickSafetyCheckToast =>
      'This will open interaction and contraindication checks.';

  @override
  String get medicineQuickRecordToast => 'This will open dose logging.';

  @override
  String get medicineRecordsTitle => 'Medication records';

  @override
  String get medicineAllMedicinesFilter => 'All meds';

  @override
  String get medicineLastSevenDaysFilter => 'Last 7 days';

  @override
  String get medicineViewMoreRecordsAction => 'View more records';

  @override
  String get medicineRecordTodayLabel => 'Today';

  @override
  String get medicineRecordPreviousDate => '5/19';

  @override
  String get medicineRecordOlderDate => '5/18';

  @override
  String get medicineRecordOnTimeStatus => 'On time';

  @override
  String get medicineRecordScheduledStatus => 'Planned';

  @override
  String get medicineReferenceNoticeTitle =>
      'For reference only. Ask a doctor or pharmacist when needed.';

  @override
  String get medicineReferenceNoticeBody =>
      'This app does not provide diagnosis. Seek care promptly if you feel unwell.';

  @override
  String get medicineSafetyTipsTitle => 'Medication safety tips';

  @override
  String get medicineSafetyTipsRefreshAction => 'Refresh';

  @override
  String get medicineSafetyTipSpacing =>
      'If alcohol is unavoidable during medication, leave at least 24 hours when possible.';

  @override
  String get medicineSafetyTipCoffee =>
      'Coffee, strong tea, or energy drinks may affect some medicines. Use moderately.';

  @override
  String get medicineSafetyTipTiming =>
      'Take medicines on time and as directed. Do not change or stop them yourself.';

  @override
  String get medicineSafetyTipStorage =>
      'Store medicines in a cool, dry place and keep them away from children.';

  @override
  String get medicineErrorTitle => 'Medication page did not load';

  @override
  String get medicineErrorDescription =>
      'Please check your network connection and try again.';

  @override
  String get medicineHeroMetricTodayCountLabel => 'Doses today';

  @override
  String get medicineHeroMetricTodayCountUnit => ' meds';

  @override
  String get medicineHeroMetricAdherenceLabel => 'On-time adherence';

  @override
  String get medicineHeroMetricAdherenceUnit => '%';

  @override
  String get medicineQuickActionSectionTitle => 'Recognition and intake';

  @override
  String get medicineQuickActionCameraTitle => 'Recognize by camera';

  @override
  String get medicineQuickActionCameraSubtitle =>
      'Read packaging, boxes, and prescription labels';

  @override
  String get medicineQuickActionBarcodeTitle => 'Scan barcode';

  @override
  String get medicineQuickActionBarcodeSubtitle =>
      'Fill dosage form, manufacturer, and common aliases';

  @override
  String get medicineQuickActionSearchTitle => 'Search manually';

  @override
  String get medicineQuickActionSearchSubtitle =>
      'Find medicines by name, ingredient, or symptom';

  @override
  String get medicineQuickActionPrescriptionTitle => 'Import prescription';

  @override
  String get medicineQuickActionPrescriptionSubtitle =>
      'OCR and follow-up reminders can attach later';

  @override
  String get medicineTodayPlanTitle => 'Today\'s dosing plan';

  @override
  String get medicineTodayPlanInspectAction => 'View all';

  @override
  String get medicineMockNameMetformin => 'Metformin XR';

  @override
  String get medicineMockDoseMetformin => '0.5 g';

  @override
  String get medicineMockScheduleMorningEvening => 'Twice daily';

  @override
  String get medicineMockTime0800 => '08:00';

  @override
  String get medicineMockTime1200 => '12:00';

  @override
  String get medicineMockTime2000 => '20:00';

  @override
  String get medicineDoseStatusTaken => 'Taken';

  @override
  String get medicineDoseStatusSkipped => 'Skipped';

  @override
  String get medicineDoseStatusPending => 'Pending';

  @override
  String get medicineDoseActionTaken => 'Taken';

  @override
  String get medicineDoseActionSkipped => 'Skipped';

  @override
  String get medicineDoseActionSavedToast => 'Dose log saved.';

  @override
  String get medicineDoseActionFailedToast => 'Dose log was not saved.';

  @override
  String get medicineDoseNotSet => 'Dose not set';

  @override
  String get medicineScheduleNotSet => 'Reminder not set';

  @override
  String get medicineReminderNewTitle => 'New reminder';

  @override
  String get medicineReminderEditTitle => 'Edit reminder';

  @override
  String get medicineReminderDetailTitle => 'Medication reminder details';

  @override
  String get medicineReminderNotFoundTitle => 'Reminder did not load';

  @override
  String get medicineReminderQuickTitle => 'Reminder setup';

  @override
  String get medicineReminderQuickSubtitle => 'Manage dose times';

  @override
  String get medicineReminderEnabledStatus => 'On';

  @override
  String get medicineReminderDisabledStatus => 'Off';

  @override
  String get medicineReminderFrequencyLabel => 'Frequency';

  @override
  String get medicineReminderFrequencyDaily => 'Daily';

  @override
  String get medicineReminderFrequencyWeekly => 'Weekly';

  @override
  String get medicineReminderFrequencyCustom => 'Custom';

  @override
  String get medicineReminderTimesLabel => 'Dose times';

  @override
  String get medicineReminderDoseLabel => 'Dose';

  @override
  String get medicineReminderStartDateLabel => 'Start date';

  @override
  String get medicineReminderEndDateLabel => 'End date';

  @override
  String get medicineReminderDateNotSet => 'Not set';

  @override
  String get medicineReminderClearDateAction => 'Clear date';

  @override
  String get medicineReminderMethodLabel => 'Reminder method';

  @override
  String get medicineReminderNotificationOn => 'Reminder notification';

  @override
  String get medicineReminderNotificationOff => 'Reminder off';

  @override
  String get medicineReminderDeviceLocalHint =>
      'Only the schedule is saved; system notifications are controlled on this device.';

  @override
  String get medicineReminderSmsLabel => 'SMS reminder';

  @override
  String get medicineReminderSmsOff => 'SMS unavailable';

  @override
  String get medicineReminderSmsUnavailableHint =>
      'SMS delivery is not open yet.';

  @override
  String get medicineReminderUnavailableStatus => 'Unavailable';

  @override
  String get medicineReminderSoundLabel => 'Sound reminder';

  @override
  String get medicineReminderSoundLocalHint =>
      'Sound preference used for local reminders.';

  @override
  String get medicineReminderSoundDefault => 'Default tone';

  @override
  String get medicineReminderSoundGentle => 'Gentle tone';

  @override
  String get medicineReminderSoundSilent => 'Silent';

  @override
  String get medicineReminderNotificationDefaultTitle => 'Medication reminder';

  @override
  String get medicineReminderNotificationDefaultBody =>
      'It\'s time to take your medicine.';

  @override
  String get medicineReminderNotificationChannelName => 'Medication reminders';

  @override
  String get medicineReminderNotificationChannelDescription =>
      'On-device reminders for your medication schedule.';

  @override
  String get medicineReminderNoteLabel => 'Note';

  @override
  String get medicineReminderNoteOptionalLabel => 'Note (optional)';

  @override
  String get medicineReminderNoteHint => 'Add a note, e.g. after meals';

  @override
  String get medicineReminderMedicineSectionTitle => 'Medicine info';

  @override
  String get medicineReminderMedicineLabel => 'Choose medicine';

  @override
  String get medicineReminderSettingsSectionTitle => 'Reminder settings';

  @override
  String get medicineReminderAddTimeAction => 'Add time';

  @override
  String get medicineReminderTodayLogsTitle => 'Today\'s dose logs';

  @override
  String get medicineReminderNoTodayLogs => 'No dose logs yet today';

  @override
  String get medicineReminderDeliveryLogsTitle => 'Reminder delivery history';

  @override
  String get medicineReminderNoDeliveryLogs =>
      'No reminder delivery records yet';

  @override
  String get medicineReminderDeliveryChannelLocal => 'Local notification';

  @override
  String get medicineReminderDeliveryChannelPush => 'Push notification';

  @override
  String get medicineReminderDeliveryChannelEmail => 'Email';

  @override
  String get medicineReminderDeliveryChannelSms => 'SMS';

  @override
  String get medicineReminderDeliveryStatusScheduled => 'Pending';

  @override
  String get medicineReminderDeliveryStatusDelivered => 'Delivered';

  @override
  String get medicineReminderDeliveryStatusFailed => 'Failed';

  @override
  String get medicineReminderMissedStatus => 'Missed';

  @override
  String get medicineReminderSavedToast => 'Medication reminder saved.';

  @override
  String get medicineReminderDeletedToast => 'Medication reminder deleted.';

  @override
  String get medicineReminderMedicineRequiredToast => 'Choose a medicine.';

  @override
  String get medicineReminderTimeRequiredToast => 'Add at least one dose time.';

  @override
  String get medicineReminderWeekdayRequiredToast => 'Choose reminder days.';

  @override
  String get medicineReminderDateRangeInvalidToast =>
      'End date cannot be before start date.';

  @override
  String get medicineReminderDeleteAction => 'Delete this reminder';

  @override
  String get medicineReminderDeleteConfirmTitle => 'Delete this reminder?';

  @override
  String get medicineReminderDeleteConfirmBody =>
      'This cannot be restored. Dose history will stay.';

  @override
  String get medicineReminderConfirmDeleteAction => 'Delete';

  @override
  String get medicineReminderCancelAction => 'Cancel';

  @override
  String get medicineNoPendingDose => 'Today\'s medicines are done';

  @override
  String get medicineNoPendingDoseDetail => 'No pending dose reminders';

  @override
  String get medicineStatusStable => 'Stable routine';

  @override
  String get medicineMockNameAtorvastatin => 'Atorvastatin calcium';

  @override
  String get medicineMockDoseAtorvastatin => '20 mg';

  @override
  String get medicineMockScheduleDailyOnce => 'Once daily';

  @override
  String get medicineStatusNeedsCheckin => 'Stable routine';

  @override
  String get medicineMockNameOmeprazole => 'Omeprazole capsules';

  @override
  String get medicineMockDoseOmeprazole => '20 mg';

  @override
  String get medicineSafetyPanelTitle => 'Medication safety';

  @override
  String get medicineSafetyPanelSubtitle =>
      'High-risk alerts and adherence risk collect here.';

  @override
  String get medicineAlertInteractionTitle => 'Interaction warning';

  @override
  String get medicineAlertInteractionBody =>
      'Aspirin with ibuprofen may increase bleeding risk.';

  @override
  String get medicineAlertInteractionDetail =>
      'Use together only with clinical advice';

  @override
  String get medicineAlertInteractionAction => 'Review details';

  @override
  String get medicineAlertOtherTitle => 'Other safety reminder';

  @override
  String get medicineAlertOtherBody =>
      'Ibuprofen is not recommended for continuous use beyond 5 days';

  @override
  String get medicineAlertOtherDetail =>
      'Ask a clinician if longer use is needed';

  @override
  String get medicineAlertOtherAction => 'Review details';

  @override
  String get medicineAlertAlcoholRiskTitle => 'Alcohol note';

  @override
  String get medicineAlertAlcoholRiskBody =>
      'Guidance preview waits for medicine data';

  @override
  String get medicineAlertAlcoholRiskDetail =>
      'Show source-backed advice before treating this as a risk';

  @override
  String get medicineAlertAlcoholRiskStatus => 'Preview';

  @override
  String get medicineAlertCoffeeReminderTitle => 'Caffeine note';

  @override
  String get medicineAlertCoffeeReminderBody =>
      'Caffeine guidance needs source review';

  @override
  String get medicineAlertCoffeeReminderDetail =>
      'Some medicines can be affected by caffeine';

  @override
  String get medicineAlertCoffeeReminderStatus => 'Review';

  @override
  String get medicineAlertDuplicateCheckTitle => 'Duplicate source check';

  @override
  String get medicineAlertDuplicateCheckBody =>
      'Same-ingredient checks need source review';

  @override
  String get medicineAlertDuplicateCheckDetail =>
      'New medicines will trigger another source check';

  @override
  String get medicineAlertDuplicateCheckStatus => 'Preview';

  @override
  String get medicineAlertSpecialGroupSafetyTitle =>
      'Special-group medication safety';

  @override
  String get medicineAlertSpecialGroupSafetyBody =>
      'Record special medication conditions for more cautious safety tips';

  @override
  String get medicineAlertSpecialGroupSafetyDetail =>
      'Follow clinician or pharmacist guidance first for pregnancy, lactation, pediatric, or other special-group medication use';

  @override
  String get medicineAlertSpecialGroupSafetyStatus => 'Missing';

  @override
  String get medicinePromiseTitle => 'Safety boundary';

  @override
  String get medicinePromiseBody =>
      'This page should help surface risk early without pretending to be a diagnosis.';

  @override
  String get medicinePromisePointBoundary =>
      'Results are reference-only and do not replace diagnosis or treatment.';

  @override
  String get medicinePromisePointSpecialGroup =>
      'Pregnancy, lactation, pediatric, and psychiatric medicines get higher-priority alerts.';

  @override
  String get medicinePromisePointPrivacy =>
      'Prescriptions, photos, and sensitive medicine data follow minimum exposure first.';

  @override
  String get medicinePromisePointDiagnosis =>
      'We do not diagnose, replace clinicians, or invent medicine facts.';

  @override
  String get medicinePromiseAction => 'Learn more about safety';

  @override
  String get medicineViewPlanToast =>
      'This will open the full medication list and history.';

  @override
  String get medicineOpenPlanItemToast =>
      'This will open medicine details, reminders, and dose history.';

  @override
  String get medicineOpenPromiseToast =>
      'This will open safety boundaries, special-population alerts, and privacy notes.';

  @override
  String get medicineQuickActionCameraToast =>
      'This will open camera recognition for boxes, blisters, or labels.';

  @override
  String get medicineQuickActionBarcodeToast =>
      'This will open barcode scan and fill medicine information.';

  @override
  String get medicineQuickActionPrescriptionToast =>
      'This will open image import and prescription recognition.';

  @override
  String get medicineAlertInteractionToast =>
      'This will open interaction details and risk notes.';

  @override
  String get medicineAlertOtherToast =>
      'This will open other safety reminder details.';

  @override
  String get medicineAlertAlcoholRiskToast =>
      'This will open source notes for the alcohol preview.';

  @override
  String get medicineAlertCoffeeReminderToast =>
      'This will open source notes for the caffeine preview.';

  @override
  String get medicineAlertDuplicateCheckToast =>
      'This will open duplicate-source preview notes.';

  @override
  String get medicineAlertSpecialGroupSafetyToast =>
      'This will open special-group medication safety notes.';

  @override
  String get medicineSearchPageTitle => 'Search medicine';

  @override
  String get medicineSearchAssistantTitle => 'Medication assistant';

  @override
  String get medicineSearchMyBoxTab => 'My drugbox';

  @override
  String get medicineSearchFieldHint =>
      'Search medicine, ingredient, condition, symptom...';

  @override
  String get medicineSearchSourceCn => 'Package inserts (cn)';

  @override
  String get medicineSearchSourceDrugbank => 'Drug knowledge (DrugBank)';

  @override
  String get medicineSearchSwitchSource => 'Switch source';

  @override
  String get medicineSearchRecentTitle => 'Recent searches';

  @override
  String get medicineSearchClearAction => 'Clear';

  @override
  String get medicineSearchPhotoAction => 'Photo recognition';

  @override
  String get medicineSearchBarcodeAction => 'Scan barcode';

  @override
  String get medicineSearchPhotoToast =>
      'This will open camera recognition for boxes, blisters, or inserts.';

  @override
  String get medicineSearchBarcodeToast =>
      'This will open barcode scan and fill medicine information.';

  @override
  String get medicineSearchScanHint =>
      'This will open scan or photo recognition.';

  @override
  String get medicineSearchCategoryTitle => 'Common medicine categories';

  @override
  String get medicineSearchCategoryPainFever => 'Pain & fever';

  @override
  String get medicineSearchCategoryColdCough => 'Cold & cough';

  @override
  String get medicineSearchCategoryStomach => 'Stomach';

  @override
  String get medicineSearchCategorySupplement => 'Supplements';

  @override
  String get medicineSearchCategoryChronic => 'Chronic care';

  @override
  String get medicineSearchReferenceNotice =>
      'Medicine information is for reference only. Follow clinical advice for actual use.';

  @override
  String get medicineSearchResultTitle => 'Search results';

  @override
  String medicineSearchResultCount(int count) {
    return '$count results found';
  }

  @override
  String get medicineSearchMatchedBy => 'Matched';

  @override
  String get medicineSearchMatchIngredient => 'ingredient';

  @override
  String get medicineSearchMatchName => 'name';

  @override
  String get medicineSearchAddToBoxAction => 'Add to drugbox';

  @override
  String get medicineSearchAddToast =>
      'This will add the medicine and open reminder setup.';

  @override
  String get medicineSearchOpenDetailToast =>
      'This will open medicine details.';

  @override
  String get medicineSearchPreviewTitle => 'Selected preview';

  @override
  String get medicineSearchSafetyLead =>
      'Your allergy, special medication conditions, or current medicines may affect use.';

  @override
  String get medicineSearchSafetyAction =>
      'Open details for complete information';

  @override
  String get medicineSearchNoResultTitle => 'No result?';

  @override
  String get medicineSearchNoResultKeyword => 'Check keywords';

  @override
  String get medicineSearchNoResultSwitch => 'Switch source';

  @override
  String get medicineSearchErrorTitle => 'Search did not load this time';

  @override
  String get medicineSearchErrorDescription =>
      'Please check your network and try again.';

  @override
  String get mineSectionTitle => 'Personal workspace';

  @override
  String get mineSectionSubtitle =>
      'Identity, goals, and privacy controls will share one calm surface here.';

  @override
  String get mineHeaderNotifications => 'Notifications';

  @override
  String get mineHeaderSettings => 'Settings';

  @override
  String get mineAccountDisplayName => 'Lumi User';

  @override
  String get mineAccountGuestDisplayName => 'Guest';

  @override
  String get mineAccountSignedIn => 'Signed in';

  @override
  String get mineAccountSignedOut => 'Signed out';

  @override
  String get mineAccountMeta => 'Member until: 2026-05-20';

  @override
  String get mineAccountSignedOutMeta =>
      'Sign in to sync profile, reminders, and personalized health data';

  @override
  String get mineAccountManageAction => 'Manage account';

  @override
  String get mineAccountEmailVerified => 'Email verified';

  @override
  String get mineAccountEmailUnverified => 'Email unverified';

  @override
  String get mineAccountPasswordSet => 'Password set';

  @override
  String get mineAccountPasswordUnset => 'No password';

  @override
  String mineAccountLinkedIdentityCount(int count) {
    return '$count linked';
  }

  @override
  String get mineAccountLinkedIdentityNone => 'No linked identity';

  @override
  String mineAccountLastLogin(String date) {
    return 'Last login $date';
  }

  @override
  String get mineAccountLastLoginNone => 'Last login --';

  @override
  String get mineAccountStudentRole => 'Student';

  @override
  String get mineSignedOutNoticeTitle => 'You are not signed in';

  @override
  String get mineSignedOutNoticeDescription =>
      'Mine stays on the static layout while signed out so it does not keep hitting the backend. Sign in to load your profile and health context.';

  @override
  String get mineCompletionTitle => 'Profile completion';

  @override
  String get mineAlertAllergyTitle => 'Allergies';

  @override
  String get mineAlertAllergySubtitle => 'Pollen, penicillin';

  @override
  String get mineAlertAllergyBadge => '2 items';

  @override
  String get mineAlertMedicineTitle => 'Current meds';

  @override
  String get mineAlertMedicineSubtitle => '2 medicines';

  @override
  String get mineAlertMedicineBadge => 'On schedule';

  @override
  String get mineAlertPrivacyTitle => 'Sharing controls';

  @override
  String get mineAlertPrivacySubtitle => 'Preview before sharing';

  @override
  String get mineAlertPrivacyBadge => 'Confirm first';

  @override
  String get mineArchiveBasicTitle => 'Basic info';

  @override
  String get mineArchiveBasicSubtitle => 'Personal and health information';

  @override
  String get mineArchiveAllergyTitle => 'Allergies';

  @override
  String get mineArchiveAllergySubtitle =>
      'Food, medicine, and environment allergy records';

  @override
  String get mineArchiveMedicineTitle => 'Current meds';

  @override
  String get mineArchiveMedicineSubtitle =>
      'Active medicines and medication records';

  @override
  String get mineArchiveEmergencyTitle => 'Emergency contact';

  @override
  String get mineArchiveEmergencySubtitle => '1 contact';

  @override
  String get mineArchiveCompleted => 'Complete';

  @override
  String get mineArchiveNeedsFill => 'Needs info';

  @override
  String get mineCampusSectionTitle => 'Campus services';

  @override
  String get mineCampusHospitalTitle => 'Campus clinic';

  @override
  String get mineCampusHospitalSubtitle => 'Book an appointment';

  @override
  String get mineCampusSupportTitle => 'Student support';

  @override
  String get mineCampusSupportSubtitle => 'Campus support resources';

  @override
  String get mineCampusPharmacyTitle => 'Campus pharmacy';

  @override
  String get mineCampusPharmacySubtitle => 'Search campus medicines';

  @override
  String get mineCampusEmergencyTitle => 'Emergency help';

  @override
  String get mineCampusEmergencySubtitle => 'Hotlines and guides';

  @override
  String get minePrivacyReportTitle => 'Report sharing';

  @override
  String get minePrivacyReportSubtitle => 'Health reports and trend analysis';

  @override
  String get minePrivacyAiTitle => 'AI summaries and advice';

  @override
  String get minePrivacyAiSubtitle => 'Daily summaries, trend advice';

  @override
  String get minePrivacyOnlyMe => 'Only me';

  @override
  String get minePrivacyShareAfterGrant => 'Share after grant';

  @override
  String get mineReminderSectionTitle => 'Reminder settings';

  @override
  String get mineReminderMedicineTitle => 'Medication';

  @override
  String get mineReminderWaterTitle => 'Water';

  @override
  String get mineReminderSleepTitle => 'Sleep';

  @override
  String get mineReminderEnabled => 'Enabled';

  @override
  String get mineAccountSettingsTitle => 'Account and settings';

  @override
  String get mineSettingLanguageTitle => 'Language';

  @override
  String get mineSettingLanguageValue => 'English';

  @override
  String get mineSettingExportTitle => 'Data export';

  @override
  String get mineSettingExportValue => 'Export my health data';

  @override
  String get mineSettingHelpTitle => 'Help and feedback';

  @override
  String get mineSettingHelpValue => 'FAQ and feedback';

  @override
  String get mineSettingAboutTitle => 'About Luminous';

  @override
  String get mineSettingAboutValue => 'Version 1.2.0';

  @override
  String get minePrivacyNoticeTitle =>
      'Sensitive data is protected by default, and grants can be revoked anytime';

  @override
  String get minePrivacyNoticeAction => 'View privacy policy';

  @override
  String get mineProfileUnknownValue => '--';

  @override
  String mineProfileAgeYears(int age) {
    return '${age}y';
  }

  @override
  String mineProfileHeightCm(int height) {
    return '${height}cm';
  }

  @override
  String mineProfileMeta(String age, String height) {
    return '$age · $height';
  }

  @override
  String get mineCompletionSubtitle =>
      'Good progress. Keep filling it out for more precise suggestions.';

  @override
  String get mineSummaryTitle => 'Health context summary';

  @override
  String get mineSummaryUpdatedAt => 'Updated 2025-05-15';

  @override
  String get mineSummaryAge => 'Age';

  @override
  String get mineSummaryAllergies => 'Allergies';

  @override
  String get mineSummaryConditions => 'Conditions';

  @override
  String get mineSummaryMedicines => 'Current meds';

  @override
  String get mineSummaryMissingInfo =>
      'Missing info: birth date, height, unit system';

  @override
  String get mineSummaryCompleteAction => 'Complete';

  @override
  String get mineProfileTitle => 'Health profile';

  @override
  String get mineProfileBasicInfoTitle => 'Basic info';

  @override
  String get mineProfileBasicInfoSubtitle => 'Personal basics';

  @override
  String get mineProfileAllergiesTitle => 'Allergies';

  @override
  String get mineProfileAllergiesSubtitle => '2 records';

  @override
  String get mineProfileConditionsTitle => 'Conditions';

  @override
  String get mineProfileConditionsSubtitle => '1 record';

  @override
  String get mineProfileMedicinesTitle => 'Current meds';

  @override
  String get mineProfileMedicinesSubtitle => '3 medicines';

  @override
  String get mineSettingsThemeTitle => 'Theme mode';

  @override
  String get mineSettingsAccountTitle => 'Account and security';

  @override
  String get mineSettingsLanguageTitle => 'Language';

  @override
  String get mineSettingsNotificationsTitle => 'Notifications';

  @override
  String get settingsLanguageSystemLabel => 'Follow system';

  @override
  String get settingsLanguageChineseLabel => 'Simplified Chinese';

  @override
  String get settingsLanguageEnglishLabel => 'English';

  @override
  String get settingsThemeAppearanceTitle => 'Appearance';

  @override
  String get settingsThemePaletteTitle => 'Palette';

  @override
  String get settingsThemePaletteClassic => 'Default';

  @override
  String get settingsThemePaletteBluePink => 'Blue pink';

  @override
  String get settingsThemePaletteYellowGreen => 'Yellow green';

  @override
  String get settingsSyncFailed => 'Failed to sync settings';

  @override
  String get settingsNotificationsMedicationReminders => 'Medication reminders';

  @override
  String get settingsNotificationsHealthAlerts => 'Health alerts';

  @override
  String get settingsNotificationsWeeklySummary => 'Weekly summary';

  @override
  String get settingsNotificationsPermissionEnabled =>
      'System notifications are enabled';

  @override
  String get settingsNotificationsPermissionDisabled =>
      'System notifications are disabled';

  @override
  String get settingsNotificationsPermissionUnsupported =>
      'Notification permission status is unavailable on this platform';

  @override
  String get settingsNotificationsPermissionEnabledHint =>
      'Notifications are allowed. Preference toggles below control which types appear.';

  @override
  String get settingsNotificationsPermissionDisabledHint =>
      'Tap to open the system permission dialog. Notifications need system approval before local reminders can appear.';

  @override
  String get mineErrorTitle => 'Mine did not load this time';

  @override
  String get mineErrorDescription =>
      'The structure is wired. Retry the mock fetch once.';

  @override
  String mineActionToast(String action) {
    return '$action: this will open the related details or settings flow later.';
  }

  @override
  String get todaySectionTitle => 'Today workspace';

  @override
  String get todaySectionSubtitle =>
      'The new home will gradually attach reminders, snapshots, water tracking, and Lumi guidance here.';

  @override
  String get authWelcomeBack => 'Welcome back';

  @override
  String get authCreateAccount => 'Create account';

  @override
  String get authModePassword => 'Password';

  @override
  String get authModeCode => 'Code';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authEmailHint => 'name@example.com';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authPasswordHint =>
      'At least 8 characters, ideally with mixed case and numbers';

  @override
  String get authCodeLabel => 'Verification code';

  @override
  String get authNicknameLabel => 'Nickname';

  @override
  String get authNicknameHint => 'Optional';

  @override
  String get authEmailRequiredToast => 'Please enter your email.';

  @override
  String get authCodeRequiredToast => 'Please enter the verification code.';

  @override
  String get authPasswordRequiredToast => 'Please enter your password.';

  @override
  String get authConfirmPasswordRequiredToast =>
      'Please confirm your password.';

  @override
  String get authSendCode => 'Send code';

  @override
  String authSendCodeAgain(int seconds) {
    return 'Send again (${seconds}s)';
  }

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authWechatSignIn => 'Sign in with WeChat';

  @override
  String get authWechatAuthorizeOpened =>
      'WeChat authorization opened in your browser.';

  @override
  String get authWechatBrowserOpenFailed =>
      'Could not open the WeChat authorization page.';

  @override
  String get authWechatCallbackLabel => 'WeChat callback link / code';

  @override
  String get authWechatCallbackHint => 'Paste the callback URL after scanning';

  @override
  String get authWechatCompleteAction => 'Complete WeChat sign-in';

  @override
  String get authWechatCallbackRequiredToast =>
      'Paste the WeChat callback link first.';

  @override
  String get authWechatCallbackInvalidToast =>
      'The WeChat callback link is missing code or state.';

  @override
  String get authCreateAccountAction => 'Create account';

  @override
  String get authForgotPasswordPrompt => 'Forgot your password?';

  @override
  String get authResetPasswordAction => 'Reset password';

  @override
  String get authNeedAccountPrompt => 'Need an account?';

  @override
  String get authRegisterNowAction => 'Register now';

  @override
  String get authHaveAccountPrompt => 'Already have an account?';

  @override
  String get authRememberPasswordPrompt => 'Remember your password?';

  @override
  String get authNewPasswordLabel => 'New password';

  @override
  String get authConfirmPasswordLabel => 'Confirm password';

  @override
  String get authPasswordsDoNotMatch => 'Passwords do not match.';

  @override
  String get authResetPasswordSubmit => 'Reset password';

  @override
  String get authResetPasswordSuccess =>
      'Password updated. Please sign in again.';

  @override
  String get authChangeEmailFormTitle => 'Change email';

  @override
  String get authNewEmailLabel => 'New email';

  @override
  String get authChangeEmailSubmit => 'Update email';

  @override
  String get authChangeEmailSuccess => 'Email updated.';

  @override
  String get authAccountSettingsFormTitle => 'Account and security';

  @override
  String get authAccountOverviewTitle => 'Account status';

  @override
  String get authAccountOverviewEmail => 'Email';

  @override
  String get authAccountOverviewEmailVerified => 'Email verification';

  @override
  String get authAccountOverviewPassword => 'Password';

  @override
  String get authAccountOverviewLastLogin => 'Last login';

  @override
  String get authEmailMissing => 'Not set';

  @override
  String authEmailVerifiedAt(String time) {
    return 'Verified $time';
  }

  @override
  String get authEmailUnverifiedStatus => 'Unverified';

  @override
  String get authPasswordSetStatus => 'Set';

  @override
  String get authPasswordUnsetStatus => 'Not set';

  @override
  String get authLastLoginUnknown => 'Unknown';

  @override
  String get authProfileSectionTitle => 'Profile details';

  @override
  String get authProfileSectionDescription =>
      'Update nickname or avatar URL; leaving a field empty will clear it under the current Lucent rules.';

  @override
  String get authAvatarLabel => 'Avatar URL';

  @override
  String get authAvatarHint => 'https://example.com/avatar.png';

  @override
  String get authProfileSaveAction => 'Save profile';

  @override
  String get authProfileSaveSuccess => 'Profile updated.';

  @override
  String get authEmailSectionTitle => 'Login email';

  @override
  String get authEmailVerifiedDescription =>
      'This email is already verified, and you can continue to the change-email flow.';

  @override
  String get authEmailUnverifiedDescription =>
      'This email is still unverified; you can still continue to the change-email flow.';

  @override
  String get authEmailAddAction => 'Add email';

  @override
  String get authEmailChangeAction => 'Change email';

  @override
  String get authLinkedIdentitiesSectionTitle => 'Linked identities';

  @override
  String get authLinkedIdentityNone => 'No third-party identity linked.';

  @override
  String get authLinkedIdentityEmailMissing => 'No provider email';

  @override
  String authLinkedIdentityLinkedAt(String date) {
    return 'Linked $date';
  }

  @override
  String get authIdentityProviderWechatWeb => 'WeChat Web';

  @override
  String get authIdentityProviderWechatMobile => 'WeChat Mobile';

  @override
  String get authIdentityUnlinkAction => 'Unlink';

  @override
  String get authIdentityUnlinkDisabledAction => 'Keep';

  @override
  String get authIdentityUnlinkSuccess => 'Identity unlinked.';

  @override
  String get authIdentityUnlinkConfirmTitle => 'Unlink identity';

  @override
  String authIdentityUnlinkConfirmMessage(String provider) {
    return 'Unlink $provider from this account?';
  }

  @override
  String get authIdentityLinkWechatAction => 'Link WeChat';

  @override
  String get authIdentityLinkSuccess => 'WeChat identity linked.';

  @override
  String get authIdentityLinkUnsupported =>
      'WeChat linking cannot be opened on this platform.';

  @override
  String get authCancelAction => 'Cancel';

  @override
  String get authPasswordSectionTitle => 'Change password';

  @override
  String get authPasswordSectionDescription =>
      'Changing the password invalidates all refresh sessions for this account, so you will need to sign in again.';

  @override
  String get authPasswordUnsetManagementHint =>
      'This account does not have a local password yet.';

  @override
  String get authCurrentPasswordLabel => 'Current password';

  @override
  String get authCurrentPasswordRequiredToast =>
      'Please enter your current password.';

  @override
  String get authNewPasswordRequiredToast => 'Please enter your new password.';

  @override
  String get authChangePasswordAction => 'Update password';

  @override
  String get authChangePasswordSuccess =>
      'Password updated. Please sign in again.';

  @override
  String get authDeleteAccountSectionTitle => 'Delete account';

  @override
  String get authDeleteAccountSectionDescription =>
      'This is a high-risk action; submitting it clears the local session and asks Lucent to soft-delete the account.';

  @override
  String get authDeleteAccountPasswordRequiredHint =>
      'This account cannot be deleted from here yet.';

  @override
  String get authDeleteAccountHint =>
      'Enter your current password to confirm deletion';

  @override
  String get authDeleteAccountAction => 'Delete account';

  @override
  String get authDeleteAccountSuccess => 'Account deleted.';

  @override
  String get authBackHomePrompt => 'Back to home?';

  @override
  String get authCheckingSession => 'Checking session...';

  @override
  String get authNotSignedIn => 'Not signed in yet';

  @override
  String get authLoginRequiredPrompt => 'Go to sign in';

  @override
  String get authGoLogin => 'Sign in';

  @override
  String get authGoRegister => 'Create account';

  @override
  String get authSignOut => 'Sign out';

  @override
  String get todayHeroTitle => 'Today';

  @override
  String get todayHeroDescription =>
      'The new home starts here: we are rebuilding the responsive visual system first, then layering in water tracking, reminders, health snapshots, and Lumi guidance.';

  @override
  String get todayChipWater => 'Water Tracking';

  @override
  String get todayChipMedication => 'Medication Reminders';

  @override
  String get todayChipSnapshot => 'Health Snapshot';

  @override
  String get todayChipDiet => 'Diet Suggestions';

  @override
  String get todayChipEnvironment => 'Environment Alerts';

  @override
  String get todayChipLumi => 'Lumi Guidance';

  @override
  String get todayNotificationsTooltip => 'Notifications';

  @override
  String get todayGreetingTitleMorning => 'Good morning, the light is perfect';

  @override
  String get todayGreetingTitleAfternoon =>
      'Good afternoon, keep the rhythm steady';

  @override
  String get todayGreetingTitleEvening => 'Good evening, let\'s close gently';

  @override
  String get todayGreetingSubtitleMorning =>
      'Good morning. Take care of yourself today.';

  @override
  String get todayGreetingSubtitleAfternoon =>
      'Good afternoon. Take care of yourself today.';

  @override
  String get todayGreetingSubtitleEvening =>
      'Good evening. Take care of yourself today.';

  @override
  String get todayHeroCareLine =>
      'When you need a nudge, we will keep it timely and gentle.';

  @override
  String get todayHeroImagePlaceholder => 'Banner image placeholder';

  @override
  String get todayWaterCardTitle => 'Today\'s water';

  @override
  String get todayWaterUnit => 'times';

  @override
  String todayWaterCount(int count) {
    return '$count times';
  }

  @override
  String todayWaterGoalCount(int count) {
    return 'Goal $count times';
  }

  @override
  String todayWaterOverviewCount(int done, int target) {
    return '$done/$target times';
  }

  @override
  String todayWaterRemainingCount(int count) {
    return '$count more to go';
  }

  @override
  String get todayMedicationCardTitle => 'Medication reminder';

  @override
  String get todayMedicationAction => 'View';

  @override
  String todayMedicationSummary(int medicineCount, int pendingCount) {
    return '$medicineCount medicines · $pendingCount pending';
  }

  @override
  String todayMedicationNextDose(String time, String medicineName) {
    return 'Next at $time · $medicineName';
  }

  @override
  String get todayMedicationNameAtorvastatin => 'Atorvastatin';

  @override
  String get todayMedicationNameVitaminBComplex => 'Vitamin B complex';

  @override
  String get todayHealthSummaryCardTitle => 'Today summary';

  @override
  String get todayVitalHeartRateLabel => 'Heart rate';

  @override
  String get todayVitalHeartRateUnit => 'bpm';

  @override
  String get todayVitalBloodPressureLabel => 'Blood pressure';

  @override
  String get todayVitalSleepLabel => 'Sleep';

  @override
  String get todayVitalSleepUnit => 'h';

  @override
  String get todaySleepFallbackValue => '7.2';

  @override
  String get todayVitalStatusNormal => 'Normal';

  @override
  String get todayVitalStatusGood => 'Good';

  @override
  String get todayMealCardTitle => 'Today\'s meal suggestion';

  @override
  String get todayMealHighProteinBalancedTitle => 'High-protein balanced bowl';

  @override
  String get todayMealHighProteinBalancedDescription =>
      'Chicken breast, quinoa, and seasonal salad';

  @override
  String get todayMealEnergyHint =>
      'Add quality protein and balanced nutrition for steady energy.';

  @override
  String get todayMealImagePlaceholder => 'Meal image placeholder';

  @override
  String get todayMealRefreshAction => 'Refresh';

  @override
  String get todayEnvironmentCardTitle => 'Environment signals';

  @override
  String get todayEnvironmentPollenLabel => 'Pollen';

  @override
  String get todayEnvironmentUvLabel => 'UV';

  @override
  String get todayEnvironmentLevelLow => 'Low';

  @override
  String get todayEnvironmentLevelMedium => 'Medium';

  @override
  String get todayEnvironmentLevelHigh => 'High';

  @override
  String get todayMoreAction => 'More';

  @override
  String get todayViewDetailsAction => 'Details';

  @override
  String get todayLumiCardTitle => 'Lumi note';

  @override
  String get todayPreviewBadge => 'Preview';

  @override
  String get todayLumiPollenProtectionBody =>
      'Pollen is elevated today. Consider a mask outdoors and reduce respiratory irritation where possible.';

  @override
  String get todayLumiAction => 'View details';

  @override
  String get todayErrorTitle => 'Today did not load this time';

  @override
  String get todayErrorDescription =>
      'The mock provider and page structure are wired up, so try fetching it again.';

  @override
  String get todayEmptyTitle => 'No records yet';

  @override
  String get todayEmptyDescription =>
      'Log water, medication, or sleep first, then we can shape personalized suggestions.';

  @override
  String get todayEmptyAction => 'Start logging';

  @override
  String get todayRetryAction => 'Retry';

  @override
  String todayUpdatedAt(String time) {
    return 'Updated at $time';
  }

  @override
  String get todayHydrationOverviewLabel => 'Water';

  @override
  String get todayMedicationOverviewLabel => 'Medication';

  @override
  String get todayStatusNeedsImprovement => 'Needs lift';

  @override
  String get todayStatusCompleted => 'Completed';

  @override
  String get todayMedicationPendingStatus => 'Pending';

  @override
  String get todayPrioritySectionTitle => 'Today\'s priorities';

  @override
  String get todayManageAction => 'Manage';

  @override
  String todayMedicationPrioritySubtitle(int count) {
    return '$count pending today';
  }

  @override
  String todayMedicationPriorityDetail(String time, String medicineName) {
    return '$time $medicineName';
  }

  @override
  String get todayMedicationTakeAction => 'Take now';

  @override
  String get todayWaterPriorityTitle => 'Water goal';

  @override
  String get todayDrinkWaterAction => 'Drink water';

  @override
  String get todayAiSummaryTitle => 'AI daily summary';

  @override
  String get todayAiSummarySubtitle => 'Generated from today\'s records';

  @override
  String get todayAiSummaryGenerateAction => 'Generate';

  @override
  String todayAiSummaryMedicationPending(int count) {
    return '$count medication items still need confirmation. Do not adjust doses casually';
  }

  @override
  String get todayAiSummaryMedicationDone =>
      'Medication todos are handled today. Check risks when adding a new medicine';

  @override
  String todayAiSummaryWaterRemaining(int count) {
    return '$count water check-ins left. Spread them across the day';
  }

  @override
  String get todayAiSummaryWaterDone =>
      'Today\'s water check-ins are complete. Keep taking small amounts often';

  @override
  String get todayAiSummarySleepPlaceholder =>
      'Record sleep to include it in today\'s summary';

  @override
  String get todayRecommendationSectionTitle => 'Proactive advice';

  @override
  String get todayViewMoreAction => 'View more';

  @override
  String get todayRecommendationMedicineSafetyTitle => 'Medication safety tips';

  @override
  String get todayRecommendationMedicineSafetyBody =>
      'Take medicines on time and do not adjust doses casually';

  @override
  String get todayRecommendationSleepTitle => 'Wind down before sleep';

  @override
  String get todayRecommendationSleepBody =>
      'Reduce blue light one hour before bed and relax your body';

  @override
  String get todayRecommendationWaterTitle => 'Drink small amounts often';

  @override
  String get todayRecommendationWaterBody =>
      'Staying hydrated supports focus and metabolism';

  @override
  String get todayRecommendationCoffeeTitle => 'Keep caffeine timed';

  @override
  String get todayRecommendationCoffeeBody =>
      'Avoid it after 3 PM when possible to protect sleep quality';

  @override
  String get todayLearnMoreAction => 'Learn more';

  @override
  String get todayCompleteAction => 'Complete';

  @override
  String get todayTodoSectionTitle => 'Today\'s todos';

  @override
  String get todayTodoAddAction => 'Add';

  @override
  String get todayTodoSourceSystem => 'System';

  @override
  String get todayTodoSourceUser => 'User';

  @override
  String get todayTodoMedicationTitle => 'Medication reminder';

  @override
  String todayTodoMedicationSubtitle(String time, String medicineName) {
    return 'Next at $time $medicineName';
  }

  @override
  String get todayTodoWaterTitle => 'Hydration';

  @override
  String todayTodoWaterSubtitle(int progress) {
    return 'Today $progress%';
  }

  @override
  String get todayTodoCustomTitle => 'Custom todo';

  @override
  String get todayTodoCustomSubtitle =>
      'Add follow-up, rest, or custom reminders';

  @override
  String placeholderSoon(String label) {
    return '$label · Coming Soon';
  }

  @override
  String get placeholderDescription =>
      'This area is reserved structurally and will be rebuilt with the new multi-platform design system.';

  @override
  String get mineThemeModeSystem => 'System';

  @override
  String get mineThemeModeLight => 'Light';

  @override
  String get mineThemeModeDark => 'Dark';

  @override
  String get medicineSearchPreviewClinical => 'Clinical Notes';

  @override
  String get medicineSearchPreviewSafety => 'Safety Checklist';

  @override
  String get medicineSearchPreviewEmpty => 'Select a medicine to view details';

  @override
  String medicineSearchSourceRefCn(String id) {
    return 'Approval No. $id';
  }

  @override
  String medicineSearchSourceRefDrugbank(String id) {
    return 'DrugBank ID: $id';
  }

  @override
  String get mineEditProfileTitle => 'Edit Profile';

  @override
  String get mineEditAllergyTitle => 'Edit Allergy';

  @override
  String get mineEditAllergyNewTitle => 'New Allergy';

  @override
  String get mineEditConditionTitle => 'Edit Condition';

  @override
  String get mineEditConditionNewTitle => 'New Condition';

  @override
  String get mineEditMedicineTitle => 'Edit Medicine';

  @override
  String get mineEditMedicineNewTitle => 'New Medicine';

  @override
  String get mineEditSaveAction => 'Save';

  @override
  String get mineEditDeleteAction => 'Delete';

  @override
  String get mineEditSavedToast => 'Saved';

  @override
  String get mineEditDeletedToast => 'Deleted';

  @override
  String get mineEditFieldBirthDate => 'Birth date (YYYY-MM-DD)';

  @override
  String get mineEditFieldHeightCm => 'Height (cm)';

  @override
  String get mineEditFieldBloodType => 'Blood type';

  @override
  String get mineEditFieldLocale => 'Locale';

  @override
  String get mineEditFieldTimezone => 'Timezone';

  @override
  String get mineEditFieldUnitSystem => 'Unit system';

  @override
  String get mineEditFieldOnboardingCompleted => 'Onboarding completed';

  @override
  String get mineEditFieldKind => 'Kind';

  @override
  String get mineEditFieldLabel => 'Label';

  @override
  String get mineEditFieldReaction => 'Reaction';

  @override
  String get mineEditFieldSeverity => 'Severity';

  @override
  String get mineEditFieldNote => 'Note';

  @override
  String get mineEditFieldRecordedAt => 'Recorded at';

  @override
  String get mineEditFieldStatus => 'Status';

  @override
  String get mineEditFieldDiagnosedAt => 'Diagnosed at (YYYY-MM-DD)';

  @override
  String get mineEditFieldSource => 'Source';

  @override
  String get mineEditFieldSourceRefId => 'Source ref ID';

  @override
  String get mineEditFieldDisplayName => 'Display name';

  @override
  String get mineEditFieldStrengthText => 'Strength';

  @override
  String get mineEditFieldDoseText => 'Dose';

  @override
  String get mineEditFieldRoute => 'Route';

  @override
  String get mineEditFieldStartedAt => 'Started at (YYYY-MM-DD)';

  @override
  String get mineEditFieldEndedAt => 'Ended at (YYYY-MM-DD)';

  @override
  String get reportWeekDateRange => 'May 19 - May 25';

  @override
  String get reportPeriodThisWeek => 'This week';

  @override
  String get reportGenerateAction => 'Preview report';

  @override
  String get reportSyncAction => 'Sync';

  @override
  String get reportSnapshotStatus => 'Showing the last report snapshot';

  @override
  String get reportSnapshotHint => 'Preview or sync to update';

  @override
  String get reportScoreTitle => 'Report preview score';

  @override
  String reportScoreOutOf(int max) {
    return 'preview / $max';
  }

  @override
  String get reportStatusOverallStable => 'Demo snapshot';

  @override
  String get reportScoreBody => 'Preview only until report data is connected';

  @override
  String get reportMetricMedicationTitle => 'Medication';

  @override
  String get reportMetricSleepTitle => 'Sleep';

  @override
  String get reportMetricWaterTitle => 'Water';

  @override
  String get reportUnitPercent => '%';

  @override
  String get reportUnitHour => 'hours';

  @override
  String get reportUnitLiter => 'L';

  @override
  String get reportStatusGood => 'Good';

  @override
  String get reportStatusNeedsImprove => 'Needs lift';

  @override
  String get reportStatusStable => 'Stable';

  @override
  String get reportDeltaMedication => '9%';

  @override
  String get reportDeltaSleep => '0.6';

  @override
  String get reportDeltaWater => '0.2';

  @override
  String get reportTrendSectionTitle => 'Health trends';

  @override
  String get reportRangeLast7Days => 'Last 7 days';

  @override
  String get reportTrendSleepLabel => 'Sleep (h)';

  @override
  String get reportTrendWaterLabel => 'Water (L)';

  @override
  String get reportTrendMedicationLabel => 'Medication (%)';

  @override
  String get reportTrendDateLabels => '5/19|5/20|5/21|5/22|5/23|5/24|5/25';

  @override
  String get reportViewDetailsAction => 'View detailed data';

  @override
  String get reportFindingsSectionTitle => 'Key findings';

  @override
  String get reportFindingCoffeeTitle => 'Caffeine affects sleep';

  @override
  String get reportFindingCoffeeBody =>
      'Sleep duration dropped after afternoon coffee.';

  @override
  String get reportFindingMedicineTitle => 'Medication routine is steady';

  @override
  String get reportFindingMedicineBody =>
      'Medication was taken on time for seven consecutive days.';

  @override
  String get reportAiSummaryTitle => 'Summary';

  @override
  String get reportAiSummarySubtitle =>
      'Smart analysis based on this week\'s records';

  @override
  String get reportViewAdviceAction => 'View advice';

  @override
  String get reportAiBulletSleep =>
      'Sleep quality was good overall, with slight weekend variation. A steady routine can help energy.';

  @override
  String get reportAiBulletWater =>
      'Water completion was moderate, with a few lower days. Carry water and drink small amounts often.';

  @override
  String get reportAiBulletMedicine =>
      'Medication adherence stayed high. Keep the on-time routine.';

  @override
  String get reportAiBulletDiet =>
      'Meals were mostly balanced, but fruit and vegetable intake could increase.';

  @override
  String get reportExportSectionTitle => 'Export summary';

  @override
  String get reportExportHospitalTitle => 'For clinic';

  @override
  String get reportExportHospitalSubtitle => 'Export health summary';

  @override
  String get reportExportMonthlyTitle => 'Monthly report';

  @override
  String get reportExportMonthlySubtitle => 'PDF format';

  @override
  String get reportExportPrintTitle => 'Print preview';

  @override
  String get reportExportPrintSubtitle => 'Paper preview';

  @override
  String get reportPatternSectionTitle => 'Health pattern analysis';

  @override
  String get reportPatternDietWaterTitle => 'Diet and water';

  @override
  String get reportPatternDietWaterStatus => 'Good pairing';

  @override
  String get reportPatternDietWaterBody =>
      'Energy is easier to keep steady when hydration is enough.';

  @override
  String get reportPatternMedicationTitle => 'Medication adherence';

  @override
  String get reportPatternMedicationStatus => 'Excellent';

  @override
  String get reportPatternMedicationBody =>
      'Taking medicine on time helps maintain health status.';

  @override
  String get reportReferenceNotice =>
      'This report is for reference only and is not diagnosis or treatment advice.';

  @override
  String reportActionToast(String action) {
    return '$action: this will open the related action later.';
  }

  @override
  String get reportErrorTitle => 'Report did not load this time';

  @override
  String get reportErrorDescription =>
      'The mock data boundary is wired, so try fetching it again.';

  @override
  String get mineSettingsAdvancedTitle => 'Advanced settings';

  @override
  String get settingsAdvancedClearImageCache => 'Clear image cache';

  @override
  String get settingsAdvancedCacheCleared => 'Image cache cleared';

  @override
  String get settingsAdvancedResetDefaults => 'Reset defaults';

  @override
  String get settingsAdvancedDefaultsReset => 'Defaults restored';

  @override
  String get settingsAdvancedOpenSourceLicenses => 'Open source licenses';

  @override
  String get reportPatternSleepTitle => 'Sleep changes';

  @override
  String get reportPatternSleepStatus => 'Watch trend';

  @override
  String get reportPatternSleepBody =>
      'Evening caffeine and schedule changes may affect sleep';
}
