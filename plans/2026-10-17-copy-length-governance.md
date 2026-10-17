# Luminous 文案长度治理计划

> 状态：待执行。审计完成，结论见第三节；本文件驱动改写。

## 一、问题

英文文案在真机上频繁换行、被截断，中文不明显。

审计确认现象成立：**超过单行容量的条目 241 条，英文 235 / 中文 6**。
按本项目实作阈值（比规范推荐值更严）判定为**不合格的 62 条**，全部按错误处理。

## 二、判定标准

### 2.1 几何容量：单行到底能放多少字

不靠经验值，从设计系统真实几何推：

| 量 | 值 | 来源 |
| --- | --- | --- |
| 可用文字宽度 | 320dp | `LayoutScaleResolver.designBaselineTextWidth` |
| 正文档位 | sm = 14px | Forui desktop 基线（`docs/reference/design-system.md`） |
| ASCII 平均字宽 | ≈ 0.5em | 拉丁字体经验值 |
| CJK 字宽 | = 1.0em | 全角定义 |

14px 档下：英文单行 ≈ 320 / 7 ≈ **45 字符**；中文单行 ≈ 320 / 14 ≈ **22 字**。
换算成**视觉宽度**（CJK/全角计 2、ASCII 计 1）后两者都 ≈ 45，故中英文共用一把尺。

### 2.2 实作阈值比规范更严（× 0.8）

规范给的是推荐值，不是目标值。本项目的实作阈值在几何容量上再收 20%：

| 行数 | 几何容量 | **实作阈值** |
| --- | --- | --- |
| 单行 | 45 | **36** |
| 双行 | 90 | **72** |
| 三行 | 135 | **108** |
| 四行（免责） | 180 | **144** |

收 20% 的三条理由：

1. 0.5em 是 ASCII **平均**字宽，W / M / @ 等宽字形接近 0.7em，按平均算会低估；
2. 行内普遍带前置图标 + 间距（约 26dp），几何容量未扣这部分；
3. 中英混排（如 "AI 分析"）打破单一字宽假设。

### 2.3 槽位映射

| 槽位 | 阈值 | 依据 |
| --- | --- | --- |
| 按钮 / 操作（Action、Button、Confirm…） | **19** | Apple HIG：动词开头、简短；截断即失败 |
| 徽标（Badge） | **11** | 非 flex 子节点，超宽会挤压 Row |
| 状态 / 计数（Status、Count） | **16** | 单行状态位 |
| 标签（Label） | **24** | 需与内容同行 |
| 列表行标题（Title、Section、Group） | **36** | Apple HIG：*"Keep item text succinct... minimize truncation and wrapping"* |
| 副标题（Subtitle） | **72** | Apple HIG：*"list item titles only, letting people choose an item to reveal its content in a detail view"* |
| 输入提示 / Toast（Hint、Toast、Prompt） | **72** | NN/g：microcopy 应防截断；Toast 1.8s 内需读完 |
| 说明 / 正文（Description、Body、Note…） | **108** | NN/g：*"shorter than 3 sentences"* |
| 错误 / 失败 / 空态（Error、Failed、Empty…） | **108** | Apple HIG：*"be clear about what someone can do to fix it"* |
| 免责声明（Disclaimer、Text） | **144** | 法务文本，允许更长 |

一手来源：

