import 'package:forui/forui.dart';
import 'package:forui_phosphor/forui_phosphor.dart';

/// 语义图标注册表
///
/// 所有业务代码应通过 [SemanticIcons] 引用图标，而非直接使用 [FLucideIcons]。
/// 这确保同一语义不会使用不同图标，不同语义不会使用相同图标。
///
/// 命名规则：`{域}{语义}`，如 `safetySafe`、`recordMedicine`、`aiEntry`。
abstract final class SemanticIcons {
  // ================================================================
  // 导航 — Tab 图标，与内容层图标严格区分
  // ================================================================
  static const tabToday = FLucideIcons.house;
  static const tabRecord = FLucideIcons.notebookPen;
  static const tabMedicine = FLucideIcons.tablets;
  static const tabReview = FLucideIcons.chartColumn;
  static const tabMine = FLucideIcons.userRound;

  // ================================================================
  // AI — 入口 / 生成中 / 结果 / 建议 各用不同图标
  // ================================================================
  static const aiEntry = FLucideIcons.sparkles;
  static const aiAnalyzing = FLucideIcons.loaderCircle;
  static const aiGenerated = FLucideIcons.bot;
  static const aiSuggestion = FLucideIcons.brain;
  static const aiTip = FLucideIcons.lightbulb;

  /// 持久化记忆(能力面板摘要行)。
  static const aiMemory = FLucideIcons.memoryStick;

  /// 知识库 / RAG 检索(能力面板摘要行)。
  static const aiKnowledge = FLucideIcons.database;

  /// 工具调用(能力面板工具列表行前缀)。
  static const aiToolCalling = FLucideIcons.wrench;

  /// 未授权访问 AI 摘要的提示。
  static const aiPermissionHint = FLucideIcons.lockKeyhole;

  /// AI 分析结果为空。
  static const aiEmptyAnalysis = FLucideIcons.circleDashed;

  /// AI 建议列表空态。
  static const aiEmptySuggestion = FLucideIcons.orbit;

  /// 后端图标字符串无法识别时的兜底图标。
  static const aiFallbackIcon = FLucideIcons.wandSparkles;

  /// 触发 AI 生成报告 / 总结。
  static const aiGenerate = FLucideIcons.wand2;

  /// 扫码「AI 识别」方式入口。
  static const aiScanMethod = FLucideIcons.scanText;

  // ================================================================
  // 健康记录类型
  // ================================================================
  static const recordMedicine = FLucideIcons.pill;
  static const recordWater = FLucideIcons.droplets;
  static const recordMeal = FLucideIcons.utensils;
  static const recordSleep = FLucideIcons.moonStar;
  static const recordCaffeine = FLucideIcons.coffee;
  static const recordSymptom = FLucideIcons.thermometer;
  static const recordMood = FLucideIcons.smile;
  static const recordNote = FLucideIcons.fileText;
  static const recordActivity = FLucideIcons.activity;
  static const recordWeight = FLucideIcons.scale;
  static const recordClipboard = FLucideIcons.clipboardList;

  // ================================================================
  // 通用状态
  // ================================================================
  static const statusError = FLucideIcons.circleAlert;
  static const statusWarning = FLucideIcons.triangleAlert;
  static const statusSuccess = FLucideIcons.circleCheck;
  static const statusInfo = FLucideIcons.info;
  static const statusPending = FLucideIcons.clock3;
  static const statusSkipped = FLucideIcons.ban;

  /// 漏服 / 未服用。
  static const statusMissed = FLucideIcons.calendarX;
  static const statusDone = FLucideIcons.check;
  static const statusAllDone = FLucideIcons.checkCheck;
  static const statusBlocked = FLucideIcons.lock;
  static const statusUnavailable = FLucideIcons.circleSlash;
  static const statusUnknown = FLucideIcons.fileQuestion;
  static const statusPaused = FLucideIcons.circlePause;

  /// 记录条目「已完成 / 已就绪」完成态。
  static const statusComplete = FLucideIcons.badgePlus;

  /// 餐食「分析已完成」。
  static const statusAnalyzed = FLucideIcons.sparkle;

