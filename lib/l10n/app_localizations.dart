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

  /// No description provided for @tabMine.
  ///
  /// In zh, this message translates to:
  /// **'我的'**
  String get tabMine;

  /// No description provided for @tabMore.
  ///
  /// In zh, this message translates to:
  /// **'更多'**
  String get tabMore;

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

  /// No description provided for @recordCreateFieldUnit.
  ///
  /// In zh, this message translates to:
  /// **'单位'**
  String get recordCreateFieldUnit;

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
  /// **'杯数'**
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
  /// **'Mock 数据边界已经接好，可以重新拉取一次。'**
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

  /// No description provided for @recordTypeWomenHealth.
  ///
  /// In zh, this message translates to:
  /// **'女性健康'**
  String get recordTypeWomenHealth;

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

  /// No description provided for @recordQuickWomenSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'未开启'**
  String get recordQuickWomenSubtitle;

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

  /// No description provided for @recordSummaryActivityTitle.
  ///
  /// In zh, this message translates to:
  /// **'运动完成度'**
  String get recordSummaryActivityTitle;

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

  /// No description provided for @recordTimelineHeartRateDetail.
  ///
  /// In zh, this message translates to:
  /// **'72 次/分 · 来源：手表 · 正常'**
  String get recordTimelineHeartRateDetail;

  /// No description provided for @recordTimelineActivityWalk.
  ///
  /// In zh, this message translates to:
  /// **'运动 · 快走'**
  String get recordTimelineActivityWalk;

  /// No description provided for @recordTimelineActivityDetail.
  ///
  /// In zh, this message translates to:
  /// **'30 分钟 · 2.6 km · 180 kcal'**
  String get recordTimelineActivityDetail;

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

  /// No description provided for @recordTrendSleepMoodTitle.
  ///
  /// In zh, this message translates to:
  /// **'情绪-睡眠'**
  String get recordTrendSleepMoodTitle;

  /// No description provided for @recordTrendSleepLegend.
  ///
  /// In zh, this message translates to:
  /// **'睡眠时长（小时）'**
  String get recordTrendSleepLegend;

  /// No description provided for @recordTrendMoodLegend.
  ///
  /// In zh, this message translates to:
  /// **'情绪评分（分）'**
  String get recordTrendMoodLegend;

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

  /// No description provided for @recordHealthBagTitle.
  ///
  /// In zh, this message translates to:
  /// **'专科健康档案袋'**
  String get recordHealthBagTitle;

  /// No description provided for @recordHealthBagBody.
  ///
  /// In zh, this message translates to:
  /// **'查看与管理牙齿、眼科、听力等专科记录与报告'**
  String get recordHealthBagBody;

  /// No description provided for @recordHealthBagLatest.
  ///
  /// In zh, this message translates to:
  /// **'最近更新：2025-05-10'**
  String get recordHealthBagLatest;

  /// No description provided for @recordHealthBagNext.
  ///
  /// In zh, this message translates to:
  /// **'下次复查：2025-06-15'**
  String get recordHealthBagNext;

  /// No description provided for @recordFoodImagePlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'餐图占位'**
  String get recordFoodImagePlaceholder;

  /// No description provided for @medicinePageDescription.
  ///
  /// In zh, this message translates to:
  /// **'拍照识别、条码扫描、手动搜索、服药计划和安全提醒先在这里合成一个可继续接后端的工作台。'**
  String get medicinePageDescription;

  /// No description provided for @medicineSectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'用药工作区'**
  String get medicineSectionTitle;

  /// No description provided for @medicineSectionSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'这里会承接基于 Lucent 重建后的完整用药闭环。'**
  String get medicineSectionSubtitle;

  /// No description provided for @medicineHeaderActionSearch.
  ///
  /// In zh, this message translates to:
  /// **'搜索药品'**
  String get medicineHeaderActionSearch;

  /// No description provided for @medicineHeaderActionAdd.
  ///
  /// In zh, this message translates to:
  /// **'添加药品'**
  String get medicineHeaderActionAdd;

  /// No description provided for @medicineHeaderActionSearchCompact.
  ///
  /// In zh, this message translates to:
  /// **'搜索'**
  String get medicineHeaderActionSearchCompact;

  /// No description provided for @medicineHeaderActionAddCompact.
  ///
  /// In zh, this message translates to:
  /// **'添加'**
  String get medicineHeaderActionAddCompact;

  /// No description provided for @medicineHeaderAddToast.
  ///
  /// In zh, this message translates to:
  /// **'会打开添加药品与识别入口。'**
  String get medicineHeaderAddToast;

  /// No description provided for @medicineHeroEyebrow.
  ///
  /// In zh, this message translates to:
  /// **'PERSONAL DRUGBOX'**
  String get medicineHeroEyebrow;

  /// No description provided for @medicineHeroTitle.
  ///
  /// In zh, this message translates to:
  /// **'先把今天的药、风险和补药节奏看清。'**
  String get medicineHeroTitle;

  /// No description provided for @medicineHeroSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'拍照识别、条码扫描、手动搜索和用药安全会从这里进入，结果始终保持参考边界。'**
  String get medicineHeroSubtitle;

  /// No description provided for @medicineHeroMetricTodayCountValue.
  ///
  /// In zh, this message translates to:
  /// **'2'**
  String get medicineHeroMetricTodayCountValue;

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

  /// No description provided for @medicineHeroMetricAdherenceValue.
  ///
  /// In zh, this message translates to:
  /// **'100%'**
  String get medicineHeroMetricAdherenceValue;

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

  /// No description provided for @medicineHeroMetricNextDoseValue.
  ///
  /// In zh, this message translates to:
  /// **'20:00'**
  String get medicineHeroMetricNextDoseValue;

  /// No description provided for @medicineHeroMetricNextDoseLabel.
  ///
  /// In zh, this message translates to:
  /// **'下一次提醒'**
  String get medicineHeroMetricNextDoseLabel;

  /// No description provided for @medicineHeroBannerTitle.
  ///
  /// In zh, this message translates to:
  /// **'安全底线先行'**
  String get medicineHeroBannerTitle;

  /// No description provided for @medicineHeroBannerBody.
  ///
  /// In zh, this message translates to:
  /// **'识别结果、相互作用和特殊人群提醒都会明确标注“仅供参考”，避免把 AI 结果误当成诊断。'**
  String get medicineHeroBannerBody;

  /// No description provided for @medicineQuickActionSectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'识别与录入'**
  String get medicineQuickActionSectionTitle;

  /// No description provided for @medicineQuickActionSectionSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'先把药品带进来，再逐步补齐提醒、安全和补药闭环。'**
  String get medicineQuickActionSectionSubtitle;

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

  /// No description provided for @medicineTodayPlanSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'Mock 数据先把节奏、库存和风险位置站稳。'**
  String get medicineTodayPlanSubtitle;

  /// No description provided for @medicineTodayPlanInspectAction.
  ///
  /// In zh, this message translates to:
  /// **'查看全部'**
  String get medicineTodayPlanInspectAction;

  /// No description provided for @medicineMockNameMetformin.
  ///
  /// In zh, this message translates to:
  /// **'二甲双胍缓释片'**
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

  /// No description provided for @medicineMockStock7Days.
  ///
  /// In zh, this message translates to:
  /// **'剩余 7 天'**
  String get medicineMockStock7Days;

  /// No description provided for @medicineStatusStable.
  ///
  /// In zh, this message translates to:
  /// **'稳定服用'**
  String get medicineStatusStable;

  /// No description provided for @medicineMockNameAtorvastatin.
  ///
  /// In zh, this message translates to:
  /// **'阿托伐他汀钙片'**
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

  /// No description provided for @medicineMockStock15Days.
  ///
  /// In zh, this message translates to:
  /// **'剩余 15 天'**
  String get medicineMockStock15Days;

  /// No description provided for @medicineStatusNeedsCheckin.
  ///
  /// In zh, this message translates to:
  /// **'稳定服用'**
  String get medicineStatusNeedsCheckin;

  /// No description provided for @medicineMockNameOmeprazole.
  ///
  /// In zh, this message translates to:
  /// **'奥美拉唑肠溶胶囊'**
  String get medicineMockNameOmeprazole;

  /// No description provided for @medicineMockDoseOmeprazole.
  ///
  /// In zh, this message translates to:
  /// **'20 mg'**
  String get medicineMockDoseOmeprazole;

  /// No description provided for @medicineMockStock3Days.
  ///
  /// In zh, this message translates to:
  /// **'剩余 3 天'**
  String get medicineMockStock3Days;

  /// No description provided for @medicineStatusNeedRefillSoon.
  ///
  /// In zh, this message translates to:
  /// **'待关注'**
  String get medicineStatusNeedRefillSoon;

  /// No description provided for @medicineStockWarningLow.
  ///
  /// In zh, this message translates to:
  /// **'库存不足，建议及时补充'**
  String get medicineStockWarningLow;

  /// No description provided for @medicineSafetyPanelTitle.
  ///
  /// In zh, this message translates to:
  /// **'安全与补药'**
  String get medicineSafetyPanelTitle;

  /// No description provided for @medicineSafetyPanelSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'高风险提醒、临期库存和依从性风险会集中在这里。'**
  String get medicineSafetyPanelSubtitle;

  /// No description provided for @medicineAlertRefillTitle.
  ///
  /// In zh, this message translates to:
  /// **'需补药提醒'**
  String get medicineAlertRefillTitle;

  /// No description provided for @medicineAlertRefillBody.
  ///
  /// In zh, this message translates to:
  /// **'维生素 D 软胶囊剩余 3 天'**
  String get medicineAlertRefillBody;

  /// No description provided for @medicineAlertRefillDetail.
  ///
  /// In zh, this message translates to:
  /// **'建议及时补货，避免中断'**
  String get medicineAlertRefillDetail;

  /// No description provided for @medicineAlertRefillAction.
  ///
  /// In zh, this message translates to:
  /// **'去补药'**
  String get medicineAlertRefillAction;

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

  /// No description provided for @medicinePromisePointPregnancy.
  ///
  /// In zh, this message translates to:
  /// **'孕期、哺乳期、儿童、精神类药物更高优先级警示。'**
  String get medicinePromisePointPregnancy;

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

  /// No description provided for @medicineAlertRefillToast.
  ///
  /// In zh, this message translates to:
  /// **'会打开补药与库存详情。'**
  String get medicineAlertRefillToast;

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
  /// **'你当前的过敏史 / 孕期状态 / 现用药可能影响此药使用'**
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
  /// **'缺失信息：生日、性别、单位制、孕哺状态'**
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

  /// No description provided for @mineProfileWomenTitle.
  ///
  /// In zh, this message translates to:
  /// **'女性/孕哺状态'**
  String get mineProfileWomenTitle;

  /// No description provided for @mineProfileWomenSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'未填写'**
  String get mineProfileWomenSubtitle;

  /// No description provided for @mineProfileSpecialistTitle.
  ///
  /// In zh, this message translates to:
  /// **'专科档案'**
  String get mineProfileSpecialistTitle;

  /// No description provided for @mineProfileSpecialistSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'口腔/视力/听力等'**
  String get mineProfileSpecialistSubtitle;

  /// No description provided for @mineProfileLifestyleTitle.
  ///
  /// In zh, this message translates to:
  /// **'生活习惯'**
  String get mineProfileLifestyleTitle;

  /// No description provided for @mineProfileLifestyleSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'饮食/运动/睡眠'**
  String get mineProfileLifestyleSubtitle;

  /// No description provided for @mineProfileFamilyTitle.
  ///
  /// In zh, this message translates to:
  /// **'家族史'**
  String get mineProfileFamilyTitle;

  /// No description provided for @mineProfileFamilySubtitle.
  ///
  /// In zh, this message translates to:
  /// **'遗传与家族病史'**
  String get mineProfileFamilySubtitle;

  /// No description provided for @minePlansTitle.
  ///
  /// In zh, this message translates to:
  /// **'健康计划中心'**
  String get minePlansTitle;

  /// No description provided for @minePlansViewAll.
  ///
  /// In zh, this message translates to:
  /// **'查看全部'**
  String get minePlansViewAll;

  /// No description provided for @minePlanBloodSugarTitle.
  ///
  /// In zh, this message translates to:
  /// **'控糖计划'**
  String get minePlanBloodSugarTitle;

  /// No description provided for @minePlanBloodSugarStatus.
  ///
  /// In zh, this message translates to:
  /// **'进行中'**
  String get minePlanBloodSugarStatus;

  /// No description provided for @minePlanBloodSugarDetail.
  ///
  /// In zh, this message translates to:
  /// **'已坚持 12 天'**
  String get minePlanBloodSugarDetail;

  /// No description provided for @minePlanWeightTitle.
  ///
  /// In zh, this message translates to:
  /// **'减重计划'**
  String get minePlanWeightTitle;

  /// No description provided for @minePlanWeightStatus.
  ///
  /// In zh, this message translates to:
  /// **'未开始'**
  String get minePlanWeightStatus;

  /// No description provided for @minePlanWeightDetail.
  ///
  /// In zh, this message translates to:
  /// **'设置目标'**
  String get minePlanWeightDetail;

  /// No description provided for @minePlanSleepTitle.
  ///
  /// In zh, this message translates to:
  /// **'助眠计划'**
  String get minePlanSleepTitle;

  /// No description provided for @minePlanSleepStatus.
  ///
  /// In zh, this message translates to:
  /// **'进行中'**
  String get minePlanSleepStatus;

  /// No description provided for @minePlanSleepDetail.
  ///
  /// In zh, this message translates to:
  /// **'睡眠改善中'**
  String get minePlanSleepDetail;

  /// No description provided for @minePlanMoodTitle.
  ///
  /// In zh, this message translates to:
  /// **'情绪稳定计划'**
  String get minePlanMoodTitle;

  /// No description provided for @minePlanMoodStatus.
  ///
  /// In zh, this message translates to:
  /// **'未开始'**
  String get minePlanMoodStatus;

  /// No description provided for @minePlanMoodDetail.
  ///
  /// In zh, this message translates to:
  /// **'关注情绪健康'**
  String get minePlanMoodDetail;

  /// No description provided for @minePlanPregnancyTitle.
  ///
  /// In zh, this message translates to:
  /// **'备孕计划'**
  String get minePlanPregnancyTitle;

  /// No description provided for @minePlanPregnancyStatus.
  ///
  /// In zh, this message translates to:
  /// **'未开始'**
  String get minePlanPregnancyStatus;

  /// No description provided for @minePlanPregnancyDetail.
  ///
  /// In zh, this message translates to:
  /// **'科学备孕'**
  String get minePlanPregnancyDetail;

  /// No description provided for @mineReportTitle.
  ///
  /// In zh, this message translates to:
  /// **'健康报告'**
  String get mineReportTitle;

  /// No description provided for @mineReportBody.
  ///
  /// In zh, this message translates to:
  /// **'周/月报表、趋势回顾、健康洞察'**
  String get mineReportBody;

  /// No description provided for @mineReportMeta.
  ///
  /// In zh, this message translates to:
  /// **'上次生成：2025-05-12'**
  String get mineReportMeta;

  /// No description provided for @mineReportAction.
  ///
  /// In zh, this message translates to:
  /// **'查看报告'**
  String get mineReportAction;

  /// No description provided for @minePrivacyTitle.
  ///
  /// In zh, this message translates to:
  /// **'隐私控制'**
  String get minePrivacyTitle;

  /// No description provided for @minePrivacyBody.
  ///
  /// In zh, this message translates to:
  /// **'数据可见性、共享授权、云同步范围'**
  String get minePrivacyBody;

  /// No description provided for @minePrivacyMeta.
  ///
  /// In zh, this message translates to:
  /// **'已保护 8 大类敏感数据'**
  String get minePrivacyMeta;

  /// No description provided for @minePrivacyAction.
  ///
  /// In zh, this message translates to:
  /// **'管理隐私'**
  String get minePrivacyAction;

  /// No description provided for @mineStatusPanelTitle.
  ///
  /// In zh, this message translates to:
  /// **'档案状态'**
  String get mineStatusPanelTitle;

  /// No description provided for @mineStatusBasicTitle.
  ///
  /// In zh, this message translates to:
  /// **'基础资料'**
  String get mineStatusBasicTitle;

  /// No description provided for @mineStatusBasicValue.
  ///
  /// In zh, this message translates to:
  /// **'1/4 完成'**
  String get mineStatusBasicValue;

  /// No description provided for @mineStatusAllergiesTitle.
  ///
  /// In zh, this message translates to:
  /// **'过敏史'**
  String get mineStatusAllergiesTitle;

  /// No description provided for @mineStatusAllergiesValue.
  ///
  /// In zh, this message translates to:
  /// **'2 项'**
  String get mineStatusAllergiesValue;

  /// No description provided for @mineStatusConditionsTitle.
  ///
  /// In zh, this message translates to:
  /// **'慢病/条件'**
  String get mineStatusConditionsTitle;

  /// No description provided for @mineStatusConditionsValue.
  ///
  /// In zh, this message translates to:
  /// **'1 项'**
  String get mineStatusConditionsValue;

  /// No description provided for @mineStatusMedicinesTitle.
  ///
  /// In zh, this message translates to:
  /// **'当前用药'**
  String get mineStatusMedicinesTitle;

  /// No description provided for @mineStatusMedicinesValue.
  ///
  /// In zh, this message translates to:
  /// **'3 种'**
  String get mineStatusMedicinesValue;

  /// No description provided for @mineStatusWomenTitle.
  ///
  /// In zh, this message translates to:
  /// **'孕哺状态'**
  String get mineStatusWomenTitle;

  /// No description provided for @mineStatusWomenValue.
  ///
  /// In zh, this message translates to:
  /// **'未填写'**
  String get mineStatusWomenValue;

  /// No description provided for @mineOnboardingTitle.
  ///
  /// In zh, this message translates to:
  /// **'Onboarding 进度'**
  String get mineOnboardingTitle;

  /// No description provided for @mineOnboardingBasicTitle.
  ///
  /// In zh, this message translates to:
  /// **'基础信息'**
  String get mineOnboardingBasicTitle;

  /// No description provided for @mineOnboardingContextTitle.
  ///
  /// In zh, this message translates to:
  /// **'健康上下文'**
  String get mineOnboardingContextTitle;

  /// No description provided for @mineOnboardingMedicineTitle.
  ///
  /// In zh, this message translates to:
  /// **'用药设置'**
  String get mineOnboardingMedicineTitle;

  /// No description provided for @mineOnboardingGoalTitle.
  ///
  /// In zh, this message translates to:
  /// **'健康目标'**
  String get mineOnboardingGoalTitle;

  /// No description provided for @mineOnboardingPrivacyTitle.
  ///
  /// In zh, this message translates to:
  /// **'隐私设置'**
  String get mineOnboardingPrivacyTitle;

  /// No description provided for @mineOnboardingProgress.
  ///
  /// In zh, this message translates to:
  /// **'{completed}/{total} 完成'**
  String mineOnboardingProgress(int completed, int total);

  /// No description provided for @mineQuickEntriesTitle.
  ///
  /// In zh, this message translates to:
  /// **'快捷入口'**
  String get mineQuickEntriesTitle;

  /// No description provided for @mineQuickExportTitle.
  ///
  /// In zh, this message translates to:
  /// **'导出健康数据'**
  String get mineQuickExportTitle;

  /// No description provided for @mineQuickExportSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'下载健康数据副本'**
  String get mineQuickExportSubtitle;

  /// No description provided for @mineQuickDoctorTitle.
  ///
  /// In zh, this message translates to:
  /// **'共享给医生'**
  String get mineQuickDoctorTitle;

  /// No description provided for @mineQuickDoctorSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'授权查看健康信息'**
  String get mineQuickDoctorSubtitle;

  /// No description provided for @mineQuickEmergencyTitle.
  ///
  /// In zh, this message translates to:
  /// **'紧急联系人'**
  String get mineQuickEmergencyTitle;

  /// No description provided for @mineQuickEmergencySubtitle.
  ///
  /// In zh, this message translates to:
  /// **'已设置 1 位联系人'**
  String get mineQuickEmergencySubtitle;

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

  /// No description provided for @mineSettingsMoreTitle.
  ///
  /// In zh, this message translates to:
  /// **'更多设置'**
  String get mineSettingsMoreTitle;

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

  /// No description provided for @settingsMoreClearImageCache.
  ///
  /// In zh, this message translates to:
  /// **'清理图片缓存'**
  String get settingsMoreClearImageCache;

  /// No description provided for @settingsMoreCacheCleared.
  ///
  /// In zh, this message translates to:
  /// **'图片缓存已清理'**
  String get settingsMoreCacheCleared;

  /// No description provided for @settingsMoreResetDefaults.
  ///
  /// In zh, this message translates to:
  /// **'恢复默认设置'**
  String get settingsMoreResetDefaults;

  /// No description provided for @settingsMoreDefaultsReset.
  ///
  /// In zh, this message translates to:
  /// **'已恢复默认设置'**
  String get settingsMoreDefaultsReset;

  /// No description provided for @settingsMoreOpenSourceLicenses.
  ///
  /// In zh, this message translates to:
  /// **'开源许可'**
  String get settingsMoreOpenSourceLicenses;

  /// No description provided for @mineErrorTitle.
  ///
  /// In zh, this message translates to:
  /// **'我的页面暂时没有加载出来'**
  String get mineErrorTitle;

  /// No description provided for @mineErrorDescription.
  ///
  /// In zh, this message translates to:
  /// **'结构已经接好，重新拉一次 mock 数据即可。'**
  String get mineErrorDescription;

  /// No description provided for @mineActionToast.
  ///
  /// In zh, this message translates to:
  /// **'{action}：后续会接入对应详情或设置流程。'**
  String mineActionToast(String action);

  /// No description provided for @morePageDescription.
  ///
  /// In zh, this message translates to:
  /// **'工具箱、紧急帮助、设备管理和低频但重要的能力归在这里。'**
  String get morePageDescription;

  /// No description provided for @moreSectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'功能枢纽'**
  String get moreSectionTitle;

  /// No description provided for @moreSectionSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'这一栏会收纳低频但依然重要的工作流。'**
  String get moreSectionSubtitle;

  /// No description provided for @moreHeaderNotifications.
  ///
  /// In zh, this message translates to:
  /// **'通知'**
  String get moreHeaderNotifications;

  /// No description provided for @moreHeaderSupport.
  ///
  /// In zh, this message translates to:
  /// **'帮助'**
  String get moreHeaderSupport;

  /// No description provided for @moreEmergencySectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'紧急救助'**
  String get moreEmergencySectionTitle;

  /// No description provided for @moreFamilySectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'家庭健康'**
  String get moreFamilySectionTitle;

  /// No description provided for @moreAiSectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'AI 识别工具箱'**
  String get moreAiSectionTitle;

  /// No description provided for @moreDeviceSectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'智能设备管理'**
  String get moreDeviceSectionTitle;

  /// No description provided for @moreKnowledgeSectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'知识与服务'**
  String get moreKnowledgeSectionTitle;

  /// No description provided for @moreEnvironmentSectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'环境与健康提醒中心'**
  String get moreEnvironmentSectionTitle;

  /// No description provided for @moreEnvironmentMoreAction.
  ///
  /// In zh, this message translates to:
  /// **'更多'**
  String get moreEnvironmentMoreAction;

  /// No description provided for @moreRecentSectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'最近使用'**
  String get moreRecentSectionTitle;

  /// No description provided for @moreRecentViewAllAction.
  ///
  /// In zh, this message translates to:
  /// **'查看全部'**
  String get moreRecentViewAllAction;

  /// No description provided for @moreQuickSectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'快捷入口'**
  String get moreQuickSectionTitle;

  /// No description provided for @moreCareNoteTitle.
  ///
  /// In zh, this message translates to:
  /// **'温馨提示'**
  String get moreCareNoteTitle;

  /// No description provided for @moreEmergencySosTitle.
  ///
  /// In zh, this message translates to:
  /// **'SOS 紧急求助'**
  String get moreEmergencySosTitle;

  /// No description provided for @moreEmergencySosSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'一键呼救，快速联系紧急联系人'**
  String get moreEmergencySosSubtitle;

  /// No description provided for @moreEmergencyMentalHotlineTitle.
  ///
  /// In zh, this message translates to:
  /// **'心理援助热线'**
  String get moreEmergencyMentalHotlineTitle;

  /// No description provided for @moreEmergencyMentalHotlineSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'24h 心理支持与危机干预'**
  String get moreEmergencyMentalHotlineSubtitle;

  /// No description provided for @moreEmergencyLockscreenTitle.
  ///
  /// In zh, this message translates to:
  /// **'锁屏医疗信息'**
  String get moreEmergencyLockscreenTitle;

  /// No description provided for @moreEmergencyLockscreenSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'紧急情况下展示你的医疗信息'**
  String get moreEmergencyLockscreenSubtitle;

  /// No description provided for @moreFamilyProfilesTitle.
  ///
  /// In zh, this message translates to:
  /// **'家人档案'**
  String get moreFamilyProfilesTitle;

  /// No description provided for @moreFamilyProfilesSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'管理家人健康档案'**
  String get moreFamilyProfilesSubtitle;

  /// No description provided for @moreFamilyVaccinationTitle.
  ///
  /// In zh, this message translates to:
  /// **'接种与体检提醒'**
  String get moreFamilyVaccinationTitle;

  /// No description provided for @moreFamilyVaccinationSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'为家人设置接种 / 体检提醒'**
  String get moreFamilyVaccinationSubtitle;

  /// No description provided for @moreFamilyAlertTitle.
  ///
  /// In zh, this message translates to:
  /// **'异常预警'**
  String get moreFamilyAlertTitle;

  /// No description provided for @moreFamilyAlertSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'家人健康异常及时提醒'**
  String get moreFamilyAlertSubtitle;

  /// No description provided for @moreAiSkinTitle.
  ///
  /// In zh, this message translates to:
  /// **'皮肤 / 皮疹识别'**
  String get moreAiSkinTitle;

  /// No description provided for @moreAiSkinSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'拍照识别皮肤问题初步识别参考'**
  String get moreAiSkinSubtitle;

  /// No description provided for @moreAiMentalScaleTitle.
  ///
  /// In zh, this message translates to:
  /// **'心理量表评估'**
  String get moreAiMentalScaleTitle;

  /// No description provided for @moreAiMentalScaleSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'多种量表自助评估结果仅供参考'**
  String get moreAiMentalScaleSubtitle;

  /// No description provided for @moreAiReportImportTitle.
  ///
  /// In zh, this message translates to:
  /// **'报告拍照导入'**
  String get moreAiReportImportTitle;

  /// No description provided for @moreAiReportImportSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'拍照识别化验单 / 病历等报告'**
  String get moreAiReportImportSubtitle;

  /// No description provided for @moreDeviceMineTitle.
  ///
  /// In zh, this message translates to:
  /// **'我的设备'**
  String get moreDeviceMineTitle;

  /// No description provided for @moreDeviceMineSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'管理已连接设备当前 2 台设备'**
  String get moreDeviceMineSubtitle;

  /// No description provided for @moreDeviceAddTitle.
  ///
  /// In zh, this message translates to:
  /// **'添加设备'**
  String get moreDeviceAddTitle;

  /// No description provided for @moreDeviceAddSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'连接手表、血压计、体脂秤等设备'**
  String get moreDeviceAddSubtitle;

  /// No description provided for @moreDeviceSyncTitle.
  ///
  /// In zh, this message translates to:
  /// **'同步状态'**
  String get moreDeviceSyncTitle;

  /// No description provided for @moreDeviceSyncSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'数据同步与历史同步：刚刚'**
  String get moreDeviceSyncSubtitle;

  /// No description provided for @moreKnowledgeSleepTitle.
  ///
  /// In zh, this message translates to:
  /// **'睡眠改善'**
  String get moreKnowledgeSleepTitle;

  /// No description provided for @moreKnowledgeSleepSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'睡眠方案与个性化建议'**
  String get moreKnowledgeSleepSubtitle;

  /// No description provided for @moreKnowledgeMindfulnessTitle.
  ///
  /// In zh, this message translates to:
  /// **'正念课程'**
  String get moreKnowledgeMindfulnessTitle;

  /// No description provided for @moreKnowledgeMindfulnessSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'冥想练习与放松训练'**
  String get moreKnowledgeMindfulnessSubtitle;

  /// No description provided for @moreKnowledgeWomenTitle.
  ///
  /// In zh, this message translates to:
  /// **'女性健康专栏'**
  String get moreKnowledgeWomenTitle;

  /// No description provided for @moreKnowledgeWomenSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'经期管理 / 备孕 / 更年期'**
  String get moreKnowledgeWomenSubtitle;

  /// No description provided for @moreEnvironmentPollenTitle.
  ///
  /// In zh, this message translates to:
  /// **'花粉'**
  String get moreEnvironmentPollenTitle;

  /// No description provided for @moreEnvironmentPollenValue.
  ///
  /// In zh, this message translates to:
  /// **'较高'**
  String get moreEnvironmentPollenValue;

  /// No description provided for @moreEnvironmentUvTitle.
  ///
  /// In zh, this message translates to:
  /// **'紫外线'**
  String get moreEnvironmentUvTitle;

  /// No description provided for @moreEnvironmentUvValue.
  ///
  /// In zh, this message translates to:
  /// **'中等'**
  String get moreEnvironmentUvValue;

  /// No description provided for @moreEnvironmentAirTitle.
  ///
  /// In zh, this message translates to:
  /// **'空气污染'**
  String get moreEnvironmentAirTitle;

  /// No description provided for @moreEnvironmentAirValue.
  ///
  /// In zh, this message translates to:
  /// **'良'**
  String get moreEnvironmentAirValue;

  /// No description provided for @moreEnvironmentAdviceTitle.
  ///
  /// In zh, this message translates to:
  /// **'过敏防护建议'**
  String get moreEnvironmentAdviceTitle;

  /// No description provided for @moreEnvironmentAdviceBody.
  ///
  /// In zh, this message translates to:
  /// **'基于你的过敏史，今天建议加强外出防护。'**
  String get moreEnvironmentAdviceBody;

  /// No description provided for @moreEnvironmentAdviceAction.
  ///
  /// In zh, this message translates to:
  /// **'查看'**
  String get moreEnvironmentAdviceAction;

  /// No description provided for @moreRecentSkinTime.
  ///
  /// In zh, this message translates to:
  /// **'今天 10:21'**
  String get moreRecentSkinTime;

  /// No description provided for @moreRecentVaccinationTime.
  ///
  /// In zh, this message translates to:
  /// **'昨天 18:30'**
  String get moreRecentVaccinationTime;

  /// No description provided for @moreRecentDeviceTime.
  ///
  /// In zh, this message translates to:
  /// **'昨天 09:15'**
  String get moreRecentDeviceTime;

  /// No description provided for @moreRecentHotlineTime.
  ///
  /// In zh, this message translates to:
  /// **'05-12 21:40'**
  String get moreRecentHotlineTime;

  /// No description provided for @moreQuickCalculatorTitle.
  ///
  /// In zh, this message translates to:
  /// **'健康计算器'**
  String get moreQuickCalculatorTitle;

  /// No description provided for @moreQuickCalculatorSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'BMI / BMR 等'**
  String get moreQuickCalculatorSubtitle;

  /// No description provided for @moreQuickBarcodeTitle.
  ///
  /// In zh, this message translates to:
  /// **'药品条码识别'**
  String get moreQuickBarcodeTitle;

  /// No description provided for @moreQuickBarcodeSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'扫码识别药品'**
  String get moreQuickBarcodeSubtitle;

  /// No description provided for @moreQuickConverterTitle.
  ///
  /// In zh, this message translates to:
  /// **'单位换算'**
  String get moreQuickConverterTitle;

  /// No description provided for @moreQuickConverterSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'体重 / 温度等'**
  String get moreQuickConverterSubtitle;

  /// No description provided for @moreQuickExportTitle.
  ///
  /// In zh, this message translates to:
  /// **'数据导出'**
  String get moreQuickExportTitle;

  /// No description provided for @moreQuickExportSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'导出健康数据'**
  String get moreQuickExportSubtitle;

  /// No description provided for @moreCareNoteBody.
  ///
  /// In zh, this message translates to:
  /// **'本应用提供的内容仅供参考，不替代医生诊断与治疗建议。'**
  String get moreCareNoteBody;

  /// No description provided for @moreErrorTitle.
  ///
  /// In zh, this message translates to:
  /// **'更多页面暂时没有加载出来'**
  String get moreErrorTitle;

  /// No description provided for @moreErrorDescription.
  ///
  /// In zh, this message translates to:
  /// **'mock 结构已经接好，重新拉一次即可。'**
  String get moreErrorDescription;

  /// No description provided for @moreActionToast.
  ///
  /// In zh, this message translates to:
  /// **'{action}：后续会打开对应工具或详情流程。'**
  String moreActionToast(String action);

  /// No description provided for @morePlannedToast.
  ///
  /// In zh, this message translates to:
  /// **'{action} — 此功能尚未开放。'**
  String morePlannedToast(Object action);

  /// No description provided for @morePlannedBadge.
  ///
  /// In zh, this message translates to:
  /// **'计划中'**
  String get morePlannedBadge;

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
  /// **'尚未登录。'**
  String get authNotSignedIn;

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
  /// **'你昨晚睡得还不错，喝神净满满！'**
  String get todayGreetingSubtitleMorning;

  /// No description provided for @todayGreetingSubtitleAfternoon.
  ///
  /// In zh, this message translates to:
  /// **'午后先补水，再把提醒和状态慢慢对齐。'**
  String get todayGreetingSubtitleAfternoon;

  /// No description provided for @todayGreetingSubtitleEvening.
  ///
  /// In zh, this message translates to:
  /// **'把今天的状态收拢一下，给明天留出节奏。'**
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

  /// No description provided for @todayHealthSummaryCardTitle.
  ///
  /// In zh, this message translates to:
  /// **'健康摘要'**
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
  /// **'Mock provider 和页面结构已经接好，可以重新拉取一次看看。'**
  String get todayErrorDescription;

  /// No description provided for @todayEmptyTitle.
  ///
  /// In zh, this message translates to:
  /// **'你还没有任何记录'**
  String get todayEmptyTitle;

  /// No description provided for @todayEmptyDescription.
  ///
  /// In zh, this message translates to:
  /// **'先记录饮水、用药或体征，我们会为你提供个性化建议。'**
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

  /// No description provided for @mineEditFieldSexAtBirth.
  ///
  /// In zh, this message translates to:
  /// **'性别'**
  String get mineEditFieldSexAtBirth;

  /// No description provided for @mineEditFieldHeightCm.
  ///
  /// In zh, this message translates to:
  /// **'身高 (cm)'**
  String get mineEditFieldHeightCm;

  /// No description provided for @mineEditFieldPregnancyState.
  ///
  /// In zh, this message translates to:
  /// **'怀孕状态'**
  String get mineEditFieldPregnancyState;

  /// No description provided for @mineEditFieldLactationState.
  ///
  /// In zh, this message translates to:
  /// **'哺乳状态'**
  String get mineEditFieldLactationState;

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
