# lib/features/customizer — 表面编排

用户编辑「某个 tab 挂哪些组件、什么顺序、每张卡多宽」的编辑器。组件跨 tab 挂载
（同一张卡可以同时出现在今日页和用药页）就由这里决定，编辑结果写进
`lib/core/composition/` 定义的 `SurfaceLayout`。

## 职责与边界

- 管：编排会话（草稿生命周期）、`LayoutDraft` / `LayoutEdit` 的纯规则、布局的本地缓存
  与远端同步、编排页 UI、跨 tab 候选面板、组件宽度档位选择。
- 不管：组件的实现与注册（各 feature 的 `presentation/components/` + `lib/app/composition/`）、
  表面布局的渲染（`ComponentHost*`）、三档列数与跨列计算
  （`lib/core/composition/responsive/`）。

## 对外契约

- 路由：`presentation/routes.dart` 导出一个路由 `/customize/:surface`，五个 surface 共用。
  `CustomizeRoute.forSurface(SurfaceId)` 接受枚举，surface 写错是编译错误。
- 入口：`presentation/widgets/title/entry.dart` 的 `openSurfaceCustomizer`，经
  `lib/core/composition` 的 `surfaceCustomizerOpenerProvider` 注入。**core 与各 tab 都不
  import 本 feature**——未注入时标题退化为纯文本，不假装可点。
- 生效点：`application/layout_store.dart` 的 `surfaceLayoutsProvider` /
  `storedSurfaceLayoutProvider` 在组合根覆盖 `core/composition/surface.dart` 的
  `surfaceLayoutProvider`，`ComponentHost` 不改一行即按用户布局渲染。

## 分层要点

| 层 | 内容 |
| --- | --- |
| `domain/` | `LayoutDraft`（各 surface 草稿 + 未挂载池）、`LayoutEdit`（move/toggle/remove/add/resize 的 sealed 动作）、`draft_rules.dart`（纯规则，非法编辑返回原草稿而不是抛异常） |
| `application/` | `layout_store.dart`（cache-first 读、乐观写、`commit`）、`usecases/edit_session.dart`（会话生命周期） |
| `data/` | KV 缓存（`layout.<surface>`）、`layout_wire.dart`、`cached_layout.dart`；`layout_remote.dart` 目前是**占位实现**（见下） |
| `presentation/` | `pages/page.dart`（编辑器本体：列表、拖拽重排、尺寸选择器、顶部操作）、`widgets/palette.dart`（跨 tab 候选面板）、`providers/draft.dart` |

## 未完成与已知约束

- **远端同步未接线**：Lucent 还没有 `/ui/layouts` 端点，`data/datasources/layout_remote.dart`
  是占位实现（`fetchAll` 返回空、`put` 返回成功）。当前布局只存本地——换机或重装会丢，
  多设备不一致。契约见 `plans/2026-10-28-composable-tabs.md` §2.7，后端落地后只需替换
  该文件。
- **跨 surface 移动没有 UI 入口**：`LayoutEdit.move` 的 `from != to` 分支已实现且有单测，
  但界面上只能「在本页移除 → 在另一页加入」，不能一次拖动完成。
- **拖拽是列表形态**：`flutter_reorderable_grid_view` 的网格模式未接入，拖拽时看不到
  格子预览；宽度档位本身可以设置（每行下方的三档 chip）。

## 两个静默失败，改这里之前务必知道

1. **加组件时不能只查「本页移除过的池」**。首次加入的组件不在池里，若此时直接返回
   原草稿，表现是「点了没反应」且无任何报错。池里没有就按目录新建 placement。
2. **候选面板必须自己 `ref.watch` 草稿**，不能接收调用方传入的快照。窄屏面板长在
   `showModalBottomSheet` 的 builder 里，那个 builder 不在页面重建范围内：传快照进来时
   组件确实加进了草稿，面板却按旧数据渲染，条目仍留在列表里——同样是「点了没反应」，
   但数据层其实已经成功。