  /// 详情页信息横幅。
  static const statusBanner = FLucideIcons.megaphone;

  /// 详情页「暂无内容」空态。
  static const statusNoContent = FLucideIcons.fileX;

  /// 风险检查「数据覆盖不足」。
  static const statusCoverageGap = FLucideIcons.scanEye;

  /// 风险检查「已发现风险」。
  static const statusConfirmedRisk = FLucideIcons.octagonAlert;

  /// 风险严重度「高」。
  static const severityHigh = FLucideIcons.alertTriangle;

  /// 风险严重度「中」。
  static const severityMedium = FLucideIcons.alertCircle;

  /// 风险严重度「提示」。
  static const severityInfo = FLucideIcons.badgeAlert;

  /// 提醒「开始日期」。
  static const doseStartDate = FLucideIcons.calendarFold;

  /// 提醒「加入系统日历」动作。
  static const actionAddToCalendar = FLucideIcons.calendarPlus;

  /// 提醒编辑页「未选择药品」空态。
  static const medicineNoneSelected = FLucideIcons.packageOpen;

  /// 提醒「提示音」设置项。
  static const doseSound = FLucideIcons.volumeOff;

  /// 提醒合并展示的药品行。
  static const medicineReminderRow = FLucideIcons.packageSearch;

  /// 扫码「相机权限被拒」空态。
  static const statusPermissionDenied = FLucideIcons.cameraOff;

  /// 风险发现条目前缀。
  static const safetyFinding = FLucideIcons.hardHat;

  /// 用药禁忌「红牌警告」。
  static const safetyRedFlag = FLucideIcons.octagonX;

  /// 规则引擎（非 AI）生成的建议来源标签。
  static const statusRuleBased = FLucideIcons.listTodo;

  /// AI 解释重试次数耗尽的提示。
  static const statusRetryExhausted = FLucideIcons.refreshCwOff;

  // ================================================================
  // 用药安全 — 风险等级、发现类型各用不同图标
  // ================================================================
  // 风险等级
  static const safetySafe = FLucideIcons.shieldCheck;
  static const safetyNeutral = FLucideIcons.shield;
  static const safetyCaution = FLucideIcons.shieldAlert;
  static const safetyRisk = FPhosphorIcons.warningOctagon;
  static const safetyDanger = FLucideIcons.siren;

  // 发现类型
  static const safetyInteraction = FLucideIcons.arrowLeftRight;
  static const safetyAllergy = FLucideIcons.zap;
  static const safetyCoverage = FLucideIcons.searchX;
  static const safetyLongTerm = FLucideIcons.calendarRange;
  static const safetySpecialGroup = FLucideIcons.baby;
  static const safetySchedulingConflict = FLucideIcons.calendarX2;
  static const safetyDuplicate = FLucideIcons.layers;
  static const safetyFoodInteraction = FPhosphorIcons.bowlSteam;
  static const safetyAlcohol = FLucideIcons.wine;
  static const safetyAllergyShot = FLucideIcons.syringe;
  static const safetyDriving = FLucideIcons.car;
  static const safetyStorage = FPhosphorIcons.warehouse;
  static const safetyTiming = FLucideIcons.clockAlert;
  static const safetyFood = FPhosphorIcons.bowlFood;

  /// 风险检查「已确认安全」结论（区别于 [safetySafe] 的通用安全等级）。
  static const safetyVerified = FLucideIcons.shieldPlus;

  /// 风险检查「未发现问题 / 全部正常」结论。
  static const safetyAllClear = FLucideIcons.listChecks;

  /// 长期用药风险发现。
  static const safetyLongTermUse = FLucideIcons.hourglass;

  /// 安全贴士「服用时机」分类。
  static const safetyTipTiming = FLucideIcons.clockFading;

  /// 风险发现「特殊人群」。
  static const safetySpecialPopulation = FLucideIcons.shieldQuestion;

  /// 安全面板空态（尚未建立安全信息）。
  static const safetyPanelEmpty = FLucideIcons.shieldOff;

  /// 药品页安全守护入口。
  static const safetyGuard = FLucideIcons.shieldHalf;

