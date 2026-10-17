"""按槽位阈值改写超限文案（中英同时改）。

只改 `lib/l10n/src/*.arb` 分片（唯一真相），绝不碰合并产物。
改写原则见 plans/2026-10-17-copy-length-governance.md：
一句话一件事、删架构解释、空态给下一步、枚举超 3 项就概括。
"""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SRC = ROOT / "lib/l10n/src"

# key -> (en, zh)。两边同时给，不留单侧。
R = {
    # ---------------- medicine ----------------
    "medicinePromisePointSpecialGroup": (
        "Special-group priority",
        "特殊人群优先警示",
    ),
    "medicineRiskCheckLlmEmptyBody": (
        "AI analysis finds long-term risks static checks miss. Add a medicine to start.",
        "AI 可发现静态检查遗漏的长期风险，添加药品后开始分析",
    ),
    "medicineSearchPrecheckUnavailableToast": (
        "Pre-check unavailable. Review it in risk check after adding.",
        "暂无法即时检查，加入后可在风险检查中查看",
    ),
    "medicineAlertSpecialGroupSafetyDetail": (
        "For special groups, follow clinician or pharmacist guidance first",
        "特殊人群用药请优先遵医嘱",
    ),
    "medicineReminderDeviceLocalHint": (
        "Only the schedule is saved; notifications follow device settings.",
        "仅保存提醒计划，通知由本机设置控制",
    ),
    "medicineDetailOpenReminderAction": (
        "Reminder details",
        "查看提醒详情",
    ),
    "medicineReminderDeleteAction": (
        "Delete reminder",
        "删除提醒",
    ),
    # scan 分片同属 medicine 文件
    "scanModelDownloadMessage": (
        "OCR needs a ~30MB offline model download. Download now?",
        "OCR 识别需下载约 30MB 离线模型，是否立即下载？",
    ),
    "scanNoResultTitle": (
        "Could not identify this medicine",
        "未能识别药品信息",
    ),
    "scanViewReminderAction": (
        "Reminder details",
        "查看提醒详情",
    ),

    # ---------------- review ----------------
    "reviewLockedFeaturesSignedOutHint": (
        "Sign in and add records to unlock summaries and exports.",
        "登录并补齐记录后解锁总结与导出",
    ),
    "reviewLockedFeaturesInsufficientHint": (
        "Add records to unlock summaries and exports.",
        "补齐记录后解锁总结与导出",
    ),
    "reviewAiSummaryDefaultHint": (
        "No AI summary yet; showing the latest report snapshot.",
        "尚未生成 AI 总结，当前显示最近报告快照",
    ),
    "reviewAiSummaryErrorHint": (
        "AI summary failed; showing the report snapshot instead.",
        "AI 总结生成失败，暂显示报告快照",
    ),
    "reviewAiSummaryDisabledHint": (
        "AI summaries are off; showing the report snapshot only.",
        "AI 总结已关闭，仅显示报告快照",
    ),
    "reviewRecordGuideDescription": (
        "Recorded {observed}/{expected} days this week. Keep tracking to see trends and notable changes.",
        "本周已记录 {observed}/{expected} 天，继续记录可见趋势与变化",
    ),
    "reviewReviewNoEventDescription": (
        "Start a health observation to review what changed and what's next.",
        "开始健康观察后，这里会回顾变化与后续",
    ),
    "reviewNoteworthyAbstainLabel": (
        "No notable changes",
        "无值得注意的变化",
    ),
    "reviewReadinessInsufficientTitle": (
        "Not enough data for a full report",
        "数据不足，暂无法生成完整报告",
    ),
    "reviewReadinessInsufficientBadge": (
        "Not enough",
        "数据不足",
    ),

    # ---------------- record ----------------
    "recordNlpInputHint": (
        "e.g. Two cups of water this morning, bloated at noon, slept 6 hours.",
        "比如：早上喝了两杯水，中午胃胀，昨晚睡 6 小时",
    ),
    "recordNlpFailedCandidatesHint": (
        "{count, plural, =0{No failed candidates remain} =1{1 candidate failed to save. Retry only the failed item.} other{{count} candidates failed to save. Retry only the failed ones.}}",
        "还有 {count} 条候选记录上次保存失败，可仅重试失败项",
    ),
    "recordDetailErrorTitle": (
        "Record details did not load",
        "记录详情暂时没有加载出来",
    ),

    # ---------------- mine ----------------
    "minePrivacyNoticeTitle": (
        "Sensitive data is protected",
        "敏感数据默认保护",
    ),
    "mineSignedOutNoticeDescription": (
        "Sign in to load your profile and health context.",
        "登录后加载你的档案与健康上下文",
    ),
    "mineAlertPrivacyBadge": (
        "Confirm",
        "先确认",
    ),
    "mineReadinessPreviewTitle": (
        "Your profile is still locked",
        "个人档案尚未解锁",
    ),

    # ---------------- auth ----------------
    "authDeleteAccountPolicyAction": (
        "View policy",
        "查看注销政策",
    ),
    "authDeleteAccountPolicyHint": (
        "Account data is permanently deleted within 30 days.",
        "账户数据将在 30 天内永久删除",
    ),
    "authEmailVerifyLinkHint": (
        "Verification email sent. Tap the link in it to finish.",
        "验证邮件已发送，点击邮件中的链接完成验证",
    ),
    "authPasswordNotSetToast": (
        "Set a local password in Account settings first.",
        "请先在账号与安全中设置本地密码",
    ),
    "authSessionsManageAction": (
        "Manage sessions",
        "管理登录会话",
    ),
    "authGoogleCompleteAction": (
        "Complete sign-in",
        "完成登录",
    ),
    "authWechatCompleteAction": (
        "Complete sign-in",
        "完成登录",
    ),
    "authGoogleCallbackLabel": (
        "Callback link or code",
        "回调链接或授权码",
    ),
    "authWechatCallbackLabel": (
        "Callback link or code",
        "回调链接或授权码",
    ),

    # ---------------- assistant ----------------
    "assistantConversationDisabledByUserHint": (
        "AI chat is off. Turn it on in Settings (top-right).",
        "AI 对话已关闭，可在右上角设置中开启",
    ),
    "assistantInputDisabledHint": (
        "Input is disabled while AI chat is off. Turn it on in Settings.",
        "AI 对话关闭时无法输入，可在设置中开启",
    ),
    "assistantDisclaimerText": (
        "AI responses are for reference only and are not medical advice. Consult a doctor before changing medications.",
        "AI 回答仅供参考，不构成医疗建议；用药调整请咨询医生",
    ),
    "assistantProposalConstraintsLabel": (
        "Constraints",
        "确认前约束",
    ),
    "assistantSettingsMemorySubtitle": (
        "New chats may reference earlier conversations",
        "新对话可能参考之前的对话",
    ),

    # ---------------- settings ----------------
    "settingsNotificationsPermissionDisabledHint": (
        "Tap to allow notifications for local reminders.",
        "点击授权通知，本地提醒才能显示",
    ),
    "settingsNotificationsPermissionPermanentlyDeniedHint": (
        "Tap to enable notifications in system settings.",
        "点击前往系统设置手动开启通知权限",
    ),
    "settingsNotificationsPermissionEnabledHint": (
        "Notifications are allowed. Toggles below pick the types.",
        "通知已授权，下方开关可选择类型",
    ),
    "settingsAiPrivacyContextNote": (
        "Selected sources are provided to the AI during conversations.",
        "勾选的数据来源会在对话时提供给 AI",
    ),
    "settingsAiPrivacyMemoryNote": (
        "When memory is on, key points from past chats may be shared with the AI.",
        "开启记忆后，此前对话的要点会提供给 AI",
    ),
    "settingsDataStorageRetentionShortenConfirmMessage": (
        "Cached data older than the new period is deleted immediately. This cannot be undone.",
        "超出新期限的本地缓存将立即清理，此操作不可撤销",
    ),
    "settingsHealthAutoSyncSubtitle": (
        "Sync the last 24 hours of health data on app open",
        "App 进入前台时同步最近 24 小时健康数据",
    ),

    # ---------------- today ----------------
    "todayHealthEventCurrentMedicineLabel": (
        "Link current medicines",
        "关联当前用药",
    ),
    "todayHealthEventReasonRecordLabel": (
        "Link a trigger symptom",
        "关联触发症状",
    ),
    "todayHealthEventCheckInAction": (
        "Confirm result",
        "确认今天结果",
    ),
    "todayObservationErrorTitle": (
        "Observations are unavailable",
        "观察项暂时不可用",
    ),
    "todayObservationSleepMissingSubtitle": (
        "Sleep trends are still unclear. Add a record to sharpen them.",
        "暂时无法判断睡眠趋势，补一条记录后会更准",
    ),
}


