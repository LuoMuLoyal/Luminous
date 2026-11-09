---
status: active
owner: frontend
updated: 2026-11-09
---

# 本地存储三层整改：缓存优先、KV 换 Hive、SQLCipher 加密

Created: 2026-10-27

> 状态：**P1（Hive）与 P2（加密）已落地，仅剩 P0（缓存优先）未完成。**
> 本计划取代并修订 `docs/reference/adr/0006-local-persistence-drift.md`
> 中的两项既有结论（§4 缓存覆盖面、§5 不加密），ADR 正文随本计划一并更新。

- 范围：`Luminous`（Flutter 客户端）
- 三项互相独立，按 P0 → P1 → P2 顺序落地，**每一项都可单独发布**

## 0. 背景与实测结论

用户提出三个问题：「有缓存也先显示骨架屏」「本地数据库该加密了」「shared_preferences 该换 Hive」。
经代码核查，三项均成立，但**根因与直觉不同**：

### 0.1 骨架屏：不是 UI 层的问题，是 repository 没做缓存

UI 层与守卫层**已经是对的**：

- `lib/core/widgets/common/feedback/page_state.dart:109` ——
  `data.isLoading && data.hasValue` 时直接返回上一份数据，不闪骨架屏。
- `lib/core/providers/auth_guarded.dart:62-68` —— 冷启动 session 恢复期间，只要本地有
  refresh token 就**直接发起 fetch**（cache-first 仓库会立即返回本地数据），不再阻塞到
  session 恢复完成。注释里明确记录这是相对早期实现的修正。

真正断在数据源：`lib/features/record/data/repositories/lucent_daily.dart:111`

```dart
TaskEither<LucentFailure, DailyRecordSummaryData> fetchSummary(String date) {
  // Summary is derived data; no caching needed.      ← 判断错误
  return TaskEither.tryCatch(() => dataSource.fetchSummary(date), ...);
}
```

`fetchSummary` 正是今日首页各卡片的直接数据来源。而今日首页
`lib/features/today/data/repositories/lucent.dart` 的 `_buildDashboard()` 是**纯网络聚合**，
依次 await 6 个数据源，全部返回才开始渲染，因此**首帧必然骨架屏**，与本地有无缓存无关。

全仓 23 个 repository 中只有 4 个真正读缓存
（`record/lucent_daily` 的列表、`review/lucent_dashboard`、`review/lucent_review`、
`health_context/lucent`）。完全无缓存的是：`today`、`medicine/lucent_workspace`、`mine`、
`notification`、`search`、`settings`。

这解释了「修过几次没修好」：历次修补都在 `PageViewState` / `authGuarded` 这层，
而没缓存的是 repository，改上层无效。

### 0.2 数据库加密：当前完全未加密

`lib/core/database/connection_io.dart:12-22`：

```dart
final file = File(p.join(dir.path, 'luminous.db'));
return NativeDatabase.createInBackground(file);   // 明文 SQLite
```

依赖中无 `sqlcipher_flutter_libs`。库内存放用药记录、健康档案、过敏史、症状等敏感健康数据。
ADR-0006 §5 当年以「设备级加密已提供基础保护」为由不加密，该结论现在推翻。

### 0.3 shared_preferences：约 90 处调用，且没有类型安全

20 个文件引用，key 集中登记在 `lib/core/config/pref_keys.dart`（约 50 个 key，
`domain.subdomain.field` 点号命名）。调用最重的：

| 文件 | 处数 |
| --- | --- |
| `features/record/data/datasources/quick_entry_preferences.dart` | 21 |
| `core/config/feature_flags.dart` | 9 |
| `features/settings/presentation/providers/notification.dart` | 7 |
| `features/medicine/data/datasources/reminder_local_preferences.dart` | 6 |
| `features/settings/data/providers/data_storage.dart` | 6 |
| `core/config/developer_settings.dart` | 6 |
| `core/accessibility/settings.dart` | 5 |

**先澄清一个容易误判的点**：`session_store.dart` 里虽然有
`PrefKeys.accessToken` / `PrefKeys.refreshToken`，但实际装配的是
`SecureLucentSessionStore`（`lib/core/network/client/client_providers.dart:41`），
token 落 `flutter_secure_storage`，**不在 SharedPreferences 明文落盘**。
`SharedPrefsLucentSessionStore` 只是旧版迁移路径。因此换 Hive **不涉及** token 安全。

---

## P0 缓存优先：让「有缓存就直接出」真正成立

### P0.1 补齐 summary 缓存（today 首页破局点）

`lucent_daily.fetchSummary` 改为 cache-first：

- 新增 drift 表 `daily_record_summaries`（`date` 主键 + `payload` JSON + `cachedAt`）。
- 读：命中即返回并触发节流后台刷新（复用列表路径的 `_refreshInBackground` 模式）。
- 空：走网络并写入缓存。
- 写路径（新增/编辑/删除记录）后按日期失效对应行。

### P0.2 让 6 个无缓存 repository 接入 cache-first

按 ADR-0006 §2 的既有模式逐个接入（读缓存 → 命中即返回并后台刷新 → miss 走网络并回写）：

| repository | 新增缓存表 | TTL |
| --- | --- | --- |
| `today/data/repositories/lucent.dart` | 不新增表，改为消费下列来源的缓存 | — |
| `medicine/data/repositories/lucent_workspace.dart` | `medicine_workspaces` | 24h |
| `mine/data/repositories/lucent.dart` | `mine_dashboards` | 24h |
| `notification/data/repositories/lucent.dart` | `notification_lists` | 1h |
| `search/data/repositories/lucent.dart` | `search_results` | 1h |
| `settings/data/repositories/lucent.dart` | `settings_snapshots` | 7d |

`today` 自身不建表：它的 `_buildDashboard()` 改为并行 await 各来源，而各来源在
P0.1/P0.2 之后已是 cache-first，聚合整体即可在首帧返回本地数据。

### P0.3 聚合层的「部分命中」语义

`_buildDashboard()` 只要**任一**来源有缓存就应渲染（缺的指标降级为「—」），
不应因为某一个来源 miss 就整体等待。当前的 `_degradedDashboard` 已具备降级渲染能力，
复用它即可，不需要引入新的状态类型。

### P0.4 验收标准

- 有缓存时冷启动，五个 tab 首帧**不出现骨架屏**（widget 测试断言：先写入缓存 DAO，
  再 pump 页面，断言骨架屏 widget 不存在且真实内容存在）。
- 清空本地库后冷启动，仍走骨架屏（证明不是简单地把骨架屏关掉）。
- 断网冷启动，有缓存时正常渲染，无缓存时走既有的 `AppStateErrorView`。

---

---

## 执行顺序与依赖

1. **P0**（缓存优先）—— 无破坏性，可单独发布，收益最大。**唯一剩余项。**
2. ~~P1（Hive）~~、~~P2（加密）~~ 已同批落地（破坏性重置一次完成），条目已删。

## 风险

| 风险 | 应对 |
| --- | --- |
| P0 新增 6 张缓存表，migration 复杂化 | 每张表独立 migration 步骤，drift schema 版本号逐次递增 |
| P0 聚合层「部分命中」导致指标长期显示「—」 | 后台刷新成功后 invalidate 对应 provider，用现有 `DataChangeBus` 触发 |

## 不做的事

- 不引入第三套存储引擎（Hive 只替代 SharedPreferences，不碰 drift）。
- 不做旧数据迁移（用户明确要求）。
- 不改 `SecureLucentSessionStore` 的 token 存储（已正确）。