- [Lists and tables – Apple HIG](https://developer.apple.com/design/human-interface-guidelines/lists-and-tables)
- [Writing – Apple HIG](https://developer.apple.com/design/human-interface-guidelines/writing)
- [Settings – Apple HIG](https://developer.apple.com/design/human-interface-guidelines/settings)
- [The 3 C's of Informational Microcopy – NN/g](https://www.nngroup.com/articles/3-cs-microcopy/)
- [Writing for All Abilities – Microsoft Style Guide](https://learn.microsoft.com/en-us/style-guide/accessibility/writing-all-abilities)

### 2.4 不合格一律按错误处理

**没有"略超微调"这一档。** 超阈值即不合格，必须改写或把内容下沉到合适的槽位，
不存在"接近阈值可放行"的豁免。改写后仍超，说明内容不该待在行内槽位。

## 三、审计结论

工具：`tool/l10n_audit/`（`derive_limits.py` 推容量、`audit_copy.py` 判槽位与量长、
`readable.py` 按 feature 导出全文供人工审读）。

- 总 key 2117；已判槽位 1282；业务名词后缀（`SpecialGroup`/`Water`/`Sleep`）834 条不判长度
- **超单行 241 条**（英文 235 / 中文 6）
- **按实作阈值不合格 62 条**

### 3.1 中文为什么没暴露问题

742 条英文 >20 字符的样本里，**英文长度 / 中文视觉宽中位比值 1.75**。
中文视觉宽只有英文约 57%，是照英文翻译后自然变短，**从未按中文自身槽位尺度校过**。
所以中文的"没问题"是假象，不是设计得当。本次中英文都过。

### 3.2 六类根因

| 类别 | 典型条目 | 说明 |
| --- | --- | --- |
| A 结构错位 | `reviewLockedFeaturesSignedOutHint`(107)、`settingsNotificationsPermissionDisabledHint`(111) | 内容多却放在行内槽位，HIG 要求下沉详情页或改分组 footer |
| B 暴露实现细节 | `mineSignedOutNoticeDescription`（*"so it does not keep hitting the backend"*）、`recordErrorDescription`（*"The data boundary is wired"*）、`todayErrorDescription`（*"The provider and page structure are wired up"*）、`mineErrorDescription`（*"The structure is wired"*） | 讲架构给用户看，零信息量 |
| C 空态/错误态缺动作 | 见 4.3 人工复核清单 | 动作可能落在旁边按钮上，需人工判断 |
| D 列举过长 | `reviewLockedFeaturesInsufficientHint`、`medicineRiskCheckTierSafeDisclaimer` | 四项并列枚举可收敛 |
| E 价值主张混入功能位 | `medicineRiskCheckLlmEmptyBody`(140) | 在空态里解释 AI 能力 |
| F 单纯超长句 | `assistantDisclaimerText`(169)、`healthSyncNotAvailable`(141) | 无结构问题，需压缩或下沉 |

## 四、不合格清单（62 条，全部按错误处理）

完整清单由 `python tool/l10n_audit/audit_copy.py` 复现。表中 `EN / 阈值` 为英文视觉宽度。

### 4.1 严重超限（英文 ≥ 1.5 倍阈值，7 条）

| key | 槽位 | EN / 阈值 | 倍数 | 根因 | 处理方向 |
| --- | --- | --- | --- | --- | --- |
| `todaySuggestionAiExplainMaxRetry` | Retry | 65 / 19 | 3.42× | A | 按钮只留"重试"，说明移出按钮位 |
| `medicinePromisePointSpecialGroup` | Group | 86 / 36 | 2.39× | A | 拆成短标签 + 正文 |
| `medicineRiskCheckCoverageAlertDetailWithMore` | More | 45 / 19 | 2.37× | A | 压成"更多" |
| `minePrivacyNoticeTitle` | Title | 73 / 36 | 2.03× | A | 压成一句短语 |
| `medicineReferenceNoticeTitle` | Title | 59 / 36 | 1.64× | A | 压成一句 |
| `reviewReadinessInsufficientBadge` | Badge | 17 / 11 | 1.55× | F | 压成 2 字 |
| `settingsNotificationsPermissionDisabledHint` | Hint | 111 / 72 | 1.54× | A | 首句留动作，次句移 footer |

### 4.2 其余超限（55 条，同样按错误处理，无豁免）

| key | 槽位 | EN / 阈值 | 倍数 |
| --- | --- | --- | --- |
| `reviewLockedFeaturesSignedOutHint` | Hint | 107 / 72 | 1.49× |
| `recordNlpInputHint` | Hint | 104 / 72 | 1.44× |
| `recordMealAnalysisFailureImageCount` | Count | 23 / 16 | 1.44× |
| `reviewNoteworthyAbstainLabel` | Label | 34 / 24 | 1.42× |
| `authPasswordNotSetToast` | Toast | 101 / 72 | 1.40× |
| `settingsNotificationsPermissionPermanentlyDeniedHint` | Hint | 100 / 72 | 1.39× |
| `todayHealthEventCurrentMedicineLabel` | Label | 33 / 24 | 1.38× |
| `todayHealthEventReasonRecordLabel` | Label | 33 / 24 | 1.38× |
| `reviewAiSummaryDefaultHint` | Hint | 98 / 72 | 1.36× |
| `medicineRiskCheckFindingBodySpecialGroup` | Group | 49 / 36 | 1.36× |
| `authDeleteAccountPolicyHint` | Hint | 97 / 72 | 1.35× |
| `assistantConversationDisabledByUserHint` | Hint | 96 / 72 | 1.33× |
| `authEmailVerifyLinkHint` | Hint | 94 / 72 | 1.31× |
| `medicineRiskCheckLlmEmptyBody` | Body | 140 / 108 | 1.30× |
| `medicineSearchPrecheckUnavailableToast` | Toast | 93 / 72 | 1.29× |
| `reviewLockedFeaturesInsufficientHint` | Hint | 93 / 72 | 1.29× |
| `mineSignedOutNoticeDescription` | Description | 138 / 108 | 1.28× |
| `reviewReadinessInsufficientTitle` | Title | 46 / 36 | 1.28× |
| `authDeleteAccountPolicyAction` | Action | 24 / 19 | 1.26× |
| `assistantInputDisabledHint` | Hint | 90 / 72 | 1.25× |
| `reviewRecordGuideDescription` | Description | 134 / 108 | 1.24× |
| `assistantToolReportSummaryByRange` | Range | 23 / 19 | 1.21× |
| `authGoogleCompleteAction` | Action | 23 / 19 | 1.21× |
| `authWechatCompleteAction` | Action | 23 / 19 | 1.21× |
| `reviewAiSummaryErrorHint` | Hint | 86 / 72 | 1.19× |
| `todayObservationErrorTitle` | Title | 43 / 36 | 1.19× |
| `mineAlertPrivacyBadge` | Badge | 13 / 11 | 1.18× |
| `settingsAiPrivacyContextNote` | Note | 127 / 108 | 1.18× |
| `assistantDisclaimerText` | Text | 169 / 144 | 1.17× |
| `reviewReadinessReadyTitleRange` | Range | 22 / 19 | 1.16× |
| `securityCenterLoginHistoryViewAll` | All | 22 / 19 | 1.16× |
| `todayHealthEventCheckInAction` | Action | 22 / 19 | 1.16× |
| `authGoogleCallbackLabel` | Label | 27 / 24 | 1.12× |
| `authWechatCallbackLabel` | Label | 27 / 24 | 1.12× |
| `medicineAlertSpecialGroupSafetyDetail` | Detail | 120 / 108 | 1.11× |
| `todayObservationSleepMissingSubtitle` | Subtitle | 80 / 72 | 1.11× |
| `authSessionsManageAction` | Action | 21 / 19 | 1.11× |
| `medicineDetailOpenReminderAction` | Action | 21 / 19 | 1.11× |
| `scanViewReminderAction` | Action | 21 / 19 | 1.11× |
| `scanModelDownloadMessage` | Message | 119 / 108 | 1.10× |
| `medicineReminderDeviceLocalHint` | Hint | 79 / 72 | 1.10× |
| `recordNlpFailedCandidatesHint` | Hint | 79 / 72 | 1.10× |
| `settingsNotificationsPermissionEnabledHint` | Hint | 79 / 72 | 1.10× |
| `reviewReviewNoEventDescription` | Description | 118 / 108 | 1.09× |
| `settingsDataStorageRetentionShortenConfirmMessage` | Message | 117 / 108 | 1.08× |
| `scanNoResultTitle` | Title | 39 / 36 | 1.08× |
| `assistantProposalConstraintsLabel` | Label | 26 / 24 | 1.08× |
| `reviewReviewWhatHappenedSymptomCount` | Count | 17 / 16 | 1.06× |
| `reviewAiSummaryDisabledHint` | Hint | 76 / 72 | 1.06× |
| `medicineReminderDeleteAction` | Action | 20 / 19 | 1.05× |
| `settingsHealthAutoSyncSubtitle` | Subtitle | 74 / 72 | 1.03× |
| `mineReadinessPreviewTitle` | Title | 37 / 36 | 1.03× |
| `recordDetailErrorTitle` | Title | 37 / 36 | 1.03× |
| `settingsAiPrivacyMemoryNote` | Note | 110 / 108 | 1.02× |
| `assistantSettingsMemorySubtitle` | Subtitle | 73 / 72 | 1.01× |

### 4.3 需人工复核：错误/空态是否说清"怎么修"

按 HIG 要求，错误信息须说明如何修复。但动作常常落在旁边按钮上，
静态看文本必然误报（如 `healthSyncResultFailed` = "Sync failed" + 重试按钮），
故列此清单人工过一遍：

`medicineDetailSequencesEmpty`、`assistantConversationModelMissing`、
`securityCenterSensitiveOperationsEmpty`、`mineSyncFailedDetailsEmpty`、
`commandPaletteEmpty`、`settingsNotificationsPermissionUnsupported`、
`reviewReviewHistoryEmpty`、`medicineTodayPlanEmpty`、`reviewClinicSummaryPdfEmpty`、
`healthSyncAutoSyncUnsupported`、`iconPickerEmpty`、`reviewShareManagementEmpty`、
`assistantSourceCoverageEmpty`、`reviewReviewRedFlagInformationGap`、
`medicineRiskCheckCoverageReasonDetailUnavailable`、`settingsAboutLicenseMissing`、
`authCodeRequiredError`、`authEmailInvalidError`、`medicineReminderCalendarUnavailable`、
`medicineRiskCheckCoverageSummaryUnavailable`、`assistantToolDisabledRetrievalUnavailable`、
`reviewReviewHistoryLoadFailed`、`authConfirmPasswordRequiredError`、
`medicineRiskCheckLlmUnavailable`、`recordMealAnalysisFailureVisionUnavailable`、
`recordQuickSettingsWaterCustomDialogInvalid`、`authPasswordRequiredError`、
`medicineDetailSequencesError`、`authEmailRequiredError`、`authPasswordsDoNotMatchError`、
`reviewReviewHistoryLoadMoreFailed`、`mineExportStatusLinkMissing`、
`settingsHelpFaqLoadError`、`authLinkedIdentityEmailMissing`、
`recordMealAnalysisStatusFailed`、`mineExportStatusUnavailable`、
`mineSyncFailedDetailsLastError`、`healthSyncResultFailed`、
`medicineReminderDeliveryStatusFailed`、`mineExportStatusFailed`、`settingsDevLogLevelError`

### 4.4 需人工判定：说明/免责类（长度在阈值内但属允许更长的类别）

`medicineRiskCheckTierSafeDisclaimer`(139)、`healthSyncNotAvailable`(141)、
`medicineRiskCheckTierUncoveredDisclaimer`(137) —— 复核措辞，必要时下沉到详情页。

## 五、执行方式

### 5.1 改写原则（HIG / NN-g 归纳）

1. **一句话一件事**。需要两句时，第二句通常是"下一步动作"，应移入按钮或 footer。
2. **删架构解释**。用户不需要知道 provider / boundary / backend 的接线方式。
3. **错误态说"怎么修"，不说"什么坏了"**。
4. **空态给下一步**，不给价值主张。
5. **枚举超过 3 项就概括**。
6. **中文按中文校一遍**，不能只照英文翻译后收工。

### 5.2 槽位归位优先于删字

HIG 的解法是"只列标题，详情放下一层"。对 A 类条目优先考虑：

- 长副标题 → 移入该分组 footer（`SettingsSectionLabel` 已有分组体系）
- 长行内说明 → 改为可展开详情或下一层页面
- 长枚举 → 概括 + 详情页列全

只有确认无处可移时才压缩文字。

### 5.3 不做门禁接入

**不接入 `tool/luminous_lints`。** 本次只交付审计工具与改写；
`tool/l10n_audit/` 作为独立脚本保留，需要时手动跑。

### 5.4 文档

- `docs/reference/localization.md`：补"文案长度约定"一节（阈值表 + 槽位映射 + 规范来源）
- `Luminous/AGENTS.md`：UI 约定处加一行指向该节
- 迁移日志：`docs/logs/migration-log/YYYY-MM-DD.md` 追加一条

## 六、验收

1. `python tool/l10n_audit/audit_copy.py` 退出码为 0（有超限即 exit 1 并列出条目）
2. 4.3 人工复核清单逐条确认（补动作或确认按钮已承载）
3. `flutter analyze` 无新增问题
4. `flutter test` 全绿（文案改动会触碰依赖字符串的 widget 测试）
5. `dart scripts/l10n/arb_tools.dart merge` + `flutter gen-l10n` 后无残留

## 七、范围边界

- 只改 `lib/l10n/src/*.arb` 分片，绝不直接改合并产物（`AGENTS.md` 硬约束）
- 不为了过阈值牺牲语义；阈值是筛子不是目标
- 品牌名、语言名、单位符号、纯数值格式不参与长度判定
- 本次不改交互结构（不新增页面、不调整导航），只做文案与槽位归位