  // ================================================================
  // 报告
  // ================================================================
  static const reportTrend = FLucideIcons.trendingUp;
  static const reportAdherence = FLucideIcons.badgeCheck;
  static const reportInsight = FLucideIcons.telescope;
  static const reportHistory = FLucideIcons.history;
  static const reportChart = FLucideIcons.chartLine;

  /// 月度报告导出动作。
  static const reportMonthlyExport = FLucideIcons.calendarDays;

  /// 报告洞察条目「用药依从」分类（区别于 [reportAdherence] 的依从率指标）。
  static const reportInsightAdherence = FLucideIcons.circleGauge;

  /// 报告「覆盖率 / 数据完备度」。
  static const reportCoverage = FLucideIcons.packageCheck;

  // ================================================================
  // 用药执行
  // ================================================================
  static const medicineDose = FPhosphorIcons.prescription;
  static const medicineBottle = FLucideIcons.pillBottle;
  static const medicineKit = FLucideIcons.briefcaseMedical;
  static const doseSchedule = FLucideIcons.alarmClockCheck;
  static const doseSlot = FPhosphorIcons.timer;
  static const doseTaken = FLucideIcons.circleCheckBig;
  static const dosePlanned = FLucideIcons.calendarClock;
  static const doseLog = FLucideIcons.receiptText;
  static const doseVolume = FLucideIcons.volume2;
  static const dosePower = FLucideIcons.power;
  static const doseRepeat = FLucideIcons.repeat2;
  static const doseCalendarCheck = FLucideIcons.calendarCheck;

  /// 提醒「每日服药次数」。
  static const doseFrequency = FLucideIcons.timerReset;

  /// 提醒「服药时间点」。
  static const doseTime = FLucideIcons.clockArrowDown;

  /// 风险检查「上次检查时间」。
  static const doseCheckedAt = FLucideIcons.calendarSync;

  /// 药箱「下一次服药」指标。
  static const doseNext = FLucideIcons.clockArrowUp;

  // ================================================================
  // 通知
  // ================================================================
  static const notificationBell = FLucideIcons.bell;
  static const notificationBellRing = FLucideIcons.bellRing;
  static const notificationRead = FLucideIcons.mailMinus;
  static const notificationWarning = FLucideIcons.mailWarning;
  static const notificationDelivered = FLucideIcons.bellCheck;
  static const notificationFailed = FLucideIcons.circleX;
  static const notificationPending = FPhosphorIcons.hourglassMedium;

  /// 提醒推送「已送达」。
  static const notificationSent = FLucideIcons.sendHorizontal;

  /// 通知设置项 / 提醒开关入口。
  static const notificationSettings = FLucideIcons.bellDot;

  // ================================================================
  // 操作
  // ================================================================
  static const actionAdd = FLucideIcons.plus;
  static const actionAddCard = FLucideIcons.squarePlus;
  static const actionEdit = FLucideIcons.pencil;
  static const actionEditCard = FLucideIcons.squarePen;
  static const actionDelete = FLucideIcons.trash2;
  static const actionSearch = FLucideIcons.search;
  static const actionClose = FLucideIcons.x;
  static const actionMore = FLucideIcons.ellipsis;
  static const actionMenu = FLucideIcons.menu;
  static const actionNext = FLucideIcons.chevronRight;
  static const actionPrev = FLucideIcons.chevronLeft;
  static const actionExpand = FLucideIcons.chevronDown;
  static const actionCollapse = FLucideIcons.chevronUp;
  static const actionRefresh = FLucideIcons.refreshCw;
  static const actionReset = FLucideIcons.rotateCcw;
  static const actionShare = FLucideIcons.share2;
  static const actionCopy = FLucideIcons.copy;
  static const actionExport = FLucideIcons.arrowDownToLine;
  static const actionExternalLink = FLucideIcons.externalLink;
  static const actionSettings = FLucideIcons.settings;
  static const actionHelp = FLucideIcons.circleHelp;
  static const actionScan = FLucideIcons.scanLine;
  static const actionTorchOn = FLucideIcons.flashlight;
  static const actionTorchOff = FLucideIcons.flashlightOff;
  static const actionCamera = FLucideIcons.camera;
  static const actionMic = FLucideIcons.mic;
  static const actionImage = FLucideIcons.image;
  static const actionCalendar = FLucideIcons.calendar;
  static const actionMessage = FLucideIcons.messageSquare;
  static const actionMail = FLucideIcons.mail;
  static const actionSend = FLucideIcons.send;
  static const actionMinus = FLucideIcons.minus;

