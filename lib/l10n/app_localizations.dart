import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In zh, this message translates to:
  /// **'Luminous'**
  String get appTitle;

  /// No description provided for @tabToday.
  ///
  /// In zh, this message translates to:
  /// **'今日'**
  String get tabToday;

  /// No description provided for @tabRecord.
  ///
  /// In zh, this message translates to:
  /// **'记录'**
  String get tabRecord;

  /// No description provided for @tabMedicine.
  ///
  /// In zh, this message translates to:
  /// **'用药'**
  String get tabMedicine;

  /// No description provided for @tabReport.
  ///
  /// In zh, this message translates to:
  /// **'报告'**
  String get tabReport;

  /// No description provided for @tabMine.
  ///
  /// In zh, this message translates to:
  /// **'我的'**
  String get tabMine;

  /// No description provided for @desktopSidebarSettings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get desktopSidebarSettings;

  /// No description provided for @desktopSidebarHelp.
  ///
  /// In zh, this message translates to:
  /// **'帮助'**
  String get desktopSidebarHelp;

  /// No description provided for @desktopSidebarHelpToast.
  ///
  /// In zh, this message translates to:
  /// **'会打开帮助与支持。'**
  String get desktopSidebarHelpToast;

  /// No description provided for @recordPageDescription.
  ///
  /// In zh, this message translates to:
  /// **'日历、时间线与多类型每日记录会从这里生长出来。'**
  String get recordPageDescription;

  /// No description provided for @recordSectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'每日时间线'**
  String get recordSectionTitle;

  /// No description provided for @recordSectionSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'记录页的第一步先搭结构，不急着恢复旧逻辑。'**
  String get recordSectionSubtitle;

  /// No description provided for @recordTodayAction.
  ///
  /// In zh, this message translates to:
  /// **'今天'**
  String get recordTodayAction;

  /// No description provided for @recordPreviousDayAction.
  ///
  /// In zh, this message translates to:
  /// **'上一天'**
  String get recordPreviousDayAction;

  /// No description provided for @recordNextDayAction.
  ///
  /// In zh, this message translates to:
  /// **'下一天'**
  String get recordNextDayAction;

  /// No description provided for @recordPickDateAction.
  ///
  /// In zh, this message translates to:
  /// **'选择日期'**
  String get recordPickDateAction;

  /// No description provided for @recordSearchAction.
  ///
  /// In zh, this message translates to:
  /// **'搜索'**
  String get recordSearchAction;

  /// No description provided for @recordFilterAction.
  ///
  /// In zh, this message translates to:
  /// **'筛选'**
  String get recordFilterAction;

  /// No description provided for @recordSwitchDateAction.
  ///
  /// In zh, this message translates to:
  /// **'切换日期'**
  String get recordSwitchDateAction;

  /// No description provided for @recordDatePillLabel.
  ///
  /// In zh, this message translates to:
  /// **'{month} 月 {day} 日  星期{weekday}'**
  String recordDatePillLabel(int month, int day, String weekday);

  /// No description provided for @recordTodayEntriesTitle.
  ///
  /// In zh, this message translates to:
  /// **'今日记录 · {count} 条'**
  String recordTodayEntriesTitle(int count);

  /// No description provided for @recordQuickActionLabel.
  ///
  /// In zh, this message translates to:
  /// **'记{type}'**
  String recordQuickActionLabel(String type);

  /// No description provided for @recordAddAction.
  ///
  /// In zh, this message translates to:
  /// **'记录'**
  String get recordAddAction;

  /// No description provided for @recordAddCompactAction.
  ///
  /// In zh, this message translates to:
  /// **'记录'**
  String get recordAddCompactAction;

  /// No description provided for @recordCreateFieldKind.
  ///
  /// In zh, this message translates to:
  /// **'类型'**
  String get recordCreateFieldKind;

  /// No description provided for @recordCreateFieldDate.
  ///
  /// In zh, this message translates to:
  /// **'日期'**
  String get recordCreateFieldDate;

  /// No description provided for @recordCreateFieldTime.
  ///
  /// In zh, this message translates to:
  /// **'时间'**
  String get recordCreateFieldTime;

  /// No description provided for @recordCreateFieldUnit.
  ///
  /// In zh, this message translates to:
  /// **'单位'**
  String get recordCreateFieldUnit;

  /// No description provided for @recordWaterUnitMl.
  ///
  /// In zh, this message translates to:
  /// **'ml'**
  String get recordWaterUnitMl;

  /// No description provided for @recordWaterUnitCup.
  ///
  /// In zh, this message translates to:
  /// **'杯'**
  String get recordWaterUnitCup;

  /// No description provided for @recordWaterUnitTimes.
  ///
  /// In zh, this message translates to:
  /// **'次'**
  String get recordWaterUnitTimes;

  /// No description provided for @recordCreateFieldTitleOptional.
  ///
  /// In zh, this message translates to:
  /// **'标题（可选）'**
  String get recordCreateFieldTitleOptional;

  /// No description provided for @recordCreateFieldNote.
  ///
  /// In zh, this message translates to:
  /// **'备注'**
  String get recordCreateFieldNote;

  /// No description provided for @recordCreateKindNote.
  ///
  /// In zh, this message translates to:
  /// **'备注'**
  String get recordCreateKindNote;

  /// No description provided for @recordCreateValueWater.
  ///
  /// In zh, this message translates to:
  /// **'饮水量'**
  String get recordCreateValueWater;

  /// No description provided for @recordCreateValueMeal.
  ///
  /// In zh, this message translates to:
  /// **'名称 / 描述'**
  String get recordCreateValueMeal;

  /// No description provided for @recordCreateValueVital.
  ///
  /// In zh, this message translates to:
  /// **'数值（如 120/80）'**
  String get recordCreateValueVital;

  /// No description provided for @recordCreateValueSymptom.
  ///
  /// In zh, this message translates to:
  /// **'严重程度 / 感受'**
  String get recordCreateValueSymptom;

  /// No description provided for @recordCreateValueSleep.
  ///
  /// In zh, this message translates to:
  /// **'时长（如 8h）'**
  String get recordCreateValueSleep;

  /// No description provided for @recordSleepInvalidValueToast.
  ///
  /// In zh, this message translates to:
  /// **'请输入有效的睡眠时长（如 7.5）'**
  String get recordSleepInvalidValueToast;

  /// No description provided for @recordSleepBedtimeLabel.
  ///
  /// In zh, this message translates to:
  /// **'就寝时间'**
  String get recordSleepBedtimeLabel;

  /// No description provided for @recordSleepWakeTimeLabel.
  ///
  /// In zh, this message translates to:
  /// **'起床时间'**
  String get recordSleepWakeTimeLabel;

  /// No description provided for @recordSleepQualityLabel.
  ///
  /// In zh, this message translates to:
  /// **'睡眠质量'**
  String get recordSleepQualityLabel;

  /// No description provided for @recordSleepQualityPoor.
  ///
  /// In zh, this message translates to:
  /// **'较差'**
  String get recordSleepQualityPoor;

  /// No description provided for @recordSleepQualityFair.
  ///
  /// In zh, this message translates to:
  /// **'一般'**
  String get recordSleepQualityFair;

  /// No description provided for @recordSleepQualityGood.
  ///
  /// In zh, this message translates to:
  /// **'良好'**
  String get recordSleepQualityGood;

  /// No description provided for @recordSleepQualityExcellent.
  ///
  /// In zh, this message translates to:
  /// **'优秀'**
  String get recordSleepQualityExcellent;

  /// No description provided for @recordSleepDeepMinutesLabel.
  ///
  /// In zh, this message translates to:
  /// **'深度睡眠（分钟）'**
  String get recordSleepDeepMinutesLabel;

  /// No description provided for @recordSleepLightMinutesLabel.
  ///
  /// In zh, this message translates to:
  /// **'浅度睡眠（分钟）'**
  String get recordSleepLightMinutesLabel;

  /// No description provided for @recordSleepRemMinutesLabel.
  ///
  /// In zh, this message translates to:
  /// **'REM 睡眠（分钟）'**
  String get recordSleepRemMinutesLabel;

  /// No description provided for @recordSleepDetailsSectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'睡眠详情'**
  String get recordSleepDetailsSectionTitle;

  /// No description provided for @recordSleepDurationLabel.
  ///
  /// In zh, this message translates to:
  /// **'时长'**
  String get recordSleepDurationLabel;

  /// No description provided for @recordSleepTimeRangeLabel.
  ///
  /// In zh, this message translates to:
  /// **'时间段'**
  String get recordSleepTimeRangeLabel;

  /// No description provided for @recordSleepNotSet.
  ///
  /// In zh, this message translates to:
  /// **'未设置'**
  String get recordSleepNotSet;

  /// No description provided for @recordSleepMinutesUnit.
  ///
  /// In zh, this message translates to:
  /// **'分钟'**
  String get recordSleepMinutesUnit;

  /// No description provided for @recordCreateFailedToast.
  ///
  /// In zh, this message translates to:
  /// **'记录未保存'**
  String get recordCreateFailedToast;

  /// No description provided for @recordImageSectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'图片附件'**
  String get recordImageSectionTitle;

  /// No description provided for @recordImageEmptyLabel.
  ///
  /// In zh, this message translates to:
  /// **'未添加图片'**
  String get recordImageEmptyLabel;

  /// No description provided for @recordImageAttachedLabel.
  ///
  /// In zh, this message translates to:
  /// **'已添加图片'**
  String get recordImageAttachedLabel;

  /// No description provided for @recordImagePickAction.
  ///
  /// In zh, this message translates to:
  /// **'选择图片'**
  String get recordImagePickAction;

  /// No description provided for @recordImageReplaceAction.
  ///
  /// In zh, this message translates to:
  /// **'更换图片'**
  String get recordImageReplaceAction;

  /// No description provided for @recordImageRemoveAction.
  ///
  /// In zh, this message translates to:
  /// **'移除'**
  String get recordImageRemoveAction;

  /// No description provided for @recordImageUnsupportedToast.
  ///
  /// In zh, this message translates to:
  /// **'仅支持 JPG、PNG、WEBP 或 GIF 图片'**
  String get recordImageUnsupportedToast;

  /// No description provided for @recordImagePickFailedToast.
  ///
  /// In zh, this message translates to:
  /// **'图片未选择'**
  String get recordImagePickFailedToast;

  /// No description provided for @recordQuickSectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'快速记录'**
  String get recordQuickSectionTitle;

  /// No description provided for @recordFastEntryTitle.
  ///
  /// In zh, this message translates to:
  /// **'快速记录{type}'**
  String recordFastEntryTitle(String type);

  /// No description provided for @recordFastEntryDateHint.
  ///
  /// In zh, this message translates to:
  /// **'保存到 {date}'**
  String recordFastEntryDateHint(String date);

  /// No description provided for @recordFastEntryMoreAction.
  ///
  /// In zh, this message translates to:
  /// **'更多'**
  String get recordFastEntryMoreAction;

  /// No description provided for @recordFastChoiceMealBreakfast.
  ///
  /// In zh, this message translates to:
  /// **'早餐'**
  String get recordFastChoiceMealBreakfast;

  /// No description provided for @recordFastChoiceMealLunch.
  ///
  /// In zh, this message translates to:
  /// **'午餐'**
  String get recordFastChoiceMealLunch;

  /// No description provided for @recordFastChoiceMealDinner.
  ///
  /// In zh, this message translates to:
  /// **'晚餐'**
  String get recordFastChoiceMealDinner;

  /// No description provided for @recordFastChoiceMealSnack.
  ///
  /// In zh, this message translates to:
  /// **'加餐'**
  String get recordFastChoiceMealSnack;

  /// No description provided for @recordFastChoiceSymptomHeadache.
  ///
  /// In zh, this message translates to:
  /// **'头痛'**
  String get recordFastChoiceSymptomHeadache;

  /// No description provided for @recordFastChoiceSymptomStomachache.
  ///
  /// In zh, this message translates to:
  /// **'胃痛'**
  String get recordFastChoiceSymptomStomachache;

  /// No description provided for @recordFastChoiceSymptomDizzy.
  ///
  /// In zh, this message translates to:
  /// **'头晕'**
  String get recordFastChoiceSymptomDizzy;

  /// No description provided for @recordFastChoiceSymptomFever.
  ///
  /// In zh, this message translates to:
  /// **'发热'**
  String get recordFastChoiceSymptomFever;

  /// No description provided for @recordFastChoiceSeverityMild.
  ///
  /// In zh, this message translates to:
  /// **'轻度'**
  String get recordFastChoiceSeverityMild;

  /// No description provided for @recordFastChoiceNoteStable.
  ///
  /// In zh, this message translates to:
  /// **'今天状态平稳'**
  String get recordFastChoiceNoteStable;

  /// No description provided for @recordFastChoiceNoteTired.
  ///
  /// In zh, this message translates to:
  /// **'今天有点累'**
  String get recordFastChoiceNoteTired;

  /// No description provided for @recordFastChoiceNoteBusy.
  ///
  /// In zh, this message translates to:
  /// **'今天比较忙'**
  String get recordFastChoiceNoteBusy;

  /// No description provided for @recordFastChoiceNoteRecovered.
  ///
  /// In zh, this message translates to:
  /// **'今天恢复不错'**
  String get recordFastChoiceNoteRecovered;

  /// No description provided for @recordAiInputHint.
  ///
  /// In zh, this message translates to:
  /// **'刚吃完饭胃有点胀...'**
  String get recordAiInputHint;

  /// No description provided for @recordAiBadge.
  ///
  /// In zh, this message translates to:
  /// **'AI'**
  String get recordAiBadge;

  /// No description provided for @recordNlpFabAction.
  ///
  /// In zh, this message translates to:
  /// **'自然语言'**
  String get recordNlpFabAction;

  /// No description provided for @recordNlpSheetTitle.
  ///
  /// In zh, this message translates to:
  /// **'自然语言录入'**
  String get recordNlpSheetTitle;

  /// No description provided for @recordNlpSheetSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'先解析成候选记录，确认后再保存。'**
  String get recordNlpSheetSubtitle;

  /// No description provided for @recordNlpInputHint.
  ///
  /// In zh, this message translates to:
  /// **'比如：今天早上喝了两杯水，中午胃有点胀，昨晚睡了 6 小时。'**
  String get recordNlpInputHint;

  /// No description provided for @recordNlpGenerateAction.
  ///
  /// In zh, this message translates to:
  /// **'解析候选'**
  String get recordNlpGenerateAction;

  /// No description provided for @recordNlpGeneratingAction.
  ///
  /// In zh, this message translates to:
  /// **'解析中'**
  String get recordNlpGeneratingAction;

  /// No description provided for @recordNlpResetAction.
  ///
  /// In zh, this message translates to:
  /// **'清空'**
  String get recordNlpResetAction;

  /// No description provided for @recordNlpMealTitleOptional.
  ///
  /// In zh, this message translates to:
  /// **'餐次 / 标题（可选）'**
  String get recordNlpMealTitleOptional;

  /// No description provided for @recordNlpSymptomTitleLabel.
  ///
  /// In zh, this message translates to:
  /// **'症状名称'**
  String get recordNlpSymptomTitleLabel;

  /// No description provided for @recordNlpNoteBodyLabel.
  ///
  /// In zh, this message translates to:
  /// **'内容'**
  String get recordNlpNoteBodyLabel;

  /// No description provided for @recordNlpDetailsLabel.
  ///
  /// In zh, this message translates to:
  /// **'补充说明'**
  String get recordNlpDetailsLabel;

  /// No description provided for @recordNlpCandidatesTitle.
  ///
  /// In zh, this message translates to:
  /// **'候选记录 · {count} 条'**
  String recordNlpCandidatesTitle(int count);

  /// No description provided for @recordNlpRemoveAction.
  ///
  /// In zh, this message translates to:
  /// **'移除'**
  String get recordNlpRemoveAction;

  /// No description provided for @recordNlpSaveAllAction.
  ///
  /// In zh, this message translates to:
  /// **'保存全部'**
  String get recordNlpSaveAllAction;

  /// No description provided for @recordNlpSaveSelectedAction.
  ///
  /// In zh, this message translates to:
  /// **'保存选中项（{count}）'**
  String recordNlpSaveSelectedAction(int count);

  /// No description provided for @recordNlpSavingAction.
  ///
  /// In zh, this message translates to:
  /// **'保存中'**
  String get recordNlpSavingAction;

  /// No description provided for @recordNlpSelectedCountHint.
  ///
  /// In zh, this message translates to:
  /// **'已选中 {count} 条，可先改再存。'**
  String recordNlpSelectedCountHint(int count);

  /// No description provided for @recordNlpInputRequiredToast.
  ///
  /// In zh, this message translates to:
  /// **'先输入一段记录描述。'**
  String get recordNlpInputRequiredToast;

  /// No description provided for @recordNlpEmptyCandidatesToast.
  ///
  /// In zh, this message translates to:
  /// **'这次没有解析出可保存的候选记录。'**
  String get recordNlpEmptyCandidatesToast;

  /// No description provided for @recordNlpNoCandidatesToSaveToast.
  ///
  /// In zh, this message translates to:
  /// **'没有可保存的候选记录。'**
  String get recordNlpNoCandidatesToSaveToast;

  /// No description provided for @recordNlpNoCandidatesSelectedToast.
  ///
  /// In zh, this message translates to:
  /// **'先选中至少一条候选记录。'**
  String get recordNlpNoCandidatesSelectedToast;

  /// No description provided for @recordNlpSavedToast.
  ///
  /// In zh, this message translates to:
  /// **'已保存 {count} 条记录'**
  String recordNlpSavedToast(int count);

  /// No description provided for @recordNlpPartialSavedToast.
  ///
  /// In zh, this message translates to:
  /// **'已保存 {savedCount} 条，另有 {failedCount} 条保存失败。'**
  String recordNlpPartialSavedToast(int savedCount, int failedCount);

  /// No description provided for @recordNlpRetryFailedAction.
  ///
  /// In zh, this message translates to:
  /// **'重试失败项'**
  String get recordNlpRetryFailedAction;

  /// No description provided for @recordNlpFailedCandidatesHint.
  ///
  /// In zh, this message translates to:
  /// **'还有 {count} 条候选记录上次保存失败，可修正后仅重试失败项。'**
  String recordNlpFailedCandidatesHint(int count);

  /// No description provided for @recordNlpRetrySavedToast.
  ///
  /// In zh, this message translates to:
  /// **'已重试并保存 {count} 条失败记录'**
  String recordNlpRetrySavedToast(int count);

  /// No description provided for @recordNlpNoFailedCandidatesToast.
  ///
  /// In zh, this message translates to:
  /// **'当前没有失败项可重试。'**
  String get recordNlpNoFailedCandidatesToast;

  /// No description provided for @recordNlpCandidateSaveFailedHint.
  ///
  /// In zh, this message translates to:
  /// **'这条上次保存失败：{message}'**
  String recordNlpCandidateSaveFailedHint(String message);

  /// No description provided for @recordSummarySectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'当天摘要'**
  String get recordSummarySectionTitle;

  /// No description provided for @recordSummaryDateLabel.
  ///
  /// In zh, this message translates to:
  /// **'2025年5月15日（周四）'**
  String get recordSummaryDateLabel;

  /// No description provided for @recordTimelineSectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'时间线'**
  String get recordTimelineSectionTitle;

  /// No description provided for @recordTrendsSectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'趋势查看'**
  String get recordTrendsSectionTitle;

  /// No description provided for @recordNewEntrySectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'新建记录'**
  String get recordNewEntrySectionTitle;

  /// No description provided for @recordFilterSectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'记录类型'**
  String get recordFilterSectionTitle;

  /// No description provided for @recordFilterMobileTitle.
  ///
  /// In zh, this message translates to:
  /// **'记录筛选'**
  String get recordFilterMobileTitle;

  /// No description provided for @recordFilterAllAction.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get recordFilterAllAction;

  /// No description provided for @recordFilterSelectAll.
  ///
  /// In zh, this message translates to:
  /// **'全选'**
  String get recordFilterSelectAll;

  /// No description provided for @recordAllTypesAction.
  ///
  /// In zh, this message translates to:
  /// **'全部类型'**
  String get recordAllTypesAction;

  /// No description provided for @recordTodayOverviewTitle.
  ///
  /// In zh, this message translates to:
  /// **'今日记录概览'**
  String get recordTodayOverviewTitle;

  /// No description provided for @recordTodayOverviewEvents.
  ///
  /// In zh, this message translates to:
  /// **'记录事件'**
  String get recordTodayOverviewEvents;

  /// No description provided for @recordTodayOverviewEventCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 条'**
  String recordTodayOverviewEventCount(int count);

  /// No description provided for @recordVoiceInputTitle.
  ///
  /// In zh, this message translates to:
  /// **'语音输入'**
  String get recordVoiceInputTitle;

  /// No description provided for @recordGuideHint.
  ///
  /// In zh, this message translates to:
  /// **'小贴士：坚持记录有助于更好地了解自己的健康状态'**
  String get recordGuideHint;

  /// No description provided for @recordGuideAction.
  ///
  /// In zh, this message translates to:
  /// **'查看记录指南'**
  String get recordGuideAction;

  /// No description provided for @recordDetailTitle.
  ///
  /// In zh, this message translates to:
  /// **'记录详情'**
  String get recordDetailTitle;

  /// No description provided for @recordDetailErrorTitle.
  ///
  /// In zh, this message translates to:
  /// **'记录详情暂时没有加载出来'**
  String get recordDetailErrorTitle;

  /// No description provided for @recordDetailValueLabel.
  ///
  /// In zh, this message translates to:
  /// **'数值'**
  String get recordDetailValueLabel;

  /// No description provided for @recordDetailSourceLabel.
  ///
  /// In zh, this message translates to:
  /// **'来源'**
  String get recordDetailSourceLabel;

  /// No description provided for @recordDetailUpdatedAtLabel.
  ///
  /// In zh, this message translates to:
  /// **'更新于'**
  String get recordDetailUpdatedAtLabel;

  /// No description provided for @recordEditAction.
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get recordEditAction;

  /// No description provided for @recordDeleteAction.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get recordDeleteAction;

  /// No description provided for @recordDeleteConfirmMessage.
  ///
  /// In zh, this message translates to:
  /// **'确定删除此记录？此操作不可撤销。'**
  String get recordDeleteConfirmMessage;

  /// No description provided for @recordMonthLabel.
  ///
  /// In zh, this message translates to:
  /// **'2025年5月'**
  String get recordMonthLabel;

  /// No description provided for @recordOpenDateAction.
  ///
  /// In zh, this message translates to:
  /// **'查看日期'**
  String get recordOpenDateAction;

  /// No description provided for @recordNotEnabledLabel.
  ///
  /// In zh, this message translates to:
  /// **'未开启'**
  String get recordNotEnabledLabel;

  /// No description provided for @recordVoiceAction.
  ///
  /// In zh, this message translates to:
  /// **'语音记录（长按说话）'**
  String get recordVoiceAction;

  /// No description provided for @recordActionToast.
  ///
  /// In zh, this message translates to:
  /// **'{action}：后续会打开对应操作。'**
  String recordActionToast(String action);

  /// No description provided for @recordErrorTitle.
  ///
  /// In zh, this message translates to:
  /// **'记录页暂时没有加载出来'**
  String get recordErrorTitle;

  /// No description provided for @recordErrorDescription.
  ///
  /// In zh, this message translates to:
  /// **'数据边界已经接好，可以重新拉取一次。'**
  String get recordErrorDescription;

  /// No description provided for @recordWeekdaySun.
  ///
  /// In zh, this message translates to:
  /// **'日'**
  String get recordWeekdaySun;

  /// No description provided for @recordWeekdayMon.
  ///
  /// In zh, this message translates to:
  /// **'一'**
  String get recordWeekdayMon;

  /// No description provided for @recordWeekdayTue.
  ///
  /// In zh, this message translates to:
  /// **'二'**
  String get recordWeekdayTue;

  /// No description provided for @recordWeekdayWed.
  ///
  /// In zh, this message translates to:
  /// **'三'**
  String get recordWeekdayWed;

  /// No description provided for @recordWeekdayThu.
  ///
  /// In zh, this message translates to:
  /// **'四'**
  String get recordWeekdayThu;

  /// No description provided for @recordWeekdayFri.
  ///
  /// In zh, this message translates to:
  /// **'五'**
  String get recordWeekdayFri;

  /// No description provided for @recordWeekdaySat.
  ///
  /// In zh, this message translates to:
  /// **'六'**
  String get recordWeekdaySat;

  /// No description provided for @recordTypeMeal.
  ///
  /// In zh, this message translates to:
  /// **'饮食'**
  String get recordTypeMeal;

  /// No description provided for @recordTypeVitals.
  ///
  /// In zh, this message translates to:
  /// **'体征'**
  String get recordTypeVitals;

  /// No description provided for @recordTypeWater.
  ///
  /// In zh, this message translates to:
  /// **'饮水'**
  String get recordTypeWater;

  /// No description provided for @recordTypeMood.
  ///
  /// In zh, this message translates to:
  /// **'情绪'**
  String get recordTypeMood;

  /// No description provided for @recordTypeSymptom.
  ///
  /// In zh, this message translates to:
  /// **'症状'**
  String get recordTypeSymptom;

  /// No description provided for @recordTypeActivity.
  ///
  /// In zh, this message translates to:
  /// **'运动'**
  String get recordTypeActivity;

  /// No description provided for @recordTypeMedication.
  ///
  /// In zh, this message translates to:
  /// **'用药'**
  String get recordTypeMedication;

  /// No description provided for @recordTypeSleep.
  ///
  /// In zh, this message translates to:
  /// **'睡眠'**
  String get recordTypeSleep;

  /// No description provided for @recordTypeHeartRate.
  ///
  /// In zh, this message translates to:
  /// **'心率'**
  String get recordTypeHeartRate;

  /// No description provided for @recordTypeWeight.
  ///
  /// In zh, this message translates to:
  /// **'体重'**
  String get recordTypeWeight;

  /// No description provided for @recordSummaryMealTitle.
  ///
  /// In zh, this message translates to:
  /// **'饮食记录'**
  String get recordSummaryMealTitle;

  /// No description provided for @recordSummaryWaterTitle.
  ///
  /// In zh, this message translates to:
  /// **'饮水进度'**
  String get recordSummaryWaterTitle;

  /// No description provided for @recordSummaryLatestVitalTitle.
  ///
  /// In zh, this message translates to:
  /// **'最新体征'**
  String get recordSummaryLatestVitalTitle;

  /// No description provided for @recordSummaryMoodTitle.
  ///
  /// In zh, this message translates to:
  /// **'情绪记录'**
  String get recordSummaryMoodTitle;

  /// No description provided for @recordSummaryTimesUnit.
  ///
  /// In zh, this message translates to:
  /// **'次'**
  String get recordSummaryTimesUnit;

  /// No description provided for @recordSummaryCupsUnit.
  ///
  /// In zh, this message translates to:
  /// **'杯'**
  String get recordSummaryCupsUnit;

  /// No description provided for @recordSummaryRecorded.
  ///
  /// In zh, this message translates to:
  /// **'已记录'**
  String get recordSummaryRecorded;

  /// No description provided for @recordSummaryNormal.
  ///
  /// In zh, this message translates to:
  /// **'正常'**
  String get recordSummaryNormal;

  /// No description provided for @recordTimelineMealLunch.
  ///
  /// In zh, this message translates to:
  /// **'饮食 · 午餐'**
  String get recordTimelineMealLunch;

  /// No description provided for @recordTimelineMealName.
  ///
  /// In zh, this message translates to:
  /// **'鸡胸肉藜麦沙拉'**
  String get recordTimelineMealName;

  /// No description provided for @recordTimelineMealNutrition.
  ///
  /// In zh, this message translates to:
  /// **'热量约 520 kcal · 蛋白质 32g · 碳水 45g · 脂肪 12g'**
  String get recordTimelineMealNutrition;

  /// No description provided for @recordTimelineAiBadge.
  ///
  /// In zh, this message translates to:
  /// **'AI 识别'**
  String get recordTimelineAiBadge;

  /// No description provided for @recordTimelineBloodPressure.
  ///
  /// In zh, this message translates to:
  /// **'血压'**
  String get recordTimelineBloodPressure;

  /// No description provided for @recordTimelineBloodPressureDetail.
  ///
  /// In zh, this message translates to:
  /// **'来源：手动记录 · 正常'**
  String get recordTimelineBloodPressureDetail;

  /// No description provided for @recordTimelineManualBadge.
  ///
  /// In zh, this message translates to:
  /// **'手动记录'**
  String get recordTimelineManualBadge;

  /// No description provided for @recordTimelineWaterAmount.
  ///
  /// In zh, this message translates to:
  /// **'1 杯 250ml'**
  String get recordTimelineWaterAmount;

  /// No description provided for @recordTimelineWaterProgress.
  ///
  /// In zh, this message translates to:
  /// **'第 4 / 8 杯'**
  String get recordTimelineWaterProgress;

  /// No description provided for @recordTimelineMedicationName.
  ///
  /// In zh, this message translates to:
  /// **'阿托伐他汀 20mg'**
  String get recordTimelineMedicationName;

  /// No description provided for @recordTimelineMedicationDetail.
  ///
  /// In zh, this message translates to:
  /// **'已服用 · 与用药计划同步'**
  String get recordTimelineMedicationDetail;

  /// No description provided for @recordTimelineMoodCalm.
  ///
  /// In zh, this message translates to:
  /// **'情绪 · 平静'**
  String get recordTimelineMoodCalm;

  /// No description provided for @recordTimelineMoodDetail.
  ///
  /// In zh, this message translates to:
  /// **'心情不错，睡得还可以'**
  String get recordTimelineMoodDetail;

  /// No description provided for @recordTimelineSymptomRecord.
  ///
  /// In zh, this message translates to:
  /// **'症状记录'**
  String get recordTimelineSymptomRecord;

  /// No description provided for @recordTimelineSymptomDetail.
  ///
  /// In zh, this message translates to:
  /// **'头痛 · 疼痛评分 3/5'**
  String get recordTimelineSymptomDetail;

  /// No description provided for @recordTimelineSleepRecord.
  ///
  /// In zh, this message translates to:
  /// **'睡眠记录'**
  String get recordTimelineSleepRecord;

  /// No description provided for @recordTimelineSleepDetail.
  ///
  /// In zh, this message translates to:
  /// **'上床 23:30 · 睡眠时长 7.0 小时'**
  String get recordTimelineSleepDetail;

  /// No description provided for @recordTimelineHeartRateDetail.
  ///
  /// In zh, this message translates to:
  /// **'72 次/分 · 来源：手表 · 正常'**
  String get recordTimelineHeartRateDetail;

  /// No description provided for @recordTimelineWeightDetail.
  ///
  /// In zh, this message translates to:
  /// **'来源：体脂秤 · BMI 22.5'**
  String get recordTimelineWeightDetail;

  /// No description provided for @recordTrendBloodSugarTitle.
  ///
  /// In zh, this message translates to:
  /// **'饮食-血糖'**
  String get recordTrendBloodSugarTitle;

  /// No description provided for @recordTrendBloodSugarLegend.
  ///
  /// In zh, this message translates to:
  /// **'餐后血糖 (mmol/L)'**
  String get recordTrendBloodSugarLegend;

  /// No description provided for @recordTrendHydrationTitle.
  ///
  /// In zh, this message translates to:
  /// **'饮水完成率'**
  String get recordTrendHydrationTitle;

  /// No description provided for @recordRange7Days.
  ///
  /// In zh, this message translates to:
  /// **'近 7 天'**
  String get recordRange7Days;

  /// No description provided for @recordRange30Days.
  ///
  /// In zh, this message translates to:
  /// **'近 30 天'**
  String get recordRange30Days;

  /// No description provided for @recordFoodImagePlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'餐图占位'**
  String get recordFoodImagePlaceholder;

  /// No description provided for @recordSymptomTrackingSectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'症状跟踪'**
  String get recordSymptomTrackingSectionTitle;

  /// No description provided for @recordSymptomHeadache.
  ///
  /// In zh, this message translates to:
  /// **'头痛'**
  String get recordSymptomHeadache;

  /// No description provided for @recordSymptomLoggedAt.
  ///
  /// In zh, this message translates to:
  /// **'今天 {time} 记录'**
  String recordSymptomLoggedAt(String time);

  /// No description provided for @recordBodyPartLabel.
  ///
  /// In zh, this message translates to:
  /// **'部位'**
  String get recordBodyPartLabel;

  /// No description provided for @recordBodyPartForehead.
  ///
  /// In zh, this message translates to:
  /// **'头部（前额）'**
  String get recordBodyPartForehead;

  /// No description provided for @recordAccompanyingSymptomsLabel.
  ///
  /// In zh, this message translates to:
  /// **'伴随症状'**
  String get recordAccompanyingSymptomsLabel;

  /// No description provided for @recordSymptomNausea.
  ///
  /// In zh, this message translates to:
  /// **'轻微恶心'**
  String get recordSymptomNausea;

  /// No description provided for @recordSymptomLightSensitive.
  ///
  /// In zh, this message translates to:
  /// **'对光敏感'**
  String get recordSymptomLightSensitive;

  /// No description provided for @recordPainRatingLabel.
  ///
  /// In zh, this message translates to:
  /// **'疼痛评分'**
  String get recordPainRatingLabel;

  /// No description provided for @recordPainModerate.
  ///
  /// In zh, this message translates to:
  /// **'中等'**
  String get recordPainModerate;

  /// No description provided for @recordViewTrendAction.
  ///
  /// In zh, this message translates to:
  /// **'查看趋势'**
  String get recordViewTrendAction;

  /// No description provided for @recordDietTitle.
  ///
  /// In zh, this message translates to:
  /// **'饮食记录'**
  String get recordDietTitle;

  /// No description provided for @recordMealCountValue.
  ///
  /// In zh, this message translates to:
  /// **'今日 {count} 餐'**
  String recordMealCountValue(int count);

  /// No description provided for @recordMealLogging.
  ///
  /// In zh, this message translates to:
  /// **'记录中'**
  String get recordMealLogging;

  /// No description provided for @recordDietRecordAction.
  ///
  /// In zh, this message translates to:
  /// **'记录饮食'**
  String get recordDietRecordAction;

  /// No description provided for @recordDentalRecordTitle.
  ///
  /// In zh, this message translates to:
  /// **'牙科记录'**
  String get recordDentalRecordTitle;

  /// No description provided for @recordEyeRecordTitle.
  ///
  /// In zh, this message translates to:
  /// **'眼科记录'**
  String get recordEyeRecordTitle;

  /// No description provided for @recordHearingRecordTitle.
  ///
  /// In zh, this message translates to:
  /// **'听力记录'**
  String get recordHearingRecordTitle;

  /// No description provided for @recordZeroCountLabel.
  ///
  /// In zh, this message translates to:
  /// **'0 条记录'**
  String get recordZeroCountLabel;

  /// No description provided for @medicineHeaderAddToast.
  ///
  /// In zh, this message translates to:
  /// **'会打开添加药品与识别入口。'**
  String get medicineHeaderAddToast;

  /// No description provided for @medicineSafetyGuardLabel.
  ///
  /// In zh, this message translates to:
  /// **'安全守护'**
  String get medicineSafetyGuardLabel;

  /// No description provided for @medicineNotificationsTooltip.
  ///
  /// In zh, this message translates to:
  /// **'用药提醒'**
  String get medicineNotificationsTooltip;

  /// No description provided for @medicineHomeSearchHint.
  ///
  /// In zh, this message translates to:
  /// **'搜索药品或症状'**
  String get medicineHomeSearchHint;

  /// No description provided for @medicineManageMedicinesAction.
  ///
  /// In zh, this message translates to:
  /// **'管理药品'**
  String get medicineManageMedicinesAction;

  /// No description provided for @medicineDrugboxTitle.
  ///
  /// In zh, this message translates to:
  /// **'我的药盒'**
  String get medicineDrugboxTitle;

  /// No description provided for @medicineDrugboxSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'管理我的药品'**
  String get medicineDrugboxSubtitle;

  /// No description provided for @medicineDrugboxTotalPrefix.
  ///
  /// In zh, this message translates to:
  /// **'药品总数'**
  String get medicineDrugboxTotalPrefix;

  /// No description provided for @medicineDrugboxTotal.
  ///
  /// In zh, this message translates to:
  /// **'{count} 种'**
  String medicineDrugboxTotal(int count);

  /// No description provided for @medicineNextDoseReminderTitle.
  ///
  /// In zh, this message translates to:
  /// **'下次服药提醒'**
  String get medicineNextDoseReminderTitle;

  /// No description provided for @medicineNextDoseTodayTime.
  ///
  /// In zh, this message translates to:
  /// **'今天 {time}'**
  String medicineNextDoseTodayTime(String time);

  /// No description provided for @medicineDoseDueStatus.
  ///
  /// In zh, this message translates to:
  /// **'待服用'**
  String get medicineDoseDueStatus;

  /// No description provided for @medicineNoMedicineTitle.
  ///
  /// In zh, this message translates to:
  /// **'暂无药品'**
  String get medicineNoMedicineTitle;

  /// No description provided for @medicineNoMedicineBody.
  ///
  /// In zh, this message translates to:
  /// **'先添加药品后显示提醒'**
  String get medicineNoMedicineBody;

  /// No description provided for @medicineSafetyEngineTitle.
  ///
  /// In zh, this message translates to:
  /// **'安全检查预览'**
  String get medicineSafetyEngineTitle;

  /// No description provided for @medicineSafetyAllRecordsAction.
  ///
  /// In zh, this message translates to:
  /// **'来源说明'**
  String get medicineSafetyAllRecordsAction;

  /// No description provided for @medicineQuickOperationTitle.
  ///
  /// In zh, this message translates to:
  /// **'用药操作'**
  String get medicineQuickOperationTitle;

  /// No description provided for @medicineQuickAddTitle.
  ///
  /// In zh, this message translates to:
  /// **'添加药品'**
  String get medicineQuickAddTitle;

  /// No description provided for @medicineQuickAddSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'手动添加'**
  String get medicineQuickAddSubtitle;

  /// No description provided for @medicineQuickRecordTitle.
  ///
  /// In zh, this message translates to:
  /// **'记录服药'**
  String get medicineQuickRecordTitle;

  /// No description provided for @medicineQuickRecordSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'记录用药情况'**
  String get medicineQuickRecordSubtitle;

  /// No description provided for @medicineQuickSafetyCheckTitle.
  ///
  /// In zh, this message translates to:
  /// **'风险检查'**
  String get medicineQuickSafetyCheckTitle;

  /// No description provided for @medicineQuickSafetyCheckSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'相互作用与禁忌'**
  String get medicineQuickSafetyCheckSubtitle;

  /// No description provided for @medicineQuickSafetyCheckToast.
  ///
  /// In zh, this message translates to:
  /// **'会打开相互作用和禁忌检查。'**
  String get medicineQuickSafetyCheckToast;

  /// No description provided for @medicineRiskCheckPageTitle.
  ///
  /// In zh, this message translates to:
  /// **'风险检查'**
  String get medicineRiskCheckPageTitle;

  /// No description provided for @medicineRiskCheckSummaryTitle.
  ///
  /// In zh, this message translates to:
  /// **'检查概览'**
  String get medicineRiskCheckSummaryTitle;

  /// No description provided for @medicineRiskCheckCurrentMedicinesLabel.
  ///
  /// In zh, this message translates to:
  /// **'当前用药'**
  String get medicineRiskCheckCurrentMedicinesLabel;

  /// No description provided for @medicineRiskCheckCheckedMedicinesLabel.
  ///
  /// In zh, this message translates to:
  /// **'已检查'**
  String get medicineRiskCheckCheckedMedicinesLabel;

  /// No description provided for @medicineRiskCheckFindingsLabel.
  ///
  /// In zh, this message translates to:
  /// **'风险提示'**
  String get medicineRiskCheckFindingsLabel;

  /// No description provided for @medicineRiskCheckCoverageLabel.
  ///
  /// In zh, this message translates to:
  /// **'覆盖不足'**
  String get medicineRiskCheckCoverageLabel;

  /// No description provided for @medicineRiskCheckFindingsTitle.
  ///
  /// In zh, this message translates to:
  /// **'风险提示'**
  String get medicineRiskCheckFindingsTitle;

  /// No description provided for @medicineRiskCheckCoverageTitle.
  ///
  /// In zh, this message translates to:
  /// **'未覆盖药品'**
  String get medicineRiskCheckCoverageTitle;

  /// No description provided for @medicineRiskCheckNoFindingsTitle.
  ///
  /// In zh, this message translates to:
  /// **'暂未发现明确风险提示'**
  String get medicineRiskCheckNoFindingsTitle;

  /// No description provided for @medicineRiskCheckNoFindingsBody.
  ///
  /// In zh, this message translates to:
  /// **'当前已检查药物里没有发现明确风险提示，但仍需结合医生建议与说明书确认。'**
  String get medicineRiskCheckNoFindingsBody;

  /// No description provided for @medicineRiskCheckViewAction.
  ///
  /// In zh, this message translates to:
  /// **'查看'**
  String get medicineRiskCheckViewAction;

  /// No description provided for @medicineRiskCheckAllClearAlertTitle.
  ///
  /// In zh, this message translates to:
  /// **'风险检查已完成'**
  String get medicineRiskCheckAllClearAlertTitle;

  /// No description provided for @medicineRiskCheckAllClearAlertBody.
  ///
  /// In zh, this message translates to:
  /// **'当前已检查药物里没有发现明确风险提示'**
  String get medicineRiskCheckAllClearAlertBody;

  /// No description provided for @medicineRiskCheckAllClearAlertDetail.
  ///
  /// In zh, this message translates to:
  /// **'这不等于适合自行用药，仍需结合医生建议与说明书确认。'**
  String get medicineRiskCheckAllClearAlertDetail;

  /// No description provided for @medicineRiskCheckCoverageAlertTitle.
  ///
  /// In zh, this message translates to:
  /// **'风险检查覆盖不足'**
  String get medicineRiskCheckCoverageAlertTitle;

  /// No description provided for @medicineRiskCheckCoverageAlertBody.
  ///
  /// In zh, this message translates to:
  /// **'还有 {count} 种药品缺少可检查资料'**
  String medicineRiskCheckCoverageAlertBody(int count);

  /// No description provided for @medicineRiskCheckCoverageAlertDetail.
  ///
  /// In zh, this message translates to:
  /// **'{names} 暂时缺少可检查资料。'**
  String medicineRiskCheckCoverageAlertDetail(String names);

  /// No description provided for @medicineRiskCheckCoverageAlertDetailWithMore.
  ///
  /// In zh, this message translates to:
  /// **'{names} 等药品暂时缺少可检查资料。'**
  String medicineRiskCheckCoverageAlertDetailWithMore(String names);

  /// No description provided for @medicineRiskCheckFindingTitleInteraction.
  ///
  /// In zh, this message translates to:
  /// **'发现药物相互作用'**
  String get medicineRiskCheckFindingTitleInteraction;

  /// No description provided for @medicineRiskCheckFindingTitleDuplicate.
  ///
  /// In zh, this message translates to:
  /// **'发现重复成分'**
  String get medicineRiskCheckFindingTitleDuplicate;

  /// No description provided for @medicineRiskCheckFindingTitleAllergy.
  ///
  /// In zh, this message translates to:
  /// **'发现过敏相关提示'**
  String get medicineRiskCheckFindingTitleAllergy;

  /// No description provided for @medicineRiskCheckFindingTitleSpecialGroup.
  ///
  /// In zh, this message translates to:
  /// **'发现特殊人群用药提示'**
  String get medicineRiskCheckFindingTitleSpecialGroup;

  /// No description provided for @medicineRiskCheckFindingTitleFoodInteraction.
  ///
  /// In zh, this message translates to:
  /// **'发现饮食相互作用提示'**
  String get medicineRiskCheckFindingTitleFoodInteraction;

  /// No description provided for @medicineRiskCheckFindingBodyInteraction.
  ///
  /// In zh, this message translates to:
  /// **'{primary} 与 {secondary} 可能存在相互作用'**
  String medicineRiskCheckFindingBodyInteraction(
    String primary,
    String secondary,
  );

  /// No description provided for @medicineRiskCheckFindingBodyInteractionSingle.
  ///
  /// In zh, this message translates to:
  /// **'{primary} 存在相互作用提示'**
  String medicineRiskCheckFindingBodyInteractionSingle(String primary);

  /// No description provided for @medicineRiskCheckFindingBodyDuplicate.
  ///
  /// In zh, this message translates to:
  /// **'{primary} 与 {secondary} 可能重复用药'**
  String medicineRiskCheckFindingBodyDuplicate(
    String primary,
    String secondary,
  );

  /// No description provided for @medicineRiskCheckFindingBodyDuplicateSingle.
  ///
  /// In zh, this message translates to:
  /// **'{primary} 可能存在重复成分'**
  String medicineRiskCheckFindingBodyDuplicateSingle(String primary);

  /// No description provided for @medicineRiskCheckFindingBodyAllergy.
  ///
  /// In zh, this message translates to:
  /// **'{primary} 资料中出现过敏相关词：{related}'**
  String medicineRiskCheckFindingBodyAllergy(String primary, String related);

  /// No description provided for @medicineRiskCheckFindingBodyAllergyGeneric.
  ///
  /// In zh, this message translates to:
  /// **'{primary} 存在过敏相关提示'**
  String medicineRiskCheckFindingBodyAllergyGeneric(String primary);

  /// No description provided for @medicineRiskCheckFindingBodySpecialGroup.
  ///
  /// In zh, this message translates to:
  /// **'{primary} 需要结合特殊人群信息重点确认'**
  String medicineRiskCheckFindingBodySpecialGroup(String primary);

  /// No description provided for @medicineRiskCheckFindingBodyFoodInteraction.
  ///
  /// In zh, this message translates to:
  /// **'{primary} 存在饮食相关注意事项'**
  String medicineRiskCheckFindingBodyFoodInteraction(String primary);

  /// No description provided for @medicineRiskCheckFindingBodyGeneric.
  ///
  /// In zh, this message translates to:
  /// **'{primary} 存在需要确认的风险信息'**
  String medicineRiskCheckFindingBodyGeneric(String primary);

  /// No description provided for @medicineRiskCheckFindingEvidenceFallback.
  ///
  /// In zh, this message translates to:
  /// **'详情来自药品资料，请在风险检查页进一步确认。'**
  String get medicineRiskCheckFindingEvidenceFallback;

  /// No description provided for @medicineRiskCheckCoverageReasonManualEntry.
  ///
  /// In zh, this message translates to:
  /// **'手动录入，暂无标准药品资料'**
  String get medicineRiskCheckCoverageReasonManualEntry;

  /// No description provided for @medicineRiskCheckCoverageReasonMissingSourceRef.
  ///
  /// In zh, this message translates to:
  /// **'缺少来源编号，无法拉取药品详情'**
  String get medicineRiskCheckCoverageReasonMissingSourceRef;

  /// No description provided for @medicineRiskCheckCoverageReasonDetailUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'药品详情暂时不可用'**
  String get medicineRiskCheckCoverageReasonDetailUnavailable;

  /// No description provided for @medicineRiskCheckSeverityHigh.
  ///
  /// In zh, this message translates to:
  /// **'高风险'**
  String get medicineRiskCheckSeverityHigh;

  /// No description provided for @medicineRiskCheckSeverityMedium.
  ///
  /// In zh, this message translates to:
  /// **'需确认'**
  String get medicineRiskCheckSeverityMedium;

  /// No description provided for @medicineRiskCheckSeverityInfo.
  ///
  /// In zh, this message translates to:
  /// **'提示'**
  String get medicineRiskCheckSeverityInfo;

  /// No description provided for @medicineRiskCheckContextPregnancy.
  ///
  /// In zh, this message translates to:
  /// **'孕期'**
  String get medicineRiskCheckContextPregnancy;

  /// No description provided for @medicineRiskCheckContextLactation.
  ///
  /// In zh, this message translates to:
  /// **'哺乳期'**
  String get medicineRiskCheckContextLactation;

  /// No description provided for @medicineRiskCheckContextPediatric.
  ///
  /// In zh, this message translates to:
  /// **'儿童'**
  String get medicineRiskCheckContextPediatric;

  /// No description provided for @medicineRiskCheckContextGeriatric.
  ///
  /// In zh, this message translates to:
  /// **'老年人'**
  String get medicineRiskCheckContextGeriatric;

  /// No description provided for @medicineRiskCheckContextAlcohol.
  ///
  /// In zh, this message translates to:
  /// **'酒精'**
  String get medicineRiskCheckContextAlcohol;

  /// No description provided for @medicineRiskCheckContextCaffeine.
  ///
  /// In zh, this message translates to:
  /// **'咖啡因'**
  String get medicineRiskCheckContextCaffeine;

  /// No description provided for @medicineRiskConclusionContraindicated.
  ///
  /// In zh, this message translates to:
  /// **'禁用'**
  String get medicineRiskConclusionContraindicated;

  /// No description provided for @medicineRiskConclusionAvoid.
  ///
  /// In zh, this message translates to:
  /// **'避免使用'**
  String get medicineRiskConclusionAvoid;

  /// No description provided for @medicineRiskConclusionCaution.
  ///
  /// In zh, this message translates to:
  /// **'慎用'**
  String get medicineRiskConclusionCaution;

  /// No description provided for @medicineRiskConclusionConsultClinician.
  ///
  /// In zh, this message translates to:
  /// **'咨询医生'**
  String get medicineRiskConclusionConsultClinician;

  /// No description provided for @medicineRiskConclusionInsufficientInformation.
  ///
  /// In zh, this message translates to:
  /// **'信息不足'**
  String get medicineRiskConclusionInsufficientInformation;

  /// No description provided for @medicineQuickRecordToast.
  ///
  /// In zh, this message translates to:
  /// **'会打开服药记录入口。'**
  String get medicineQuickRecordToast;

  /// No description provided for @medicineRecordsTitle.
  ///
  /// In zh, this message translates to:
  /// **'用药记录'**
  String get medicineRecordsTitle;

  /// No description provided for @medicineAllMedicinesFilter.
  ///
  /// In zh, this message translates to:
  /// **'全部药品'**
  String get medicineAllMedicinesFilter;

  /// No description provided for @medicineLastSevenDaysFilter.
  ///
  /// In zh, this message translates to:
  /// **'近 7 天'**
  String get medicineLastSevenDaysFilter;

  /// No description provided for @medicineViewMoreRecordsAction.
  ///
  /// In zh, this message translates to:
  /// **'查看更多记录'**
  String get medicineViewMoreRecordsAction;

  /// No description provided for @medicineRecordTodayLabel.
  ///
  /// In zh, this message translates to:
  /// **'今天'**
  String get medicineRecordTodayLabel;

  /// No description provided for @medicineRecordPreviousDate.
  ///
  /// In zh, this message translates to:
  /// **'5/19'**
  String get medicineRecordPreviousDate;

  /// No description provided for @medicineRecordOlderDate.
  ///
  /// In zh, this message translates to:
  /// **'5/18'**
  String get medicineRecordOlderDate;

  /// No description provided for @medicineRecordOnTimeStatus.
  ///
  /// In zh, this message translates to:
  /// **'按时服用'**
  String get medicineRecordOnTimeStatus;

  /// No description provided for @medicineRecordScheduledStatus.
  ///
  /// In zh, this message translates to:
  /// **'计划中'**
  String get medicineRecordScheduledStatus;

  /// No description provided for @medicineReferenceNoticeTitle.
  ///
  /// In zh, this message translates to:
  /// **'仅供参考，必要时咨询医生或药师'**
  String get medicineReferenceNoticeTitle;

  /// No description provided for @medicineReferenceNoticeBody.
  ///
  /// In zh, this message translates to:
  /// **'本应用不提供诊断服务，如有不适请及时就医。'**
  String get medicineReferenceNoticeBody;

  /// No description provided for @medicineSafetyTipsTitle.
  ///
  /// In zh, this message translates to:
  /// **'用药安全小贴士'**
  String get medicineSafetyTipsTitle;

  /// No description provided for @medicineSafetyTipsRefreshAction.
  ///
  /// In zh, this message translates to:
  /// **'换一换'**
  String get medicineSafetyTipsRefreshAction;

  /// No description provided for @medicineSafetyTipSpacing.
  ///
  /// In zh, this message translates to:
  /// **'服药期间如需饮酒，建议间隔至少 24 小时以上。'**
  String get medicineSafetyTipSpacing;

  /// No description provided for @medicineSafetyTipCoffee.
  ///
  /// In zh, this message translates to:
  /// **'咖啡 / 浓茶 / 能量饮料可能影响部分药物效果，注意适量。'**
  String get medicineSafetyTipCoffee;

  /// No description provided for @medicineSafetyTipTiming.
  ///
  /// In zh, this message translates to:
  /// **'按时按量用药，不要自行增减或停药。'**
  String get medicineSafetyTipTiming;

  /// No description provided for @medicineSafetyTipStorage.
  ///
  /// In zh, this message translates to:
  /// **'药品请置于阴凉干燥处，避免儿童接触。'**
  String get medicineSafetyTipStorage;

  /// No description provided for @medicineErrorTitle.
  ///
  /// In zh, this message translates to:
  /// **'用药页暂时没有加载出来'**
  String get medicineErrorTitle;

  /// No description provided for @medicineErrorDescription.
  ///
  /// In zh, this message translates to:
  /// **'请检查网络连接后重试。'**
  String get medicineErrorDescription;

  /// No description provided for @medicineHeroMetricTodayCountLabel.
  ///
  /// In zh, this message translates to:
  /// **'今日需服用'**
  String get medicineHeroMetricTodayCountLabel;

  /// No description provided for @medicineHeroMetricTodayCountUnit.
  ///
  /// In zh, this message translates to:
  /// **'种'**
  String get medicineHeroMetricTodayCountUnit;

  /// No description provided for @medicineHeroMetricAdherenceLabel.
  ///
  /// In zh, this message translates to:
  /// **'按时服用率'**
  String get medicineHeroMetricAdherenceLabel;

  /// No description provided for @medicineHeroMetricAdherenceUnit.
  ///
  /// In zh, this message translates to:
  /// **'%'**
  String get medicineHeroMetricAdherenceUnit;

  /// No description provided for @medicineQuickActionSectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'识别与录入'**
  String get medicineQuickActionSectionTitle;

  /// No description provided for @medicineQuickActionCameraTitle.
  ///
  /// In zh, this message translates to:
  /// **'拍照识别药品'**
  String get medicineQuickActionCameraTitle;

  /// No description provided for @medicineQuickActionCameraSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'识别包装、药盒与处方标签'**
  String get medicineQuickActionCameraSubtitle;

  /// No description provided for @medicineQuickActionBarcodeTitle.
  ///
  /// In zh, this message translates to:
  /// **'扫描条形码'**
  String get medicineQuickActionBarcodeTitle;

  /// No description provided for @medicineQuickActionBarcodeSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'补齐规格、厂家与常见别名'**
  String get medicineQuickActionBarcodeSubtitle;

  /// No description provided for @medicineQuickActionSearchTitle.
  ///
  /// In zh, this message translates to:
  /// **'手动搜索药品'**
  String get medicineQuickActionSearchTitle;

  /// No description provided for @medicineQuickActionSearchSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'按药名、成分或症状快速查找'**
  String get medicineQuickActionSearchSubtitle;

  /// No description provided for @medicineQuickActionPrescriptionTitle.
  ///
  /// In zh, this message translates to:
  /// **'导入处方与包装'**
  String get medicineQuickActionPrescriptionTitle;

  /// No description provided for @medicineQuickActionPrescriptionSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'后续可接 OCR 与复诊提醒'**
  String get medicineQuickActionPrescriptionSubtitle;

  /// No description provided for @medicineTodayPlanTitle.
  ///
  /// In zh, this message translates to:
  /// **'今日服用计划'**
  String get medicineTodayPlanTitle;

  /// No description provided for @medicineTodayPlanInspectAction.
  ///
  /// In zh, this message translates to:
  /// **'查看全部'**
  String get medicineTodayPlanInspectAction;

  /// No description provided for @medicineMockNameMetformin.
  ///
  /// In zh, this message translates to:
  /// **'示例药品 A'**
  String get medicineMockNameMetformin;

  /// No description provided for @medicineMockDoseMetformin.
  ///
  /// In zh, this message translates to:
  /// **'0.5 g'**
  String get medicineMockDoseMetformin;

  /// No description provided for @medicineMockScheduleMorningEvening.
  ///
  /// In zh, this message translates to:
  /// **'每日 2 次'**
  String get medicineMockScheduleMorningEvening;

  /// No description provided for @medicineMockTime0800.
  ///
  /// In zh, this message translates to:
  /// **'08:00'**
  String get medicineMockTime0800;

  /// No description provided for @medicineMockTime1200.
  ///
  /// In zh, this message translates to:
  /// **'12:00'**
  String get medicineMockTime1200;

  /// No description provided for @medicineMockTime2000.
  ///
  /// In zh, this message translates to:
  /// **'20:00'**
  String get medicineMockTime2000;

  /// No description provided for @medicineDoseStatusTaken.
  ///
  /// In zh, this message translates to:
  /// **'已服用'**
  String get medicineDoseStatusTaken;

  /// No description provided for @medicineDoseStatusSkipped.
  ///
  /// In zh, this message translates to:
  /// **'已跳过'**
  String get medicineDoseStatusSkipped;

  /// No description provided for @medicineDoseStatusPending.
  ///
  /// In zh, this message translates to:
  /// **'待服用'**
  String get medicineDoseStatusPending;

  /// No description provided for @medicineDoseActionTaken.
  ///
  /// In zh, this message translates to:
  /// **'已服用'**
  String get medicineDoseActionTaken;

  /// No description provided for @medicineDoseActionSkipped.
  ///
  /// In zh, this message translates to:
  /// **'跳过'**
  String get medicineDoseActionSkipped;

  /// No description provided for @medicineDoseActionSavedToast.
  ///
  /// In zh, this message translates to:
  /// **'用药打卡已保存'**
  String get medicineDoseActionSavedToast;

  /// No description provided for @medicineDoseActionFailedToast.
  ///
  /// In zh, this message translates to:
  /// **'用药打卡未保存'**
  String get medicineDoseActionFailedToast;

  /// No description provided for @medicineDoseNotSet.
  ///
  /// In zh, this message translates to:
  /// **'剂量未设置'**
  String get medicineDoseNotSet;

  /// No description provided for @medicineScheduleNotSet.
  ///
  /// In zh, this message translates to:
  /// **'提醒未设置'**
  String get medicineScheduleNotSet;

  /// No description provided for @medicineReminderNewTitle.
  ///
  /// In zh, this message translates to:
  /// **'新建提醒'**
  String get medicineReminderNewTitle;

  /// No description provided for @medicineReminderEditTitle.
  ///
  /// In zh, this message translates to:
  /// **'编辑提醒'**
  String get medicineReminderEditTitle;

  /// No description provided for @medicineReminderDetailTitle.
  ///
  /// In zh, this message translates to:
  /// **'用药提醒详情'**
  String get medicineReminderDetailTitle;

  /// No description provided for @medicineReminderNotFoundTitle.
  ///
  /// In zh, this message translates to:
  /// **'提醒暂时没有加载出来'**
  String get medicineReminderNotFoundTitle;

  /// No description provided for @medicineReminderQuickTitle.
  ///
  /// In zh, this message translates to:
  /// **'提醒设置'**
  String get medicineReminderQuickTitle;

  /// No description provided for @medicineReminderQuickSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'管理服药时间'**
  String get medicineReminderQuickSubtitle;

  /// No description provided for @medicineReminderEnabledStatus.
  ///
  /// In zh, this message translates to:
  /// **'启用中'**
  String get medicineReminderEnabledStatus;

  /// No description provided for @medicineReminderDisabledStatus.
  ///
  /// In zh, this message translates to:
  /// **'已关闭'**
  String get medicineReminderDisabledStatus;

  /// No description provided for @medicineReminderFrequencyLabel.
  ///
  /// In zh, this message translates to:
  /// **'服用频次'**
  String get medicineReminderFrequencyLabel;

  /// No description provided for @medicineReminderFrequencyDaily.
  ///
  /// In zh, this message translates to:
  /// **'每日'**
  String get medicineReminderFrequencyDaily;

  /// No description provided for @medicineReminderFrequencyWeekly.
  ///
  /// In zh, this message translates to:
  /// **'每周'**
  String get medicineReminderFrequencyWeekly;

  /// No description provided for @medicineReminderFrequencyCustom.
  ///
  /// In zh, this message translates to:
  /// **'自定义'**
  String get medicineReminderFrequencyCustom;

  /// No description provided for @medicineReminderTimesLabel.
  ///
  /// In zh, this message translates to:
  /// **'服用时间'**
  String get medicineReminderTimesLabel;

  /// No description provided for @medicineReminderDoseLabel.
  ///
  /// In zh, this message translates to:
  /// **'每次剂量'**
  String get medicineReminderDoseLabel;

  /// No description provided for @medicineReminderStartDateLabel.
  ///
  /// In zh, this message translates to:
  /// **'开始日期'**
  String get medicineReminderStartDateLabel;

  /// No description provided for @medicineReminderEndDateLabel.
  ///
  /// In zh, this message translates to:
  /// **'结束日期'**
  String get medicineReminderEndDateLabel;

  /// No description provided for @medicineReminderDateNotSet.
  ///
  /// In zh, this message translates to:
  /// **'未设置'**
  String get medicineReminderDateNotSet;

  /// No description provided for @medicineReminderClearDateAction.
  ///
  /// In zh, this message translates to:
  /// **'清除日期'**
  String get medicineReminderClearDateAction;

  /// No description provided for @medicineReminderMethodLabel.
  ///
  /// In zh, this message translates to:
  /// **'提醒方式'**
  String get medicineReminderMethodLabel;

  /// No description provided for @medicineReminderNotificationOn.
  ///
  /// In zh, this message translates to:
  /// **'提醒通知'**
  String get medicineReminderNotificationOn;

  /// No description provided for @medicineReminderNotificationOff.
  ///
  /// In zh, this message translates to:
  /// **'提醒关闭'**
  String get medicineReminderNotificationOff;

  /// No description provided for @medicineReminderDeviceLocalHint.
  ///
  /// In zh, this message translates to:
  /// **'仅保存提醒计划，系统通知由本机设置控制'**
  String get medicineReminderDeviceLocalHint;

  /// No description provided for @medicineReminderSmsLabel.
  ///
  /// In zh, this message translates to:
  /// **'短信提醒'**
  String get medicineReminderSmsLabel;

  /// No description provided for @medicineReminderSmsOff.
  ///
  /// In zh, this message translates to:
  /// **'短信未开通'**
  String get medicineReminderSmsOff;

  /// No description provided for @medicineReminderSmsUnavailableHint.
  ///
  /// In zh, this message translates to:
  /// **'短信通道暂未开通'**
  String get medicineReminderSmsUnavailableHint;

  /// No description provided for @medicineReminderUnavailableStatus.
  ///
  /// In zh, this message translates to:
  /// **'未开通'**
  String get medicineReminderUnavailableStatus;

  /// No description provided for @medicineReminderSoundLabel.
  ///
  /// In zh, this message translates to:
  /// **'声音提醒'**
  String get medicineReminderSoundLabel;

  /// No description provided for @medicineReminderSoundLocalHint.
  ///
  /// In zh, this message translates to:
  /// **'本机提醒使用的声音偏好'**
  String get medicineReminderSoundLocalHint;

  /// No description provided for @medicineReminderSoundDefault.
  ///
  /// In zh, this message translates to:
  /// **'默认铃声'**
  String get medicineReminderSoundDefault;

  /// No description provided for @medicineReminderSoundGentle.
  ///
  /// In zh, this message translates to:
  /// **'轻柔铃声'**
  String get medicineReminderSoundGentle;

  /// No description provided for @medicineReminderSoundSilent.
  ///
  /// In zh, this message translates to:
  /// **'静音'**
  String get medicineReminderSoundSilent;

  /// No description provided for @medicineReminderNotificationDefaultTitle.
  ///
  /// In zh, this message translates to:
  /// **'用药提醒'**
  String get medicineReminderNotificationDefaultTitle;

  /// No description provided for @medicineReminderNotificationDefaultBody.
  ///
  /// In zh, this message translates to:
  /// **'该按时吃药了。'**
  String get medicineReminderNotificationDefaultBody;

  /// No description provided for @medicineReminderNotificationChannelName.
  ///
  /// In zh, this message translates to:
  /// **'用药提醒'**
  String get medicineReminderNotificationChannelName;

  /// No description provided for @medicineReminderNotificationChannelDescription.
  ///
  /// In zh, this message translates to:
  /// **'按用药计划在本机发送的提醒。'**
  String get medicineReminderNotificationChannelDescription;

  /// No description provided for @medicineReminderNoteLabel.
  ///
  /// In zh, this message translates to:
  /// **'备注'**
  String get medicineReminderNoteLabel;

  /// No description provided for @medicineReminderNoteOptionalLabel.
  ///
  /// In zh, this message translates to:
  /// **'备注（可选）'**
  String get medicineReminderNoteOptionalLabel;

  /// No description provided for @medicineReminderNoteHint.
  ///
  /// In zh, this message translates to:
  /// **'添加备注，例如：饭后服用'**
  String get medicineReminderNoteHint;

  /// No description provided for @medicineReminderMedicineSectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'药品信息'**
  String get medicineReminderMedicineSectionTitle;

  /// No description provided for @medicineReminderMedicineLabel.
  ///
  /// In zh, this message translates to:
  /// **'选择药品'**
  String get medicineReminderMedicineLabel;

  /// No description provided for @medicineReminderSettingsSectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'提醒设置'**
  String get medicineReminderSettingsSectionTitle;

  /// No description provided for @medicineReminderAddTimeAction.
  ///
  /// In zh, this message translates to:
  /// **'添加时间'**
  String get medicineReminderAddTimeAction;

  /// No description provided for @medicineReminderTodayLogsTitle.
  ///
  /// In zh, this message translates to:
  /// **'今日用药打卡'**
  String get medicineReminderTodayLogsTitle;

  /// No description provided for @medicineReminderNoTodayLogs.
  ///
  /// In zh, this message translates to:
  /// **'今天还没有用药打卡'**
  String get medicineReminderNoTodayLogs;

  /// No description provided for @medicineReminderDeliveryLogsTitle.
  ///
  /// In zh, this message translates to:
  /// **'提醒投递历史'**
  String get medicineReminderDeliveryLogsTitle;

  /// No description provided for @medicineReminderNoDeliveryLogs.
  ///
  /// In zh, this message translates to:
  /// **'暂无提醒投递记录'**
  String get medicineReminderNoDeliveryLogs;

  /// No description provided for @medicineReminderDeliveryChannelLocal.
  ///
  /// In zh, this message translates to:
  /// **'本机通知'**
  String get medicineReminderDeliveryChannelLocal;

  /// No description provided for @medicineReminderDeliveryChannelPush.
  ///
  /// In zh, this message translates to:
  /// **'推送通知'**
  String get medicineReminderDeliveryChannelPush;

  /// No description provided for @medicineReminderDeliveryChannelEmail.
  ///
  /// In zh, this message translates to:
  /// **'邮件'**
  String get medicineReminderDeliveryChannelEmail;

  /// No description provided for @medicineReminderDeliveryChannelSms.
  ///
  /// In zh, this message translates to:
  /// **'短信'**
  String get medicineReminderDeliveryChannelSms;

  /// No description provided for @medicineReminderDeliveryStatusScheduled.
  ///
  /// In zh, this message translates to:
  /// **'待投递'**
  String get medicineReminderDeliveryStatusScheduled;

  /// No description provided for @medicineReminderDeliveryStatusDelivered.
  ///
  /// In zh, this message translates to:
  /// **'已投递'**
  String get medicineReminderDeliveryStatusDelivered;

  /// No description provided for @medicineReminderDeliveryStatusFailed.
  ///
  /// In zh, this message translates to:
  /// **'投递失败'**
  String get medicineReminderDeliveryStatusFailed;

  /// No description provided for @medicineReminderMissedStatus.
  ///
  /// In zh, this message translates to:
  /// **'已错过'**
  String get medicineReminderMissedStatus;

  /// No description provided for @medicineReminderSavedToast.
  ///
  /// In zh, this message translates to:
  /// **'用药提醒已保存'**
  String get medicineReminderSavedToast;

  /// No description provided for @medicineReminderDeletedToast.
  ///
  /// In zh, this message translates to:
  /// **'用药提醒已删除'**
  String get medicineReminderDeletedToast;

  /// No description provided for @medicineReminderMedicineRequiredToast.
  ///
  /// In zh, this message translates to:
  /// **'请选择药品'**
  String get medicineReminderMedicineRequiredToast;

  /// No description provided for @medicineReminderTimeRequiredToast.
  ///
  /// In zh, this message translates to:
  /// **'请至少添加一个服用时间'**
  String get medicineReminderTimeRequiredToast;

  /// No description provided for @medicineReminderWeekdayRequiredToast.
  ///
  /// In zh, this message translates to:
  /// **'请选择提醒日期'**
  String get medicineReminderWeekdayRequiredToast;

  /// No description provided for @medicineReminderDateRangeInvalidToast.
  ///
  /// In zh, this message translates to:
  /// **'结束日期不能早于开始日期'**
  String get medicineReminderDateRangeInvalidToast;

  /// No description provided for @medicineReminderDeleteAction.
  ///
  /// In zh, this message translates to:
  /// **'删除此提醒'**
  String get medicineReminderDeleteAction;

  /// No description provided for @medicineReminderDeleteConfirmTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除这条提醒？'**
  String get medicineReminderDeleteConfirmTitle;

  /// No description provided for @medicineReminderDeleteConfirmBody.
  ///
  /// In zh, this message translates to:
  /// **'删除后将无法恢复，历史用药打卡仍会保留。'**
  String get medicineReminderDeleteConfirmBody;

  /// No description provided for @medicineReminderConfirmDeleteAction.
  ///
  /// In zh, this message translates to:
  /// **'确认删除'**
  String get medicineReminderConfirmDeleteAction;

  /// No description provided for @medicineReminderCancelAction.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get medicineReminderCancelAction;

  /// No description provided for @medicineNoPendingDose.
  ///
  /// In zh, this message translates to:
  /// **'今日用药已完成'**
  String get medicineNoPendingDose;

  /// No description provided for @medicineNoPendingDoseDetail.
  ///
  /// In zh, this message translates to:
  /// **'暂无待服用提醒'**
  String get medicineNoPendingDoseDetail;

  /// No description provided for @medicineStatusStable.
  ///
  /// In zh, this message translates to:
  /// **'稳定服用'**
  String get medicineStatusStable;

  /// No description provided for @medicineMockNameAtorvastatin.
  ///
  /// In zh, this message translates to:
  /// **'示例药品 B'**
  String get medicineMockNameAtorvastatin;

  /// No description provided for @medicineMockDoseAtorvastatin.
  ///
  /// In zh, this message translates to:
  /// **'20 mg'**
  String get medicineMockDoseAtorvastatin;

  /// No description provided for @medicineMockScheduleDailyOnce.
  ///
  /// In zh, this message translates to:
  /// **'每日 1 次'**
  String get medicineMockScheduleDailyOnce;

  /// No description provided for @medicineStatusNeedsCheckin.
  ///
  /// In zh, this message translates to:
  /// **'稳定服用'**
  String get medicineStatusNeedsCheckin;

  /// No description provided for @medicineMockNameOmeprazole.
  ///
  /// In zh, this message translates to:
  /// **'示例药品 C'**
  String get medicineMockNameOmeprazole;

  /// No description provided for @medicineMockDoseOmeprazole.
  ///
  /// In zh, this message translates to:
  /// **'20 mg'**
  String get medicineMockDoseOmeprazole;

  /// No description provided for @medicineSafetyPanelTitle.
  ///
  /// In zh, this message translates to:
  /// **'用药安全'**
  String get medicineSafetyPanelTitle;

  /// No description provided for @medicineSafetyPanelSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'高风险提醒和依从性风险会集中在这里。'**
  String get medicineSafetyPanelSubtitle;

  /// No description provided for @medicineAlertInteractionTitle.
  ///
  /// In zh, this message translates to:
  /// **'相互作用提醒'**
  String get medicineAlertInteractionTitle;

  /// No description provided for @medicineAlertInteractionBody.
  ///
  /// In zh, this message translates to:
  /// **'阿司匹林与布洛芬可能增加出血风险。'**
  String get medicineAlertInteractionBody;

  /// No description provided for @medicineAlertInteractionDetail.
  ///
  /// In zh, this message translates to:
  /// **'同时使用时请遵医嘱'**
  String get medicineAlertInteractionDetail;

  /// No description provided for @medicineAlertInteractionAction.
  ///
  /// In zh, this message translates to:
  /// **'查看详情'**
  String get medicineAlertInteractionAction;

  /// No description provided for @medicineAlertOtherTitle.
  ///
  /// In zh, this message translates to:
  /// **'其他安全提醒'**
  String get medicineAlertOtherTitle;

  /// No description provided for @medicineAlertOtherBody.
  ///
  /// In zh, this message translates to:
  /// **'布洛芬不建议长期连续使用超过 5 天'**
  String get medicineAlertOtherBody;

  /// No description provided for @medicineAlertOtherDetail.
  ///
  /// In zh, this message translates to:
  /// **'如需长期使用，请咨询医生'**
  String get medicineAlertOtherDetail;

  /// No description provided for @medicineAlertOtherAction.
  ///
  /// In zh, this message translates to:
  /// **'查看详情'**
  String get medicineAlertOtherAction;

  /// No description provided for @medicineAlertAlcoholRiskTitle.
  ///
  /// In zh, this message translates to:
  /// **'酒精提示'**
  String get medicineAlertAlcoholRiskTitle;

  /// No description provided for @medicineAlertAlcoholRiskBody.
  ///
  /// In zh, this message translates to:
  /// **'待接入药品数据后给出来源建议'**
  String get medicineAlertAlcoholRiskBody;

  /// No description provided for @medicineAlertAlcoholRiskDetail.
  ///
  /// In zh, this message translates to:
  /// **'作为风险展示前需要说明书或规则来源支撑'**
  String get medicineAlertAlcoholRiskDetail;

  /// No description provided for @medicineAlertAlcoholRiskStatus.
  ///
  /// In zh, this message translates to:
  /// **'预览'**
  String get medicineAlertAlcoholRiskStatus;

  /// No description provided for @medicineAlertCoffeeReminderTitle.
  ///
  /// In zh, this message translates to:
  /// **'咖啡因提示'**
  String get medicineAlertCoffeeReminderTitle;

  /// No description provided for @medicineAlertCoffeeReminderBody.
  ///
  /// In zh, this message translates to:
  /// **'咖啡因建议需要来源核验'**
  String get medicineAlertCoffeeReminderBody;

  /// No description provided for @medicineAlertCoffeeReminderDetail.
  ///
  /// In zh, this message translates to:
  /// **'部分药物可能受咖啡因影响'**
  String get medicineAlertCoffeeReminderDetail;

  /// No description provided for @medicineAlertCoffeeReminderStatus.
  ///
  /// In zh, this message translates to:
  /// **'待核验'**
  String get medicineAlertCoffeeReminderStatus;

  /// No description provided for @medicineAlertDuplicateCheckTitle.
  ///
  /// In zh, this message translates to:
  /// **'重复来源检查'**
  String get medicineAlertDuplicateCheckTitle;

  /// No description provided for @medicineAlertDuplicateCheckBody.
  ///
  /// In zh, this message translates to:
  /// **'相同成分检查需要来源核验'**
  String get medicineAlertDuplicateCheckBody;

  /// No description provided for @medicineAlertDuplicateCheckDetail.
  ///
  /// In zh, this message translates to:
  /// **'添加新药后会再次进行来源检查'**
  String get medicineAlertDuplicateCheckDetail;

  /// No description provided for @medicineAlertDuplicateCheckStatus.
  ///
  /// In zh, this message translates to:
  /// **'预览'**
  String get medicineAlertDuplicateCheckStatus;

  /// No description provided for @medicineAlertSpecialGroupSafetyTitle.
  ///
  /// In zh, this message translates to:
  /// **'特殊人群用药提示'**
  String get medicineAlertSpecialGroupSafetyTitle;

  /// No description provided for @medicineAlertSpecialGroupSafetyBody.
  ///
  /// In zh, this message translates to:
  /// **'记录特殊用药条件以获得更谨慎的安全提示'**
  String get medicineAlertSpecialGroupSafetyBody;

  /// No description provided for @medicineAlertSpecialGroupSafetyDetail.
  ///
  /// In zh, this message translates to:
  /// **'孕期、哺乳期、儿童或其他特殊人群用药请优先遵医嘱'**
  String get medicineAlertSpecialGroupSafetyDetail;

  /// No description provided for @medicineAlertSpecialGroupSafetyStatus.
  ///
  /// In zh, this message translates to:
  /// **'未记录'**
  String get medicineAlertSpecialGroupSafetyStatus;

  /// No description provided for @medicinePromiseTitle.
  ///
  /// In zh, this message translates to:
  /// **'安全边界'**
  String get medicinePromiseTitle;

  /// No description provided for @medicinePromiseBody.
  ///
  /// In zh, this message translates to:
  /// **'这个页面会主动帮你发现风险，但不会伪装成诊断结论。'**
  String get medicinePromiseBody;

  /// No description provided for @medicinePromisePointBoundary.
  ///
  /// In zh, this message translates to:
  /// **'结果仅供参考，不替代医生诊断与治疗。'**
  String get medicinePromisePointBoundary;

  /// No description provided for @medicinePromisePointSpecialGroup.
  ///
  /// In zh, this message translates to:
  /// **'孕期、哺乳期、儿童、精神类药物更高优先级警示。'**
  String get medicinePromisePointSpecialGroup;

  /// No description provided for @medicinePromisePointPrivacy.
  ///
  /// In zh, this message translates to:
  /// **'处方、拍照和敏感药物信息遵循最小暴露原则。'**
  String get medicinePromisePointPrivacy;

  /// No description provided for @medicinePromisePointDiagnosis.
  ///
  /// In zh, this message translates to:
  /// **'我们不诊断、不替代医生、不编造药品事实。'**
  String get medicinePromisePointDiagnosis;

  /// No description provided for @medicinePromiseAction.
  ///
  /// In zh, this message translates to:
  /// **'了解更多安全说明'**
  String get medicinePromiseAction;

  /// No description provided for @medicineViewPlanToast.
  ///
  /// In zh, this message translates to:
  /// **'会打开完整的今日用药列表与历史记录。'**
  String get medicineViewPlanToast;

  /// No description provided for @medicineOpenPlanItemToast.
  ///
  /// In zh, this message translates to:
  /// **'会打开药品详情、提醒设置和历史服用记录。'**
  String get medicineOpenPlanItemToast;

  /// No description provided for @medicineOpenPromiseToast.
  ///
  /// In zh, this message translates to:
  /// **'会打开安全边界、特殊人群提示和隐私处理说明。'**
  String get medicineOpenPromiseToast;

  /// No description provided for @medicineQuickActionCameraToast.
  ///
  /// In zh, this message translates to:
  /// **'会调用相机拍摄药盒、药板或标签并开始识别。'**
  String get medicineQuickActionCameraToast;

  /// No description provided for @medicineQuickActionBarcodeToast.
  ///
  /// In zh, this message translates to:
  /// **'会打开扫码流程，识别条形码并补齐药品信息。'**
  String get medicineQuickActionBarcodeToast;

  /// No description provided for @medicineQuickActionPrescriptionToast.
  ///
  /// In zh, this message translates to:
  /// **'会打开图片导入与处方识别流程。'**
  String get medicineQuickActionPrescriptionToast;

  /// No description provided for @medicineAlertInteractionToast.
  ///
  /// In zh, this message translates to:
  /// **'会打开相互作用详情与风险说明。'**
  String get medicineAlertInteractionToast;

  /// No description provided for @medicineAlertOtherToast.
  ///
  /// In zh, this message translates to:
  /// **'会打开其他安全提醒详情。'**
  String get medicineAlertOtherToast;

  /// No description provided for @medicineAlertAlcoholRiskToast.
  ///
  /// In zh, this message translates to:
  /// **'会打开酒精预览的来源说明。'**
  String get medicineAlertAlcoholRiskToast;

  /// No description provided for @medicineAlertCoffeeReminderToast.
  ///
  /// In zh, this message translates to:
  /// **'会打开咖啡因预览的来源说明。'**
  String get medicineAlertCoffeeReminderToast;

  /// No description provided for @medicineAlertDuplicateCheckToast.
  ///
  /// In zh, this message translates to:
  /// **'会打开重复来源预览说明。'**
  String get medicineAlertDuplicateCheckToast;

  /// No description provided for @medicineAlertSpecialGroupSafetyToast.
  ///
  /// In zh, this message translates to:
  /// **'会打开特殊人群用药安全提示。'**
  String get medicineAlertSpecialGroupSafetyToast;

  /// No description provided for @medicineSearchPageTitle.
  ///
  /// In zh, this message translates to:
  /// **'搜索药品'**
  String get medicineSearchPageTitle;

  /// No description provided for @medicineSearchAssistantTitle.
  ///
  /// In zh, this message translates to:
  /// **'用药助手'**
  String get medicineSearchAssistantTitle;

  /// No description provided for @medicineSearchMyBoxTab.
  ///
  /// In zh, this message translates to:
  /// **'我的药箱'**
  String get medicineSearchMyBoxTab;

  /// No description provided for @medicineSearchFieldHint.
  ///
  /// In zh, this message translates to:
  /// **'搜索药品、成分、疾病、症状...'**
  String get medicineSearchFieldHint;

  /// No description provided for @medicineSearchSourceCn.
  ///
  /// In zh, this message translates to:
  /// **'药品说明书（cn）'**
  String get medicineSearchSourceCn;

  /// No description provided for @medicineSearchSourceDrugbank.
  ///
  /// In zh, this message translates to:
  /// **'药物知识（DrugBank）'**
  String get medicineSearchSourceDrugbank;

  /// No description provided for @medicineSearchSwitchSource.
  ///
  /// In zh, this message translates to:
  /// **'切换数据源'**
  String get medicineSearchSwitchSource;

  /// No description provided for @medicineSearchRecentTitle.
  ///
  /// In zh, this message translates to:
  /// **'最近搜索'**
  String get medicineSearchRecentTitle;

  /// No description provided for @medicineSearchClearAction.
  ///
  /// In zh, this message translates to:
  /// **'清空'**
  String get medicineSearchClearAction;

  /// No description provided for @medicineSearchPhotoAction.
  ///
  /// In zh, this message translates to:
  /// **'拍照识别'**
  String get medicineSearchPhotoAction;

  /// No description provided for @medicineSearchBarcodeAction.
  ///
  /// In zh, this message translates to:
  /// **'扫描条形码'**
  String get medicineSearchBarcodeAction;

  /// No description provided for @medicineSearchPhotoToast.
  ///
  /// In zh, this message translates to:
  /// **'会打开相机识别药盒、药板或说明书。'**
  String get medicineSearchPhotoToast;

  /// No description provided for @medicineSearchBarcodeToast.
  ///
  /// In zh, this message translates to:
  /// **'会打开扫码流程，识别条形码并补齐药品信息。'**
  String get medicineSearchBarcodeToast;

  /// No description provided for @medicineSearchScanHint.
  ///
  /// In zh, this message translates to:
  /// **'会打开扫码或拍照识别入口。'**
  String get medicineSearchScanHint;

  /// No description provided for @medicineSearchCategoryTitle.
  ///
  /// In zh, this message translates to:
  /// **'热门常备药分类'**
  String get medicineSearchCategoryTitle;

  /// No description provided for @medicineSearchCategoryPainFever.
  ///
  /// In zh, this message translates to:
  /// **'退烧止痛'**
  String get medicineSearchCategoryPainFever;

  /// No description provided for @medicineSearchCategoryColdCough.
  ///
  /// In zh, this message translates to:
  /// **'感冒咳嗽'**
  String get medicineSearchCategoryColdCough;

  /// No description provided for @medicineSearchCategoryStomach.
  ///
  /// In zh, this message translates to:
  /// **'肠胃'**
  String get medicineSearchCategoryStomach;

  /// No description provided for @medicineSearchCategorySupplement.
  ///
  /// In zh, this message translates to:
  /// **'维矿补充'**
  String get medicineSearchCategorySupplement;

  /// No description provided for @medicineSearchCategoryChronic.
  ///
  /// In zh, this message translates to:
  /// **'慢病常用'**
  String get medicineSearchCategoryChronic;

  /// No description provided for @medicineSearchReferenceNotice.
  ///
  /// In zh, this message translates to:
  /// **'药品信息仅供参考，具体用药请遵医嘱'**
  String get medicineSearchReferenceNotice;

  /// No description provided for @medicineSearchResultTitle.
  ///
  /// In zh, this message translates to:
  /// **'搜索结果'**
  String get medicineSearchResultTitle;

  /// No description provided for @medicineSearchResultCount.
  ///
  /// In zh, this message translates to:
  /// **'共找到 {count} 条结果'**
  String medicineSearchResultCount(int count);

  /// No description provided for @medicineSearchMatchedBy.
  ///
  /// In zh, this message translates to:
  /// **'命中'**
  String get medicineSearchMatchedBy;

  /// No description provided for @medicineSearchMatchIngredient.
  ///
  /// In zh, this message translates to:
  /// **'成分'**
  String get medicineSearchMatchIngredient;

  /// No description provided for @medicineSearchMatchName.
  ///
  /// In zh, this message translates to:
  /// **'名称'**
  String get medicineSearchMatchName;

  /// No description provided for @medicineSearchAddToBoxAction.
  ///
  /// In zh, this message translates to:
  /// **'加入药箱'**
  String get medicineSearchAddToBoxAction;

  /// No description provided for @medicineSearchAddToast.
  ///
  /// In zh, this message translates to:
  /// **'会加入药箱并进入用药提醒设置。'**
  String get medicineSearchAddToast;

  /// No description provided for @medicineSearchPrecheckTitle.
  ///
  /// In zh, this message translates to:
  /// **'添加前风险检查'**
  String get medicineSearchPrecheckTitle;

  /// No description provided for @medicineSearchPrecheckDescription.
  ///
  /// In zh, this message translates to:
  /// **'发现风险提示或资料不足，确认后仍可继续加入药箱。'**
  String get medicineSearchPrecheckDescription;

  /// No description provided for @medicineSearchPrecheckConfirmAction.
  ///
  /// In zh, this message translates to:
  /// **'仍然加入'**
  String get medicineSearchPrecheckConfirmAction;

  /// No description provided for @medicineSearchPrecheckFailedToast.
  ///
  /// In zh, this message translates to:
  /// **'风险检查失败'**
  String get medicineSearchPrecheckFailedToast;

  /// No description provided for @medicineSearchOpenDetailToast.
  ///
  /// In zh, this message translates to:
  /// **'会打开药品详情页。'**
  String get medicineSearchOpenDetailToast;

  /// No description provided for @medicineSearchPreviewTitle.
  ///
  /// In zh, this message translates to:
  /// **'选中项预览'**
  String get medicineSearchPreviewTitle;

  /// No description provided for @medicineSearchSafetyLead.
  ///
  /// In zh, this message translates to:
  /// **'你当前的过敏史 / 特殊用药条件 / 现用药可能影响此药使用'**
  String get medicineSearchSafetyLead;

  /// No description provided for @medicineSearchSafetyAction.
  ///
  /// In zh, this message translates to:
  /// **'查看详情页获取完整信息'**
  String get medicineSearchSafetyAction;

  /// No description provided for @medicineSearchNoResultTitle.
  ///
  /// In zh, this message translates to:
  /// **'无结果？'**
  String get medicineSearchNoResultTitle;

  /// No description provided for @medicineSearchNoResultKeyword.
  ///
  /// In zh, this message translates to:
  /// **'检查关键词'**
  String get medicineSearchNoResultKeyword;

  /// No description provided for @medicineSearchNoResultSwitch.
  ///
  /// In zh, this message translates to:
  /// **'切换数据源'**
  String get medicineSearchNoResultSwitch;

  /// No description provided for @medicineSearchErrorTitle.
  ///
  /// In zh, this message translates to:
  /// **'搜索页暂时没有加载出来'**
  String get medicineSearchErrorTitle;

  /// No description provided for @medicineSearchErrorDescription.
  ///
  /// In zh, this message translates to:
  /// **'请检查网络连接后重试。'**
  String get medicineSearchErrorDescription;

  /// No description provided for @mineSectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'个人工作区'**
  String get mineSectionTitle;

  /// No description provided for @mineSectionSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'身份、目标与隐私控制会共享在这一块安静的界面里。'**
  String get mineSectionSubtitle;

  /// No description provided for @mineHeaderNotifications.
  ///
  /// In zh, this message translates to:
  /// **'通知'**
  String get mineHeaderNotifications;

  /// No description provided for @mineHeaderSettings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get mineHeaderSettings;

  /// No description provided for @mineAccountDisplayName.
  ///
  /// In zh, this message translates to:
  /// **'Lumi 用户'**
  String get mineAccountDisplayName;

  /// No description provided for @mineAccountGuestDisplayName.
  ///
  /// In zh, this message translates to:
  /// **'访客'**
  String get mineAccountGuestDisplayName;

  /// No description provided for @mineAccountSignedIn.
  ///
  /// In zh, this message translates to:
  /// **'已登录'**
  String get mineAccountSignedIn;

  /// No description provided for @mineAccountSignedOut.
  ///
  /// In zh, this message translates to:
  /// **'未登录'**
  String get mineAccountSignedOut;

  /// No description provided for @mineAccountMeta.
  ///
  /// In zh, this message translates to:
  /// **'会员到期：2026-05-20'**
  String get mineAccountMeta;

  /// No description provided for @mineAccountSignedOutMeta.
  ///
  /// In zh, this message translates to:
  /// **'登录后可同步档案、提醒与个性化健康数据'**
  String get mineAccountSignedOutMeta;

  /// No description provided for @mineAccountManageAction.
  ///
  /// In zh, this message translates to:
  /// **'管理账号'**
  String get mineAccountManageAction;

  /// No description provided for @mineAccountEmailVerified.
  ///
  /// In zh, this message translates to:
  /// **'邮箱已验证'**
  String get mineAccountEmailVerified;

  /// No description provided for @mineAccountEmailUnverified.
  ///
  /// In zh, this message translates to:
  /// **'邮箱未验证'**
  String get mineAccountEmailUnverified;

  /// No description provided for @mineAccountPasswordSet.
  ///
  /// In zh, this message translates to:
  /// **'已设置密码'**
  String get mineAccountPasswordSet;

  /// No description provided for @mineAccountPasswordUnset.
  ///
  /// In zh, this message translates to:
  /// **'未设置密码'**
  String get mineAccountPasswordUnset;

  /// No description provided for @mineAccountLinkedIdentityCount.
  ///
  /// In zh, this message translates to:
  /// **'已绑定 {count} 个'**
  String mineAccountLinkedIdentityCount(int count);

  /// No description provided for @mineAccountLinkedIdentityNone.
  ///
  /// In zh, this message translates to:
  /// **'未绑定第三方'**
  String get mineAccountLinkedIdentityNone;

  /// No description provided for @mineAccountLastLogin.
  ///
  /// In zh, this message translates to:
  /// **'上次登录 {date}'**
  String mineAccountLastLogin(String date);

  /// No description provided for @mineAccountLastLoginNone.
  ///
  /// In zh, this message translates to:
  /// **'上次登录 --'**
  String get mineAccountLastLoginNone;

  /// No description provided for @mineAccountStudentRole.
  ///
  /// In zh, this message translates to:
  /// **'大学生'**
  String get mineAccountStudentRole;

  /// No description provided for @mineSignedOutNoticeTitle.
  ///
  /// In zh, this message translates to:
  /// **'当前未登录'**
  String get mineSignedOutNoticeTitle;

  /// No description provided for @mineSignedOutNoticeDescription.
  ///
  /// In zh, this message translates to:
  /// **'我的页面先展示静态结构，避免未登录时反复请求后端。登录后再加载你的档案与健康上下文。'**
  String get mineSignedOutNoticeDescription;

  /// No description provided for @mineCompletionTitle.
  ///
  /// In zh, this message translates to:
  /// **'档案完整度'**
  String get mineCompletionTitle;

  /// No description provided for @mineAlertAllergyTitle.
  ///
  /// In zh, this message translates to:
  /// **'过敏史'**
  String get mineAlertAllergyTitle;

  /// No description provided for @mineAlertAllergySubtitle.
  ///
  /// In zh, this message translates to:
  /// **'花粉、青霉素'**
  String get mineAlertAllergySubtitle;

  /// No description provided for @mineAlertAllergyBadge.
  ///
  /// In zh, this message translates to:
  /// **'2 项'**
  String get mineAlertAllergyBadge;

  /// No description provided for @mineAlertMedicineTitle.
  ///
  /// In zh, this message translates to:
  /// **'当前用药'**
  String get mineAlertMedicineTitle;

  /// No description provided for @mineAlertMedicineSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'2 种药物'**
  String get mineAlertMedicineSubtitle;

  /// No description provided for @mineAlertMedicineBadge.
  ///
  /// In zh, this message translates to:
  /// **'按时服用'**
  String get mineAlertMedicineBadge;

  /// No description provided for @mineAlertPrivacyTitle.
  ///
  /// In zh, this message translates to:
  /// **'分享控制'**
  String get mineAlertPrivacyTitle;

  /// No description provided for @mineAlertPrivacySubtitle.
  ///
  /// In zh, this message translates to:
  /// **'分享前先预览确认'**
  String get mineAlertPrivacySubtitle;

  /// No description provided for @mineAlertPrivacyBadge.
  ///
  /// In zh, this message translates to:
  /// **'先确认'**
  String get mineAlertPrivacyBadge;

  /// No description provided for @mineArchiveBasicTitle.
  ///
  /// In zh, this message translates to:
  /// **'基础信息'**
  String get mineArchiveBasicTitle;

  /// No description provided for @mineArchiveBasicSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'个人信息与健康信息'**
  String get mineArchiveBasicSubtitle;

  /// No description provided for @mineArchiveAllergyTitle.
  ///
  /// In zh, this message translates to:
  /// **'过敏史'**
  String get mineArchiveAllergyTitle;

  /// No description provided for @mineArchiveAllergySubtitle.
  ///
  /// In zh, this message translates to:
  /// **'食物、药物、环境过敏记录'**
  String get mineArchiveAllergySubtitle;

  /// No description provided for @mineArchiveMedicineTitle.
  ///
  /// In zh, this message translates to:
  /// **'当前用药'**
  String get mineArchiveMedicineTitle;

  /// No description provided for @mineArchiveMedicineSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'正在使用的药品与用药记录'**
  String get mineArchiveMedicineSubtitle;

  /// No description provided for @mineArchiveEmergencyTitle.
  ///
  /// In zh, this message translates to:
  /// **'紧急联系人'**
  String get mineArchiveEmergencyTitle;

  /// No description provided for @mineArchiveEmergencySubtitle.
  ///
  /// In zh, this message translates to:
  /// **'1 位联系人'**
  String get mineArchiveEmergencySubtitle;

  /// No description provided for @mineArchiveCompleted.
  ///
  /// In zh, this message translates to:
  /// **'已完善'**
  String get mineArchiveCompleted;

  /// No description provided for @mineArchiveNeedsFill.
  ///
  /// In zh, this message translates to:
  /// **'待补充'**
  String get mineArchiveNeedsFill;

  /// No description provided for @mineCampusSectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'校园服务'**
  String get mineCampusSectionTitle;

  /// No description provided for @mineCampusHospitalTitle.
  ///
  /// In zh, this message translates to:
  /// **'校医院'**
  String get mineCampusHospitalTitle;

  /// No description provided for @mineCampusHospitalSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'在线预约挂号'**
  String get mineCampusHospitalSubtitle;

  /// No description provided for @mineCampusSupportTitle.
  ///
  /// In zh, this message translates to:
  /// **'学生支持'**
  String get mineCampusSupportTitle;

  /// No description provided for @mineCampusSupportSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'校内支持资源'**
  String get mineCampusSupportSubtitle;

  /// No description provided for @mineCampusPharmacyTitle.
  ///
  /// In zh, this message translates to:
  /// **'校园药房'**
  String get mineCampusPharmacyTitle;

  /// No description provided for @mineCampusPharmacySubtitle.
  ///
  /// In zh, this message translates to:
  /// **'校内药品查询'**
  String get mineCampusPharmacySubtitle;

  /// No description provided for @mineCampusEmergencyTitle.
  ///
  /// In zh, this message translates to:
  /// **'紧急帮助'**
  String get mineCampusEmergencyTitle;

  /// No description provided for @mineCampusEmergencySubtitle.
  ///
  /// In zh, this message translates to:
  /// **'紧急电话与指南'**
  String get mineCampusEmergencySubtitle;

  /// No description provided for @minePrivacyReportTitle.
  ///
  /// In zh, this message translates to:
  /// **'报告分享'**
  String get minePrivacyReportTitle;

  /// No description provided for @minePrivacyReportSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'健康报告、趋势分析'**
  String get minePrivacyReportSubtitle;

  /// No description provided for @minePrivacyAiTitle.
  ///
  /// In zh, this message translates to:
  /// **'AI 总结与建议'**
  String get minePrivacyAiTitle;

  /// No description provided for @minePrivacyAiSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'每日总结、趋势建议'**
  String get minePrivacyAiSubtitle;

  /// No description provided for @assistantEntryTitle.
  ///
  /// In zh, this message translates to:
  /// **'AI 对话'**
  String get assistantEntryTitle;

  /// No description provided for @assistantEntrySubtitle.
  ///
  /// In zh, this message translates to:
  /// **'流式问答与受控健康上下文'**
  String get assistantEntrySubtitle;

  /// No description provided for @minePrivacyOnlyMe.
  ///
  /// In zh, this message translates to:
  /// **'仅自己可见'**
  String get minePrivacyOnlyMe;

  /// No description provided for @minePrivacyShareAfterGrant.
  ///
  /// In zh, this message translates to:
  /// **'授权后分享'**
  String get minePrivacyShareAfterGrant;

  /// No description provided for @mineReminderSectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'提醒设置'**
  String get mineReminderSectionTitle;

  /// No description provided for @mineReminderMedicineTitle.
  ///
  /// In zh, this message translates to:
  /// **'用药提醒'**
  String get mineReminderMedicineTitle;

  /// No description provided for @mineReminderWaterTitle.
  ///
  /// In zh, this message translates to:
  /// **'饮水提醒'**
  String get mineReminderWaterTitle;

  /// No description provided for @mineReminderSleepTitle.
  ///
  /// In zh, this message translates to:
  /// **'睡眠提醒'**
  String get mineReminderSleepTitle;

  /// No description provided for @mineReminderLocalOnly.
  ///
  /// In zh, this message translates to:
  /// **'仅本地'**
  String get mineReminderLocalOnly;

  /// No description provided for @mineReminderEnabled.
  ///
  /// In zh, this message translates to:
  /// **'已开启'**
  String get mineReminderEnabled;

  /// No description provided for @mineAccountSettingsTitle.
  ///
  /// In zh, this message translates to:
  /// **'账号与设置'**
  String get mineAccountSettingsTitle;

  /// No description provided for @mineSettingLanguageTitle.
  ///
  /// In zh, this message translates to:
  /// **'语言设置'**
  String get mineSettingLanguageTitle;

  /// No description provided for @mineSettingLanguageValue.
  ///
  /// In zh, this message translates to:
  /// **'简体中文'**
  String get mineSettingLanguageValue;

  /// No description provided for @mineSettingExportTitle.
  ///
  /// In zh, this message translates to:
  /// **'数据导出'**
  String get mineSettingExportTitle;

  /// No description provided for @mineSettingExportValue.
  ///
  /// In zh, this message translates to:
  /// **'导出我的健康数据'**
  String get mineSettingExportValue;

  /// No description provided for @mineSettingHelpTitle.
  ///
  /// In zh, this message translates to:
  /// **'帮助与反馈'**
  String get mineSettingHelpTitle;

  /// No description provided for @mineSettingHelpValue.
  ///
  /// In zh, this message translates to:
  /// **'常见问题与意见反馈'**
  String get mineSettingHelpValue;

  /// No description provided for @mineSettingAboutTitle.
  ///
  /// In zh, this message translates to:
  /// **'关于 Luminous'**
  String get mineSettingAboutTitle;

  /// No description provided for @mineSettingAboutValue.
  ///
  /// In zh, this message translates to:
  /// **'版本 1.2.0'**
  String get mineSettingAboutValue;

  /// No description provided for @minePrivacyNoticeTitle.
  ///
  /// In zh, this message translates to:
  /// **'敏感数据默认保护，可随时撤回授权'**
  String get minePrivacyNoticeTitle;

  /// No description provided for @minePrivacyNoticeAction.
  ///
  /// In zh, this message translates to:
  /// **'查看隐私政策'**
  String get minePrivacyNoticeAction;

  /// No description provided for @mineProfileUnknownValue.
  ///
  /// In zh, this message translates to:
  /// **'--'**
  String get mineProfileUnknownValue;

  /// No description provided for @mineProfileAgeYears.
  ///
  /// In zh, this message translates to:
  /// **'{age}岁'**
  String mineProfileAgeYears(int age);

  /// No description provided for @mineProfileHeightCm.
  ///
  /// In zh, this message translates to:
  /// **'{height}cm'**
  String mineProfileHeightCm(int height);

  /// No description provided for @mineProfileMeta.
  ///
  /// In zh, this message translates to:
  /// **'{age} · {height}'**
  String mineProfileMeta(String age, String height);

  /// No description provided for @mineCompletionSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'完成度良好，继续完善更准确的建议'**
  String get mineCompletionSubtitle;

  /// No description provided for @mineSummaryTitle.
  ///
  /// In zh, this message translates to:
  /// **'健康上下文摘要'**
  String get mineSummaryTitle;

  /// No description provided for @mineSummaryUpdatedAt.
  ///
  /// In zh, this message translates to:
  /// **'更新于 2025-05-15'**
  String get mineSummaryUpdatedAt;

  /// No description provided for @mineSummaryAge.
  ///
  /// In zh, this message translates to:
  /// **'年龄'**
  String get mineSummaryAge;

  /// No description provided for @mineSummaryAllergies.
  ///
  /// In zh, this message translates to:
  /// **'过敏'**
  String get mineSummaryAllergies;

  /// No description provided for @mineSummaryConditions.
  ///
  /// In zh, this message translates to:
  /// **'慢病/条件'**
  String get mineSummaryConditions;

  /// No description provided for @mineSummaryMedicines.
  ///
  /// In zh, this message translates to:
  /// **'当前用药'**
  String get mineSummaryMedicines;

  /// No description provided for @mineSummaryMissingInfo.
  ///
  /// In zh, this message translates to:
  /// **'缺失信息：生日、身高、单位制'**
  String get mineSummaryMissingInfo;

  /// No description provided for @mineSummaryCompleteAction.
  ///
  /// In zh, this message translates to:
  /// **'去完善'**
  String get mineSummaryCompleteAction;

  /// No description provided for @mineProfileTitle.
  ///
  /// In zh, this message translates to:
  /// **'健康档案'**
  String get mineProfileTitle;

  /// No description provided for @mineProfileBasicInfoTitle.
  ///
  /// In zh, this message translates to:
  /// **'基础资料'**
  String get mineProfileBasicInfoTitle;

  /// No description provided for @mineProfileBasicInfoSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'个人基本信息'**
  String get mineProfileBasicInfoSubtitle;

  /// No description provided for @mineProfileAllergiesTitle.
  ///
  /// In zh, this message translates to:
  /// **'过敏史'**
  String get mineProfileAllergiesTitle;

  /// No description provided for @mineProfileAllergiesSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'2 项记录'**
  String get mineProfileAllergiesSubtitle;

  /// No description provided for @mineProfileConditionsTitle.
  ///
  /// In zh, this message translates to:
  /// **'基础病史'**
  String get mineProfileConditionsTitle;

  /// No description provided for @mineProfileConditionsSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'1 项记录'**
  String get mineProfileConditionsSubtitle;

  /// No description provided for @mineProfileMedicinesTitle.
  ///
  /// In zh, this message translates to:
  /// **'当前用药'**
  String get mineProfileMedicinesTitle;

  /// No description provided for @mineProfileMedicinesSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'3 种药品'**
  String get mineProfileMedicinesSubtitle;

  /// No description provided for @mineSettingsThemeTitle.
  ///
  /// In zh, this message translates to:
  /// **'主题模式'**
  String get mineSettingsThemeTitle;

  /// No description provided for @mineSettingsAccountTitle.
  ///
  /// In zh, this message translates to:
  /// **'账号与安全'**
  String get mineSettingsAccountTitle;

  /// No description provided for @mineSettingsLanguageTitle.
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get mineSettingsLanguageTitle;

  /// No description provided for @mineSettingsNotificationsTitle.
  ///
  /// In zh, this message translates to:
  /// **'通知设置'**
  String get mineSettingsNotificationsTitle;

  /// No description provided for @settingsLanguageSystemLabel.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get settingsLanguageSystemLabel;

  /// No description provided for @settingsLanguageChineseLabel.
  ///
  /// In zh, this message translates to:
  /// **'简体中文'**
  String get settingsLanguageChineseLabel;

  /// No description provided for @settingsLanguageEnglishLabel.
  ///
  /// In zh, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglishLabel;

  /// No description provided for @settingsThemeAppearanceTitle.
  ///
  /// In zh, this message translates to:
  /// **'外观'**
  String get settingsThemeAppearanceTitle;

  /// No description provided for @settingsThemePaletteTitle.
  ///
  /// In zh, this message translates to:
  /// **'配色'**
  String get settingsThemePaletteTitle;

  /// No description provided for @settingsThemePaletteClassic.
  ///
  /// In zh, this message translates to:
  /// **'默认'**
  String get settingsThemePaletteClassic;

  /// No description provided for @settingsThemePaletteBluePink.
  ///
  /// In zh, this message translates to:
  /// **'蓝粉'**
  String get settingsThemePaletteBluePink;

  /// No description provided for @settingsThemePaletteYellowGreen.
  ///
  /// In zh, this message translates to:
  /// **'黄绿'**
  String get settingsThemePaletteYellowGreen;

  /// No description provided for @settingsSyncFailed.
  ///
  /// In zh, this message translates to:
  /// **'同步设置失败'**
  String get settingsSyncFailed;

  /// No description provided for @settingsNotificationsMedicationReminders.
  ///
  /// In zh, this message translates to:
  /// **'用药提醒'**
  String get settingsNotificationsMedicationReminders;

  /// No description provided for @settingsNotificationsHealthAlerts.
  ///
  /// In zh, this message translates to:
  /// **'健康提醒'**
  String get settingsNotificationsHealthAlerts;

  /// No description provided for @settingsNotificationsWeeklySummary.
  ///
  /// In zh, this message translates to:
  /// **'每周摘要'**
  String get settingsNotificationsWeeklySummary;

  /// No description provided for @settingsNotificationsPermissionEnabled.
  ///
  /// In zh, this message translates to:
  /// **'系统通知已开启'**
  String get settingsNotificationsPermissionEnabled;

  /// No description provided for @settingsNotificationsPermissionDisabled.
  ///
  /// In zh, this message translates to:
  /// **'系统通知未开启'**
  String get settingsNotificationsPermissionDisabled;

  /// No description provided for @settingsNotificationsPermissionUnsupported.
  ///
  /// In zh, this message translates to:
  /// **'当前平台不提供通知权限状态'**
  String get settingsNotificationsPermissionUnsupported;

  /// No description provided for @settingsNotificationsPermissionEnabledHint.
  ///
  /// In zh, this message translates to:
  /// **'通知已授权。下方开关可控制各类通知的显示。'**
  String get settingsNotificationsPermissionEnabledHint;

  /// No description provided for @settingsNotificationsPermissionDisabledHint.
  ///
  /// In zh, this message translates to:
  /// **'点击可打开系统权限对话框。系统通知权限未开启时，本地提醒无法显示。'**
  String get settingsNotificationsPermissionDisabledHint;

  /// No description provided for @mineErrorTitle.
  ///
  /// In zh, this message translates to:
  /// **'我的页面暂时没有加载出来'**
  String get mineErrorTitle;

  /// No description provided for @mineErrorDescription.
  ///
  /// In zh, this message translates to:
  /// **'结构已经接好，可以重新拉取一次数据。'**
  String get mineErrorDescription;

  /// No description provided for @mineActionToast.
  ///
  /// In zh, this message translates to:
  /// **'{action}：后续会接入对应详情或设置流程。'**
  String mineActionToast(String action);

  /// No description provided for @todaySectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'今日工作区'**
  String get todaySectionTitle;

  /// No description provided for @todaySectionSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'新的首页会从这里逐步接入提醒、快照、喝水与 Lumi 建议。'**
  String get todaySectionSubtitle;

  /// No description provided for @authWelcomeBack.
  ///
  /// In zh, this message translates to:
  /// **'欢迎回来'**
  String get authWelcomeBack;

  /// No description provided for @authCreateAccount.
  ///
  /// In zh, this message translates to:
  /// **'创建账号'**
  String get authCreateAccount;

  /// No description provided for @authModePassword.
  ///
  /// In zh, this message translates to:
  /// **'密码'**
  String get authModePassword;

  /// No description provided for @authModeCode.
  ///
  /// In zh, this message translates to:
  /// **'验证码'**
  String get authModeCode;

  /// No description provided for @authEmailLabel.
  ///
  /// In zh, this message translates to:
  /// **'邮箱'**
  String get authEmailLabel;

  /// No description provided for @authEmailHint.
  ///
  /// In zh, this message translates to:
  /// **'name@example.com'**
  String get authEmailHint;

  /// No description provided for @authPasswordLabel.
  ///
  /// In zh, this message translates to:
  /// **'密码'**
  String get authPasswordLabel;

  /// No description provided for @authPasswordHint.
  ///
  /// In zh, this message translates to:
  /// **'至少 8 位，建议包含大小写和数字'**
  String get authPasswordHint;

  /// No description provided for @authCodeLabel.
  ///
  /// In zh, this message translates to:
  /// **'验证码'**
  String get authCodeLabel;

  /// No description provided for @authNicknameLabel.
  ///
  /// In zh, this message translates to:
  /// **'昵称'**
  String get authNicknameLabel;

  /// No description provided for @authNicknameHint.
  ///
  /// In zh, this message translates to:
  /// **'可选'**
  String get authNicknameHint;

  /// No description provided for @authEmailRequiredToast.
  ///
  /// In zh, this message translates to:
  /// **'请先填写邮箱。'**
  String get authEmailRequiredToast;

  /// No description provided for @authCodeRequiredToast.
  ///
  /// In zh, this message translates to:
  /// **'请先填写验证码。'**
  String get authCodeRequiredToast;

  /// No description provided for @authPasswordRequiredToast.
  ///
  /// In zh, this message translates to:
  /// **'请先填写密码。'**
  String get authPasswordRequiredToast;

  /// No description provided for @authConfirmPasswordRequiredToast.
  ///
  /// In zh, this message translates to:
  /// **'请先确认密码。'**
  String get authConfirmPasswordRequiredToast;

  /// No description provided for @authSendCode.
  ///
  /// In zh, this message translates to:
  /// **'发送验证码'**
  String get authSendCode;

  /// No description provided for @authSendCodeAgain.
  ///
  /// In zh, this message translates to:
  /// **'{seconds} 秒后重发'**
  String authSendCodeAgain(int seconds);

  /// No description provided for @authSignIn.
  ///
  /// In zh, this message translates to:
  /// **'登录'**
  String get authSignIn;

  /// No description provided for @authWechatSignIn.
  ///
  /// In zh, this message translates to:
  /// **'微信登录'**
  String get authWechatSignIn;

  /// No description provided for @authWechatAuthorizeOpened.
  ///
  /// In zh, this message translates to:
  /// **'已在浏览器打开微信授权页。'**
  String get authWechatAuthorizeOpened;

  /// No description provided for @authWechatBrowserOpenFailed.
  ///
  /// In zh, this message translates to:
  /// **'无法打开微信授权页。'**
  String get authWechatBrowserOpenFailed;

  /// No description provided for @authWechatCallbackLabel.
  ///
  /// In zh, this message translates to:
  /// **'微信回调链接 / 授权码'**
  String get authWechatCallbackLabel;

  /// No description provided for @authWechatCallbackHint.
  ///
  /// In zh, this message translates to:
  /// **'扫码后粘贴回调链接'**
  String get authWechatCallbackHint;

  /// No description provided for @authWechatCompleteAction.
  ///
  /// In zh, this message translates to:
  /// **'完成微信登录'**
  String get authWechatCompleteAction;

  /// No description provided for @authWechatCallbackRequiredToast.
  ///
  /// In zh, this message translates to:
  /// **'请先粘贴微信回调链接。'**
  String get authWechatCallbackRequiredToast;

  /// No description provided for @authWechatCallbackInvalidToast.
  ///
  /// In zh, this message translates to:
  /// **'微信回调链接缺少 code 或 state。'**
  String get authWechatCallbackInvalidToast;

  /// No description provided for @authCreateAccountAction.
  ///
  /// In zh, this message translates to:
  /// **'创建账号'**
  String get authCreateAccountAction;

  /// No description provided for @authForgotPasswordPrompt.
  ///
  /// In zh, this message translates to:
  /// **'忘记密码？'**
  String get authForgotPasswordPrompt;

  /// No description provided for @authResetPasswordAction.
  ///
  /// In zh, this message translates to:
  /// **'重置密码'**
  String get authResetPasswordAction;

  /// No description provided for @authNeedAccountPrompt.
  ///
  /// In zh, this message translates to:
  /// **'还没有账号？'**
  String get authNeedAccountPrompt;

  /// No description provided for @authRegisterNowAction.
  ///
  /// In zh, this message translates to:
  /// **'立即注册'**
  String get authRegisterNowAction;

  /// No description provided for @authHaveAccountPrompt.
  ///
  /// In zh, this message translates to:
  /// **'已经有账号？'**
  String get authHaveAccountPrompt;

  /// No description provided for @authRememberPasswordPrompt.
  ///
  /// In zh, this message translates to:
  /// **'想起密码了？'**
  String get authRememberPasswordPrompt;

  /// No description provided for @authNewPasswordLabel.
  ///
  /// In zh, this message translates to:
  /// **'新密码'**
  String get authNewPasswordLabel;

  /// No description provided for @authConfirmPasswordLabel.
  ///
  /// In zh, this message translates to:
  /// **'确认密码'**
  String get authConfirmPasswordLabel;

  /// No description provided for @authPasswordsDoNotMatch.
  ///
  /// In zh, this message translates to:
  /// **'两次输入的密码不一致。'**
  String get authPasswordsDoNotMatch;

  /// No description provided for @authResetPasswordSubmit.
  ///
  /// In zh, this message translates to:
  /// **'重置密码'**
  String get authResetPasswordSubmit;

  /// No description provided for @authResetPasswordSuccess.
  ///
  /// In zh, this message translates to:
  /// **'密码已更新，请重新登录。'**
  String get authResetPasswordSuccess;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'登录以继续你的健康记录'**
  String get authLoginSubtitle;

  /// No description provided for @authRegisterSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'加入 Luminous,开启你的健康记录'**
  String get authRegisterSubtitle;

  /// No description provided for @authForgotPasswordSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'我们将发送验证码以重置你的密码'**
  String get authForgotPasswordSubtitle;

  /// No description provided for @authTermsAgreement.
  ///
  /// In zh, this message translates to:
  /// **'创建即表示同意{terms}与{privacy}'**
  String authTermsAgreement(String terms, String privacy);

  /// No description provided for @authTermsOfService.
  ///
  /// In zh, this message translates to:
  /// **'服务条款'**
  String get authTermsOfService;

  /// No description provided for @authPrivacyPolicy.
  ///
  /// In zh, this message translates to:
  /// **'隐私政策'**
  String get authPrivacyPolicy;

  /// No description provided for @authTermsComingSoonToast.
  ///
  /// In zh, this message translates to:
  /// **'服务条款与隐私政策即将上线。'**
  String get authTermsComingSoonToast;

  /// No description provided for @authChangeEmailFormTitle.
  ///
  /// In zh, this message translates to:
  /// **'更换邮箱'**
  String get authChangeEmailFormTitle;

  /// No description provided for @authNewEmailLabel.
  ///
  /// In zh, this message translates to:
  /// **'新邮箱'**
  String get authNewEmailLabel;

  /// No description provided for @authChangeEmailSubmit.
  ///
  /// In zh, this message translates to:
  /// **'更新邮箱'**
  String get authChangeEmailSubmit;

  /// No description provided for @authChangeEmailSuccess.
  ///
  /// In zh, this message translates to:
  /// **'邮箱已更新。'**
  String get authChangeEmailSuccess;

  /// No description provided for @authAccountSettingsFormTitle.
  ///
  /// In zh, this message translates to:
  /// **'账号与安全'**
  String get authAccountSettingsFormTitle;

  /// No description provided for @authAccountOverviewTitle.
  ///
  /// In zh, this message translates to:
  /// **'账号状态'**
  String get authAccountOverviewTitle;

  /// No description provided for @authAccountOverviewEmail.
  ///
  /// In zh, this message translates to:
  /// **'邮箱'**
  String get authAccountOverviewEmail;

  /// No description provided for @authAccountOverviewEmailVerified.
  ///
  /// In zh, this message translates to:
  /// **'邮箱验证'**
  String get authAccountOverviewEmailVerified;

  /// No description provided for @authAccountOverviewPassword.
  ///
  /// In zh, this message translates to:
  /// **'密码'**
  String get authAccountOverviewPassword;

  /// No description provided for @authAccountOverviewLastLogin.
  ///
  /// In zh, this message translates to:
  /// **'上次登录'**
  String get authAccountOverviewLastLogin;

  /// No description provided for @authEmailMissing.
  ///
  /// In zh, this message translates to:
  /// **'未设置'**
  String get authEmailMissing;

  /// No description provided for @authEmailVerifiedAt.
  ///
  /// In zh, this message translates to:
  /// **'{time} 已验证'**
  String authEmailVerifiedAt(String time);

  /// No description provided for @authEmailUnverifiedStatus.
  ///
  /// In zh, this message translates to:
  /// **'未验证'**
  String get authEmailUnverifiedStatus;

  /// No description provided for @authPasswordSetStatus.
  ///
  /// In zh, this message translates to:
  /// **'已设置'**
  String get authPasswordSetStatus;

  /// No description provided for @authPasswordUnsetStatus.
  ///
  /// In zh, this message translates to:
  /// **'未设置'**
  String get authPasswordUnsetStatus;

  /// No description provided for @authLastLoginUnknown.
  ///
  /// In zh, this message translates to:
  /// **'未知'**
  String get authLastLoginUnknown;

  /// No description provided for @authProfileSectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'资料信息'**
  String get authProfileSectionTitle;

  /// No description provided for @authProfileSectionDescription.
  ///
  /// In zh, this message translates to:
  /// **'修改昵称或头像地址；留空会按 Lucent 当前规则清空对应字段。'**
  String get authProfileSectionDescription;

  /// No description provided for @authAvatarLabel.
  ///
  /// In zh, this message translates to:
  /// **'头像地址'**
  String get authAvatarLabel;

  /// No description provided for @authAvatarHint.
  ///
  /// In zh, this message translates to:
  /// **'https://example.com/avatar.png'**
  String get authAvatarHint;

  /// No description provided for @authProfileSaveAction.
  ///
  /// In zh, this message translates to:
  /// **'保存资料'**
  String get authProfileSaveAction;

  /// No description provided for @authProfileSaveSuccess.
  ///
  /// In zh, this message translates to:
  /// **'资料已更新。'**
  String get authProfileSaveSuccess;

  /// No description provided for @authEmailSectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'登录邮箱'**
  String get authEmailSectionTitle;

  /// No description provided for @authEmailVerifiedDescription.
  ///
  /// In zh, this message translates to:
  /// **'当前邮箱已经验证，可以继续更换登录邮箱。'**
  String get authEmailVerifiedDescription;

  /// No description provided for @authEmailUnverifiedDescription.
  ///
  /// In zh, this message translates to:
  /// **'当前邮箱仍未验证；你仍可以进入更换邮箱流程。'**
  String get authEmailUnverifiedDescription;

  /// No description provided for @authEmailAddAction.
  ///
  /// In zh, this message translates to:
  /// **'添加邮箱'**
  String get authEmailAddAction;

  /// No description provided for @authEmailChangeAction.
  ///
  /// In zh, this message translates to:
  /// **'更换邮箱'**
  String get authEmailChangeAction;

  /// No description provided for @authLinkedIdentitiesSectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'第三方身份'**
  String get authLinkedIdentitiesSectionTitle;

  /// No description provided for @authLinkedIdentityNone.
  ///
  /// In zh, this message translates to:
  /// **'尚未绑定第三方身份。'**
  String get authLinkedIdentityNone;

  /// No description provided for @authLinkedIdentityEmailMissing.
  ///
  /// In zh, this message translates to:
  /// **'无第三方邮箱'**
  String get authLinkedIdentityEmailMissing;

  /// No description provided for @authLinkedIdentityLinkedAt.
  ///
  /// In zh, this message translates to:
  /// **'{date} 绑定'**
  String authLinkedIdentityLinkedAt(String date);

  /// No description provided for @authIdentityProviderWechatWeb.
  ///
  /// In zh, this message translates to:
  /// **'微信网页'**
  String get authIdentityProviderWechatWeb;

  /// No description provided for @authIdentityProviderWechatMobile.
  ///
  /// In zh, this message translates to:
  /// **'微信移动端'**
  String get authIdentityProviderWechatMobile;

  /// No description provided for @authIdentityUnlinkAction.
  ///
  /// In zh, this message translates to:
  /// **'解绑'**
  String get authIdentityUnlinkAction;

  /// No description provided for @authIdentityUnlinkDisabledAction.
  ///
  /// In zh, this message translates to:
  /// **'保留'**
  String get authIdentityUnlinkDisabledAction;

  /// No description provided for @authIdentityUnlinkSuccess.
  ///
  /// In zh, this message translates to:
  /// **'身份已解绑。'**
  String get authIdentityUnlinkSuccess;

  /// No description provided for @authIdentityUnlinkConfirmTitle.
  ///
  /// In zh, this message translates to:
  /// **'解绑身份'**
  String get authIdentityUnlinkConfirmTitle;

  /// No description provided for @authIdentityUnlinkConfirmMessage.
  ///
  /// In zh, this message translates to:
  /// **'确定要解绑 {provider}？'**
  String authIdentityUnlinkConfirmMessage(String provider);

  /// No description provided for @authIdentityLinkWechatAction.
  ///
  /// In zh, this message translates to:
  /// **'绑定微信'**
  String get authIdentityLinkWechatAction;

  /// No description provided for @authIdentityLinkSuccess.
  ///
  /// In zh, this message translates to:
  /// **'微信身份已绑定。'**
  String get authIdentityLinkSuccess;

  /// No description provided for @authIdentityLinkUnsupported.
  ///
  /// In zh, this message translates to:
  /// **'当前平台无法打开微信绑定。'**
  String get authIdentityLinkUnsupported;

  /// No description provided for @authCancelAction.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get authCancelAction;

  /// No description provided for @authPasswordSectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'修改密码'**
  String get authPasswordSectionTitle;

  /// No description provided for @authPasswordSectionDescription.
  ///
  /// In zh, this message translates to:
  /// **'修改后当前账号的 refresh 会话会全部失效，你需要重新登录。'**
  String get authPasswordSectionDescription;

  /// No description provided for @authPasswordUnsetManagementHint.
  ///
  /// In zh, this message translates to:
  /// **'当前账号还没有本地密码。'**
  String get authPasswordUnsetManagementHint;

  /// No description provided for @authCurrentPasswordLabel.
  ///
  /// In zh, this message translates to:
  /// **'当前密码'**
  String get authCurrentPasswordLabel;

  /// No description provided for @authCurrentPasswordRequiredToast.
  ///
  /// In zh, this message translates to:
  /// **'请先填写当前密码。'**
  String get authCurrentPasswordRequiredToast;

  /// No description provided for @authNewPasswordRequiredToast.
  ///
  /// In zh, this message translates to:
  /// **'请先填写新密码。'**
  String get authNewPasswordRequiredToast;

  /// No description provided for @authChangePasswordAction.
  ///
  /// In zh, this message translates to:
  /// **'更新密码'**
  String get authChangePasswordAction;

  /// No description provided for @authChangePasswordSuccess.
  ///
  /// In zh, this message translates to:
  /// **'密码已更新，请重新登录。'**
  String get authChangePasswordSuccess;

  /// No description provided for @authDeleteAccountSectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'注销账号'**
  String get authDeleteAccountSectionTitle;

  /// No description provided for @authDeleteAccountSectionDescription.
  ///
  /// In zh, this message translates to:
  /// **'这是高风险操作；提交后会清空本地会话并让 Lucent 将账号标记为删除状态。'**
  String get authDeleteAccountSectionDescription;

  /// No description provided for @authDeleteAccountPasswordRequiredHint.
  ///
  /// In zh, this message translates to:
  /// **'当前账号暂不能在这里注销。'**
  String get authDeleteAccountPasswordRequiredHint;

  /// No description provided for @authDeleteAccountHint.
  ///
  /// In zh, this message translates to:
  /// **'输入当前密码以确认注销'**
  String get authDeleteAccountHint;

  /// No description provided for @authDeleteAccountAction.
  ///
  /// In zh, this message translates to:
  /// **'注销账号'**
  String get authDeleteAccountAction;

  /// No description provided for @authDeleteAccountSuccess.
  ///
  /// In zh, this message translates to:
  /// **'账号已注销。'**
  String get authDeleteAccountSuccess;

  /// No description provided for @authBackHomePrompt.
  ///
  /// In zh, this message translates to:
  /// **'返回首页？'**
  String get authBackHomePrompt;

  /// No description provided for @authCheckingSession.
  ///
  /// In zh, this message translates to:
  /// **'正在检查登录状态...'**
  String get authCheckingSession;

  /// No description provided for @authNotSignedIn.
  ///
  /// In zh, this message translates to:
  /// **'尚未登录'**
  String get authNotSignedIn;

  /// No description provided for @authLoginRequiredPrompt.
  ///
  /// In zh, this message translates to:
  /// **'是否去登录'**
  String get authLoginRequiredPrompt;

  /// No description provided for @authGoLogin.
  ///
  /// In zh, this message translates to:
  /// **'去登录'**
  String get authGoLogin;

  /// No description provided for @authGoRegister.
  ///
  /// In zh, this message translates to:
  /// **'去注册'**
  String get authGoRegister;

  /// No description provided for @authSignOut.
  ///
  /// In zh, this message translates to:
  /// **'退出登录'**
  String get authSignOut;

  /// No description provided for @todayHeroTitle.
  ///
  /// In zh, this message translates to:
  /// **'今日'**
  String get todayHeroTitle;

  /// No description provided for @todayHeroDescription.
  ///
  /// In zh, this message translates to:
  /// **'新的首页将从这里开始重建：先完成响应式视觉系统，再逐步接入喝水、提醒、健康快照和 Lumi 建议。'**
  String get todayHeroDescription;

  /// No description provided for @todayChipWater.
  ///
  /// In zh, this message translates to:
  /// **'喝水追踪'**
  String get todayChipWater;

  /// No description provided for @todayChipMedication.
  ///
  /// In zh, this message translates to:
  /// **'用药提醒'**
  String get todayChipMedication;

  /// No description provided for @todayChipSnapshot.
  ///
  /// In zh, this message translates to:
  /// **'健康快照'**
  String get todayChipSnapshot;

  /// No description provided for @todayChipDiet.
  ///
  /// In zh, this message translates to:
  /// **'饮食建议'**
  String get todayChipDiet;

  /// No description provided for @todayChipEnvironment.
  ///
  /// In zh, this message translates to:
  /// **'环境提醒'**
  String get todayChipEnvironment;

  /// No description provided for @todayChipLumi.
  ///
  /// In zh, this message translates to:
  /// **'Lumi 建议'**
  String get todayChipLumi;

  /// No description provided for @todayNotificationsTooltip.
  ///
  /// In zh, this message translates to:
  /// **'通知'**
  String get todayNotificationsTooltip;

  /// No description provided for @todayGreetingTitleMorning.
  ///
  /// In zh, this message translates to:
  /// **'早上好，阳光正好'**
  String get todayGreetingTitleMorning;

  /// No description provided for @todayGreetingTitleAfternoon.
  ///
  /// In zh, this message translates to:
  /// **'下午好，继续稳稳推进'**
  String get todayGreetingTitleAfternoon;

  /// No description provided for @todayGreetingTitleEvening.
  ///
  /// In zh, this message translates to:
  /// **'晚上好，准备轻松收尾'**
  String get todayGreetingTitleEvening;

  /// No description provided for @todayGreetingSubtitleMorning.
  ///
  /// In zh, this message translates to:
  /// **'早上好，照顾好自己每一天'**
  String get todayGreetingSubtitleMorning;

  /// No description provided for @todayGreetingSubtitleAfternoon.
  ///
  /// In zh, this message translates to:
  /// **'下午好，照顾好自己每一天'**
  String get todayGreetingSubtitleAfternoon;

  /// No description provided for @todayGreetingSubtitleEvening.
  ///
  /// In zh, this message translates to:
  /// **'晚上好，照顾好自己每一天'**
  String get todayGreetingSubtitleEvening;

  /// No description provided for @todayHeroCareLine.
  ///
  /// In zh, this message translates to:
  /// **'我们会在需要时，给你恰到好处的提醒'**
  String get todayHeroCareLine;

  /// No description provided for @todayHeroImagePlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'Banner 图片占位'**
  String get todayHeroImagePlaceholder;

  /// No description provided for @todayWaterCardTitle.
  ///
  /// In zh, this message translates to:
  /// **'今日喝水'**
  String get todayWaterCardTitle;

  /// No description provided for @todayWaterUnit.
  ///
  /// In zh, this message translates to:
  /// **'次'**
  String get todayWaterUnit;

  /// No description provided for @todayWaterCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 次'**
  String todayWaterCount(int count);

  /// No description provided for @todayWaterGoalCount.
  ///
  /// In zh, this message translates to:
  /// **'目标 {count} 次'**
  String todayWaterGoalCount(int count);

  /// No description provided for @todayWaterOverviewCount.
  ///
  /// In zh, this message translates to:
  /// **'{done}/{target} 次'**
  String todayWaterOverviewCount(int done, int target);

  /// No description provided for @todayWaterRemainingCount.
  ///
  /// In zh, this message translates to:
  /// **'还差 {count} 次'**
  String todayWaterRemainingCount(int count);

  /// No description provided for @todayMedicationCardTitle.
  ///
  /// In zh, this message translates to:
  /// **'用药提醒'**
  String get todayMedicationCardTitle;

  /// No description provided for @todayMedicationAction.
  ///
  /// In zh, this message translates to:
  /// **'查看'**
  String get todayMedicationAction;

  /// No description provided for @todayMedicationSummary.
  ///
  /// In zh, this message translates to:
  /// **'{medicineCount} 种药品 · {pendingCount} 个待服用'**
  String todayMedicationSummary(int medicineCount, int pendingCount);

  /// No description provided for @todayMedicationNextDose.
  ///
  /// In zh, this message translates to:
  /// **'下一次 {time} · {medicineName}'**
  String todayMedicationNextDose(String time, String medicineName);

  /// No description provided for @todayMedicationNameAtorvastatin.
  ///
  /// In zh, this message translates to:
  /// **'阿托伐他汀'**
  String get todayMedicationNameAtorvastatin;

  /// No description provided for @todayMedicationNameVitaminBComplex.
  ///
  /// In zh, this message translates to:
  /// **'维生素B族'**
  String get todayMedicationNameVitaminBComplex;

  /// No description provided for @todayHealthSummaryCardTitle.
  ///
  /// In zh, this message translates to:
  /// **'今日摘要'**
  String get todayHealthSummaryCardTitle;

  /// No description provided for @todayVitalHeartRateLabel.
  ///
  /// In zh, this message translates to:
  /// **'心率'**
  String get todayVitalHeartRateLabel;

  /// No description provided for @todayVitalHeartRateUnit.
  ///
  /// In zh, this message translates to:
  /// **'次/分'**
  String get todayVitalHeartRateUnit;

  /// No description provided for @todayVitalBloodPressureLabel.
  ///
  /// In zh, this message translates to:
  /// **'血压'**
  String get todayVitalBloodPressureLabel;

  /// No description provided for @todayVitalSleepLabel.
  ///
  /// In zh, this message translates to:
  /// **'睡眠'**
  String get todayVitalSleepLabel;

  /// No description provided for @todayVitalSleepUnit.
  ///
  /// In zh, this message translates to:
  /// **'小时'**
  String get todayVitalSleepUnit;

  /// No description provided for @todaySleepFallbackValue.
  ///
  /// In zh, this message translates to:
  /// **'--'**
  String get todaySleepFallbackValue;

  /// No description provided for @todayVitalStatusNormal.
  ///
  /// In zh, this message translates to:
  /// **'正常'**
  String get todayVitalStatusNormal;

  /// No description provided for @todayVitalStatusGood.
  ///
  /// In zh, this message translates to:
  /// **'良好'**
  String get todayVitalStatusGood;

  /// No description provided for @todayMealCardTitle.
  ///
  /// In zh, this message translates to:
  /// **'今日饮食建议'**
  String get todayMealCardTitle;

  /// No description provided for @todayMealHighProteinBalancedTitle.
  ///
  /// In zh, this message translates to:
  /// **'高蛋白均衡餐'**
  String get todayMealHighProteinBalancedTitle;

  /// No description provided for @todayMealHighProteinBalancedDescription.
  ///
  /// In zh, this message translates to:
  /// **'鸡胸肉、藜麦、时蔬沙拉'**
  String get todayMealHighProteinBalancedDescription;

  /// No description provided for @todayMealEnergyHint.
  ///
  /// In zh, this message translates to:
  /// **'补充优质蛋白，均衡营养，给身体满满能量。'**
  String get todayMealEnergyHint;

  /// No description provided for @todayMealImagePlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'餐图占位'**
  String get todayMealImagePlaceholder;

  /// No description provided for @todayMealRefreshAction.
  ///
  /// In zh, this message translates to:
  /// **'换一换'**
  String get todayMealRefreshAction;

  /// No description provided for @todayEnvironmentCardTitle.
  ///
  /// In zh, this message translates to:
  /// **'环境提醒'**
  String get todayEnvironmentCardTitle;

  /// No description provided for @todayEnvironmentPollenLabel.
  ///
  /// In zh, this message translates to:
  /// **'花粉'**
  String get todayEnvironmentPollenLabel;

  /// No description provided for @todayEnvironmentUvLabel.
  ///
  /// In zh, this message translates to:
  /// **'紫外线'**
  String get todayEnvironmentUvLabel;

  /// No description provided for @todayEnvironmentLevelLow.
  ///
  /// In zh, this message translates to:
  /// **'较低'**
  String get todayEnvironmentLevelLow;

  /// No description provided for @todayEnvironmentLevelMedium.
  ///
  /// In zh, this message translates to:
  /// **'中等'**
  String get todayEnvironmentLevelMedium;

  /// No description provided for @todayEnvironmentLevelHigh.
  ///
  /// In zh, this message translates to:
  /// **'较高'**
  String get todayEnvironmentLevelHigh;

  /// No description provided for @todayMoreAction.
  ///
  /// In zh, this message translates to:
  /// **'更多'**
  String get todayMoreAction;

  /// No description provided for @todayViewDetailsAction.
  ///
  /// In zh, this message translates to:
  /// **'查看详情'**
  String get todayViewDetailsAction;

  /// No description provided for @todayLumiCardTitle.
  ///
  /// In zh, this message translates to:
  /// **'Lumi 建议'**
  String get todayLumiCardTitle;

  /// No description provided for @todayPreviewBadge.
  ///
  /// In zh, this message translates to:
  /// **'预览'**
  String get todayPreviewBadge;

  /// No description provided for @todayLumiPollenProtectionBody.
  ///
  /// In zh, this message translates to:
  /// **'今天空气中花粉较多，建议外出佩戴口罩，注意防护呼吸敏感。'**
  String get todayLumiPollenProtectionBody;

  /// No description provided for @todayLumiAction.
  ///
  /// In zh, this message translates to:
  /// **'查看详情'**
  String get todayLumiAction;

  /// No description provided for @todayErrorTitle.
  ///
  /// In zh, this message translates to:
  /// **'今日页暂时没有加载出来'**
  String get todayErrorTitle;

  /// No description provided for @todayErrorDescription.
  ///
  /// In zh, this message translates to:
  /// **'页面结构已经接好，可以重新拉取一次看看。'**
  String get todayErrorDescription;

  /// No description provided for @todayEmptyTitle.
  ///
  /// In zh, this message translates to:
  /// **'你还没有任何记录'**
  String get todayEmptyTitle;

  /// No description provided for @todayEmptyDescription.
  ///
  /// In zh, this message translates to:
  /// **'先记录饮水、用药或睡眠，我们会为你提供个性化建议。'**
  String get todayEmptyDescription;

  /// No description provided for @todayEmptyAction.
  ///
  /// In zh, this message translates to:
  /// **'去记录'**
  String get todayEmptyAction;

  /// No description provided for @todayRetryAction.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get todayRetryAction;

  /// No description provided for @assistantPageTitle.
  ///
  /// In zh, this message translates to:
  /// **'AI 对话'**
  String get assistantPageTitle;

  /// No description provided for @assistantSignedOutDescription.
  ///
  /// In zh, this message translates to:
  /// **'登录后才可以使用 AI 对话，并由你决定是否开放健康上下文。'**
  String get assistantSignedOutDescription;

  /// No description provided for @assistantLoadErrorTitle.
  ///
  /// In zh, this message translates to:
  /// **'AI 对话暂时没有加载出来'**
  String get assistantLoadErrorTitle;

  /// No description provided for @assistantLoadErrorFallback.
  ///
  /// In zh, this message translates to:
  /// **'能力信息这次没有取到，可以重新拉取一次。'**
  String get assistantLoadErrorFallback;

  /// No description provided for @assistantSettingsEnableTitle.
  ///
  /// In zh, this message translates to:
  /// **'启用 AI 对话'**
  String get assistantSettingsEnableTitle;

  /// No description provided for @assistantSettingsEnableSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'关闭后不会发送新的对话请求'**
  String get assistantSettingsEnableSubtitle;

  /// No description provided for @assistantSettingsMemoryTitle.
  ///
  /// In zh, this message translates to:
  /// **'启用持久化记忆'**
  String get assistantSettingsMemoryTitle;

  /// No description provided for @assistantSettingsMemorySubtitle.
  ///
  /// In zh, this message translates to:
  /// **'新对话开始时，可选择让助手参考之前的对话历史'**
  String get assistantSettingsMemorySubtitle;

  /// No description provided for @assistantContextHealthProfile.
  ///
  /// In zh, this message translates to:
  /// **'健康档案'**
  String get assistantContextHealthProfile;

  /// No description provided for @assistantContextDailyRecords.
  ///
  /// In zh, this message translates to:
  /// **'最近记录'**
  String get assistantContextDailyRecords;

  /// No description provided for @assistantContextSleepRecords.
  ///
  /// In zh, this message translates to:
  /// **'睡眠数据'**
  String get assistantContextSleepRecords;

  /// No description provided for @assistantContextCurrentMedicines.
  ///
  /// In zh, this message translates to:
  /// **'当前用药'**
  String get assistantContextCurrentMedicines;

  /// No description provided for @assistantStatusSectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'当前状态'**
  String get assistantStatusSectionTitle;

  /// No description provided for @assistantStatusReady.
  ///
  /// In zh, this message translates to:
  /// **'后端能力已就绪，可以开始对话。'**
  String get assistantStatusReady;

  /// No description provided for @assistantStatusDisabled.
  ///
  /// In zh, this message translates to:
  /// **'你已关闭 AI 对话，当前不会发送聊天请求。'**
  String get assistantStatusDisabled;

  /// No description provided for @assistantStatusModelMissing.
  ///
  /// In zh, this message translates to:
  /// **'服务端还没有可用的聊天模型配置。'**
  String get assistantStatusModelMissing;

  /// No description provided for @assistantStatusNotReady.
  ///
  /// In zh, this message translates to:
  /// **'交互式对话链路还没有完全就绪。'**
  String get assistantStatusNotReady;

  /// No description provided for @assistantStatusToolsLabel.
  ///
  /// In zh, this message translates to:
  /// **'工具'**
  String get assistantStatusToolsLabel;

  /// No description provided for @assistantStatusContextLabel.
  ///
  /// In zh, this message translates to:
  /// **'上下文'**
  String get assistantStatusContextLabel;

  /// No description provided for @assistantStatusStreamingLabel.
  ///
  /// In zh, this message translates to:
  /// **'流式输出'**
  String get assistantStatusStreamingLabel;

  /// No description provided for @assistantStatusRagLabel.
  ///
  /// In zh, this message translates to:
  /// **'RAG'**
  String get assistantStatusRagLabel;

  /// No description provided for @assistantConversationDisabledTitle.
  ///
  /// In zh, this message translates to:
  /// **'当前还不能开始对话'**
  String get assistantConversationDisabledTitle;

  /// No description provided for @assistantConversationDisabledByUser.
  ///
  /// In zh, this message translates to:
  /// **'你已关闭 AI 对话，重新开启后才能发送消息。'**
  String get assistantConversationDisabledByUser;

  /// No description provided for @assistantConversationModelMissing.
  ///
  /// In zh, this message translates to:
  /// **'服务端还没有可用模型，暂时无法生成回复。'**
  String get assistantConversationModelMissing;

  /// No description provided for @assistantConversationNotReady.
  ///
  /// In zh, this message translates to:
  /// **'交互式对话链路还没准备好，先保持当前设置即可。'**
  String get assistantConversationNotReady;

  /// No description provided for @assistantConversationEmptyTitle.
  ///
  /// In zh, this message translates to:
  /// **'开始第一条消息'**
  String get assistantConversationEmptyTitle;

  /// No description provided for @assistantConversationEmptyDescription.
  ///
  /// In zh, this message translates to:
  /// **'可以直接问最近睡眠、最近记录或当前用药相关的问题。'**
  String get assistantConversationEmptyDescription;

  /// No description provided for @assistantSendErrorTitle.
  ///
  /// In zh, this message translates to:
  /// **'这次回复没有完成'**
  String get assistantSendErrorTitle;

  /// No description provided for @assistantInputHint.
  ///
  /// In zh, this message translates to:
  /// **'比如：结合我最近几天的睡眠和用药，帮我看看要注意什么。'**
  String get assistantInputHint;

  /// No description provided for @assistantSendAction.
  ///
  /// In zh, this message translates to:
  /// **'发送'**
  String get assistantSendAction;

  /// No description provided for @assistantSendingAction.
  ///
  /// In zh, this message translates to:
  /// **'发送中'**
  String get assistantSendingAction;

  /// No description provided for @assistantNewConversationAction.
  ///
  /// In zh, this message translates to:
  /// **'新对话'**
  String get assistantNewConversationAction;

  /// No description provided for @assistantRecentConversationsAction.
  ///
  /// In zh, this message translates to:
  /// **'最近会话'**
  String get assistantRecentConversationsAction;

  /// No description provided for @assistantRecentConversationsTitle.
  ///
  /// In zh, this message translates to:
  /// **'最近会话'**
  String get assistantRecentConversationsTitle;

  /// No description provided for @assistantRecentConversationsEmptyTitle.
  ///
  /// In zh, this message translates to:
  /// **'还没有历史会话'**
  String get assistantRecentConversationsEmptyTitle;

  /// No description provided for @assistantRecentConversationsEmptyDescription.
  ///
  /// In zh, this message translates to:
  /// **'开始一次对话后，最近的会话会显示在这里。'**
  String get assistantRecentConversationsEmptyDescription;

  /// No description provided for @assistantRecentConversationCurrentLabel.
  ///
  /// In zh, this message translates to:
  /// **'当前'**
  String get assistantRecentConversationCurrentLabel;

  /// No description provided for @assistantOpeningConversationLabel.
  ///
  /// In zh, this message translates to:
  /// **'正在切换会话…'**
  String get assistantOpeningConversationLabel;

  /// No description provided for @assistantUntitledConversation.
  ///
  /// In zh, this message translates to:
  /// **'未命名会话'**
  String get assistantUntitledConversation;

  /// No description provided for @assistantStreamingLabel.
  ///
  /// In zh, this message translates to:
  /// **'正在生成'**
  String get assistantStreamingLabel;

  /// No description provided for @assistantRetryAction.
  ///
  /// In zh, this message translates to:
  /// **'重新发送'**
  String get assistantRetryAction;

  /// No description provided for @assistantErrorStreamInterrupted.
  ///
  /// In zh, this message translates to:
  /// **'连接中断了，请检查网络后重试。'**
  String get assistantErrorStreamInterrupted;

  /// No description provided for @assistantErrorEmptyResult.
  ///
  /// In zh, this message translates to:
  /// **'AI 没有返回有效内容，可以再试一次。'**
  String get assistantErrorEmptyResult;

  /// No description provided for @assistantErrorServer.
  ///
  /// In zh, this message translates to:
  /// **'服务端出现问题，请稍后再试。'**
  String get assistantErrorServer;

  /// No description provided for @assistantToolTodayRecords.
  ///
  /// In zh, this message translates to:
  /// **'今日记录'**
  String get assistantToolTodayRecords;

  /// No description provided for @assistantToolRecordsByDate.
  ///
  /// In zh, this message translates to:
  /// **'按日记录'**
  String get assistantToolRecordsByDate;

  /// No description provided for @assistantToolRecordsByRange.
  ///
  /// In zh, this message translates to:
  /// **'区间记录'**
  String get assistantToolRecordsByRange;

  /// No description provided for @assistantToolTodaySummaryByDate.
  ///
  /// In zh, this message translates to:
  /// **'指定日期总结'**
  String get assistantToolTodaySummaryByDate;

  /// No description provided for @assistantToolReportSummaryByRange.
  ///
  /// In zh, this message translates to:
  /// **'指定报告总结'**
  String get assistantToolReportSummaryByRange;

  /// No description provided for @assistantToolRecentTodaySummaries.
  ///
  /// In zh, this message translates to:
  /// **'今日历史总结'**
  String get assistantToolRecentTodaySummaries;

  /// No description provided for @assistantToolRecentReportSummaries.
  ///
  /// In zh, this message translates to:
  /// **'报告历史总结'**
  String get assistantToolRecentReportSummaries;

  /// No description provided for @assistantToolUserProfile.
  ///
  /// In zh, this message translates to:
  /// **'用户档案'**
  String get assistantToolUserProfile;

  /// No description provided for @assistantToolUserSettings.
  ///
  /// In zh, this message translates to:
  /// **'用户设置'**
  String get assistantToolUserSettings;

  /// No description provided for @assistantToolCurrentMedicines.
  ///
  /// In zh, this message translates to:
  /// **'当前用药'**
  String get assistantToolCurrentMedicines;

  /// No description provided for @assistantToolSleepByRange.
  ///
  /// In zh, this message translates to:
  /// **'睡眠概况'**
  String get assistantToolSleepByRange;

  /// No description provided for @assistantToolProposeCreateRecord.
  ///
  /// In zh, this message translates to:
  /// **'保存建议'**
  String get assistantToolProposeCreateRecord;

  /// No description provided for @assistantToolProposeUpdateRecord.
  ///
  /// In zh, this message translates to:
  /// **'修改建议'**
  String get assistantToolProposeUpdateRecord;

  /// No description provided for @assistantToolProposeDeleteRecord.
  ///
  /// In zh, this message translates to:
  /// **'删除建议'**
  String get assistantToolProposeDeleteRecord;

  /// No description provided for @assistantToolProposeUpdateSettings.
  ///
  /// In zh, this message translates to:
  /// **'设置建议'**
  String get assistantToolProposeUpdateSettings;

  /// No description provided for @assistantUsedToolsLabel.
  ///
  /// In zh, this message translates to:
  /// **'参考来源'**
  String get assistantUsedToolsLabel;

  /// No description provided for @assistantConversationDisabledByUserHint.
  ///
  /// In zh, this message translates to:
  /// **'你已关闭 AI 对话，打开上方的“启用 AI 对话”开关即可恢复。'**
  String get assistantConversationDisabledByUserHint;

  /// No description provided for @assistantProposalConfirmCreateAction.
  ///
  /// In zh, this message translates to:
  /// **'确认保存'**
  String get assistantProposalConfirmCreateAction;

  /// No description provided for @assistantProposalConfirmUpdateAction.
  ///
  /// In zh, this message translates to:
  /// **'确认修改'**
  String get assistantProposalConfirmUpdateAction;

  /// No description provided for @assistantProposalConfirmDeleteAction.
  ///
  /// In zh, this message translates to:
  /// **'确认删除'**
  String get assistantProposalConfirmDeleteAction;

  /// No description provided for @assistantProposalConfirmSettingsAction.
  ///
  /// In zh, this message translates to:
  /// **'确认更新'**
  String get assistantProposalConfirmSettingsAction;

  /// No description provided for @assistantProposalDismissAction.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get assistantProposalDismissAction;

  /// No description provided for @assistantProposalPendingState.
  ///
  /// In zh, this message translates to:
  /// **'待确认'**
  String get assistantProposalPendingState;

  /// No description provided for @assistantProposalExecutingState.
  ///
  /// In zh, this message translates to:
  /// **'执行中'**
  String get assistantProposalExecutingState;

  /// No description provided for @assistantProposalConfirmedState.
  ///
  /// In zh, this message translates to:
  /// **'已确认'**
  String get assistantProposalConfirmedState;

  /// No description provided for @assistantProposalDismissedState.
  ///
  /// In zh, this message translates to:
  /// **'已取消'**
  String get assistantProposalDismissedState;

  /// No description provided for @assistantProposalFailedState.
  ///
  /// In zh, this message translates to:
  /// **'执行失败'**
  String get assistantProposalFailedState;

  /// No description provided for @assistantProposalConfirmedToast.
  ///
  /// In zh, this message translates to:
  /// **'已执行这条建议。'**
  String get assistantProposalConfirmedToast;

  /// No description provided for @assistantProposalTargetLabel.
  ///
  /// In zh, this message translates to:
  /// **'目标'**
  String get assistantProposalTargetLabel;

  /// No description provided for @assistantProposalMatchedByLabel.
  ///
  /// In zh, this message translates to:
  /// **'定位方式'**
  String get assistantProposalMatchedByLabel;

  /// No description provided for @assistantProposalSettingKeysLabel.
  ///
  /// In zh, this message translates to:
  /// **'设置项'**
  String get assistantProposalSettingKeysLabel;

  /// No description provided for @assistantProposalExpiresAtLabel.
  ///
  /// In zh, this message translates to:
  /// **'过期时间'**
  String get assistantProposalExpiresAtLabel;

  /// No description provided for @assistantProposalConstraintsLabel.
  ///
  /// In zh, this message translates to:
  /// **'确认前约束'**
  String get assistantProposalConstraintsLabel;

  /// No description provided for @assistantProposalExpiredHint.
  ///
  /// In zh, this message translates to:
  /// **'这条建议已经过期，请重新生成后再确认。'**
  String get assistantProposalExpiredHint;

  /// No description provided for @todayUpdatedAt.
  ///
  /// In zh, this message translates to:
  /// **'更新于 {time}'**
  String todayUpdatedAt(String time);

  /// No description provided for @todayHydrationOverviewLabel.
  ///
  /// In zh, this message translates to:
  /// **'饮水'**
  String get todayHydrationOverviewLabel;

  /// No description provided for @todayMedicationOverviewLabel.
  ///
  /// In zh, this message translates to:
  /// **'用药'**
  String get todayMedicationOverviewLabel;

  /// No description provided for @todayStatusNeedsImprovement.
  ///
  /// In zh, this message translates to:
  /// **'待提升'**
  String get todayStatusNeedsImprovement;

  /// No description provided for @todayStatusCompleted.
  ///
  /// In zh, this message translates to:
  /// **'已完成'**
  String get todayStatusCompleted;

  /// No description provided for @todayMedicationPendingStatus.
  ///
  /// In zh, this message translates to:
  /// **'待服用'**
  String get todayMedicationPendingStatus;

  /// No description provided for @todayPrioritySectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'今日优先事项'**
  String get todayPrioritySectionTitle;

  /// No description provided for @todayManageAction.
  ///
  /// In zh, this message translates to:
  /// **'管理'**
  String get todayManageAction;

  /// No description provided for @todayMedicationPrioritySubtitle.
  ///
  /// In zh, this message translates to:
  /// **'今日 {count} 条待服用'**
  String todayMedicationPrioritySubtitle(int count);

  /// No description provided for @todayMedicationPriorityDetail.
  ///
  /// In zh, this message translates to:
  /// **'{time} {medicineName}'**
  String todayMedicationPriorityDetail(String time, String medicineName);

  /// No description provided for @todayMedicationTakeAction.
  ///
  /// In zh, this message translates to:
  /// **'去服用'**
  String get todayMedicationTakeAction;

  /// No description provided for @todayWaterPriorityTitle.
  ///
  /// In zh, this message translates to:
  /// **'饮水目标'**
  String get todayWaterPriorityTitle;

  /// No description provided for @todayDrinkWaterAction.
  ///
  /// In zh, this message translates to:
  /// **'去喝水'**
  String get todayDrinkWaterAction;

  /// No description provided for @todayAiSummaryTitle.
  ///
  /// In zh, this message translates to:
  /// **'AI 日总结'**
  String get todayAiSummaryTitle;

  /// No description provided for @todayAiSummarySubtitle.
  ///
  /// In zh, this message translates to:
  /// **'基于今日记录生成'**
  String get todayAiSummarySubtitle;

  /// No description provided for @todayAiSummaryGenerateAction.
  ///
  /// In zh, this message translates to:
  /// **'生成'**
  String get todayAiSummaryGenerateAction;

  /// No description provided for @todayAiSummaryGeneratingAction.
  ///
  /// In zh, this message translates to:
  /// **'生成中'**
  String get todayAiSummaryGeneratingAction;

  /// No description provided for @todayAiSummaryOpenSettingsAction.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get todayAiSummaryOpenSettingsAction;

  /// No description provided for @todayAiSummaryDefaultHint.
  ///
  /// In zh, this message translates to:
  /// **'点击生成后，会基于今日真实记录产出低风险总结。'**
  String get todayAiSummaryDefaultHint;

  /// No description provided for @todayAiSummaryGeneratingHint.
  ///
  /// In zh, this message translates to:
  /// **'正在整理今天的记录，请稍等一下。'**
  String get todayAiSummaryGeneratingHint;

  /// No description provided for @todayAiSummaryErrorHint.
  ///
  /// In zh, this message translates to:
  /// **'这次生成没有成功，可以再试一次。'**
  String get todayAiSummaryErrorHint;

  /// No description provided for @todayAiSummaryDisabledHint.
  ///
  /// In zh, this message translates to:
  /// **'AI 总结已在设置中关闭，开启后才会生成。'**
  String get todayAiSummaryDisabledHint;

  /// No description provided for @todayAiSummarySignedOutHint.
  ///
  /// In zh, this message translates to:
  /// **'登录后才会基于你的今日记录生成 AI 总结。'**
  String get todayAiSummarySignedOutHint;

  /// No description provided for @todayAiSummaryMedicationPending.
  ///
  /// In zh, this message translates to:
  /// **'还有 {count} 条用药需要确认，先不要自行调整剂量'**
  String todayAiSummaryMedicationPending(int count);

  /// No description provided for @todayAiSummaryMedicationDone.
  ///
  /// In zh, this message translates to:
  /// **'今日用药待办已处理，新增药物后仍需检查风险'**
  String get todayAiSummaryMedicationDone;

  /// No description provided for @todayAiSummaryWaterRemaining.
  ///
  /// In zh, this message translates to:
  /// **'饮水还差 {count} 次，可分几次补齐'**
  String todayAiSummaryWaterRemaining(int count);

  /// No description provided for @todayAiSummaryWaterDone.
  ///
  /// In zh, this message translates to:
  /// **'今日饮水次数已达标，继续保持少量多次'**
  String get todayAiSummaryWaterDone;

  /// No description provided for @todayAiSummarySleepPlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'记录睡眠后会纳入今日总结'**
  String get todayAiSummarySleepPlaceholder;

  /// No description provided for @todayRecommendationSectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'主动建议'**
  String get todayRecommendationSectionTitle;

  /// No description provided for @todayViewMoreAction.
  ///
  /// In zh, this message translates to:
  /// **'查看更多'**
  String get todayViewMoreAction;

  /// No description provided for @todayRecommendationMedicineSafetyTitle.
  ///
  /// In zh, this message translates to:
  /// **'用药安全小贴士'**
  String get todayRecommendationMedicineSafetyTitle;

  /// No description provided for @todayRecommendationMedicineSafetyBody.
  ///
  /// In zh, this message translates to:
  /// **'按时按量用药，勿随意增减或停药'**
  String get todayRecommendationMedicineSafetyBody;

  /// No description provided for @todayRecommendationSleepTitle.
  ///
  /// In zh, this message translates to:
  /// **'睡前放松，助力睡眠'**
  String get todayRecommendationSleepTitle;

  /// No description provided for @todayRecommendationSleepBody.
  ///
  /// In zh, this message translates to:
  /// **'睡前 1 小时减少蓝光，放松身心'**
  String get todayRecommendationSleepBody;

  /// No description provided for @todayRecommendationWaterTitle.
  ///
  /// In zh, this message translates to:
  /// **'少量多次喝水'**
  String get todayRecommendationWaterTitle;

  /// No description provided for @todayRecommendationWaterBody.
  ///
  /// In zh, this message translates to:
  /// **'保持身体水分，有助于专注与代谢'**
  String get todayRecommendationWaterBody;

  /// No description provided for @todayRecommendationCoffeeTitle.
  ///
  /// In zh, this message translates to:
  /// **'咖啡因适量，注意时间'**
  String get todayRecommendationCoffeeTitle;

  /// No description provided for @todayRecommendationCoffeeBody.
  ///
  /// In zh, this message translates to:
  /// **'下午 3 点后尽量避免，影响睡眠质量'**
  String get todayRecommendationCoffeeBody;

  /// No description provided for @todayLearnMoreAction.
  ///
  /// In zh, this message translates to:
  /// **'了解更多'**
  String get todayLearnMoreAction;

  /// No description provided for @todayCompleteAction.
  ///
  /// In zh, this message translates to:
  /// **'去完成'**
  String get todayCompleteAction;

  /// No description provided for @todayTodoSectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'今日待办'**
  String get todayTodoSectionTitle;

  /// No description provided for @todayTodoAddAction.
  ///
  /// In zh, this message translates to:
  /// **'添加'**
  String get todayTodoAddAction;

  /// No description provided for @todayTodoSourceSystem.
  ///
  /// In zh, this message translates to:
  /// **'系统'**
  String get todayTodoSourceSystem;

  /// No description provided for @todayTodoSourceUser.
  ///
  /// In zh, this message translates to:
  /// **'用户'**
  String get todayTodoSourceUser;

  /// No description provided for @todayTodoMedicationTitle.
  ///
  /// In zh, this message translates to:
  /// **'服药提醒'**
  String get todayTodoMedicationTitle;

  /// No description provided for @todayTodoMedicationSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'下一次 {time} {medicineName}'**
  String todayTodoMedicationSubtitle(String time, String medicineName);

  /// No description provided for @todayTodoWaterTitle.
  ///
  /// In zh, this message translates to:
  /// **'补充饮水'**
  String get todayTodoWaterTitle;

  /// No description provided for @todayTodoWaterSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'今日进度 {progress}%'**
  String todayTodoWaterSubtitle(int progress);

  /// No description provided for @todayTodoCustomTitle.
  ///
  /// In zh, this message translates to:
  /// **'自定义待办'**
  String get todayTodoCustomTitle;

  /// No description provided for @todayTodoCustomSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'可添加复诊、休息或自定义提醒'**
  String get todayTodoCustomSubtitle;

  /// No description provided for @placeholderSoon.
  ///
  /// In zh, this message translates to:
  /// **'{label} · 即将上线'**
  String placeholderSoon(String label);

  /// No description provided for @placeholderDescription.
  ///
  /// In zh, this message translates to:
  /// **'这一栏的结构已经预留完成，下一步会按新的多端设计系统重建。'**
  String get placeholderDescription;

  /// No description provided for @mineThemeModeSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get mineThemeModeSystem;

  /// No description provided for @mineThemeModeLight.
  ///
  /// In zh, this message translates to:
  /// **'浅色'**
  String get mineThemeModeLight;

  /// No description provided for @mineThemeModeDark.
  ///
  /// In zh, this message translates to:
  /// **'深色'**
  String get mineThemeModeDark;

  /// No description provided for @medicineSearchPreviewClinical.
  ///
  /// In zh, this message translates to:
  /// **'临床提示'**
  String get medicineSearchPreviewClinical;

  /// No description provided for @medicineSearchPreviewSafety.
  ///
  /// In zh, this message translates to:
  /// **'安全确认'**
  String get medicineSearchPreviewSafety;

  /// No description provided for @medicineSearchPreviewEmpty.
  ///
  /// In zh, this message translates to:
  /// **'选择一个药品查看详情'**
  String get medicineSearchPreviewEmpty;

  /// No description provided for @medicineSearchSourceRefCn.
  ///
  /// In zh, this message translates to:
  /// **'批准文号：{id}'**
  String medicineSearchSourceRefCn(String id);

  /// No description provided for @medicineSearchSourceRefDrugbank.
  ///
  /// In zh, this message translates to:
  /// **'DrugBank ID：{id}'**
  String medicineSearchSourceRefDrugbank(String id);

  /// No description provided for @mineEditProfileTitle.
  ///
  /// In zh, this message translates to:
  /// **'编辑档案'**
  String get mineEditProfileTitle;

  /// No description provided for @mineEditAllergyTitle.
  ///
  /// In zh, this message translates to:
  /// **'编辑过敏'**
  String get mineEditAllergyTitle;

  /// No description provided for @mineEditAllergyNewTitle.
  ///
  /// In zh, this message translates to:
  /// **'新增过敏'**
  String get mineEditAllergyNewTitle;

  /// No description provided for @mineEditConditionTitle.
  ///
  /// In zh, this message translates to:
  /// **'编辑疾病'**
  String get mineEditConditionTitle;

  /// No description provided for @mineEditConditionNewTitle.
  ///
  /// In zh, this message translates to:
  /// **'新增疾病'**
  String get mineEditConditionNewTitle;

  /// No description provided for @mineEditMedicineTitle.
  ///
  /// In zh, this message translates to:
  /// **'编辑用药'**
  String get mineEditMedicineTitle;

  /// No description provided for @mineEditMedicineNewTitle.
  ///
  /// In zh, this message translates to:
  /// **'新增用药'**
  String get mineEditMedicineNewTitle;

  /// No description provided for @mineEditSaveAction.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get mineEditSaveAction;

  /// No description provided for @mineEditDeleteAction.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get mineEditDeleteAction;

  /// No description provided for @mineEditSavedToast.
  ///
  /// In zh, this message translates to:
  /// **'已保存'**
  String get mineEditSavedToast;

  /// No description provided for @mineEditDeletedToast.
  ///
  /// In zh, this message translates to:
  /// **'已删除'**
  String get mineEditDeletedToast;

  /// No description provided for @mineEditFieldBirthDate.
  ///
  /// In zh, this message translates to:
  /// **'出生日期 (YYYY-MM-DD)'**
  String get mineEditFieldBirthDate;

  /// No description provided for @mineEditFieldHeightCm.
  ///
  /// In zh, this message translates to:
  /// **'身高 (cm)'**
  String get mineEditFieldHeightCm;

  /// No description provided for @mineEditFieldBloodType.
  ///
  /// In zh, this message translates to:
  /// **'血型'**
  String get mineEditFieldBloodType;

  /// No description provided for @mineEditFieldLocale.
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get mineEditFieldLocale;

  /// No description provided for @mineEditFieldTimezone.
  ///
  /// In zh, this message translates to:
  /// **'时区'**
  String get mineEditFieldTimezone;

  /// No description provided for @mineEditFieldUnitSystem.
  ///
  /// In zh, this message translates to:
  /// **'单位制'**
  String get mineEditFieldUnitSystem;

  /// No description provided for @mineEditFieldOnboardingCompleted.
  ///
  /// In zh, this message translates to:
  /// **'完成新手引导'**
  String get mineEditFieldOnboardingCompleted;

  /// No description provided for @mineEditFieldKind.
  ///
  /// In zh, this message translates to:
  /// **'类型'**
  String get mineEditFieldKind;

  /// No description provided for @mineEditFieldLabel.
  ///
  /// In zh, this message translates to:
  /// **'名称'**
  String get mineEditFieldLabel;

  /// No description provided for @mineEditFieldReaction.
  ///
  /// In zh, this message translates to:
  /// **'反应'**
  String get mineEditFieldReaction;

  /// No description provided for @mineEditFieldSeverity.
  ///
  /// In zh, this message translates to:
  /// **'严重程度'**
  String get mineEditFieldSeverity;

  /// No description provided for @mineEditFieldNote.
  ///
  /// In zh, this message translates to:
  /// **'备注'**
  String get mineEditFieldNote;

  /// No description provided for @mineEditFieldRecordedAt.
  ///
  /// In zh, this message translates to:
  /// **'记录时间'**
  String get mineEditFieldRecordedAt;

  /// No description provided for @mineEditFieldStatus.
  ///
  /// In zh, this message translates to:
  /// **'状态'**
  String get mineEditFieldStatus;

  /// No description provided for @mineEditFieldDiagnosedAt.
  ///
  /// In zh, this message translates to:
  /// **'诊断日期 (YYYY-MM-DD)'**
  String get mineEditFieldDiagnosedAt;

  /// No description provided for @mineEditFieldSource.
  ///
  /// In zh, this message translates to:
  /// **'来源'**
  String get mineEditFieldSource;

  /// No description provided for @mineEditFieldSourceRefId.
  ///
  /// In zh, this message translates to:
  /// **'来源ID'**
  String get mineEditFieldSourceRefId;

  /// No description provided for @mineEditFieldDisplayName.
  ///
  /// In zh, this message translates to:
  /// **'药品名称'**
  String get mineEditFieldDisplayName;

  /// No description provided for @mineEditFieldStrengthText.
  ///
  /// In zh, this message translates to:
  /// **'规格'**
  String get mineEditFieldStrengthText;

  /// No description provided for @mineEditFieldDoseText.
  ///
  /// In zh, this message translates to:
  /// **'剂量'**
  String get mineEditFieldDoseText;

  /// No description provided for @mineEditFieldRoute.
  ///
  /// In zh, this message translates to:
  /// **'给药途径'**
  String get mineEditFieldRoute;

  /// No description provided for @mineEditFieldStartedAt.
  ///
  /// In zh, this message translates to:
  /// **'开始日期 (YYYY-MM-DD)'**
  String get mineEditFieldStartedAt;

  /// No description provided for @mineEditFieldEndedAt.
  ///
  /// In zh, this message translates to:
  /// **'结束日期 (YYYY-MM-DD)'**
  String get mineEditFieldEndedAt;

  /// No description provided for @reportWeekDateRange.
  ///
  /// In zh, this message translates to:
  /// **'5月19日 - 5月25日'**
  String get reportWeekDateRange;

  /// No description provided for @reportPeriodThisWeek.
  ///
  /// In zh, this message translates to:
  /// **'本周'**
  String get reportPeriodThisWeek;

  /// No description provided for @reportGenerateAction.
  ///
  /// In zh, this message translates to:
  /// **'生成总结'**
  String get reportGenerateAction;

  /// No description provided for @reportSyncAction.
  ///
  /// In zh, this message translates to:
  /// **'同步'**
  String get reportSyncAction;

  /// No description provided for @reportSnapshotStatus.
  ///
  /// In zh, this message translates to:
  /// **'当前显示上次报告快照'**
  String get reportSnapshotStatus;

  /// No description provided for @reportSnapshotHint.
  ///
  /// In zh, this message translates to:
  /// **'点击生成或同步后更新'**
  String get reportSnapshotHint;

  /// No description provided for @reportScoreTitle.
  ///
  /// In zh, this message translates to:
  /// **'报告预览评分'**
  String get reportScoreTitle;

  /// No description provided for @reportScoreOutOf.
  ///
  /// In zh, this message translates to:
  /// **'预览 / {max}'**
  String reportScoreOutOf(int max);

  /// No description provided for @reportStatusOverallStable.
  ///
  /// In zh, this message translates to:
  /// **'演示快照'**
  String get reportStatusOverallStable;

  /// No description provided for @reportScoreBody.
  ///
  /// In zh, this message translates to:
  /// **'报告数据接入前仅作预览'**
  String get reportScoreBody;

  /// No description provided for @reportMetricMedicationTitle.
  ///
  /// In zh, this message translates to:
  /// **'用药完成率'**
  String get reportMetricMedicationTitle;

  /// No description provided for @reportMetricSleepTitle.
  ///
  /// In zh, this message translates to:
  /// **'睡眠'**
  String get reportMetricSleepTitle;

  /// No description provided for @reportMetricWaterTitle.
  ///
  /// In zh, this message translates to:
  /// **'饮水'**
  String get reportMetricWaterTitle;

  /// No description provided for @reportMetricOverallTitle.
  ///
  /// In zh, this message translates to:
  /// **'总体状态'**
  String get reportMetricOverallTitle;

  /// No description provided for @reportMetricOverallDelta.
  ///
  /// In zh, this message translates to:
  /// **'综合最近 7 天'**
  String get reportMetricOverallDelta;

  /// No description provided for @reportUnitPercent.
  ///
  /// In zh, this message translates to:
  /// **'%'**
  String get reportUnitPercent;

  /// No description provided for @reportUnitHour.
  ///
  /// In zh, this message translates to:
  /// **'小时'**
  String get reportUnitHour;

  /// No description provided for @reportUnitLiter.
  ///
  /// In zh, this message translates to:
  /// **'L'**
  String get reportUnitLiter;

  /// No description provided for @reportStatusGood.
  ///
  /// In zh, this message translates to:
  /// **'良好'**
  String get reportStatusGood;

  /// No description provided for @reportStatusNeedsImprove.
  ///
  /// In zh, this message translates to:
  /// **'待提升'**
  String get reportStatusNeedsImprove;

  /// No description provided for @reportStatusStable.
  ///
  /// In zh, this message translates to:
  /// **'稳定'**
  String get reportStatusStable;

  /// No description provided for @reportDeltaMedication.
  ///
  /// In zh, this message translates to:
  /// **'9%'**
  String get reportDeltaMedication;

  /// No description provided for @reportDeltaSleep.
  ///
  /// In zh, this message translates to:
  /// **'0.6'**
  String get reportDeltaSleep;

  /// No description provided for @reportDeltaWater.
  ///
  /// In zh, this message translates to:
  /// **'0.2'**
  String get reportDeltaWater;

  /// No description provided for @reportTrendSectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'健康趋势'**
  String get reportTrendSectionTitle;

  /// No description provided for @reportRangeLast7Days.
  ///
  /// In zh, this message translates to:
  /// **'近 7 天'**
  String get reportRangeLast7Days;

  /// No description provided for @reportRangeLast30Days.
  ///
  /// In zh, this message translates to:
  /// **'近 30 天'**
  String get reportRangeLast30Days;

  /// No description provided for @reportTrendSleepLabel.
  ///
  /// In zh, this message translates to:
  /// **'睡眠(小时)'**
  String get reportTrendSleepLabel;

  /// No description provided for @reportTrendWaterLabel.
  ///
  /// In zh, this message translates to:
  /// **'饮水(L)'**
  String get reportTrendWaterLabel;

  /// No description provided for @reportTrendMedicationLabel.
  ///
  /// In zh, this message translates to:
  /// **'用药完成率(%)'**
  String get reportTrendMedicationLabel;

  /// No description provided for @reportTrendDateLabels.
  ///
  /// In zh, this message translates to:
  /// **'5/19|5/20|5/21|5/22|5/23|5/24|5/25'**
  String get reportTrendDateLabels;

  /// No description provided for @reportViewDetailsAction.
  ///
  /// In zh, this message translates to:
  /// **'查看详细数据'**
  String get reportViewDetailsAction;

  /// No description provided for @reportFindingsSectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'重点发现'**
  String get reportFindingsSectionTitle;

  /// No description provided for @reportFindingCoffeeTitle.
  ///
  /// In zh, this message translates to:
  /// **'咖啡因影响睡眠'**
  String get reportFindingCoffeeTitle;

  /// No description provided for @reportFindingCoffeeBody.
  ///
  /// In zh, this message translates to:
  /// **'下午摄入咖啡后睡眠时长下降'**
  String get reportFindingCoffeeBody;

  /// No description provided for @reportFindingMedicineTitle.
  ///
  /// In zh, this message translates to:
  /// **'按时用药稳定'**
  String get reportFindingMedicineTitle;

  /// No description provided for @reportFindingMedicineBody.
  ///
  /// In zh, this message translates to:
  /// **'连续 7 天按时用药状态良好'**
  String get reportFindingMedicineBody;

  /// No description provided for @reportAiSummaryTitle.
  ///
  /// In zh, this message translates to:
  /// **'总结'**
  String get reportAiSummaryTitle;

  /// No description provided for @reportAiSummarySubtitle.
  ///
  /// In zh, this message translates to:
  /// **'基于本周记录的智能分析'**
  String get reportAiSummarySubtitle;

  /// No description provided for @reportAiSummarySubtitleLast30Days.
  ///
  /// In zh, this message translates to:
  /// **'基于近 30 天记录的智能分析'**
  String get reportAiSummarySubtitleLast30Days;

  /// No description provided for @reportAiSummaryDefaultHint.
  ///
  /// In zh, this message translates to:
  /// **'还没有生成本周 AI 总结，当前先显示最近一次报告快照。'**
  String get reportAiSummaryDefaultHint;

  /// No description provided for @reportAiSummaryGeneratingHint.
  ///
  /// In zh, this message translates to:
  /// **'正在生成本周 AI 总结'**
  String get reportAiSummaryGeneratingHint;

  /// No description provided for @reportAiSummaryGeneratingHintLast30Days.
  ///
  /// In zh, this message translates to:
  /// **'正在生成近 30 天 AI 总结'**
  String get reportAiSummaryGeneratingHintLast30Days;

  /// No description provided for @reportAiSummaryErrorHint.
  ///
  /// In zh, this message translates to:
  /// **'本周 AI 总结生成失败，当前先保留报告快照。'**
  String get reportAiSummaryErrorHint;

  /// No description provided for @reportAiSummaryDisabledHint.
  ///
  /// In zh, this message translates to:
  /// **'你已在设置中关闭 AI 总结，当前只显示报告快照。'**
  String get reportAiSummaryDisabledHint;

  /// No description provided for @reportViewAdviceAction.
  ///
  /// In zh, this message translates to:
  /// **'查看建议'**
  String get reportViewAdviceAction;

  /// No description provided for @reportAiBulletSleep.
  ///
  /// In zh, this message translates to:
  /// **'睡眠质量整体良好，周末略有波动，保持规律作息有助于提升精力。'**
  String get reportAiBulletSleep;

  /// No description provided for @reportAiBulletWater.
  ///
  /// In zh, this message translates to:
  /// **'饮水达成率中等，部分天数偏低，记得随身带水，少量多次补水。'**
  String get reportAiBulletWater;

  /// No description provided for @reportAiBulletMedicine.
  ///
  /// In zh, this message translates to:
  /// **'用药达成率较高，继续保持按时服药的好习惯。'**
  String get reportAiBulletMedicine;

  /// No description provided for @reportAiBulletDiet.
  ///
  /// In zh, this message translates to:
  /// **'饮食多为均衡搭配，但水果与蔬菜摄入偏少，可适当增加。'**
  String get reportAiBulletDiet;

  /// No description provided for @reportExportSectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'导出摘要'**
  String get reportExportSectionTitle;

  /// No description provided for @reportExportHospitalTitle.
  ///
  /// In zh, this message translates to:
  /// **'给校医院'**
  String get reportExportHospitalTitle;

  /// No description provided for @reportExportHospitalSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'导出健康摘要'**
  String get reportExportHospitalSubtitle;

  /// No description provided for @reportExportMonthlyTitle.
  ///
  /// In zh, this message translates to:
  /// **'月度报告'**
  String get reportExportMonthlyTitle;

  /// No description provided for @reportExportMonthlySubtitle.
  ///
  /// In zh, this message translates to:
  /// **'PDF 格式'**
  String get reportExportMonthlySubtitle;

  /// No description provided for @reportExportPrintTitle.
  ///
  /// In zh, this message translates to:
  /// **'打印预览'**
  String get reportExportPrintTitle;

  /// No description provided for @reportExportPrintSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'纸质版预览'**
  String get reportExportPrintSubtitle;

  /// No description provided for @reportExportRequestedToast.
  ///
  /// In zh, this message translates to:
  /// **'导出请求已提交。'**
  String get reportExportRequestedToast;

  /// No description provided for @reportExportProcessingToast.
  ///
  /// In zh, this message translates to:
  /// **'导出正在处理中。'**
  String get reportExportProcessingToast;

  /// No description provided for @reportExportUnavailableToast.
  ///
  /// In zh, this message translates to:
  /// **'当前环境暂时无法生成这个导出文件。'**
  String get reportExportUnavailableToast;

  /// No description provided for @reportExportReadyToast.
  ///
  /// In zh, this message translates to:
  /// **'导出文件已准备好，正在打开。'**
  String get reportExportReadyToast;

  /// No description provided for @reportExportFailedToast.
  ///
  /// In zh, this message translates to:
  /// **'导出失败。'**
  String get reportExportFailedToast;

  /// No description provided for @reportExportLinkMissingToast.
  ///
  /// In zh, this message translates to:
  /// **'导出已完成，但下载链接暂时不可用。'**
  String get reportExportLinkMissingToast;

  /// No description provided for @reportExportOpenFailedToast.
  ///
  /// In zh, this message translates to:
  /// **'导出已完成，但无法打开下载链接。'**
  String get reportExportOpenFailedToast;

  /// No description provided for @reportPatternSectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'健康模式分析'**
  String get reportPatternSectionTitle;

  /// No description provided for @reportPatternDietWaterTitle.
  ///
  /// In zh, this message translates to:
  /// **'饮食与饮水'**
  String get reportPatternDietWaterTitle;

  /// No description provided for @reportPatternDietWaterStatus.
  ///
  /// In zh, this message translates to:
  /// **'良好搭配'**
  String get reportPatternDietWaterStatus;

  /// No description provided for @reportPatternDietWaterBody.
  ///
  /// In zh, this message translates to:
  /// **'饮水充足时，精力更容易保持稳定'**
  String get reportPatternDietWaterBody;

  /// No description provided for @reportPatternMedicationTitle.
  ///
  /// In zh, this message translates to:
  /// **'用药依从性'**
  String get reportPatternMedicationTitle;

  /// No description provided for @reportPatternMedicationStatus.
  ///
  /// In zh, this message translates to:
  /// **'表现优秀'**
  String get reportPatternMedicationStatus;

  /// No description provided for @reportPatternMedicationBody.
  ///
  /// In zh, this message translates to:
  /// **'按时服药有助于维持健康状态'**
  String get reportPatternMedicationBody;

  /// No description provided for @reportReferenceNotice.
  ///
  /// In zh, this message translates to:
  /// **'本报告仅供参考，不构成诊断或治疗建议。'**
  String get reportReferenceNotice;

  /// No description provided for @reportActionToast.
  ///
  /// In zh, this message translates to:
  /// **'{action}：后续会打开对应操作。'**
  String reportActionToast(String action);

  /// No description provided for @reportErrorTitle.
  ///
  /// In zh, this message translates to:
  /// **'报告页暂时没有加载出来'**
  String get reportErrorTitle;

  /// No description provided for @reportErrorDescription.
  ///
  /// In zh, this message translates to:
  /// **'报告数据这次没有拉取成功，可以重新同步一次。'**
  String get reportErrorDescription;

  /// No description provided for @reportSignedOutInlineHint.
  ///
  /// In zh, this message translates to:
  /// **'登录后查看你的真实周报、AI 总结和导出结果。'**
  String get reportSignedOutInlineHint;

  /// No description provided for @mineSettingsAdvancedTitle.
  ///
  /// In zh, this message translates to:
  /// **'高级设置'**
  String get mineSettingsAdvancedTitle;

  /// No description provided for @settingsAdvancedClearImageCache.
  ///
  /// In zh, this message translates to:
  /// **'清理图片缓存'**
  String get settingsAdvancedClearImageCache;

  /// No description provided for @settingsAdvancedCacheCleared.
  ///
  /// In zh, this message translates to:
  /// **'图片缓存已清理'**
  String get settingsAdvancedCacheCleared;

  /// No description provided for @settingsAdvancedResetDefaults.
  ///
  /// In zh, this message translates to:
  /// **'恢复默认设置'**
  String get settingsAdvancedResetDefaults;

  /// No description provided for @settingsAdvancedDefaultsReset.
  ///
  /// In zh, this message translates to:
  /// **'已恢复默认设置'**
  String get settingsAdvancedDefaultsReset;

  /// No description provided for @settingsAdvancedOpenSourceLicenses.
  ///
  /// In zh, this message translates to:
  /// **'开源许可'**
  String get settingsAdvancedOpenSourceLicenses;

  /// No description provided for @reportPatternSleepTitle.
  ///
  /// In zh, this message translates to:
  /// **'睡眠变化'**
  String get reportPatternSleepTitle;

  /// No description provided for @reportPatternSleepStatus.
  ///
  /// In zh, this message translates to:
  /// **'持续观察'**
  String get reportPatternSleepStatus;

  /// No description provided for @reportPatternSleepBody.
  ///
  /// In zh, this message translates to:
  /// **'晚间咖啡因和作息变化可能影响睡眠'**
  String get reportPatternSleepBody;

  /// No description provided for @mineReminderDisabled.
  ///
  /// In zh, this message translates to:
  /// **'已关闭'**
  String get mineReminderDisabled;

  /// No description provided for @mineExportStatusRequested.
  ///
  /// In zh, this message translates to:
  /// **'已提交'**
  String get mineExportStatusRequested;

  /// No description provided for @mineExportStatusPending.
  ///
  /// In zh, this message translates to:
  /// **'处理中'**
  String get mineExportStatusPending;

  /// No description provided for @mineExportStatusCompleted.
  ///
  /// In zh, this message translates to:
  /// **'已完成'**
  String get mineExportStatusCompleted;

  /// No description provided for @mineExportStatusFailed.
  ///
  /// In zh, this message translates to:
  /// **'失败'**
  String get mineExportStatusFailed;

  /// No description provided for @mineExportStatusLinkMissing.
  ///
  /// In zh, this message translates to:
  /// **'链接待刷新'**
  String get mineExportStatusLinkMissing;

  /// No description provided for @mineExportStatusUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'暂不可用'**
  String get mineExportStatusUnavailable;

  /// No description provided for @mineExportRequested.
  ///
  /// In zh, this message translates to:
  /// **'导出请求已提交'**
  String get mineExportRequested;

  /// No description provided for @medicineRiskCheckRedFlagBannerTitle.
  ///
  /// In zh, this message translates to:
  /// **'红旗警告'**
  String get medicineRiskCheckRedFlagBannerTitle;

  /// No description provided for @medicineRiskCheckRedFlagSevereAllergy.
  ///
  /// In zh, this message translates to:
  /// **'严重过敏风险：{drug} 含有 {allergen}，请勿使用并立即咨询医生。'**
  String medicineRiskCheckRedFlagSevereAllergy(Object drug, Object allergen);

  /// No description provided for @medicineRiskCheckRedFlagSevereAllergyGeneric.
  ///
  /// In zh, this message translates to:
  /// **'严重过敏风险：{drug} 与已知过敏原匹配，请勿使用并立即咨询医生。'**
  String medicineRiskCheckRedFlagSevereAllergyGeneric(Object drug);

  /// No description provided for @medicineRiskCheckRedFlagPregnancyContraindication.
  ///
  /// In zh, this message translates to:
  /// **'孕期/哺乳期用药警告：{drug} 标注为禁忌，请务必咨询医生后再使用。'**
  String medicineRiskCheckRedFlagPregnancyContraindication(Object drug);

  /// No description provided for @medicineRiskCheckRedFlagInformationGap.
  ///
  /// In zh, this message translates to:
  /// **'无法确认 {drug} 的安全性，建议线下核对药品说明书或咨询药师。'**
  String medicineRiskCheckRedFlagInformationGap(Object drug);

  /// No description provided for @medicineRiskCheckRedFlagResourceEmergency.
  ///
  /// In zh, this message translates to:
  /// **'急救资源'**
  String get medicineRiskCheckRedFlagResourceEmergency;

  /// No description provided for @medicineRiskCheckRedFlagResourceHospital.
  ///
  /// In zh, this message translates to:
  /// **'校医院'**
  String get medicineRiskCheckRedFlagResourceHospital;

  /// No description provided for @medicineRiskCheckRedFlagResourcePharmacy.
  ///
  /// In zh, this message translates to:
  /// **'校园药房'**
  String get medicineRiskCheckRedFlagResourcePharmacy;

  /// No description provided for @medicineRiskCheckRedFlagActionSevereAllergy.
  ///
  /// In zh, this message translates to:
  /// **'请立即联系急救（120），不要自行处理'**
  String get medicineRiskCheckRedFlagActionSevereAllergy;

  /// No description provided for @medicineRiskCheckRedFlagActionPregnancyContraindication.
  ///
  /// In zh, this message translates to:
  /// **'请停止自行用药，尽快咨询医生或药师'**
  String get medicineRiskCheckRedFlagActionPregnancyContraindication;

  /// No description provided for @medicineRiskCheckRedFlagActionInformationGap.
  ///
  /// In zh, this message translates to:
  /// **'当前处于高风险状态，部分药品无法自动检查，建议尽快线下确认'**
  String get medicineRiskCheckRedFlagActionInformationGap;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
