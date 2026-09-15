---
status: active
owner: frontend
updated: 2026-09-15
---

# Localization

l10n 工作流与约定。键清单是 `flutter gen-l10n` 的投影，不在此维护；ARB 分片（`lib/l10n/src/*.arb`）是唯一真相。

## 文件

- 配置：`l10n.yaml`
- ARB 分片（唯一真相，手工编辑）：`lib/l10n/src/{fragment}_{locale}.arb`（12 分片 × zh/en）
- 合并产物（生成、gitignored，勿手编）：`lib/l10n/app_zh.arb` / `app_en.arb`
- 生成 Dart（gitignored）：`lib/l10n/app_localizations*.dart`
- 合并/拆分工具：`scripts/l10n/arb_tools.dart`

## 分片划分（粗粒度）

- `common`：shell 与全局（tab / desktop / state / placeholder / legal 前缀）；`network`：网络层错误文案，经 `NetworkErrorL10n` 映射。
- feature 分片与 feature 对应：`record`、`medicine`（含 `scan*`）、`today`、`review`（原 report，`review*` 前缀）、`settings`（含 `sidebar*`）、`auth`、`mine`、`assistant`、`notification`；`health_sync` 独立承载健康数据导入与自动同步文案。
- 键前缀与分片的归属规则在 `scripts/l10n/arb_tools.dart` 的 `fragmentRules`；新增 feature 在此加行。

## 工作流

1. 编辑 `lib/l10n/src/` 对应分片，zh/en 同步。
2. 合并并生成：

```bash
dart scripts/l10n/arb_tools.dart merge
flutter gen-l10n
```

3. 代码读取：`AppLocalizations.of(context)`。
4. 至少跑 `flutter analyze` + `flutter test`。

## 规则

- 不在页面/widget 硬编码用户可见文案；新增文案必须同时进 zh/en 分片。
- **占位符/复数**：占位符类型在分片 `@key` 元数据中声明（int/String/num），如 `{days}`、`{count}`；复数用 plural 语义键；已格式化数值（如 fl oz 换算、ml 汇总）在 Dart 侧完成后以 String 占位传入。模板 locale 是 **zh**（`l10n.yaml` 的 `template-arb-file: app_zh.arb`），`@key` 元数据必须落在 `*_zh.arb` 分片上——只写在 `*_en.arb` 时 `flutter gen-l10n` 会以「placeholder 在 en 是 int、在 template 是 Object」报错；建议 zh/en 两侧都写，保持一致。
- 删除拥有它的 UI 时同步删除 l10n 键；延迟（deferred）代码的键仅当代码仍被引用且带注释时保留。
  删键前先全仓检索（源码 + 测试，生成物不算引用），再 merge + `flutter gen-l10n`；只删一份语言会在生成时报
  placeholder / 缺键错误。
  - **判定口径用精确成员访问**（`l10n.<key>`，大小写敏感）：`MineSectionTitle`、`TodayMedicationSummary`
    这类与键同名的类/组件不是引用，大小写不敏感的检索也会因折叠而误判。删完以 `flutter analyze` 兜底——
    误删仍被引用的键会在这一步直接编译失败。
- 页面文案克制：仅必要的标题/标签/值/状态/动作，不做解释性、引导性或营销式文案。
- 动作迁到其他 tab 时删除旧 tab 的动作文案，不保留失活标签。
- **不要把句子当模板裁剪**：需要「前缀 + 富文本链接 + 连接词」这类拼接时，把各部分拆成独立键
  （如 `authTermsAgreementPrefix` / `authTermsConjunction`），不要传空占位符再正则裁尾、
  也不要按 `localeName` 硬编码连接词——模板微调即碎，且各语言连接词不同。整句键仅在需要
  完整可读文本时使用（如无障碍 `semanticsLabel`）。

## Locale 运行时

- `LuminousApp` 读 `appLocaleControllerProvider`，解析结果传入 `MaterialApp.router.locale`；支持 `system` / `zh-CN` / `en`。
- Lucent 请求经 `LucentDioClient` 拦截器注入 `Accept-Language`（`generated/lucent_api` 客户端行为不变）。
- 登录态语言变更经 `locale / timezone / unitSystem` 同步到 Lucent profile；选 `system` 清除后端偏好。
- auth 恢复或登录后，`LuminousApp` 可从 Lucent `profile.locale` 回填本地 locale（仅当值映射到 `zh-CN` / `en` / `system`）。