  /// 表单「添加图片」。
  static const actionAddImage = FLucideIcons.imagePlus;

  /// 删除菜品条目。
  static const actionRemoveDish = FLucideIcons.utensilsCrossed;
  static const actionThemeLight = FLucideIcons.sun;

  /// 深色主题。
  static const actionThemeDark = FLucideIcons.moon;
  static const actionTimeSlot = FLucideIcons.clock4;

  /// 账号安全入口。
  static const actionSecurity = FLucideIcons.shieldBan;

  // ================================================================
  // 健康 / 档案
  // ================================================================
  static const profileUser = FLucideIcons.userCheck;
  static const profileCondition = FLucideIcons.heartPulse;
  static const profileEmergency = FLucideIcons.phone;
  static const profileContact = FLucideIcons.contact;

  /// 「我的」档案卡片：基本档案。
  static const profileArchiveBasic = FLucideIcons.clipboardCheck;

  /// 邮箱已验证标记。
  static const authEmailVerified = FLucideIcons.mailCheck;

  // ================================================================
  // 页面内按区块拆分的图标（同页不同区块不复用同一字形）
  // ================================================================
  /// `actionAdd` 的页面区分版本（page_body.dart）。
  static const actionAddPageBody = FLucideIcons.circlePlus;

  /// `actionAdd` 的页面区分版本（new_entry_panel.dart）。
  static const actionAddNewEntryPanel = FLucideIcons.listPlus;

  /// `actionAdd` 的页面区分版本（timeline.dart）。
  static const actionAddTimeline = FLucideIcons.calendarPlus2;

  /// `actionCalendar` 的页面区分版本（date_bar.dart）。
  static const actionCalendarDateBar = FLucideIcons.calendars;

  /// `actionCalendar` 的页面区分版本（timeline_drag_handler.dart）。
  static const actionCalendarTimelineDragHandler = FLucideIcons.calendarCheck2;

  /// `actionCamera` 的页面区分版本（content.dart）。
  static const actionCameraContent = FLucideIcons.webcam;

  /// `actionCopy` 的页面区分版本（oss_licenses.dart）。
  static const actionCopyOssLicenses = FLucideIcons.copyCheck;

  /// `actionDelete` 的页面区分版本（list_item.dart）。
  static const actionDeleteListItem = FLucideIcons.trash;

  /// `actionDelete` 的页面区分版本（edit_actions.dart）。
  static const actionDeleteEditActions = FLucideIcons.packageX;

  /// `actionExternalLink` 的页面区分版本（help.dart）。
  static const actionExternalLinkHelp = FLucideIcons.squareArrowOutUpRight;

  /// `actionExternalLink` 的页面区分版本（general_section.dart）。
  static const actionExternalLinkGeneralSection = FLucideIcons.arrowUpRight;

  /// `actionImage` 的页面区分版本（image_attachment_field.dart）。
  static const actionImageImageAttachmentField = FLucideIcons.images;

  /// `actionImage` 的页面区分版本（timeline_item.dart）。
  static const actionImageTimelineItem = FLucideIcons.imageOff;

  /// `actionMessage` 的页面区分版本（empty_support.dart）。
  static const actionMessageEmptySupport = FLucideIcons.messageCircle;

  /// `actionMessage` 的页面区分版本（account_manage_sections.dart）。
  static const actionMessageAccountManageSections = FLucideIcons.messagesSquare;

  /// `actionMessage` 的页面区分版本（form_body.dart）。
  static const actionMessageFormBody = FLucideIcons.inbox;

  /// `actionRefresh` 的页面区分版本（top_bar.dart）。
  static const actionRefreshTopBar = FLucideIcons.refreshCcw;

  /// `actionSearch` 的页面区分版本（conversation_drawer_list.dart）。
  static const actionSearchConversationDrawerList = FLucideIcons.searchCheck;

