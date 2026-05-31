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

  /// No description provided for @medicineMockTime0800Taken.
  ///
  /// In zh, this message translates to:
  /// **'08:00 已服用'**
  String get medicineMockTime0800Taken;

  /// No description provided for @medicineMockTime2000Pending.
  ///
  /// In zh, this message translates to:
  /// **'20:00 待服用'**
  String get medicineMockTime2000Pending;

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

  /// No description provided for @medicineMockNameVitaminD.
  ///
  /// In zh, this message translates to:
  /// **'维生素 D3'**
  String get medicineMockNameVitaminD;

  /// No description provided for @medicineMockDoseVitaminD.
  ///
  /// In zh, this message translates to:
  /// **'1000 IU'**
  String get medicineMockDoseVitaminD;

  /// No description provided for @medicineMockScheduleDailyOnce.
  ///
  /// In zh, this message translates to:
  /// **'每日 1 次'**
  String get medicineMockScheduleDailyOnce;

  /// No description provided for @medicineMockWithDinner.
  ///
  /// In zh, this message translates to:
  /// **'建议随晚餐'**
  String get medicineMockWithDinner;

  /// No description provided for @medicineMockStock15Days.
  ///
  /// In zh, this message translates to:
  /// **'剩余 15 天'**
  String get medicineMockStock15Days;

  /// No description provided for @medicineStatusNeedsCheckin.
  ///
  /// In zh, this message translates to:
  /// **'今晚记得打卡'**
  String get medicineStatusNeedsCheckin;

  /// No description provided for @medicineMockNameSertraline.
  ///
  /// In zh, this message translates to:
  /// **'舍曲林'**
  String get medicineMockNameSertraline;

  /// No description provided for @medicineMockDoseSertraline.
  ///
  /// In zh, this message translates to:
  /// **'50 mg'**
  String get medicineMockDoseSertraline;

  /// No description provided for @medicineMockTime2200Pending.
  ///
  /// In zh, this message translates to:
  /// **'22:00 待服用'**
  String get medicineMockTime2200Pending;

  /// No description provided for @medicineMockStressRisk.
  ///
  /// In zh, this message translates to:
  /// **'近期压力偏高，漏服风险上升'**
  String get medicineMockStressRisk;

  /// No description provided for @medicineMockStock3Days.
  ///
  /// In zh, this message translates to:
  /// **'剩余 3 天'**
  String get medicineMockStock3Days;

  /// No description provided for @medicineStatusNeedRefillSoon.
  ///
  /// In zh, this message translates to:
  /// **'需要尽快补药'**
  String get medicineStatusNeedRefillSoon;

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
  /// **'补充提醒'**
  String get medicineAlertRefillTitle;

  /// No description provided for @medicineAlertRefillBody.
  ///
  /// In zh, this message translates to:
  /// **'维生素 D 低于 7 天，请及时补货。'**
  String get medicineAlertRefillBody;

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

  /// No description provided for @medicineAlertInteractionAction.
  ///
  /// In zh, this message translates to:
  /// **'查看详情'**
  String get medicineAlertInteractionAction;

  /// No description provided for @medicinePromiseTitle.
  ///
  /// In zh, this message translates to:
  /// **'Luminous 用药边界'**
  String get medicinePromiseTitle;

  /// No description provided for @medicinePromiseBody.
  ///
  /// In zh, this message translates to:
  /// **'这个页面会主动帮你发现风险，但不会伪装成诊断结论。'**
  String get medicinePromiseBody;

  /// No description provided for @medicinePromisePointBoundary.
  ///
  /// In zh, this message translates to:
  /// **'所有结果都作为参考，不替代医生诊断或治疗决定。'**
  String get medicinePromisePointBoundary;

  /// No description provided for @medicinePromisePointPregnancy.
  ///
  /// In zh, this message translates to:
  /// **'孕期、哺乳期、儿童和精神类药物会被更高优先级地警示。'**
  String get medicinePromisePointPregnancy;

  /// No description provided for @medicinePromisePointPrivacy.
  ///
  /// In zh, this message translates to:
  /// **'拍照、处方和高敏感药物信息会优先按最小暴露原则处理。'**
  String get medicinePromisePointPrivacy;

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

  /// No description provided for @medicineSearchNoResultScan.
  ///
  /// In zh, this message translates to:
  /// **'拍照或扫码'**
  String get medicineSearchNoResultScan;

  /// No description provided for @medicineSearchErrorTitle.
  ///
  /// In zh, this message translates to:
  /// **'搜索页暂时没有加载出来'**
  String get medicineSearchErrorTitle;

  /// No description provided for @minePageDescription.
  ///
  /// In zh, this message translates to:
  /// **'档案、目标、隐私与账号设置会在这里重建。'**
  String get minePageDescription;

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

  /// No description provided for @authLoginBadge.
  ///
  /// In zh, this message translates to:
  /// **'认证 / 登录'**
  String get authLoginBadge;

  /// No description provided for @authRegisterBadge.
  ///
  /// In zh, this message translates to:
  /// **'认证 / 注册'**
  String get authRegisterBadge;

  /// No description provided for @authLoginTitle.
  ///
  /// In zh, this message translates to:
  /// **'用更克制的方式登录。'**
  String get authLoginTitle;

  /// No description provided for @authLoginDescription.
  ///
  /// In zh, this message translates to:
  /// **'使用 Lucent 账号进入新的用药主线，后续再逐步解锁提醒、快照和多语言健康流程。'**
  String get authLoginDescription;

  /// No description provided for @authRegisterTitle.
  ///
  /// In zh, this message translates to:
  /// **'先把干净版本搭起来。'**
  String get authRegisterTitle;

  /// No description provided for @authRegisterDescription.
  ///
  /// In zh, this message translates to:
  /// **'先完成注册，再在 Lucent 之上逐步生长用药计划、提醒和多语言健康能力。'**
  String get authRegisterDescription;

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

  /// No description provided for @authLoginLead.
  ///
  /// In zh, this message translates to:
  /// **'先输入邮箱，再选择密码登录或验证码登录。'**
  String get authLoginLead;

  /// No description provided for @authRegisterLead.
  ///
  /// In zh, this message translates to:
  /// **'先验证邮箱，再设置密码。昵称可选。'**
  String get authRegisterLead;

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

  /// No description provided for @authForgotPasswordBadge.
  ///
  /// In zh, this message translates to:
  /// **'认证 / 重置'**
  String get authForgotPasswordBadge;

  /// No description provided for @authForgotPasswordTitle.
  ///
  /// In zh, this message translates to:
  /// **'通过邮箱重置密码。'**
  String get authForgotPasswordTitle;

  /// No description provided for @authForgotPasswordDescription.
  ///
  /// In zh, this message translates to:
  /// **'发送验证码，设置新密码，然后回到登录页重新登录。'**
  String get authForgotPasswordDescription;

  /// No description provided for @authResetPasswordTitle.
  ///
  /// In zh, this message translates to:
  /// **'重置密码'**
  String get authResetPasswordTitle;

  /// No description provided for @authResetPasswordLead.
  ///
  /// In zh, this message translates to:
  /// **'使用账号绑定的邮箱接收重置验证码。'**
  String get authResetPasswordLead;

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

  /// No description provided for @authChangeEmailBadge.
  ///
  /// In zh, this message translates to:
  /// **'认证 / 邮箱'**
  String get authChangeEmailBadge;

  /// No description provided for @authChangeEmailTitle.
  ///
  /// In zh, this message translates to:
  /// **'谨慎更换账号邮箱。'**
  String get authChangeEmailTitle;

  /// No description provided for @authChangeEmailDescription.
  ///
  /// In zh, this message translates to:
  /// **'先验证新邮箱，再把它设为账号登录邮箱。'**
  String get authChangeEmailDescription;

  /// No description provided for @authChangeEmailFormTitle.
  ///
  /// In zh, this message translates to:
  /// **'更换邮箱'**
  String get authChangeEmailFormTitle;

  /// No description provided for @authChangeEmailLead.
  ///
  /// In zh, this message translates to:
  /// **'当前邮箱：{email}'**
  String authChangeEmailLead(String email);

  /// No description provided for @authChangeEmailSignedOutLead.
  ///
  /// In zh, this message translates to:
  /// **'请先登录，再更换账号邮箱。'**
  String get authChangeEmailSignedOutLead;

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

  /// No description provided for @authBackHomePrompt.
  ///
  /// In zh, this message translates to:
  /// **'返回首页？'**
  String get authBackHomePrompt;

  /// No description provided for @authSignedInAs.
  ///
  /// In zh, this message translates to:
  /// **'当前已登录：{email}'**
  String authSignedInAs(String email);

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

  /// No description provided for @authInfraHint.
  ///
  /// In zh, this message translates to:
  /// **'安全 token 存储、Lucent 多语言响应与会话恢复能力已经接到这层表单之下。'**
  String get authInfraHint;

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

  /// No description provided for @todayWaterCardTitle.
  ///
  /// In zh, this message translates to:
  /// **'今日喝水'**
  String get todayWaterCardTitle;

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

  /// No description provided for @todayLumiCardTitle.
  ///
  /// In zh, this message translates to:
  /// **'Lumi 建议'**
  String get todayLumiCardTitle;

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