def vw(s: str) -> int:
    return sum(2 if ("\u2e80" <= c <= "\u9fff" or "\uff00" <= c <= "\uffef") else 1 for c in s)


def main() -> int:
    # 建立 key -> 文件索引
    loc: dict[str, tuple[Path, Path]] = {}
    for p in sorted(SRC.glob("*_en.arb")):
        zh_p = p.with_name(p.name.replace("_en.arb", "_zh.arb"))
        for k in json.loads(p.read_text(encoding="utf-8")):
            if not k.startswith("@"):
                loc[k] = (p, zh_p)

    changed = 0
    problems = []
    for k, (en_new, zh_new) in R.items():
        if k not in loc:
            problems.append(f"{k}: 不在任何分片中")
            continue
        en_p, zh_p = loc[k]
        en_d = json.loads(en_p.read_text(encoding="utf-8"))
        zh_d = json.loads(zh_p.read_text(encoding="utf-8"))
        if k not in en_d or k not in zh_d:
            problems.append(f"{k}: 分片内缺一侧")
            continue
        en_d[k] = en_new
        zh_d[k] = zh_new
        en_p.write_text(json.dumps(en_d, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        zh_p.write_text(json.dumps(zh_d, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        changed += 1
        print(f"  {k:52} en={vw(en_new):4} zh={vw(zh_new):4}")

    print(f"\n改写 {changed} 个 key（中英各 {changed} 条）")
    if problems:
        print("\n问题:")
        for p in problems:
            print("  " + p)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
