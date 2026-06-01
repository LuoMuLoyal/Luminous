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
  String get tabMine => 'Mine';

  @override
  String get tabMore => 'More';

  @override
  String get desktopSidebarSettings => 'Settings';

  @override
  String get desktopSidebarHelp => 'Help';

  @override
  String get desktopSidebarSettingsToast => 'This will open settings.';

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
  String get recordAddAction => 'Record';

  @override
  String get recordAddCompactAction => 'Record';

  @override
  String get recordQuickSectionTitle => 'Quick record';

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
  String get recordFilterSelectAll => 'Select all';

  @override
  String get recordAllTypesAction => 'All types';

  @override
  String get recordEditAction => 'Edit';

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
  String get recordTypeWomenHealth => 'Women\'s health';

  @override
  String get recordTypeHeartRate => 'Heart rate';

  @override
  String get recordTypeWeight => 'Weight';

  @override
  String get recordQuickWomenSubtitle => 'Off';

  @override
  String get recordSummaryMealTitle => 'Meal records';

  @override
  String get recordSummaryWaterTitle => 'Water progress';

  @override
  String get recordSummaryLatestVitalTitle => 'Latest vital';

  @override
  String get recordSummaryMoodTitle => 'Mood record';

  @override
  String get recordSummaryActivityTitle => 'Activity completion';

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
  String get recordTimelineHeartRateDetail => '72 bpm · source: watch · normal';

  @override
  String get recordTimelineActivityWalk => 'Activity · Brisk walk';

  @override
  String get recordTimelineActivityDetail => '30 min · 2.6 km · 180 kcal';

  @override
  String get recordTimelineWeightDetail => 'Source: smart scale · BMI 22.5';

  @override
  String get recordTrendBloodSugarTitle => 'Meal-blood sugar';

  @override
  String get recordTrendBloodSugarLegend => 'Post-meal glucose (mmol/L)';

  @override
  String get recordTrendSleepMoodTitle => 'Mood-sleep';

  @override
  String get recordTrendSleepLegend => 'Sleep duration (hours)';

  @override
  String get recordTrendMoodLegend => 'Mood score';

  @override
  String get recordTrendHydrationTitle => 'Water completion';

  @override
  String get recordRange7Days => 'Last 7 days';

  @override
  String get recordRange30Days => 'Last 30 days';

  @override
  String get recordHealthBagTitle => 'Specialist health bag';

  @override
  String get recordHealthBagBody =>
      'Review and manage dental, eye, hearing, and other specialist reports';

  @override
  String get recordHealthBagLatest => 'Last updated: 2025-05-10';

  @override
  String get recordHealthBagNext => 'Next review: 2025-06-15';

  @override
  String get recordFoodImagePlaceholder => 'Meal image placeholder';

  @override
  String get medicinePageDescription =>
      'Photo recognition, barcode scan, manual search, dosing plans, and safety signals come together here as an API-ready medication workspace.';

  @override
  String get medicineSectionTitle => 'Medication workspace';

  @override
  String get medicineSectionSubtitle =>
      'This section will host the rebuilt medication flow on top of Lucent.';

  @override
  String get medicineHeaderActionSearch => 'Search medicine';

  @override
  String get medicineHeaderActionAdd => 'Add medicine';

  @override
  String get medicineHeaderActionSearchCompact => 'Search';

  @override
  String get medicineHeaderActionAddCompact => 'Add';

  @override
  String get medicineHeaderAddToast =>
      'This will open medicine addition and recognition.';

  @override
  String get medicineHeroEyebrow => 'PERSONAL DRUGBOX';

  @override
  String get medicineHeroTitle =>
      'See today\'s medicines, risks, and refill rhythm clearly first.';

  @override
  String get medicineHeroSubtitle =>
      'Photo recognition, barcode scan, manual search, and medication safety start here with a clear reference-only boundary.';

  @override
  String get medicineHeroMetricTodayCountValue => '2';

  @override
  String get medicineHeroMetricTodayCountLabel => 'Doses today';

  @override
  String get medicineHeroMetricTodayCountUnit => ' meds';

  @override
  String get medicineHeroMetricAdherenceValue => '100%';

  @override
  String get medicineHeroMetricAdherenceLabel => 'On-time adherence';

  @override
  String get medicineHeroMetricAdherenceUnit => '%';

  @override
  String get medicineHeroMetricNextDoseValue => '20:00';

  @override
  String get medicineHeroMetricNextDoseLabel => 'Next reminder';

  @override
  String get medicineHeroBannerTitle => 'Safety boundary first';

  @override
  String get medicineHeroBannerBody =>
      'Recognition results, interactions, and special-population alerts stay clearly marked as reference-only so AI output is not mistaken for diagnosis.';

  @override
  String get medicineQuickActionSectionTitle => 'Recognition and intake';

  @override
  String get medicineQuickActionSectionSubtitle =>
      'Bring medicines in first, then layer reminders, safety checks, and refill workflows on top.';

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
  String get medicineTodayPlanSubtitle =>
      'Mock data is enough to lock the rhythm, stock position, and risk placement first.';

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
  String get medicineDoseStatusPending => 'Pending';

  @override
  String get medicineMockStock7Days => '7 days left';

  @override
  String get medicineStatusStable => 'Stable routine';

  @override
  String get medicineMockNameAtorvastatin => 'Atorvastatin calcium';

  @override
  String get medicineMockDoseAtorvastatin => '20 mg';

  @override
  String get medicineMockScheduleDailyOnce => 'Once daily';

  @override
  String get medicineMockStock15Days => '15 days left';

  @override
  String get medicineStatusNeedsCheckin => 'Stable routine';

  @override
  String get medicineMockNameOmeprazole => 'Omeprazole capsules';

  @override
  String get medicineMockDoseOmeprazole => '20 mg';

  @override
  String get medicineMockStock3Days => '3 days left';

  @override
  String get medicineStatusNeedRefillSoon => 'Needs attention';

  @override
  String get medicineStockWarningLow => 'Stock is low. Refill soon.';

  @override
  String get medicineSafetyPanelTitle => 'Safety and refill';

  @override
  String get medicineSafetyPanelSubtitle =>
      'High-risk alerts, near-empty stock, and adherence risk collect here.';

  @override
  String get medicineAlertRefillTitle => 'Refill reminder';

  @override
  String get medicineAlertRefillBody => 'Vitamin D softgels have 3 days left';

  @override
  String get medicineAlertRefillDetail => 'Refill soon to avoid interruption';

  @override
  String get medicineAlertRefillAction => 'Refill now';

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
  String get medicinePromiseTitle => 'Safety boundary';

  @override
  String get medicinePromiseBody =>
      'This page should help surface risk early without pretending to be a diagnosis.';

  @override
  String get medicinePromisePointBoundary =>
      'Results are reference-only and do not replace diagnosis or treatment.';

  @override
  String get medicinePromisePointPregnancy =>
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
  String get medicineAlertRefillToast =>
      'This will open refill and stock details.';

  @override
  String get medicineAlertInteractionToast =>
      'This will open interaction details and risk notes.';

  @override
  String get medicineAlertOtherToast =>
      'This will open other safety reminder details.';

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
      'Your allergy, pregnancy status, or current medicines may affect use.';

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
  String get medicineSearchNoResultScan => 'Photo or scan';

  @override
  String get medicineSearchErrorTitle => 'Search did not load this time';

  @override
  String get medicineSearchErrorDescription =>
      'Please check your network and try again.';

  @override
  String get minePageDescription =>
      'Profile, goals, privacy, and account settings will be rebuilt here.';

  @override
  String get mineSectionTitle => 'Personal workspace';

  @override
  String get mineSectionSubtitle =>
      'Identity, goals, and privacy controls will share one calm surface here.';

  @override
  String get mineHeaderNotifications => 'Notifications';

  @override
  String get mineHeaderSettings => 'Page settings';

  @override
  String get mineAccountDisplayName => 'Lumi User';

  @override
  String get mineAccountSignedIn => 'Signed in';

  @override
  String get mineAccountMeta => 'Member until: 2026-05-20';

  @override
  String get mineCompletionTitle => 'Profile completion';

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
      'Missing info: birth date, sex, unit system, pregnancy/lactation state';

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
  String get mineProfileWomenTitle => 'Women / pregnancy';

  @override
  String get mineProfileWomenSubtitle => 'Not filled';

  @override
  String get mineProfileSpecialistTitle => 'Specialist bag';

  @override
  String get mineProfileSpecialistSubtitle =>
      'Dental, vision, hearing, and more';

  @override
  String get mineProfileLifestyleTitle => 'Lifestyle';

  @override
  String get mineProfileLifestyleSubtitle => 'Diet, exercise, sleep';

  @override
  String get mineProfileFamilyTitle => 'Family history';

  @override
  String get mineProfileFamilySubtitle => 'Genetic and family conditions';

  @override
  String get minePlansTitle => 'Health plan center';

  @override
  String get minePlansViewAll => 'View all';

  @override
  String get minePlanBloodSugarTitle => 'Blood sugar plan';

  @override
  String get minePlanBloodSugarStatus => 'In progress';

  @override
  String get minePlanBloodSugarDetail => '12 days in';

  @override
  String get minePlanWeightTitle => 'Weight plan';

  @override
  String get minePlanWeightStatus => 'Not started';

  @override
  String get minePlanWeightDetail => 'Set goal';

  @override
  String get minePlanSleepTitle => 'Sleep plan';

  @override
  String get minePlanSleepStatus => 'In progress';

  @override
  String get minePlanSleepDetail => 'Improving sleep';

  @override
  String get minePlanMoodTitle => 'Mood stability plan';

  @override
  String get minePlanMoodStatus => 'Not started';

  @override
  String get minePlanMoodDetail => 'Focus on emotional health';

  @override
  String get minePlanPregnancyTitle => 'Pre-pregnancy plan';

  @override
  String get minePlanPregnancyStatus => 'Not started';

  @override
  String get minePlanPregnancyDetail => 'Prepare with science';

  @override
  String get mineReportTitle => 'Health report';

  @override
  String get mineReportBody =>
      'Weekly/monthly reports, trend reviews, and health insights';

  @override
  String get mineReportMeta => 'Last generated: 2025-05-12';

  @override
  String get mineReportAction => 'View report';

  @override
  String get minePrivacyTitle => 'Privacy control';

  @override
  String get minePrivacyBody =>
      'Data visibility, sharing grants, and cloud sync scope';

  @override
  String get minePrivacyMeta => '8 sensitive data groups protected';

  @override
  String get minePrivacyAction => 'Manage privacy';

  @override
  String get mineStatusPanelTitle => 'Profile status';

  @override
  String get mineStatusBasicTitle => 'Basic info';

  @override
  String get mineStatusBasicValue => '1/4 complete';

  @override
  String get mineStatusAllergiesTitle => 'Allergies';

  @override
  String get mineStatusAllergiesValue => '2 items';

  @override
  String get mineStatusConditionsTitle => 'Conditions';

  @override
  String get mineStatusConditionsValue => '1 item';

  @override
  String get mineStatusMedicinesTitle => 'Current meds';

  @override
  String get mineStatusMedicinesValue => '3 meds';

  @override
  String get mineStatusWomenTitle => 'Pregnancy/lactation';

  @override
  String get mineStatusWomenValue => 'Missing';

  @override
  String get mineOnboardingTitle => 'Onboarding progress';

  @override
  String get mineOnboardingBasicTitle => 'Basic info';

  @override
  String get mineOnboardingContextTitle => 'Health context';

  @override
  String get mineOnboardingMedicineTitle => 'Medication setup';

  @override
  String get mineOnboardingGoalTitle => 'Health goals';

  @override
  String get mineOnboardingPrivacyTitle => 'Privacy setup';

  @override
  String mineOnboardingProgress(int completed, int total) {
    return '$completed/$total complete';
  }

  @override
  String get mineQuickEntriesTitle => 'Quick entries';

  @override
  String get mineQuickExportTitle => 'Export health data';

  @override
  String get mineQuickExportSubtitle => 'Download a health data copy';

  @override
  String get mineQuickDoctorTitle => 'Share with doctor';

  @override
  String get mineQuickDoctorSubtitle => 'Grant access to health details';

  @override
  String get mineQuickEmergencyTitle => 'Emergency contact';

  @override
  String get mineQuickEmergencySubtitle => '1 contact configured';

  @override
  String get mineSettingsSectionTitle => 'Settings and support';

  @override
  String get mineSettingsPanelTitle => 'Settings';

  @override
  String get mineSettingsThemeTitle => 'Theme mode';

  @override
  String get mineSettingsThemeValue => 'Follow system';

  @override
  String get mineSettingsAccountTitle => 'Account and security';

  @override
  String get mineSettingsLanguageTitle => 'Language';

  @override
  String get mineSettingsLanguageValue => 'Simplified Chinese';

  @override
  String get mineSettingsNotificationsTitle => 'Notifications';

  @override
  String get mineSettingsMoreTitle => 'More settings';

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
  String get morePageDescription =>
      'Utility tools, emergency help, device management, and lower-frequency features belong here.';

  @override
  String get moreSectionTitle => 'Utility hub';

  @override
  String get moreSectionSubtitle =>
      'This tab will gather the lower-frequency but still important workflows.';

  @override
  String get moreHeaderNotifications => 'Notifications';

  @override
  String get moreHeaderSupport => 'Support';

  @override
  String get moreEmergencySectionTitle => 'Emergency help';

  @override
  String get moreFamilySectionTitle => 'Family health';

  @override
  String get moreAiSectionTitle => 'AI recognition toolbox';

  @override
  String get moreDeviceSectionTitle => 'Smart device management';

  @override
  String get moreKnowledgeSectionTitle => 'Knowledge and services';

  @override
  String get moreEnvironmentSectionTitle =>
      'Environment and health reminder center';

  @override
  String get moreEnvironmentMoreAction => 'More';

  @override
  String get moreRecentSectionTitle => 'Recent activity';

  @override
  String get moreRecentViewAllAction => 'View all';

  @override
  String get moreQuickSectionTitle => 'Quick entries';

  @override
  String get moreCareNoteTitle => 'Care note';

  @override
  String get moreEmergencySosTitle => 'SOS emergency help';

  @override
  String get moreEmergencySosSubtitle =>
      'One tap away. Reach emergency contacts quickly.';

  @override
  String get moreEmergencyMentalHotlineTitle => 'Mental health hotline';

  @override
  String get moreEmergencyMentalHotlineSubtitle =>
      '24h emotional support and crisis intervention.';

  @override
  String get moreEmergencyLockscreenTitle => 'Lock-screen medical info';

  @override
  String get moreEmergencyLockscreenSubtitle =>
      'Show your key medical info in emergencies.';

  @override
  String get moreFamilyProfilesTitle => 'Family profiles';

  @override
  String get moreFamilyProfilesSubtitle =>
      'Manage health records for family members.';

  @override
  String get moreFamilyVaccinationTitle => 'Vaccination and checkup reminders';

  @override
  String get moreFamilyVaccinationSubtitle =>
      'Track routine vaccines and checkups.';

  @override
  String get moreFamilyAlertTitle => 'Abnormal alerts';

  @override
  String get moreFamilyAlertSubtitle =>
      'Notice unusual health signals in time.';

  @override
  String get moreAiSkinTitle => 'Skin / rash recognition';

  @override
  String get moreAiSkinSubtitle =>
      'Take or upload photos for a first-pass reference.';

  @override
  String get moreAiMentalScaleTitle => 'Mental health scales';

  @override
  String get moreAiMentalScaleSubtitle =>
      'Use short scales for reference results.';

  @override
  String get moreAiReportImportTitle => 'Report photo import';

  @override
  String get moreAiReportImportSubtitle =>
      'Import lab sheets or reports for structured reading.';

  @override
  String get moreDeviceMineTitle => 'My devices';

  @override
  String get moreDeviceMineSubtitle => '2 connected devices managed here.';

  @override
  String get moreDeviceAddTitle => 'Add device';

  @override
  String get moreDeviceAddSubtitle =>
      'Connect watch, cuff, or respiratory device.';

  @override
  String get moreDeviceSyncTitle => 'Sync status';

  @override
  String get moreDeviceSyncSubtitle => 'Last sync: just now.';

  @override
  String get moreKnowledgeSleepTitle => 'Sleep improvement';

  @override
  String get moreKnowledgeSleepSubtitle =>
      'Sleep plans and practical suggestions.';

  @override
  String get moreKnowledgeMindfulnessTitle => 'Mindfulness courses';

  @override
  String get moreKnowledgeMindfulnessSubtitle =>
      'Breathing, meditation, and relaxation sessions.';

  @override
  String get moreKnowledgeWomenTitle => 'Women\'s health channel';

  @override
  String get moreKnowledgeWomenSubtitle =>
      'Menstruation, pregnancy, and menopause topics.';

  @override
  String get moreEnvironmentPollenTitle => 'Pollen';

  @override
  String get moreEnvironmentPollenValue => 'High';

  @override
  String get moreEnvironmentUvTitle => 'UV';

  @override
  String get moreEnvironmentUvValue => 'Medium';

  @override
  String get moreEnvironmentAirTitle => 'Air quality';

  @override
  String get moreEnvironmentAirValue => 'Good';

  @override
  String get moreEnvironmentAdviceTitle => 'Allergy protection advice';

  @override
  String get moreEnvironmentAdviceBody =>
      'Based on your history, outdoor protection is recommended today.';

  @override
  String get moreEnvironmentAdviceAction => 'Review';

  @override
  String get moreRecentSkinTime => 'Today 10:21';

  @override
  String get moreRecentVaccinationTime => 'Yesterday 18:30';

  @override
  String get moreRecentDeviceTime => 'Yesterday 09:15';

  @override
  String get moreRecentHotlineTime => '05-12 21:40';

  @override
  String get moreQuickCalculatorTitle => 'Health calculator';

  @override
  String get moreQuickCalculatorSubtitle => 'BMI / BMR and more';

  @override
  String get moreQuickBarcodeTitle => 'Medicine barcode scan';

  @override
  String get moreQuickBarcodeSubtitle => 'Scan and identify medicine items';

  @override
  String get moreQuickConverterTitle => 'Unit converter';

  @override
  String get moreQuickConverterSubtitle => 'Weight / temperature and more';

  @override
  String get moreQuickExportTitle => 'Data export';

  @override
  String get moreQuickExportSubtitle => 'Export health data copies';

  @override
  String get moreCareNoteBody =>
      'The content and suggestions in this app are for reference and do not replace diagnosis or treatment advice.';

  @override
  String get moreErrorTitle => 'More did not load this time';

  @override
  String get moreErrorDescription =>
      'The mock structure is wired. Retry the fetch once.';

  @override
  String moreActionToast(String action) {
    return '$action: this will open the related tool or detail flow later.';
  }

  @override
  String get todaySectionTitle => 'Today workspace';

  @override
  String get todaySectionSubtitle =>
      'The new home will gradually attach reminders, snapshots, water tracking, and Lumi guidance here.';

  @override
  String get authLoginBadge => 'AUTH / LOGIN';

  @override
  String get authRegisterBadge => 'AUTH / REGISTER';

  @override
  String get authLoginTitle => 'Sign in with calm, not clutter.';

  @override
  String get authLoginDescription =>
      'Use your Lucent account to enter the rebuilt medication flow, then layer in reminders, snapshots, and multilingual health routines.';

  @override
  String get authRegisterTitle => 'Create the clean version first.';

  @override
  String get authRegisterDescription =>
      'Register once, then grow medication plans, reminders, and multilingual health workflows on top of Lucent.';

  @override
  String get authWelcomeBack => 'Welcome back';

  @override
  String get authCreateAccount => 'Create account';

  @override
  String get authLoginLead =>
      'Start with email, then choose password or verification code.';

  @override
  String get authRegisterLead =>
      'Verify your email, then set a password. Nickname is optional.';

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
  String get authForgotPasswordBadge => 'AUTH / RESET';

  @override
  String get authForgotPasswordTitle => 'Reset password from your email.';

  @override
  String get authForgotPasswordDescription =>
      'Send a verification code, set a new password, then return to sign in.';

  @override
  String get authResetPasswordTitle => 'Reset password';

  @override
  String get authResetPasswordLead =>
      'Use the email attached to your account to receive a reset code.';

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
  String get authChangeEmailBadge => 'AUTH / EMAIL';

  @override
  String get authChangeEmailTitle => 'Move account email carefully.';

  @override
  String get authChangeEmailDescription =>
      'Verify the new address before it becomes the account login email.';

  @override
  String get authChangeEmailFormTitle => 'Change email';

  @override
  String authChangeEmailLead(String email) {
    return 'Current email: $email';
  }

  @override
  String get authChangeEmailSignedOutLead =>
      'Sign in before changing the account email.';

  @override
  String get authNewEmailLabel => 'New email';

  @override
  String get authChangeEmailSubmit => 'Update email';

  @override
  String get authChangeEmailSuccess => 'Email updated.';

  @override
  String get authBackHomePrompt => 'Back to home?';

  @override
  String authSignedInAs(String email) {
    return 'Signed in as $email';
  }

  @override
  String get authCheckingSession => 'Checking session...';

  @override
  String get authNotSignedIn => 'Not signed in yet.';

  @override
  String get authGoLogin => 'Sign in';

  @override
  String get authGoRegister => 'Create account';

  @override
  String get authSignOut => 'Sign out';

  @override
  String get authInfraHint =>
      'Secure session storage, Lucent-backed localized responses, and session restore are already wired beneath this form layer.';

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
      'You slept fairly well last night. Time to refill with calm energy.';

  @override
  String get todayGreetingSubtitleAfternoon =>
      'Start with water, then bring reminders and status back into sync.';

  @override
  String get todayGreetingSubtitleEvening =>
      'Gather today\'s signals gently and leave room for tomorrow.';

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
  String get todayHealthSummaryCardTitle => 'Health summary';

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
      'Log water, medication, or vitals first, then we can shape personalized suggestions.';

  @override
  String get todayEmptyAction => 'Start logging';

  @override
  String get todayRetryAction => 'Retry';

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
}
