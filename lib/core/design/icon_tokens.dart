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
  static const tabMedicine = FLucideIcons.pillBottle;
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
  static const recordMoon = FLucideIcons.moon;
  static const recordClipboard = FLucideIcons.clipboardList;

  // ================================================================
  // 通用状态
  // ================================================================
  static const statusError = FLucideIcons.circleAlert;
  static const statusWarning = FLucideIcons.triangleAlert;
  static const statusSuccess = FLucideIcons.circleCheck;
  static const statusInfo = FLucideIcons.info;
  static const statusInfoCircle = FPhosphorIcons.info;
  static const statusPending = FLucideIcons.clock3;
  static const statusSkipped = FLucideIcons.ban;
  static const statusDone = FLucideIcons.check;
  static const statusAllDone = FLucideIcons.checkCheck;
  static const statusBlocked = FLucideIcons.lock;
  static const statusUnavailable = FLucideIcons.circleSlash;
  static const statusUnknown = FLucideIcons.fileQuestion;
  static const statusPaused = FLucideIcons.circlePause;

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
  static const safetyLongTerm = FLucideIcons.hourglass;
  static const safetySpecialGroup = FLucideIcons.baby;
  static const safetySchedulingConflict = FLucideIcons.calendarX2;
  static const safetyDuplicate = FPhosphorIcons.copySimple;
  static const safetyFoodInteraction = FPhosphorIcons.bowlSteam;
  static const safetyAlcohol = FLucideIcons.wine;
  static const safetyAllergyShot = FLucideIcons.syringe;
  static const safetyDriving = FLucideIcons.car;
  static const safetyPregnancy = FLucideIcons.heartPulse;
  static const safetyStorage = FPhosphorIcons.warehouse;
  static const safetyTiming = FLucideIcons.calendarClock;
  static const safetyCaffeine = FLucideIcons.coffee;
  static const safetyFood = FPhosphorIcons.bowlFood;

  // ================================================================
  // 报告
  // ================================================================
  static const reportReady = FLucideIcons.circleCheck;
  static const reportInsufficient = FLucideIcons.fileQuestion;
  static const reportTrend = FLucideIcons.trendingUp;
  static const reportAdherence = FLucideIcons.badgeCheck;
  static const reportInsight = FLucideIcons.lightbulb;
  static const reportExport = FLucideIcons.arrowDownToLine;
  static const reportHistory = FLucideIcons.history;
  static const reportChart = FLucideIcons.chartLine;

  // ================================================================
  // 用药执行
  // ================================================================
  static const medicineDose = FPhosphorIcons.prescription;
  static const medicineBottle = FLucideIcons.pillBottle;
  static const medicineKit = FLucideIcons.briefcaseMedical;
  static const doseSchedule = FLucideIcons.alarmClockCheck;
  static const doseSlot = FPhosphorIcons.timer;
  static const doseTaken = FPhosphorIcons.checkCircle;
  static const doseSkipped = FLucideIcons.ban;
  static const dosePending = FLucideIcons.clock3;
  static const dosePlanned = FLucideIcons.calendarClock;
  static const doseLog = FLucideIcons.receiptText;
  static const doseVolume = FLucideIcons.volume2;
  static const dosePower = FLucideIcons.power;
  static const doseRepeat = FLucideIcons.repeat2;
  static const doseCalendarCheck = FLucideIcons.calendarCheck;

  // ================================================================
  // 通知
  // ================================================================
  static const notificationBell = FLucideIcons.bell;
  static const notificationBellRing = FLucideIcons.bellRing;
  static const notificationRead = FLucideIcons.mailMinus;
  static const notificationWarning = FLucideIcons.mailWarning;
  static const notificationDelivered = FPhosphorIcons.bellRinging;
  static const notificationFailed = FLucideIcons.circleX;
  static const notificationPending = FPhosphorIcons.hourglassMedium;

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
  static const actionCamera = FLucideIcons.camera;
  static const actionMic = FLucideIcons.mic;
  static const actionImage = FLucideIcons.image;
  static const actionCalendar = FLucideIcons.calendar;
  static const actionMessage = FLucideIcons.messageSquare;
  static const actionSend = FLucideIcons.send;
  static const actionMinus = FLucideIcons.minus;
  static const actionThemeLight = FLucideIcons.sun;
  static const actionTimeSlot = FLucideIcons.clock4;

  // ================================================================
  // 健康 / 档案
  // ================================================================
  static const profileUser = FLucideIcons.userCheck;
  static const profileAllergy = FLucideIcons.zap;
  static const profileCondition = FLucideIcons.heartPulse;
  static const profileMedicine = FLucideIcons.briefcaseMedical;
  static const profileEmergency = FLucideIcons.phone;
  static const profileContact = FLucideIcons.contact;
}
