# lib/core/i18n — 语言区域选择与持久化

单文件目录(`locale.dart`):`AppLocale` 枚举 + `LocaleController`,是"用户选了哪种语言"的唯一事实源。

## 职责与边界

- 管:`AppLocale`(system/en/zhCn)的取值映射(`flutterLocale` / `acceptLanguage`)、偏好
  持久化(`LocaleController` + `localeControllerProvider`,存 SharedPreferences)、系统与
  后端 locale 的解析入口(`fromStorage` / `fromFlutterLocale` / `fromBackendPreference`)。
- 不管:ARB 文案与 `flutter gen-l10n` 产物(在 `lib/l10n`,分片合并工作流见根 AGENTS.md 与
  `../../../docs/reference/Localization.md`)、语言之外的用户设置(features/settings)。

## 对外契约

- 导出:`locale.dart` 的 `AppLocale`、`LocaleController`、`localeControllerProvider`。
- 被依赖:`../../app/bootstrap.dart`(MaterialApp locale + 后端 profile locale 同步)、
  `../network/client/client_providers.dart`(Dio 默认 `Accept-Language` 头)、
  features/settings(语言设置页)、today/medicine/legal(按 locale 取数)。

## 不变量

- `AppLocale` 是封闭枚举,storageValue 契约固定为 `system` / `en` / `zh-CN`;`fromStorage`
  对未知值回退 `system`,`fromBackendPreference` 对不可识别值返回 null
  (`test/core/i18n/app_locale_test.dart`、`app_locale_controller_test.dart` 断言)。
- `system.flutterLocale` 返回 null(交由 MaterialApp 跟随系统);`system.acceptLanguage`
  在调用时读 `PlatformDispatcher.instance.locale`,不缓存。
- `setLocale` 先置 state 再写盘,语言切换不被持久化 IO 阻塞。

## 依赖禁区

- 不依赖 features;仅依赖 `../config/pref_keys.dart` 与 `shared_preferences`。
- 文案字符串不出现在本目录;本目录不 import `AppLocalizations`。

## 陷阱与决策

- `zhCn.flutterLocale` 是 `Locale('zh')`,而 HTTP 头用 `zh-CN` —— 两套写法分别对应 Flutter
  匹配规则与后端契约,不要"统一"。
- 放在 core 而非 features/settings 的原因:Dio 默认头与应用启动 locale 都要在此之前可用,
  且 core/network 不允许依赖 features。
- `fromBackendPreference` 只认 zh*/en* 前缀;后端新增语言时需同步此处与 ARB 支持集。
