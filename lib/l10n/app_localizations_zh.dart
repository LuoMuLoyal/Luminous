// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Luminous';

  @override
  String get tabToday => '今日';

  @override
  String get tabRecord => '记录';

  @override
  String get tabMedicine => '用药';

  @override
  String get tabMine => '我的';

  @override
  String get tabMore => '更多';

  @override
  String get desktopSidebarSettings => '设置';

  @override
  String get desktopSidebarHelp => '帮助';

  @override
  String get desktopSidebarHelpToast => '会打开帮助与支持。';

  @override
  String get recordPageDescription => '日历、时间线与多类型每日记录会从这里生长出来。';

  @override
  String get recordSectionTitle => '每日时间线';

  @override
  String get recordSectionSubtitle => '记录页的第一步先搭结构，不急着恢复旧逻辑。';

  @override
  String get recordTodayAction => '今天';

  @override
  String get recordPreviousDayAction => '上一天';

  @override
  String get recordNextDayAction => '下一天';

  @override
  String get recordPickDateAction => '选择日期';

  @override
  String get recordAddAction => '记录';

  @override
  String get recordAddCompactAction => '记录';

  @override
  String get recordCreateFieldKind => '类型';

  @override
  String get recordCreateFieldUnit => '单位';

  @override
  String get recordCreateFieldTitleOptional => '标题（可选）';

  @override
  String get recordCreateFieldNote => '备注';

  @override
  String get recordCreateKindNote => '备注';

  @override
  String get recordCreateValueWater => '杯数';

  @override
  String get recordCreateValueMeal => '名称 / 描述';

  @override
  String get recordCreateValueVital => '数值（如 120/80）';

  @override
  String get recordCreateFailedToast => '记录未保存';

  @override
  String get recordQuickSectionTitle => '快速记录';

  @override
  String get recordSummarySectionTitle => '当天摘要';

  @override
  String get recordSummaryDateLabel => '2025年5月15日（周四）';

  @override
  String get recordTimelineSectionTitle => '时间线';

  @override
  String get recordTrendsSectionTitle => '趋势查看';

  @override
  String get recordNewEntrySectionTitle => '新建记录';

  @override
  String get recordFilterSectionTitle => '记录类型';

  @override
  String get recordFilterSelectAll => '全选';

  @override
  String get recordAllTypesAction => '全部类型';

  @override
  String get recordEditAction => '编辑';

  @override
  String get recordDeleteAction => '删除';

  @override
  String get recordDeleteConfirmMessage => '确定删除此记录？此操作不可撤销。';

  @override
  String get recordMonthLabel => '2025年5月';

  @override
  String get recordOpenDateAction => '查看日期';

  @override
  String get recordNotEnabledLabel => '未开启';

  @override
  String get recordVoiceAction => '语音记录（长按说话）';

  @override
  String recordActionToast(String action) {
    return '$action：后续会打开对应操作。';
  }

  @override
  String get recordErrorTitle => '记录页暂时没有加载出来';

  @override
  String get recordErrorDescription => 'Mock 数据边界已经接好，可以重新拉取一次。';

  @override
  String get recordWeekdaySun => '日';

  @override
  String get recordWeekdayMon => '一';

  @override
  String get recordWeekdayTue => '二';

  @override
  String get recordWeekdayWed => '三';

  @override
  String get recordWeekdayThu => '四';

  @override
  String get recordWeekdayFri => '五';

  @override
  String get recordWeekdaySat => '六';

  @override
  String get recordTypeMeal => '饮食';

  @override
  String get recordTypeVitals => '体征';

  @override
  String get recordTypeWater => '饮水';

  @override
  String get recordTypeMood => '情绪';

  @override
  String get recordTypeSymptom => '症状';

  @override
  String get recordTypeActivity => '运动';

  @override
  String get recordTypeMedication => '用药';

  @override
  String get recordTypeWomenHealth => '女性健康';

  @override
  String get recordTypeHeartRate => '心率';

  @override
  String get recordTypeWeight => '体重';

  @override
  String get recordQuickWomenSubtitle => '未开启';

  @override
  String get recordSummaryMealTitle => '饮食记录';

  @override
  String get recordSummaryWaterTitle => '饮水进度';

  @override
  String get recordSummaryLatestVitalTitle => '最新体征';

  @override
  String get recordSummaryMoodTitle => '情绪记录';

  @override
  String get recordSummaryActivityTitle => '运动完成度';

  @override
  String get recordSummaryTimesUnit => '次';

  @override
  String get recordSummaryCupsUnit => '杯';

  @override
  String get recordSummaryRecorded => '已记录';

  @override
  String get recordSummaryNormal => '正常';

  @override
  String get recordTimelineMealLunch => '饮食 · 午餐';

  @override
  String get recordTimelineMealName => '鸡胸肉藜麦沙拉';

  @override
  String get recordTimelineMealNutrition =>
      '热量约 520 kcal · 蛋白质 32g · 碳水 45g · 脂肪 12g';

  @override
  String get recordTimelineAiBadge => 'AI 识别';

  @override
  String get recordTimelineBloodPressure => '血压';

  @override
  String get recordTimelineBloodPressureDetail => '来源：手动记录 · 正常';

  @override
  String get recordTimelineManualBadge => '手动记录';

  @override
  String get recordTimelineWaterAmount => '1 杯 250ml';

  @override
  String get recordTimelineWaterProgress => '第 4 / 8 杯';

  @override
  String get recordTimelineMedicationName => '阿托伐他汀 20mg';

  @override
  String get recordTimelineMedicationDetail => '已服用 · 与用药计划同步';

  @override
  String get recordTimelineMoodCalm => '情绪 · 平静';

  @override
  String get recordTimelineMoodDetail => '心情不错，睡得还可以';

  @override
  String get recordTimelineHeartRateDetail => '72 次/分 · 来源：手表 · 正常';

  @override
  String get recordTimelineActivityWalk => '运动 · 快走';

  @override
  String get recordTimelineActivityDetail => '30 分钟 · 2.6 km · 180 kcal';

  @override
  String get recordTimelineWeightDetail => '来源：体脂秤 · BMI 22.5';

  @override
  String get recordTrendBloodSugarTitle => '饮食-血糖';

  @override
  String get recordTrendBloodSugarLegend => '餐后血糖 (mmol/L)';

  @override
  String get recordTrendSleepMoodTitle => '情绪-睡眠';

  @override
  String get recordTrendSleepLegend => '睡眠时长（小时）';

  @override
  String get recordTrendMoodLegend => '情绪评分（分）';

  @override
  String get recordTrendHydrationTitle => '饮水完成率';

  @override
  String get recordRange7Days => '近 7 天';

  @override
  String get recordRange30Days => '近 30 天';

  @override
  String get recordHealthBagTitle => '专科健康档案袋';

  @override
  String get recordHealthBagBody => '查看与管理牙齿、眼科、听力等专科记录与报告';

  @override
  String get recordHealthBagLatest => '最近更新：2025-05-10';

  @override
  String get recordHealthBagNext => '下次复查：2025-06-15';

  @override
  String get recordFoodImagePlaceholder => '餐图占位';

  @override
  String get medicinePageDescription =>
      '拍照识别、条码扫描、手动搜索、服药计划和安全提醒先在这里合成一个可继续接后端的工作台。';

  @override
  String get medicineSectionTitle => '用药工作区';

  @override
  String get medicineSectionSubtitle => '这里会承接基于 Lucent 重建后的完整用药闭环。';

  @override
  String get medicineHeaderActionSearch => '搜索药品';

  @override
  String get medicineHeaderActionAdd => '添加药品';

  @override
  String get medicineHeaderActionSearchCompact => '搜索';

  @override
  String get medicineHeaderActionAddCompact => '添加';

  @override
  String get medicineHeaderAddToast => '会打开添加药品与识别入口。';

  @override
  String get medicineHeroEyebrow => 'PERSONAL DRUGBOX';

  @override
  String get medicineHeroTitle => '先把今天的药、风险和补药节奏看清。';

  @override
  String get medicineHeroSubtitle => '拍照识别、条码扫描、手动搜索和用药安全会从这里进入，结果始终保持参考边界。';

  @override
  String get medicineHeroMetricTodayCountValue => '2';

  @override
  String get medicineHeroMetricTodayCountLabel => '今日需服用';

  @override
  String get medicineHeroMetricTodayCountUnit => '种';

  @override
  String get medicineHeroMetricAdherenceValue => '100%';

  @override
  String get medicineHeroMetricAdherenceLabel => '按时服用率';

  @override
  String get medicineHeroMetricAdherenceUnit => '%';

  @override
  String get medicineHeroMetricNextDoseValue => '20:00';

  @override
  String get medicineHeroMetricNextDoseLabel => '下一次提醒';

  @override
  String get medicineHeroBannerTitle => '安全底线先行';

  @override
  String get medicineHeroBannerBody =>
      '识别结果、相互作用和特殊人群提醒都会明确标注“仅供参考”，避免把 AI 结果误当成诊断。';

  @override
  String get medicineQuickActionSectionTitle => '识别与录入';

  @override
  String get medicineQuickActionSectionSubtitle => '先把药品带进来，再逐步补齐提醒、安全和补药闭环。';

  @override
  String get medicineQuickActionCameraTitle => '拍照识别药品';

  @override
  String get medicineQuickActionCameraSubtitle => '识别包装、药盒与处方标签';

  @override
  String get medicineQuickActionBarcodeTitle => '扫描条形码';

  @override
  String get medicineQuickActionBarcodeSubtitle => '补齐规格、厂家与常见别名';

  @override
  String get medicineQuickActionSearchTitle => '手动搜索药品';

  @override
  String get medicineQuickActionSearchSubtitle => '按药名、成分或症状快速查找';

  @override
  String get medicineQuickActionPrescriptionTitle => '导入处方与包装';

  @override
  String get medicineQuickActionPrescriptionSubtitle => '后续可接 OCR 与复诊提醒';

  @override
  String get medicineTodayPlanTitle => '今日服用计划';

  @override
  String get medicineTodayPlanSubtitle => 'Mock 数据先把节奏、库存和风险位置站稳。';

  @override
  String get medicineTodayPlanInspectAction => '查看全部';

  @override
  String get medicineMockNameMetformin => '二甲双胍缓释片';

  @override
  String get medicineMockDoseMetformin => '0.5 g';

  @override
  String get medicineMockScheduleMorningEvening => '每日 2 次';

  @override
  String get medicineMockTime0800 => '08:00';

  @override
  String get medicineMockTime1200 => '12:00';

  @override
  String get medicineMockTime2000 => '20:00';

  @override
  String get medicineDoseStatusTaken => '已服用';

  @override
  String get medicineDoseStatusSkipped => '已跳过';

  @override
  String get medicineDoseStatusPending => '待服用';

  @override
  String get medicineDoseActionTaken => '已服用';

  @override
  String get medicineDoseActionSkipped => '跳过';

  @override
  String get medicineDoseActionSavedToast => '用药打卡已保存';

  @override
  String get medicineDoseActionFailedToast => '用药打卡未保存';

  @override
  String get medicineMockStock7Days => '剩余 7 天';

  @override
  String get medicineStatusStable => '稳定服用';

  @override
  String get medicineMockNameAtorvastatin => '阿托伐他汀钙片';

  @override
  String get medicineMockDoseAtorvastatin => '20 mg';

  @override
  String get medicineMockScheduleDailyOnce => '每日 1 次';

  @override
  String get medicineMockStock15Days => '剩余 15 天';

  @override
  String get medicineStatusNeedsCheckin => '稳定服用';

  @override
  String get medicineMockNameOmeprazole => '奥美拉唑肠溶胶囊';

  @override
  String get medicineMockDoseOmeprazole => '20 mg';

  @override
  String get medicineMockStock3Days => '剩余 3 天';

  @override
  String get medicineStatusNeedRefillSoon => '待关注';

  @override
  String get medicineStockWarningLow => '库存不足，建议及时补充';

  @override
  String get medicineSafetyPanelTitle => '安全与补药';

  @override
  String get medicineSafetyPanelSubtitle => '高风险提醒、临期库存和依从性风险会集中在这里。';

  @override
  String get medicineAlertRefillTitle => '需补药提醒';

  @override
  String get medicineAlertRefillBody => '维生素 D 软胶囊剩余 3 天';

  @override
  String get medicineAlertRefillDetail => '建议及时补货，避免中断';

  @override
  String get medicineAlertRefillAction => '去补药';

  @override
  String get medicineAlertInteractionTitle => '相互作用提醒';

  @override
  String get medicineAlertInteractionBody => '阿司匹林与布洛芬可能增加出血风险。';

  @override
  String get medicineAlertInteractionDetail => '同时使用时请遵医嘱';

  @override
  String get medicineAlertInteractionAction => '查看详情';

  @override
  String get medicineAlertOtherTitle => '其他安全提醒';

  @override
  String get medicineAlertOtherBody => '布洛芬不建议长期连续使用超过 5 天';

  @override
  String get medicineAlertOtherDetail => '如需长期使用，请咨询医生';

  @override
  String get medicineAlertOtherAction => '查看详情';

  @override
  String get medicinePromiseTitle => '安全边界';

  @override
  String get medicinePromiseBody => '这个页面会主动帮你发现风险，但不会伪装成诊断结论。';

  @override
  String get medicinePromisePointBoundary => '结果仅供参考，不替代医生诊断与治疗。';

  @override
  String get medicinePromisePointPregnancy => '孕期、哺乳期、儿童、精神类药物更高优先级警示。';

  @override
  String get medicinePromisePointPrivacy => '处方、拍照和敏感药物信息遵循最小暴露原则。';

  @override
  String get medicinePromisePointDiagnosis => '我们不诊断、不替代医生、不编造药品事实。';

  @override
  String get medicinePromiseAction => '了解更多安全说明';

  @override
  String get medicineViewPlanToast => '会打开完整的今日用药列表与历史记录。';

  @override
  String get medicineOpenPlanItemToast => '会打开药品详情、提醒设置和历史服用记录。';

  @override
  String get medicineOpenPromiseToast => '会打开安全边界、特殊人群提示和隐私处理说明。';

  @override
  String get medicineQuickActionCameraToast => '会调用相机拍摄药盒、药板或标签并开始识别。';

  @override
  String get medicineQuickActionBarcodeToast => '会打开扫码流程，识别条形码并补齐药品信息。';

  @override
  String get medicineQuickActionPrescriptionToast => '会打开图片导入与处方识别流程。';

  @override
  String get medicineAlertRefillToast => '会打开补药与库存详情。';

  @override
  String get medicineAlertInteractionToast => '会打开相互作用详情与风险说明。';

  @override
  String get medicineAlertOtherToast => '会打开其他安全提醒详情。';

  @override
  String get medicineSearchPageTitle => '搜索药品';

  @override
  String get medicineSearchAssistantTitle => '用药助手';

  @override
  String get medicineSearchMyBoxTab => '我的药箱';

  @override
  String get medicineSearchFieldHint => '搜索药品、成分、疾病、症状...';

  @override
  String get medicineSearchSourceCn => '药品说明书（cn）';

  @override
  String get medicineSearchSourceDrugbank => '药物知识（DrugBank）';

  @override
  String get medicineSearchSwitchSource => '切换数据源';

  @override
  String get medicineSearchRecentTitle => '最近搜索';

  @override
  String get medicineSearchClearAction => '清空';

  @override
  String get medicineSearchPhotoAction => '拍照识别';

  @override
  String get medicineSearchBarcodeAction => '扫描条形码';

  @override
  String get medicineSearchPhotoToast => '会打开相机识别药盒、药板或说明书。';

  @override
  String get medicineSearchBarcodeToast => '会打开扫码流程，识别条形码并补齐药品信息。';

  @override
  String get medicineSearchScanHint => '会打开扫码或拍照识别入口。';

  @override
  String get medicineSearchCategoryTitle => '热门常备药分类';

  @override
  String get medicineSearchCategoryPainFever => '退烧止痛';

  @override
  String get medicineSearchCategoryColdCough => '感冒咳嗽';

  @override
  String get medicineSearchCategoryStomach => '肠胃';

  @override
  String get medicineSearchCategorySupplement => '维矿补充';

  @override
  String get medicineSearchCategoryChronic => '慢病常用';

  @override
  String get medicineSearchReferenceNotice => '药品信息仅供参考，具体用药请遵医嘱';

  @override
  String get medicineSearchResultTitle => '搜索结果';

  @override
  String medicineSearchResultCount(int count) {
    return '共找到 $count 条结果';
  }

  @override
  String get medicineSearchMatchedBy => '命中';

  @override
  String get medicineSearchMatchIngredient => '成分';

  @override
  String get medicineSearchMatchName => '名称';

  @override
  String get medicineSearchAddToBoxAction => '加入药箱';

  @override
  String get medicineSearchAddToast => '会加入药箱并进入用药提醒设置。';

  @override
  String get medicineSearchOpenDetailToast => '会打开药品详情页。';

  @override
  String get medicineSearchPreviewTitle => '选中项预览';

  @override
  String get medicineSearchSafetyLead => '你当前的过敏史 / 孕期状态 / 现用药可能影响此药使用';

  @override
  String get medicineSearchSafetyAction => '查看详情页获取完整信息';

  @override
  String get medicineSearchNoResultTitle => '无结果？';

  @override
  String get medicineSearchNoResultKeyword => '检查关键词';

  @override
  String get medicineSearchNoResultSwitch => '切换数据源';

  @override
  String get medicineSearchErrorTitle => '搜索页暂时没有加载出来';

  @override
  String get medicineSearchErrorDescription => '请检查网络连接后重试。';

  @override
  String get mineSectionTitle => '个人工作区';

  @override
  String get mineSectionSubtitle => '身份、目标与隐私控制会共享在这一块安静的界面里。';

  @override
  String get mineHeaderNotifications => '通知';

  @override
  String get mineHeaderSettings => '设置';

  @override
  String get mineAccountDisplayName => 'Lumi 用户';

  @override
  String get mineAccountGuestDisplayName => '访客';

  @override
  String get mineAccountSignedIn => '已登录';

  @override
  String get mineAccountSignedOut => '未登录';

  @override
  String get mineAccountMeta => '会员到期：2026-05-20';

  @override
  String get mineAccountSignedOutMeta => '登录后可同步档案、提醒与个性化健康数据';

  @override
  String get mineAccountManageAction => '管理账号';

  @override
  String get mineAccountEmailVerified => '邮箱已验证';

  @override
  String get mineAccountEmailUnverified => '邮箱未验证';

  @override
  String get mineAccountPasswordSet => '已设置密码';

  @override
  String get mineAccountPasswordUnset => '未设置密码';

  @override
  String mineAccountLinkedIdentityCount(int count) {
    return '已绑定 $count 个';
  }

  @override
  String get mineAccountLinkedIdentityNone => '未绑定第三方';

  @override
  String mineAccountLastLogin(String date) {
    return '上次登录 $date';
  }

  @override
  String get mineAccountLastLoginNone => '上次登录 --';

  @override
  String get mineSignedOutNoticeTitle => '当前未登录';

  @override
  String get mineSignedOutNoticeDescription =>
      '我的页面先展示静态结构，避免未登录时反复请求后端。登录后再加载你的档案与健康上下文。';

  @override
  String get mineCompletionTitle => '档案完整度';

  @override
  String get mineCompletionSubtitle => '完成度良好，继续完善更准确的建议';

  @override
  String get mineSummaryTitle => '健康上下文摘要';

  @override
  String get mineSummaryUpdatedAt => '更新于 2025-05-15';

  @override
  String get mineSummaryAge => '年龄';

  @override
  String get mineSummaryAllergies => '过敏';

  @override
  String get mineSummaryConditions => '慢病/条件';

  @override
  String get mineSummaryMedicines => '当前用药';

  @override
  String get mineSummaryMissingInfo => '缺失信息：生日、性别、单位制、孕哺状态';

  @override
  String get mineSummaryCompleteAction => '去完善';

  @override
  String get mineProfileTitle => '健康档案';

  @override
  String get mineProfileBasicInfoTitle => '基础资料';

  @override
  String get mineProfileBasicInfoSubtitle => '个人基本信息';

  @override
  String get mineProfileAllergiesTitle => '过敏史';

  @override
  String get mineProfileAllergiesSubtitle => '2 项记录';

  @override
  String get mineProfileConditionsTitle => '基础病史';

  @override
  String get mineProfileConditionsSubtitle => '1 项记录';

  @override
  String get mineProfileMedicinesTitle => '当前用药';

  @override
  String get mineProfileMedicinesSubtitle => '3 种药品';

  @override
  String get mineProfileWomenTitle => '女性/孕哺状态';

  @override
  String get mineProfileWomenSubtitle => '未填写';

  @override
  String get mineProfileSpecialistTitle => '专科档案';

  @override
  String get mineProfileSpecialistSubtitle => '口腔/视力/听力等';

  @override
  String get mineProfileLifestyleTitle => '生活习惯';

  @override
  String get mineProfileLifestyleSubtitle => '饮食/运动/睡眠';

  @override
  String get mineProfileFamilyTitle => '家族史';

  @override
  String get mineProfileFamilySubtitle => '遗传与家族病史';

  @override
  String get minePlansTitle => '健康计划中心';

  @override
  String get minePlansViewAll => '查看全部';

  @override
  String get minePlanBloodSugarTitle => '控糖计划';

  @override
  String get minePlanBloodSugarStatus => '进行中';

  @override
  String get minePlanBloodSugarDetail => '已坚持 12 天';

  @override
  String get minePlanWeightTitle => '减重计划';

  @override
  String get minePlanWeightStatus => '未开始';

  @override
  String get minePlanWeightDetail => '设置目标';

  @override
  String get minePlanSleepTitle => '助眠计划';

  @override
  String get minePlanSleepStatus => '进行中';

  @override
  String get minePlanSleepDetail => '睡眠改善中';

  @override
  String get minePlanMoodTitle => '情绪稳定计划';

  @override
  String get minePlanMoodStatus => '未开始';

  @override
  String get minePlanMoodDetail => '关注情绪健康';

  @override
  String get minePlanPregnancyTitle => '备孕计划';

  @override
  String get minePlanPregnancyStatus => '未开始';

  @override
  String get minePlanPregnancyDetail => '科学备孕';

  @override
  String get mineReportTitle => '健康报告';

  @override
  String get mineReportBody => '周/月报表、趋势回顾、健康洞察';

  @override
  String get mineReportMeta => '上次生成：2025-05-12';

  @override
  String get mineReportAction => '查看报告';

  @override
  String get minePrivacyTitle => '隐私控制';

  @override
  String get minePrivacyBody => '数据可见性、共享授权、云同步范围';

  @override
  String get minePrivacyMeta => '已保护 8 大类敏感数据';

  @override
  String get minePrivacyAction => '管理隐私';

  @override
  String get mineStatusPanelTitle => '档案状态';

  @override
  String get mineStatusBasicTitle => '基础资料';

  @override
  String get mineStatusBasicValue => '1/4 完成';

  @override
  String get mineStatusAllergiesTitle => '过敏史';

  @override
  String get mineStatusAllergiesValue => '2 项';

  @override
  String get mineStatusConditionsTitle => '慢病/条件';

  @override
  String get mineStatusConditionsValue => '1 项';

  @override
  String get mineStatusMedicinesTitle => '当前用药';

  @override
  String get mineStatusMedicinesValue => '3 种';

  @override
  String get mineStatusWomenTitle => '孕哺状态';

  @override
  String get mineStatusWomenValue => '未填写';

  @override
  String get mineOnboardingTitle => 'Onboarding 进度';

  @override
  String get mineOnboardingBasicTitle => '基础信息';

  @override
  String get mineOnboardingContextTitle => '健康上下文';

  @override
  String get mineOnboardingMedicineTitle => '用药设置';

  @override
  String get mineOnboardingGoalTitle => '健康目标';

  @override
  String get mineOnboardingPrivacyTitle => '隐私设置';

  @override
  String mineOnboardingProgress(int completed, int total) {
    return '$completed/$total 完成';
  }

  @override
  String get mineQuickEntriesTitle => '快捷入口';

  @override
  String get mineQuickExportTitle => '导出健康数据';

  @override
  String get mineQuickExportSubtitle => '下载健康数据副本';

  @override
  String get mineQuickDoctorTitle => '共享给医生';

  @override
  String get mineQuickDoctorSubtitle => '授权查看健康信息';

  @override
  String get mineQuickEmergencyTitle => '紧急联系人';

  @override
  String get mineQuickEmergencySubtitle => '已设置 1 位联系人';

  @override
  String get mineSettingsThemeTitle => '主题模式';

  @override
  String get mineSettingsAccountTitle => '账号与安全';

  @override
  String get mineSettingsLanguageTitle => '语言';

  @override
  String get mineSettingsNotificationsTitle => '通知设置';

  @override
  String get mineSettingsMoreTitle => '更多设置';

  @override
  String get settingsLanguageSystemLabel => '跟随系统';

  @override
  String get settingsLanguageChineseLabel => '简体中文';

  @override
  String get settingsLanguageEnglishLabel => 'English';

  @override
  String get settingsThemeAppearanceTitle => '外观';

  @override
  String get settingsThemePaletteTitle => '配色';

  @override
  String get settingsThemePaletteClassic => '默认';

  @override
  String get settingsThemePaletteBluePink => '蓝粉';

  @override
  String get settingsThemePaletteYellowGreen => '黄绿';

  @override
  String get settingsSyncFailed => '同步设置失败';

  @override
  String get settingsNotificationsMedicationReminders => '用药提醒';

  @override
  String get settingsNotificationsHealthAlerts => '健康提醒';

  @override
  String get settingsNotificationsWeeklySummary => '每周摘要';

  @override
  String get settingsNotificationsPermissionEnabled => '系统通知已开启';

  @override
  String get settingsNotificationsPermissionDisabled => '系统通知未开启';

  @override
  String get settingsNotificationsPermissionUnsupported => '当前平台不提供通知权限状态';

  @override
  String get settingsNotificationsPermissionEnabledHint =>
      '通知已授权。下方开关可控制各类通知的显示。';

  @override
  String get settingsNotificationsPermissionDisabledHint =>
      '点击可打开系统权限对话框。系统通知权限未开启时，本地提醒无法显示。';

  @override
  String get settingsMoreClearImageCache => '清理图片缓存';

  @override
  String get settingsMoreCacheCleared => '图片缓存已清理';

  @override
  String get settingsMoreResetDefaults => '恢复默认设置';

  @override
  String get settingsMoreDefaultsReset => '已恢复默认设置';

  @override
  String get settingsMoreOpenSourceLicenses => '开源许可';

  @override
  String get mineErrorTitle => '我的页面暂时没有加载出来';

  @override
  String get mineErrorDescription => '结构已经接好，重新拉一次 mock 数据即可。';

  @override
  String mineActionToast(String action) {
    return '$action：后续会接入对应详情或设置流程。';
  }

  @override
  String get morePageDescription => '工具箱、紧急帮助、设备管理和低频但重要的能力归在这里。';

  @override
  String get moreSectionTitle => '功能枢纽';

  @override
  String get moreSectionSubtitle => '这一栏会收纳低频但依然重要的工作流。';

  @override
  String get moreHeaderNotifications => '通知';

  @override
  String get moreHeaderSupport => '帮助';

  @override
  String get moreEmergencySectionTitle => '紧急救助';

  @override
  String get moreFamilySectionTitle => '家庭健康';

  @override
  String get moreAiSectionTitle => 'AI 识别工具箱';

  @override
  String get moreDeviceSectionTitle => '智能设备管理';

  @override
  String get moreKnowledgeSectionTitle => '知识与服务';

  @override
  String get moreEnvironmentSectionTitle => '环境与健康提醒中心';

  @override
  String get moreEnvironmentMoreAction => '更多';

  @override
  String get moreRecentSectionTitle => '最近使用';

  @override
  String get moreRecentViewAllAction => '查看全部';

  @override
  String get moreQuickSectionTitle => '快捷入口';

  @override
  String get moreCareNoteTitle => '温馨提示';

  @override
  String get moreEmergencySosTitle => 'SOS 紧急求助';

  @override
  String get moreEmergencySosSubtitle => '一键呼救，快速联系紧急联系人';

  @override
  String get moreEmergencyMentalHotlineTitle => '心理援助热线';

  @override
  String get moreEmergencyMentalHotlineSubtitle => '24h 心理支持与危机干预';

  @override
  String get moreEmergencyLockscreenTitle => '锁屏医疗信息';

  @override
  String get moreEmergencyLockscreenSubtitle => '紧急情况下展示你的医疗信息';

  @override
  String get moreFamilyProfilesTitle => '家人档案';

  @override
  String get moreFamilyProfilesSubtitle => '管理家人健康档案';

  @override
  String get moreFamilyVaccinationTitle => '接种与体检提醒';

  @override
  String get moreFamilyVaccinationSubtitle => '为家人设置接种 / 体检提醒';

  @override
  String get moreFamilyAlertTitle => '异常预警';

  @override
  String get moreFamilyAlertSubtitle => '家人健康异常及时提醒';

  @override
  String get moreAiSkinTitle => '皮肤 / 皮疹识别';

  @override
  String get moreAiSkinSubtitle => '拍照识别皮肤问题初步识别参考';

  @override
  String get moreAiMentalScaleTitle => '心理量表评估';

  @override
  String get moreAiMentalScaleSubtitle => '多种量表自助评估结果仅供参考';

  @override
  String get moreAiReportImportTitle => '报告拍照导入';

  @override
  String get moreAiReportImportSubtitle => '拍照识别化验单 / 病历等报告';

  @override
  String get moreDeviceMineTitle => '我的设备';

  @override
  String get moreDeviceMineSubtitle => '管理已连接设备当前 2 台设备';

  @override
  String get moreDeviceAddTitle => '添加设备';

  @override
  String get moreDeviceAddSubtitle => '连接手表、血压计、体脂秤等设备';

  @override
  String get moreDeviceSyncTitle => '同步状态';

  @override
  String get moreDeviceSyncSubtitle => '数据同步与历史同步：刚刚';

  @override
  String get moreKnowledgeSleepTitle => '睡眠改善';

  @override
  String get moreKnowledgeSleepSubtitle => '睡眠方案与个性化建议';

  @override
  String get moreKnowledgeMindfulnessTitle => '正念课程';

  @override
  String get moreKnowledgeMindfulnessSubtitle => '冥想练习与放松训练';

  @override
  String get moreKnowledgeWomenTitle => '女性健康专栏';

  @override
  String get moreKnowledgeWomenSubtitle => '经期管理 / 备孕 / 更年期';

  @override
  String get moreEnvironmentPollenTitle => '花粉';

  @override
  String get moreEnvironmentPollenValue => '较高';

  @override
  String get moreEnvironmentUvTitle => '紫外线';

  @override
  String get moreEnvironmentUvValue => '中等';

  @override
  String get moreEnvironmentAirTitle => '空气污染';

  @override
  String get moreEnvironmentAirValue => '良';

  @override
  String get moreEnvironmentAdviceTitle => '过敏防护建议';

  @override
  String get moreEnvironmentAdviceBody => '基于你的过敏史，今天建议加强外出防护。';

  @override
  String get moreEnvironmentAdviceAction => '查看';

  @override
  String get moreRecentSkinTime => '今天 10:21';

  @override
  String get moreRecentVaccinationTime => '昨天 18:30';

  @override
  String get moreRecentDeviceTime => '昨天 09:15';

  @override
  String get moreRecentHotlineTime => '05-12 21:40';

  @override
  String get moreQuickCalculatorTitle => '健康计算器';

  @override
  String get moreQuickCalculatorSubtitle => 'BMI / BMR 等';

  @override
  String get moreQuickBarcodeTitle => '药品条码识别';

  @override
  String get moreQuickBarcodeSubtitle => '扫码识别药品';

  @override
  String get moreQuickConverterTitle => '单位换算';

  @override
  String get moreQuickConverterSubtitle => '体重 / 温度等';

  @override
  String get moreQuickExportTitle => '数据导出';

  @override
  String get moreQuickExportSubtitle => '导出健康数据';

  @override
  String get moreCareNoteBody => '本应用提供的内容仅供参考，不替代医生诊断与治疗建议。';

  @override
  String get moreErrorTitle => '更多页面暂时没有加载出来';

  @override
  String get moreErrorDescription => 'mock 结构已经接好，重新拉一次即可。';

  @override
  String moreActionToast(String action) {
    return '$action：后续会打开对应工具或详情流程。';
  }

  @override
  String morePlannedToast(Object action) {
    return '$action — 此功能尚未开放。';
  }

  @override
  String get morePlannedBadge => '计划中';

  @override
  String get todaySectionTitle => '今日工作区';

  @override
  String get todaySectionSubtitle => '新的首页会从这里逐步接入提醒、快照、喝水与 Lumi 建议。';

  @override
  String get authWelcomeBack => '欢迎回来';

  @override
  String get authCreateAccount => '创建账号';

  @override
  String get authModePassword => '密码';

  @override
  String get authModeCode => '验证码';

  @override
  String get authEmailLabel => '邮箱';

  @override
  String get authEmailHint => 'name@example.com';

  @override
  String get authPasswordLabel => '密码';

  @override
  String get authPasswordHint => '至少 8 位，建议包含大小写和数字';

  @override
  String get authCodeLabel => '验证码';

  @override
  String get authNicknameLabel => '昵称';

  @override
  String get authNicknameHint => '可选';

  @override
  String get authEmailRequiredToast => '请先填写邮箱。';

  @override
  String get authCodeRequiredToast => '请先填写验证码。';

  @override
  String get authPasswordRequiredToast => '请先填写密码。';

  @override
  String get authConfirmPasswordRequiredToast => '请先确认密码。';

  @override
  String get authSendCode => '发送验证码';

  @override
  String authSendCodeAgain(int seconds) {
    return '$seconds 秒后重发';
  }

  @override
  String get authSignIn => '登录';

  @override
  String get authWechatSignIn => '微信登录';

  @override
  String get authWechatAuthorizeOpened => '已在浏览器打开微信授权页。';

  @override
  String get authWechatBrowserOpenFailed => '无法打开微信授权页。';

  @override
  String get authWechatCallbackLabel => '微信回调链接 / 授权码';

  @override
  String get authWechatCallbackHint => '扫码后粘贴回调链接';

  @override
  String get authWechatCompleteAction => '完成微信登录';

  @override
  String get authWechatCallbackRequiredToast => '请先粘贴微信回调链接。';

  @override
  String get authWechatCallbackInvalidToast => '微信回调链接缺少 code 或 state。';

  @override
  String get authCreateAccountAction => '创建账号';

  @override
  String get authForgotPasswordPrompt => '忘记密码？';

  @override
  String get authResetPasswordAction => '重置密码';

  @override
  String get authNeedAccountPrompt => '还没有账号？';

  @override
  String get authRegisterNowAction => '立即注册';

  @override
  String get authHaveAccountPrompt => '已经有账号？';

  @override
  String get authRememberPasswordPrompt => '想起密码了？';

  @override
  String get authNewPasswordLabel => '新密码';

  @override
  String get authConfirmPasswordLabel => '确认密码';

  @override
  String get authPasswordsDoNotMatch => '两次输入的密码不一致。';

  @override
  String get authResetPasswordSubmit => '重置密码';

  @override
  String get authResetPasswordSuccess => '密码已更新，请重新登录。';

  @override
  String get authChangeEmailFormTitle => '更换邮箱';

  @override
  String get authNewEmailLabel => '新邮箱';

  @override
  String get authChangeEmailSubmit => '更新邮箱';

  @override
  String get authChangeEmailSuccess => '邮箱已更新。';

  @override
  String get authAccountSettingsFormTitle => '账号与安全';

  @override
  String get authAccountOverviewTitle => '账号状态';

  @override
  String get authAccountOverviewEmail => '邮箱';

  @override
  String get authAccountOverviewEmailVerified => '邮箱验证';

  @override
  String get authAccountOverviewPassword => '密码';

  @override
  String get authAccountOverviewLastLogin => '上次登录';

  @override
  String get authEmailMissing => '未设置';

  @override
  String authEmailVerifiedAt(String time) {
    return '$time 已验证';
  }

  @override
  String get authEmailUnverifiedStatus => '未验证';

  @override
  String get authPasswordSetStatus => '已设置';

  @override
  String get authPasswordUnsetStatus => '未设置';

  @override
  String get authLastLoginUnknown => '未知';

  @override
  String get authProfileSectionTitle => '资料信息';

  @override
  String get authProfileSectionDescription =>
      '修改昵称或头像地址；留空会按 Lucent 当前规则清空对应字段。';

  @override
  String get authAvatarLabel => '头像地址';

  @override
  String get authAvatarHint => 'https://example.com/avatar.png';

  @override
  String get authProfileSaveAction => '保存资料';

  @override
  String get authProfileSaveSuccess => '资料已更新。';

  @override
  String get authEmailSectionTitle => '登录邮箱';

  @override
  String get authEmailVerifiedDescription => '当前邮箱已经验证，可以继续更换登录邮箱。';

  @override
  String get authEmailUnverifiedDescription => '当前邮箱仍未验证；你仍可以进入更换邮箱流程。';

  @override
  String get authEmailAddAction => '添加邮箱';

  @override
  String get authEmailChangeAction => '更换邮箱';

  @override
  String get authLinkedIdentitiesSectionTitle => '第三方身份';

  @override
  String get authLinkedIdentityNone => '尚未绑定第三方身份。';

  @override
  String get authLinkedIdentityEmailMissing => '无第三方邮箱';

  @override
  String authLinkedIdentityLinkedAt(String date) {
    return '$date 绑定';
  }

  @override
  String get authIdentityProviderWechatWeb => '微信网页';

  @override
  String get authIdentityProviderWechatMobile => '微信移动端';

  @override
  String get authIdentityUnlinkAction => '解绑';

  @override
  String get authIdentityUnlinkDisabledAction => '保留';

  @override
  String get authIdentityUnlinkSuccess => '身份已解绑。';

  @override
  String get authIdentityUnlinkConfirmTitle => '解绑身份';

  @override
  String authIdentityUnlinkConfirmMessage(String provider) {
    return '确定要解绑 $provider？';
  }

  @override
  String get authIdentityLinkWechatAction => '绑定微信';

  @override
  String get authIdentityLinkSuccess => '微信身份已绑定。';

  @override
  String get authIdentityLinkUnsupported => '当前平台无法打开微信绑定。';

  @override
  String get authCancelAction => '取消';

  @override
  String get authPasswordSectionTitle => '修改密码';

  @override
  String get authPasswordSectionDescription =>
      '修改后当前账号的 refresh 会话会全部失效，你需要重新登录。';

  @override
  String get authPasswordUnsetManagementHint => '当前账号还没有本地密码。';

  @override
  String get authCurrentPasswordLabel => '当前密码';

  @override
  String get authCurrentPasswordRequiredToast => '请先填写当前密码。';

  @override
  String get authNewPasswordRequiredToast => '请先填写新密码。';

  @override
  String get authChangePasswordAction => '更新密码';

  @override
  String get authChangePasswordSuccess => '密码已更新，请重新登录。';

  @override
  String get authDeleteAccountSectionTitle => '注销账号';

  @override
  String get authDeleteAccountSectionDescription =>
      '这是高风险操作；提交后会清空本地会话并让 Lucent 将账号标记为删除状态。';

  @override
  String get authDeleteAccountPasswordRequiredHint => '当前账号暂不能在这里注销。';

  @override
  String get authDeleteAccountHint => '输入当前密码以确认注销';

  @override
  String get authDeleteAccountAction => '注销账号';

  @override
  String get authDeleteAccountSuccess => '账号已注销。';

  @override
  String get authBackHomePrompt => '返回首页？';

  @override
  String get authCheckingSession => '正在检查登录状态...';

  @override
  String get authNotSignedIn => '尚未登录。';

  @override
  String get authGoLogin => '去登录';

  @override
  String get authGoRegister => '去注册';

  @override
  String get authSignOut => '退出登录';

  @override
  String get todayHeroTitle => '今日';

  @override
  String get todayHeroDescription =>
      '新的首页将从这里开始重建：先完成响应式视觉系统，再逐步接入喝水、提醒、健康快照和 Lumi 建议。';

  @override
  String get todayChipWater => '喝水追踪';

  @override
  String get todayChipMedication => '用药提醒';

  @override
  String get todayChipSnapshot => '健康快照';

  @override
  String get todayChipDiet => '饮食建议';

  @override
  String get todayChipEnvironment => '环境提醒';

  @override
  String get todayChipLumi => 'Lumi 建议';

  @override
  String get todayNotificationsTooltip => '通知';

  @override
  String get todayGreetingTitleMorning => '早上好，阳光正好';

  @override
  String get todayGreetingTitleAfternoon => '下午好，继续稳稳推进';

  @override
  String get todayGreetingTitleEvening => '晚上好，准备轻松收尾';

  @override
  String get todayGreetingSubtitleMorning => '你昨晚睡得还不错，喝神净满满！';

  @override
  String get todayGreetingSubtitleAfternoon => '午后先补水，再把提醒和状态慢慢对齐。';

  @override
  String get todayGreetingSubtitleEvening => '把今天的状态收拢一下，给明天留出节奏。';

  @override
  String get todayHeroCareLine => '我们会在需要时，给你恰到好处的提醒';

  @override
  String get todayHeroImagePlaceholder => 'Banner 图片占位';

  @override
  String get todayWaterCardTitle => '今日喝水';

  @override
  String get todayWaterUnit => '次';

  @override
  String todayWaterCount(int count) {
    return '$count 次';
  }

  @override
  String todayWaterGoalCount(int count) {
    return '目标 $count 次';
  }

  @override
  String todayWaterRemainingCount(int count) {
    return '还差 $count 次';
  }

  @override
  String get todayMedicationCardTitle => '用药提醒';

  @override
  String get todayMedicationAction => '查看';

  @override
  String todayMedicationSummary(int medicineCount, int pendingCount) {
    return '$medicineCount 种药品 · $pendingCount 个待服用';
  }

  @override
  String todayMedicationNextDose(String time, String medicineName) {
    return '下一次 $time · $medicineName';
  }

  @override
  String get todayMedicationNameAtorvastatin => '阿托伐他汀';

  @override
  String get todayHealthSummaryCardTitle => '健康摘要';

  @override
  String get todayVitalHeartRateLabel => '心率';

  @override
  String get todayVitalHeartRateUnit => '次/分';

  @override
  String get todayVitalBloodPressureLabel => '血压';

  @override
  String get todayVitalSleepLabel => '睡眠';

  @override
  String get todayVitalSleepUnit => '小时';

  @override
  String get todayVitalStatusNormal => '正常';

  @override
  String get todayVitalStatusGood => '良好';

  @override
  String get todayMealCardTitle => '今日饮食建议';

  @override
  String get todayMealHighProteinBalancedTitle => '高蛋白均衡餐';

  @override
  String get todayMealHighProteinBalancedDescription => '鸡胸肉、藜麦、时蔬沙拉';

  @override
  String get todayMealEnergyHint => '补充优质蛋白，均衡营养，给身体满满能量。';

  @override
  String get todayMealImagePlaceholder => '餐图占位';

  @override
  String get todayMealRefreshAction => '换一换';

  @override
  String get todayEnvironmentCardTitle => '环境提醒';

  @override
  String get todayEnvironmentPollenLabel => '花粉';

  @override
  String get todayEnvironmentUvLabel => '紫外线';

  @override
  String get todayEnvironmentLevelLow => '较低';

  @override
  String get todayEnvironmentLevelMedium => '中等';

  @override
  String get todayEnvironmentLevelHigh => '较高';

  @override
  String get todayMoreAction => '更多';

  @override
  String get todayViewDetailsAction => '查看详情';

  @override
  String get todayLumiCardTitle => 'Lumi 建议';

  @override
  String get todayPreviewBadge => '预览';

  @override
  String get todayLumiPollenProtectionBody => '今天空气中花粉较多，建议外出佩戴口罩，注意防护呼吸敏感。';

  @override
  String get todayLumiAction => '查看详情';

  @override
  String get todayErrorTitle => '今日页暂时没有加载出来';

  @override
  String get todayErrorDescription => 'Mock provider 和页面结构已经接好，可以重新拉取一次看看。';

  @override
  String get todayEmptyTitle => '你还没有任何记录';

  @override
  String get todayEmptyDescription => '先记录饮水、用药或体征，我们会为你提供个性化建议。';

  @override
  String get todayEmptyAction => '去记录';

  @override
  String get todayRetryAction => '重试';

  @override
  String placeholderSoon(String label) {
    return '$label · 即将上线';
  }

  @override
  String get placeholderDescription => '这一栏的结构已经预留完成，下一步会按新的多端设计系统重建。';

  @override
  String get mineThemeModeSystem => '跟随系统';

  @override
  String get mineThemeModeLight => '浅色';

  @override
  String get mineThemeModeDark => '深色';

  @override
  String get medicineSearchPreviewClinical => '临床提示';

  @override
  String get medicineSearchPreviewSafety => '安全确认';

  @override
  String get medicineSearchPreviewEmpty => '选择一个药品查看详情';

  @override
  String medicineSearchSourceRefCn(String id) {
    return '批准文号：$id';
  }

  @override
  String medicineSearchSourceRefDrugbank(String id) {
    return 'DrugBank ID：$id';
  }

  @override
  String get mineEditProfileTitle => '编辑档案';

  @override
  String get mineEditAllergyTitle => '编辑过敏';

  @override
  String get mineEditAllergyNewTitle => '新增过敏';

  @override
  String get mineEditConditionTitle => '编辑疾病';

  @override
  String get mineEditConditionNewTitle => '新增疾病';

  @override
  String get mineEditMedicineTitle => '编辑用药';

  @override
  String get mineEditMedicineNewTitle => '新增用药';

  @override
  String get mineEditSaveAction => '保存';

  @override
  String get mineEditDeleteAction => '删除';

  @override
  String get mineEditSavedToast => '已保存';

  @override
  String get mineEditDeletedToast => '已删除';

  @override
  String get mineEditFieldBirthDate => '出生日期 (YYYY-MM-DD)';

  @override
  String get mineEditFieldSexAtBirth => '性别';

  @override
  String get mineEditFieldHeightCm => '身高 (cm)';

  @override
  String get mineEditFieldPregnancyState => '怀孕状态';

  @override
  String get mineEditFieldLactationState => '哺乳状态';

  @override
  String get mineEditFieldBloodType => '血型';

  @override
  String get mineEditFieldLocale => '语言';

  @override
  String get mineEditFieldTimezone => '时区';

  @override
  String get mineEditFieldUnitSystem => '单位制';

  @override
  String get mineEditFieldOnboardingCompleted => '完成新手引导';

  @override
  String get mineEditFieldKind => '类型';

  @override
  String get mineEditFieldLabel => '名称';

  @override
  String get mineEditFieldReaction => '反应';

  @override
  String get mineEditFieldSeverity => '严重程度';

  @override
  String get mineEditFieldNote => '备注';

  @override
  String get mineEditFieldRecordedAt => '记录时间';

  @override
  String get mineEditFieldStatus => '状态';

  @override
  String get mineEditFieldDiagnosedAt => '诊断日期 (YYYY-MM-DD)';

  @override
  String get mineEditFieldSource => '来源';

  @override
  String get mineEditFieldSourceRefId => '来源ID';

  @override
  String get mineEditFieldDisplayName => '药品名称';

  @override
  String get mineEditFieldStrengthText => '规格';

  @override
  String get mineEditFieldDoseText => '剂量';

  @override
  String get mineEditFieldRoute => '给药途径';

  @override
  String get mineEditFieldStartedAt => '开始日期 (YYYY-MM-DD)';

  @override
  String get mineEditFieldEndedAt => '结束日期 (YYYY-MM-DD)';
}
