# Luminous 头像上传、裁剪与查看分阶段实施计划

Created: 2026-09-12

> 目标：补齐头像“选择 →（移动端裁剪 / Web 原图）→ 本地预览 → 上传 → 展示 → 全屏查看 → 移除”链路。
> 交互参考 `profile_picker_plus`，但使用 Luminous 现有 Forui Sheet/Dialog、Riverpod、GoRouter 和设计 token。
> 本计划执行期间，每个阶段都必须单独验证并创建一个可独立回滚的 Git commit；不得把多个阶段压成一个提交。

## 一、已决决策

1. 头像仍归账户资料，复用 `AuthUser.avatar` 与现有 `updateAccountProfile(avatar: ...)`，不新增重复的 Mine 数据源。
2. `MineAccount` 增加只读 `avatar` 字段，由现有 Mine repository 从 `authSessionProvider.user` 投影；Mine presentation 不消费 Auth presentation provider。
3. Forui Bottom Sheet 提供“拍照 / 从相册选择 / 移除头像”三项；Web 隐藏拍照；无头像时移除项隐藏或禁用。
4. 原生平台使用 `crop_your_image` 固定 1:1 输出；Web 跳过裁剪、直接使用原图。裁剪器封装在头像能力层。
5. 上传复用 `presignFileUpload` + `putPresignedObject` + `requirePublicUrl`；头像对象使用随机对象名和 `avatars/{userId}/` 前缀，不覆盖原文件名。
6. 取消选择、取消裁剪、关闭查看器不改变服务端头像；上传失败保留旧头像并 Toast；移除使用现有资料更新 `avatar: null`。旧对象清理不在本计划内。
7. 全屏查看第一版使用内置 `InteractiveViewer`，不引入 `photo_view`；宽屏用 Forui Dialog，移动端用全屏查看表面。
8. 先保证新链路稳定，再单独清理不可达 URL 编辑代码，行为变更和死代码清理不混在同一提交。

## 二、现状锚点

- `AuthUser.avatar` 已存在；资料更新链路为 `authAccountProvider.updateProfile` → auth repository/data source → `authSessionProvider.applyUser`。
- `ProfilePage` 当前展示占位图标和头像 URL 输入框，头像预览不读取 URL。
- Mine 的 `MineAccount` 没有 avatar 字段，Mine 只能显示占位图标。
- 设置账户头部、桌面侧栏和账号概要没有统一头像组件；账号概要只有一处直接使用网络图片。
- 上传底座位于 `lib/core/network/client/object_upload.dart`；记录/扫描已有 presign + PUT 参考实现。
- `image_picker`、`cached_network_image`、`ImageCompressor` 已存在；`crop_your_image`、头像裁剪器和全屏查看器尚未引入。
- Forui Sheet 统一使用 `showFSheet(..., side: FLayout.btt)`，Dialog 使用 `showAppDialog`。

## 三、阶段清单与独立提交边界

### Phase 0：计划落地

- [ ] 新增本计划文件并在 `plans/README.md` 登记，注明承接已失效的账号资料计划。
- [ ] 追加当日迁移日志。
- [ ] 验收计划可读、阶段顺序、文件边界和提交边界明确。
- 独立提交：`docs(plan): 规划头像上传裁剪与查看链路`。

### Phase 1：头像数据投影与统一展示

- [ ] `MineAccount` 增加 `String? avatar`，Mine repository 映射 `AuthUser.avatar`。
- [ ] 在 `lib/core/widgets/common/avatar/` 新建无写操作的共享展示组件：URL 使用 `CachedNetworkImage`，空值/失败回退 `SemanticIcons.profileUser`，支持尺寸、圆形、边框和语义标签。
- [ ] 接入 Profile、Mine、设置账户头部、桌面侧栏、账号概要的头像槽位；暂时保留编辑角标视觉但不改变点击行为。
- [ ] 新增/更新 core avatar 与 Mine 测试，覆盖 URL、空值、失败回退和 signed-out 预览。
- [ ] 独立运行定向测试、`flutter analyze`、`git diff --check`，追加迁移日志。
- 独立提交：`feat(avatar): 统一头像数据投影与展示`。
- 回滚边界：只恢复占位/分散渲染，不影响账户 API 或上传底座。

### Phase 2：Forui 头像操作 Sheet、角标与全屏查看

- [ ] 新建 `showFSheet` 头像操作 Sheet，使用 `SheetDragHandle`；原生显示拍照/相册/移除，Web 隐藏拍照，返回明确枚举，不直接改账户状态。
- [ ] 新建可点击头像编辑角标/动作封装，接入 Profile 和 Mine；头像本体有图时打开查看器，角标打开操作 Sheet。
- [ ] 新建全屏查看器，使用 `showAppDialog` 或符合路由规范的全屏表面和 `InteractiveViewer`，覆盖加载、失败、关闭/返回。
- [ ] 测试 Sheet 三选项、Web 选项、移除状态及 viewer 打开/关闭/失败回退；追加迁移日志。
- 独立提交：`feat(avatar): 增加头像操作菜单与全屏查看`。
- 回滚边界：头像仍可显示，但不再有 Sheet、角标动作和查看器。

### Phase 3：选图、移动端裁剪与 Web 原图回退

