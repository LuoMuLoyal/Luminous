---
status: active
owner: frontend
updated: 2026-08-31
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
- **占位符/复数**：占位符类型在分片 `@key` 元数据中声明（int/String/num），如 `{days}`、`{count}`；复数用 plural 语义键；已格式化数值（如 fl oz 换算、ml 汇总）在 Dart 侧完成后以 String 占位传入。
- 删除拥有它的 UI 时同步删除 l10n 键；延迟（deferred）代码的键仅当代码仍被引用且带注释时保留。
- 页面文案克制：仅必要的标题/标签/值/状态/动作，不做解释性、引导性或营销式文案。
- 动作迁到其他 tab 时删除旧 tab 的动作文案，不保留失活标签。

## Locale 运行时

- `LuminousApp` 读 `appLocaleControllerProvider`，解析结果传入 `MaterialApp.router.locale`；支持 `system` / `zh-CN` / `en`。
- Lucent 请求经 `LucentDioClient` 拦截器注入 `Accept-Language`（`generated/lucent_api` 客户端行为不变）。
- 登录态语言变更经 `locale / timezone / unitSystem` 同步到 Lucent profile；选 `system` 清除后端偏好。
- auth 恢复或登录后，`LuminousApp` 可从 Lucent `profile.locale` 回填本地 locale（仅当值映射到 `zh-CN` / `en` / `system`）。
