part of '../home.dart';

const List<String> _kHomeDefaultHealthTips = <String>[
  '按时服药，别漏别补',
  '饭前饭后按说明来',
  '合并用药先问药师',
  '漏服勿加倍，咨询放在先',
  '出现不适，及时就医',
  '抗生素按疗程，不要擅停',
  '药品避光防潮，远离高温',
  '定期清理过期药品',
  '用药前看禁忌与相互作用',
  '规律作息，药效更稳',
];

List<String> _buildHomeHealthTips(AppLocalizations? l10n) {
  if (l10n == null) {
    return _kHomeDefaultHealthTips;
  }
  return <String>[
    l10n.homeTip1,
    l10n.homeTip2,
    l10n.homeTip3,
    l10n.homeTip4,
    l10n.homeTip5,
    l10n.homeTip6,
    l10n.homeTip7,
    l10n.homeTip8,
    l10n.homeTip9,
    l10n.homeTip10,
  ];
}

List<HomeReminderItemData> _buildHomeDemoReminders(AppLocalizations? l10n) {
  final reminder1Title =
      l10n?.homeFallbackReminder1Title ??
      AppI18nText.pick(zh: '08:30 维生素D', en: '08:30 Vitamin D');
  final reminder1Subtitle =
      l10n?.homeFallbackReminder1Subtitle ??
      AppI18nText.pick(zh: '早餐后服用 1 粒', en: 'Take 1 capsule after breakfast');
  final reminder2Title =
      l10n?.homeFallbackReminder2Title ??
      AppI18nText.pick(zh: '19:30 阿莫西林', en: '19:30 Amoxicillin');
  final reminder2Subtitle =
      l10n?.homeFallbackReminder2Subtitle ??
      AppI18nText.pick(zh: '晚餐后服用 1 粒', en: 'Take 1 capsule after dinner');
  final reminder3Title =
      l10n?.homeFallbackReminder3Title ??
      AppI18nText.pick(zh: '22:00 血压记录', en: '22:00 Blood Pressure Log');
  final reminder3Subtitle =
      l10n?.homeFallbackReminder3Subtitle ??
      AppI18nText.pick(zh: '睡前记录并上传', en: 'Record and upload before sleep');

  return <HomeReminderItemData>[
    HomeReminderItemData(
      icon: Icons.access_time_rounded,
      title: reminder1Title,
      subtitle: reminder1Subtitle,
      done: true,
    ),
    HomeReminderItemData(
      icon: Icons.access_time_rounded,
      title: reminder2Title,
      subtitle: reminder2Subtitle,
      done: false,
    ),
    HomeReminderItemData(
      icon: Icons.access_time_rounded,
      title: reminder3Title,
      subtitle: reminder3Subtitle,
      done: false,
    ),
  ];
}

List<HomeCheckInRecordData> _buildHomeDemoCheckInRecords(
  AppLocalizations? l10n,
) {
  final demoReminders = _buildHomeDemoReminders(l10n);
  final reminder1 = _splitHomeDemoReminderTitle(demoReminders[0].title);
  final reminder2 = _splitHomeDemoReminderTitle(demoReminders[1].title);
  final reminder3 = _splitHomeDemoReminderTitle(demoReminders[2].title);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final twoDaysAgo = today.subtract(const Duration(days: 2));

  return <HomeCheckInRecordData>[
    HomeCheckInRecordData(
      dateKey: _homeDateKey(today),
      reminderId: 'demo-amoxicillin',
      title: reminder1.title,
      reminderTime: reminder1.time,
      done: true,
      takenAt: today
          .add(const Duration(hours: 8, minutes: 34))
          .millisecondsSinceEpoch,
    ),
    HomeCheckInRecordData(
      dateKey: _homeDateKey(today),
      reminderId: 'demo-vitamin-d',
      title: reminder2.title,
      reminderTime: reminder2.time,
      done: false,
    ),
    HomeCheckInRecordData(
      dateKey: _homeDateKey(today),
      reminderId: 'demo-valsartan',
      title: reminder3.title,
      reminderTime: reminder3.time,
      done: false,
    ),
    HomeCheckInRecordData(
      dateKey: _homeDateKey(yesterday),
      reminderId: 'demo-valsartan',
      title: reminder3.title,
      reminderTime: reminder3.time,
      done: true,
      takenAt: yesterday
          .add(const Duration(hours: 20, minutes: 41))
          .millisecondsSinceEpoch,
    ),
    HomeCheckInRecordData(
      dateKey: _homeDateKey(twoDaysAgo),
      reminderId: 'demo-vitamin-d',
      title: reminder2.title,
      reminderTime: reminder2.time,
      done: true,
      takenAt: twoDaysAgo
          .add(const Duration(hours: 12, minutes: 5))
          .millisecondsSinceEpoch,
    ),
  ];
}

({String time, String title}) _splitHomeDemoReminderTitle(String raw) {
  final text = raw.trim();
  if (text.isEmpty) {
    return (time: '', title: '');
  }
  final firstSpace = text.indexOf(' ');
  if (firstSpace <= 0) {
    return (time: '', title: text);
  }
  final maybeTime = text.substring(0, firstSpace).trim();
  if (!RegExp(r'^\d{1,2}:\d{2}$').hasMatch(maybeTime)) {
    return (time: '', title: text);
  }
  final title = text.substring(firstSpace + 1).trim();
  return (time: maybeTime, title: title.isEmpty ? text : title);
}

String _homeDateKey(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