- [ ] 引入兼容当前 Flutter/Dart 的 `crop_your_image`，执行 `flutter pub get`。
- [ ] 新建头像编辑草稿与能力模型，封装 native crop / web original-only、取消、损坏图片和裁剪失败状态。
- [ ] 原生固定 1:1 裁剪，圆形仅作视觉提示，提供取消/重置/完成；Web 跳过裁剪保留原图 bytes。
- [ ] 复用压缩器，头像采用独立 512–768 px 目标，不改变记录/扫描参数；本地完成后更新预览，关闭/取消丢弃草稿。
- [ ] 注入 `ImagePickerPlatform` fake 与裁剪能力 fake；按需修改 l10n 分片并执行 merge/gen-l10n，同步 localization 文档。
- [ ] 独立运行裁剪/回退/取消/损坏图片和 widget 测试、`flutter analyze`，追加迁移日志。
- 独立提交：`feat(avatar): 接入选图裁剪与 Web 原图回退`。
- 回滚边界：Phase 2 Sheet 保留，但选择项不产生本地草稿。

### Phase 4：预签名上传与账户资料更新

- [ ] 在 auth domain/application/data 接缝新增头像上传用例/服务，复用 object upload，不把协议塞进 Widget。
- [ ] 校验真实 MIME、字节大小和服务端 `maxSizeBytes`；对象名为 `avatars/{userId}/{uuid}.<ext>`。
- [ ] 处理 idle/picking/cropping/uploading/removing/success/failure，上传期间禁用重复操作。
- [ ] 按 presign → PUT → public URL → `updateAccountProfile` → `applyUser` 顺序落地；失败保留旧头像；移除更新为 null。
- [ ] Profile 头像区使用新流程，移除/降级 URL 文本入口；新 UUID 保证缓存不陈旧。
- [ ] 新增 mock FilesApi/Dio 上传测试，覆盖空响应、无 public URL、PUT/资料更新失败、移除和重复操作；追加迁移日志。
- 独立提交：`feat(avatar): 接通头像上传与账户资料同步`。
- 回滚边界：已有 avatar URL 仍可展示，但不再支持新上传/移除。

### Phase 5：页面收口、遗留清理与全量验收

- [ ] 核对 Profile、Mine、设置账户头部、桌面侧栏和账号管理页行为一致。
- [ ] 只删除已证明不可达的旧 URL helper、重复 helper、无用 controller/参数，不触碰仍有路由的账号管理能力。
- [ ] 补齐 Profile、Mine avatar 和必要回归测试；不写真实设备 E2E。
- [ ] Lucent 孤儿对象事项不在本计划内关闭；只在后端完成删除端点后更新 TODO。
- [ ] 将稳定约束写入 feature README，计划完成后删除本计划文件并从 `plans/README.md` 删除登记项；追加最终迁移日志。
- [ ] 独立运行 `flutter analyze`、定向测试、全量 `flutter test`、docs verify 和（环境允许时）daily workflow。
- 独立提交：`chore(avatar): 收口头像页面与测试文档`。
- 回滚边界：只回滚收口清理和测试/文档，不影响 Phase 4 功能。

## 四、文件影响清单

| 区域 | 预期动作 |
|---|---|
| `lib/features/mine/domain/entities/dashboard.dart`、`data/repositories/lucent.dart` | 增加并映射 avatar |
| `lib/core/widgets/common/avatar/` | 展示、角标、Sheet、viewer、草稿/能力组件 |
| `lib/features/settings/presentation/pages/profile.dart` | 接入头像展示与编辑流程，保持健康档案不变 |
| `lib/features/mine/presentation/widgets/sections/account_hero.dart` | 真实头像与角标动作 |
| `lib/features/settings/presentation/widgets/account_header.dart`、`lib/features/shell/presentation/page.dart` | 共享头像展示 |
| `lib/features/auth/presentation/pages/account_manage_sections.dart` | 收敛已有头像展示 |
| `lib/features/auth/domain/application/data` | 上传用例/服务 |
| `lib/l10n/src/*_{zh,en}.arb`、`docs/reference/localization.md` | 按需文案同步 |
| `test/core/widgets/avatar/`、`test/mine/`、`test/settings/`、`test/auth/` | 单元/widget/回归测试 |
| `docs/logs/migration-log/YYYY-MM-DD.md` | 每阶段追加 |

## 五、已决边界与风险

- 不做头像框、动态头像、AI 生成头像、多尺寸切图和历史版本。
- 不新增对象删除端点；旧头像孤儿对象由 Lucent 后续清理。
- 不把 IconMind 用于头像 UI；操作/状态图标继续使用 `SemanticIcons`/Forui。
- 不为全屏查看引入 `photo_view`。
- Web 选择后不强制裁剪；服务端仍负责最终格式/大小校验。
- `crop_your_image` 兼容性在 Phase 3 单独验证；若 Web 编译受影响，Web 只走原图能力分支。
- Mine 与 Auth 状态只经 `authSessionProvider` 投影，避免复制头像状态。

## 六、每阶段执行铁律

- 阶段顺序固定：Phase 0 → 1 → 2 → 3 → 4 → 5；上一阶段必须在干净工作树上验证并提交，才开始下一阶段。
- 每个 commit 只包含该阶段代码、测试、必要文档和当日迁移日志追加；提交信息使用中文 Conventional Commit，不写 Task/P 编号或过程性字段。
- 每阶段完成后检查 `git status --short`、`git diff --check`、`git show --stat --oneline HEAD`，确认独立可回滚。
- l10n 只编辑 `lib/l10n/src/` 后 merge/gen-l10n；禁止手改生成文件。
- 不修改 Lucent 或兄弟项目无关脏文件；不强推。
- 计划完成后把稳定结论迁入 README/docs，删除计划文件和 `plans/README.md` 登记项，不保留完成标记。