  /// `actionSearch` 的页面区分版本（results.dart）。
  static const actionSearchResults = FLucideIcons.searchSlash;

  /// `actionSearch` 的页面区分版本（input.dart）。
  static const actionSearchInput = FLucideIcons.searchCode;

  /// `actionSettings` 的页面区分版本（page_body.dart）。
  static const actionSettingsPageBody = FLucideIcons.settings2;

  /// `actionSettings` 的页面区分版本（sessions.dart）。
  static const actionSettingsSessions = FLucideIcons.columnsSettings;

  /// `actionSettings` 的页面区分版本（top_bar.dart）。
  static const actionSettingsTopBar = FLucideIcons.sliders;

  /// `actionSettings` 的页面区分版本（general_section.dart）。
  static const actionSettingsGeneralSection = FLucideIcons.slidersHorizontal;

  /// `aiAnalyzing` 的页面区分版本（export.dart）。
  static const aiAnalyzingExport = FLucideIcons.loader;

  /// `aiAnalyzing` 的页面区分版本（top_bar.dart）。
  static const aiAnalyzingTopBar = FLucideIcons.loaderPinwheel;

  /// `aiEntry` 的页面区分版本（top_bar.dart）。
  static const aiEntryTopBar = FLucideIcons.cpu;

  /// `aiGenerate` 的页面区分版本（top_bar.dart）。
  static const aiGenerateTopBar = FLucideIcons.star;

  /// `authEmailVerified` 的页面区分版本（account_manage_sections.dart）。
  static const authEmailVerifiedAccountManageSections = FLucideIcons.mailOpen;

  /// `doseCheckedAt` 的页面区分版本（mobile_safety.dart）。
  static const doseCheckedAtMobileSafety = FLucideIcons.clipboardClock;

  /// `medicineBottle` 的页面区分版本（workspace_view.dart）。
  static const medicineBottleWorkspaceView = FLucideIcons.package;

  /// `notificationBell` 的页面区分版本（top_bar.dart）。
  static const notificationBellTopBar = FLucideIcons.bellOff;

  /// `notificationRead` 的页面区分版本（list_item.dart）。
  static const notificationReadListItem = FLucideIcons.mails;

  /// `profileUser` 的页面区分版本（view_models.dart）。
  static const profileUserViewModels = FLucideIcons.user;

  /// `recordActivity` 的页面区分版本（suggestion_history.dart）。
  static const recordActivitySuggestionHistory = FLucideIcons.footprints;

  /// `recordClipboard` 的页面区分版本（suggestion_history.dart）。
  static const recordClipboardSuggestionHistory = FLucideIcons.clipboard;

  /// `recordMedicine` 的页面区分版本（view_models.dart）。
  static const recordMedicineViewModels = FLucideIcons.hospital;

  /// `recordSleep` 的页面区分版本（suggestion_icon_mapping.dart）。
  static const recordSleepSuggestionIconMapping = FLucideIcons.bedDouble;

  /// `recordSleep` 的页面区分版本（view_models.dart）。
  static const recordSleepViewModels = FLucideIcons.bed;

  /// `recordWater` 的页面区分版本（water_progress.dart）。
  static const recordWaterWaterProgress = FLucideIcons.droplet;

  /// `recordWater` 的页面区分版本（view_models.dart）。
  static const recordWaterViewModels = FLucideIcons.dropletOff;

  /// `reportHistory` 的页面区分版本（dashboard_preview.dart）。
  static const reportHistoryDashboardPreview = FLucideIcons.archive;

  /// `reportHistory` 的页面区分版本（more_actions.dart）。
  static const reportHistoryMoreActions = FLucideIcons.archiveRestore;

  /// `reportHistory` 的页面区分版本（review_view.dart）。
  static const reportHistoryReviewView = FLucideIcons.fileClock;

  /// `reportInsight` 的页面区分版本（review_view.dart）。
  static const reportInsightReviewView = FLucideIcons.eye;

  /// `reportTrend` 的页面区分版本（suggestion_history.dart）。
  static const reportTrendSuggestionHistory = FLucideIcons.trendingDown;

