# Removed From Active Scope

- 旧 More tab 及其剩余 `features/more` mock 工作区。
- 女性健康与经期管理。
- 运动恢复。
- 校园服务模块（Mine 校园区块、RedFlagAlert 的 campus-resource escalation、campus l10n keys）。
- 2FA / TOTP 双因素认证（已替换为 Security PIN + JWT elevation token）。
- 多色板主题偏好设置（主题仅保留 system / light / dark）。
- 专家健康包。
- 智能设备。
- 家庭档案。
- 皮肤识别。
- 报告照片导入。
- 桌面优先工作流。
- feature 级调色板类（`MedicinePalette`、`TodayPalette`、`ReportPalette`）已完全移除。
- 旧的 `AppColorTokens` wrapper 也已移除。
- 所有颜色引用现在通过语义 `SemanticColor` token enum 或直接的 `context.theme.colors.*` 读取。
- 健康上下文、风险检查器与 Prisma schema 中的孕/乳/儿童/老年特殊人群字段。