  /// `reportTrend` 的页面区分版本（review_view.dart）。
  static const reportTrendReviewView = FLucideIcons.trendingUpDown;

  /// `safetyCaution` 的页面区分版本（risk_check.dart）。
  static const safetyCautionRiskCheck = FLucideIcons.shieldEllipsis;

  /// `safetyCaution` 的页面区分版本（medicine_add_precheck_dialog.dart）。
  static const safetyCautionMedicineAddPrecheckDialog = FLucideIcons.shieldUser;

  /// `safetyInteraction` 的页面区分版本（results.dart）。
  static const safetyInteractionResults = FLucideIcons.arrowRightLeft;

  /// `safetyPanelEmpty` 的页面区分版本（safety_cards.dart）。
  static const safetyPanelEmptySafetyCards = FLucideIcons.shieldQuestionMark;

  /// `safetySchedulingConflict` 的页面区分版本（form_body.dart）。
  static const safetySchedulingConflictFormBody = FLucideIcons.calendarOff;

  /// `safetySchedulingConflict` 的页面区分版本（copy.dart）。
  static const safetySchedulingConflictCopy = FLucideIcons.calendarMinus;

  /// `safetyVerified` 的页面区分版本（safety_cards.dart）。
  static const safetyVerifiedSafetyCards = FLucideIcons.bookmarkCheck;

  /// `statusAllDone` 的页面区分版本（list_item.dart）。
  static const statusAllDoneListItem = FLucideIcons.bookCheck;

  /// `statusAnalyzed` 的页面区分版本（analysis_summary_card.dart）。
  static const statusAnalyzedAnalysisSummaryCard = FLucideIcons.pencilSparkles;

  /// `statusBlocked` 的页面区分版本（export.dart）。
  static const statusBlockedExport = FLucideIcons.circleOff;

  /// `statusBlocked` 的页面区分版本（dashboard_view.dart）。
  static const statusBlockedDashboardView = FLucideIcons.shieldLock;

  /// `statusDone` 的页面区分版本（medicine_add_precheck_dialog.dart）。
  static const statusDoneMedicineAddPrecheckDialog = FLucideIcons.squareCheck;

  /// `statusDone` 的页面区分版本（results.dart）。
  static const statusDoneResults = FLucideIcons.checkCircle;

  /// `statusDone` 的页面区分版本（what_happened.dart）。
  static const statusDoneWhatHappened = FLucideIcons.checkSquare;

  /// `statusDone` 的页面区分版本（completed_actions.dart）。
  static const statusDoneCompletedActions = FLucideIcons.checkSquare2;

  /// `statusDone` 的页面区分版本（scan_result_sheet.dart）。
  static const statusDoneScanResultSheet = FLucideIcons.squareCheckBig;

  /// `statusDone` 的页面区分版本（selection_icon.dart）。
  static const statusDoneSelectionIcon = FLucideIcons.checkLine;

  /// `statusDone` 的页面区分版本（suggestion_interactive.dart）。
  static const statusDoneSuggestionInteractive = FLucideIcons.fileCheck;

  /// `statusPending` 的页面区分版本（security_center.dart）。
  static const statusPendingSecurityCenter = FLucideIcons.clock1;

  /// `statusPending` 的页面区分版本（recognize_dialog.dart）。
  static const statusPendingRecognizeDialog = FLucideIcons.clock2;

  /// `statusPending` 的页面区分版本（what_happened.dart）。
  static const statusPendingWhatHappened = FLucideIcons.clock5;

  /// `statusSkipped` 的页面区分版本（overview_states.dart）。
  static const statusSkippedOverviewStates = FLucideIcons.circleSlash2;

  /// `statusSuccess` 的页面区分版本（recognize_dialog.dart）。
  static const statusSuccessRecognizeDialog = FLucideIcons.checkCircle2;

  /// `statusUnavailable` 的页面区分版本（image_attachment_field.dart）。
  static const statusUnavailableImageAttachmentField = FLucideIcons.squareSlash;

  /// `statusUnavailable` 的页面区分版本（timeline_item.dart）。
  static const statusUnavailableTimelineItem = FLucideIcons.slash;
}
