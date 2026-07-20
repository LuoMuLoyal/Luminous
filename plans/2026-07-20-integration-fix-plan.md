# 联调修正与接入实施计划

> **日期**: 2026-07-20
> **范围**: SSE 超时修复 + 诊所摘要全链路接入 + 建议历史详情面板
> **前置审计**: `plans/2026-07-20-frontend-backend-integration-audit.md`

---

## 任务总览

| # | 任务 | 难度 | 预计工时 | 涉及项目 |
|---|---|---|---|---|
| 3 | 诊所摘要预览弹窗 | ⭐⭐ | 4-6h | Luminous |
| 4 | 诊所摘要 PDF 下载 | ⭐⭐⭐ | 4-6h | Luminous |
| 5 | 诊所摘要分享链路改造（先预览再分享） | ⭐⭐ | 2h | Luminous |
| 6 | 诊所摘要公开分享页（深链接） | ⭐⭐⭐ | 4-6h | Luminous |
| 7 | i18n 字符串补充 | ⭐ | 1h | Luminous |
| 8 | 生成客户端确认 + 测试 | ⭐ | 1-2h | Luminous |

> UserDevices 暂不接入（用户决定）。

---

## 任务 3：诊所摘要预览弹窗

### 问题

后端 `POST /api/v1/user/reports/clinic-summary/preview` 返回 `ClinicSummaryDto`（脱敏摘要），生成客户端已有 `reportsControllerPreviewClinicSummaryV1()` 方法，但前端从未调用。

### 修改方案

新增 `ClinicSummaryPreviewDialog`，调用预览端点获取 `ClinicSummaryDto`，展示脱敏内容。使用 `AppDialogShell` 保持与其他弹窗一致的视觉风格。

### 新增文件

**`lib/features/report/presentation/providers/clinic_summary.dart`**

```dart
@riverpod
Future<ClinicSummaryDto?> clinicSummaryPreview(Ref ref) async {
  final api = ref.watch(lucentClientProvider).reports;
  final response = await api.reportsControllerPreviewClinicSummaryV1();
  return response;
}
```

**`lib/features/report/presentation/widgets/dialogs/clinic_summary_preview_dialog.dart`**

弹窗内容布局：

```
┌──────────────────────────────────────┐
│  诊所摘要预览                  [关闭] │
├──────────────────────────────────────┤
│  生成时间: 2026-07-20 14:30          │
│  数据范围: 近 30 天                  │
│                                      │
│  ── 个人信息（脱敏）──               │
│  昵称: 张**    年龄: 28              │
│  性别: 男      血型: A              │
│                                      │
│  ── 过敏记录 ──                      │
│  • 青霉素                            │
│  • 花生                              │
│                                      │
│  ── 疾病记录 ──                      │
│  • 高血压（2024 年诊断）             │
│                                      │
│  ── 当前用药 ──                      │
│  • 氨氯地平片 5mg                    │
│  • 阿托伐他汀 20mg                   │
│                                      │
│  ── 关键发现 ──                     │
│  • 服药依从性: 92%                   │
│  • 血压趋势稳定                      │
│                                      │
│  ── 免责声明 ──                      │
│  本摘要仅供就医参考，不替代诊断...   │
│                                      │
│  [下载 PDF]  [分享给医生]            │
└──────────────────────────────────────┘
```

关键实现：

```dart
Future<void> showClinicSummaryPreviewDialog(
  BuildContext context, {
  required WidgetRef ref,
}) async {
  final l10n = AppLocalizations.of(context)!;

  await showFDialog<void>(
    context: context,
    builder: (dialogContext, style, animation) {
      return AppDialogShell(
        title: Text(l10n.reportClinicSummaryPreviewTitle),
        builder: (_) => Consumer(
          builder: (_, ref, ___) {
            final async = ref.watch(clinicSummaryPreviewProvider);
            return async.when(
              loading: () => const SizedBox(
                height: 200,
                child: Center(child: FCircularProgress.loader()),
              ),
              error: (e, _) => _ClinicSummaryError(
                message: e.toString(),
                l10n: l10n,
              ),
              data: (dto) => dto == null
                  ? _ClinicSummaryError(
                      message: l10n.reportClinicSummaryEmpty,
                      l10n: l10n,
                    )
                  : _ClinicSummaryContent(
                      dto: dto,
                      l10n: l10n,
                      onDownloadPdf: () => _downloadPdf(context, ref),
                      onShare: () => _share(context, ref),
                    ),
            );
          },
        ),
      );
    },
  );
}
```

`ClinicSummaryDto` 字段映射：

| DTO 字段 | 类型 | 展示 |
|---|---|---|
| `generatedAt` | `String` | 格式化日期时间 |
| `dataRange` | `String` | 本地化标签 |
| `profile.nickname` | `String` | 脱敏昵称（如"张**"） |
| `profile.age` | `num?` | 年龄 |
| `profile.sexAtBirth` | `String?` | 本地化 |
| `profile.bloodType` | `String?` | 本地化 |
| `allergies` | `List<String>` | Bullet list |
| `conditions` | `List<String>` | Bullet list |
| `currentMedicines` | `List<String>` | Bullet list |
| `findings` | `List<String>?` | Bullet list |
| `disclaimer` | `String` | 小字灰色 |

---

## 任务 4：诊所摘要 PDF 下载

### 问题

后端 `GET /api/v1/user/reports/clinic-summary/preview/pdf` 返回 PDF 二进制，但生成客户端声明为 `Future<void>`，丢弃了响应体。需要用 Raw Dio 下载。

### 修改方案

在 `LucentApiPaths` 中添加 PDF 路径常量，用 Raw Dio 以 `ResponseType.bytes` 下载 PDF，通过 `share_plus` 分享/保存。

### 修改文件

**`lib/core/network/api_paths.dart`** — 新增常量

```dart
/// `GET /api/v1/user/reports/clinic-summary/preview/pdf` —
/// 下载认证用户的诊所摘要 PDF（二进制响应）。
static const clinicSummaryPreviewPdf =
    '/api/v1/user/reports/clinic-summary/preview/pdf';
```

**`lib/features/report/presentation/widgets/dialogs/clinic_summary_preview_dialog.dart`** — 下载逻辑

```dart
Future<void> _downloadPdf(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context)!;
  final dio = ref.read(lucentDioClientProvider).dio;

  try {
    final response = await dio.get<List<int>>(
      LucentApiPaths.clinicSummaryPreviewPdf,
      options: Options(
        responseType: ResponseType.bytes,
        extra: const {'skipAuthRefresh': false},
      ),
    );
    final bytes = response.data ?? <int>[];
    if (bytes.isEmpty) {
      await AppToast.show(context, l10n.reportClinicSummaryPdfEmpty);
      return;
    }

    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/clinic-summary-${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(bytes);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        subject: l10n.reportExportClinicShareTitle,
      ),
    );
  } catch (e) {
    await AppToast.show(context, l10n.reportClinicSummaryPdfFailed);
  }
}
```

**`pubspec.yaml`** — 确认 `share_plus` 已在依赖中（已存在），`path_provider` 需要确认或添加。

### 需要确认的依赖

| 包 | 状态 | 用途 |
|---|---|---|
| `share_plus` | ✅ 已有 | 分享 PDF 文件 |
| `path_provider` | 需确认 | 获取临时目录保存 PDF |

如果 `path_provider` 不在依赖中，需添加到 `pubspec.yaml`。

---

## 任务 5：诊所摘要分享链路改造

### 问题

当前 `_handleClinicShare` 直接调用 `share` 端点生成链接并分享，用户在分享前无法看到脱敏内容。

### 修改方案

将 `clinicShare` 导出按钮的行为改为"先弹出预览弹窗 → 弹窗内有[分享给医生]按钮"。

### 修改文件

**`lib/features/report/presentation/pages/page.dart`** — `_handleExportAction` 方法第 96-98 行

```dart
// 修改前
if (kind == ReportExportKind.clinicShare) {
  await _handleClinicShare(context, ref, l10n);
  return;
}

// 修改后
if (kind == ReportExportKind.clinicShare) {
  await showClinicSummaryPreviewDialog(context: context, ref: ref);
  return;
}
```

弹窗内的 `[分享给医生]` 按钮调用原有的 `_handleClinicShare` 逻辑（`reportsControllerShareClinicSummaryV1` → `SharePlus.instance.share`）。

`_handleClinicShare` 方法本身不需要改动，只是调用入口从直接调用改为通过弹窗触发。

---

## 任务 6：诊所摘要公开分享页（深链接）

### 问题

后端 `GET /api/v1/user/reports/clinic-summary/shared/{token}` 返回 `ClinicSummaryDto`，生成客户端已有 `reportsControllerGetSharedClinicSummaryV1()` 方法，但前端无路由页面。

### 修改方案

新增 `/report/clinic-summary/:token` 路由和页面，调用公开端点展示分享的摘要。此页面为 **公开路由**（无需认证），需要在 `_publicRoutePrefixes` 中注册。

### 新增文件

**`lib/features/report/presentation/pages/clinic_summary_shared.dart`**

```dart
class ClinicSummarySharedPage extends ConsumerWidget {
  const ClinicSummarySharedPage({super.key, required this.token});
  final String token;

  @override
  Widget build(context, ref) {
    final async = ref.watch(clinicSummarySharedProvider(token));
    // loading / error / data 三态
    // data 复用 _ClinicSummaryContent 但无 [下载 PDF] / [分享] 按钮
    // 底部增加 [下载 PDF] 按钮，调用 shared/{token}/pdf 端点
  }
}
```

**`lib/features/report/presentation/providers/clinic_summary.dart`** — 新增 shared provider

```dart
@riverpod
Future<ClinicSummaryDto?> clinicSummaryShared(
  Ref ref, {
  required String token,
}) async {
  final api = ref.watch(lucentClientProvider).reports;
  return api.reportsControllerGetSharedClinicSummaryV1(token: token);
}
```

### 修改文件

**`lib/app/router.dart`**

```dart
// 在 AppRoutes 类中新增
static const reportClinicSummaryShared = '/report/clinic-summary/:token';

// 在 _publicRoutePrefixes 中添加
const _publicRoutePrefixes = <String>['/legal', '/report/clinic-summary'];

// 在 routes 列表中添加
GoRoute(
  path: AppRoutes.reportClinicSummaryShared,
  pageBuilder: (context, state) => tabFadePage(
    key: state.pageKey,
    child: ClinicSummarySharedPage(
      token: state.pathParameters['token']!,
    ),
  ),
),
```

**`lib/features/report/routes.dart`**（或直接在 `router.dart` 中内联）— 用 `go_router_builder` 生成 typed route。

### 公开 PDF 下载

公开分享页的 [下载 PDF] 按钮调用 `GET /shared/{token}/pdf`（无需认证）。同样用 Raw Dio 下载：

**`lib/core/network/api_paths.dart`** — 新增

```dart
/// `GET /api/v1/user/reports/clinic-summary/shared/{token}/pdf` —
/// 下载公开分享的诊所摘要 PDF（无需认证）。
static String clinicSummarySharedPdf(String token) =>
    '/api/v1/user/reports/clinic-summary/shared/$token/pdf';
```

下载逻辑与任务 4 类似，但路径用 `clinicSummarySharedPdf(token)`，且 `extra` 中设 `skipAuthorization: true`（公开端点不需要 token）。

---

## 任务 7：i18n 字符串补充

### 新增 ARB 片段

**`lib/l10n/src/report_zh.arb`** 新增：

```json
"reportClinicSummaryPreviewTitle": "诊所摘要预览",
"reportClinicSummaryGeneratedAt": "生成时间",
"reportClinicSummaryDataRange": "数据范围",
"reportClinicSummaryProfileSection": "个人信息（已脱敏）",
"reportClinicSummaryAllergiesSection": "过敏记录",
"reportClinicSummaryConditionsSection": "疾病记录",
"reportClinicSummaryMedicinesSection": "当前用药",
"reportClinicSummaryFindingsSection": "关键发现",
"reportClinicSummaryDisclaimerSection": "免责声明",
"reportClinicSummaryEmpty": "暂无可生成的摘要数据",
"reportClinicSummaryDownloadPdf": "下载 PDF",
"reportClinicSummaryShare": "分享给医生",
"reportClinicSummaryPdfEmpty": "PDF 内容为空",
"reportClinicSummaryPdfFailed": "PDF 下载失败，请稍后再试",
"reportClinicSummarySharedTitle": "诊所摘要",
"reportClinicSummarySharedExpired": "分享链接已过期或失效",
"reportClinicSummarySharedDownloadPdf": "下载 PDF",
```

**`lib/l10n/src/report_en.arb`** 新增对应英文。

### 生成命令

```bash
cd Luminous
dart scripts/arb_tools.dart merge
flutter gen-l10n
```

---

## 任务 8：生成客户端确认 + 测试

### 确认

生成客户端已包含以下方法（无需重新生成）：

| 方法 | 端点 | 状态 |
|---|---|---|
| `reportsControllerPreviewClinicSummaryV1()` | `POST clinic-summary/preview` | ✅ 已有 |
| `reportsControllerShareClinicSummaryV1()` | `POST clinic-summary/share` | ✅ 已有 |
| `reportsControllerGetSharedClinicSummaryV1(token)` | `GET clinic-summary/shared/{token}` | ✅ 已有 |
| `reportsControllerDownloadClinicSummaryPdfV1()` | `GET clinic-summary/preview/pdf` | ⚠️ 返回 `Future<void>`，需用 Raw Dio |

> `preview/pdf` 和 `shared/{token}/pdf` 在生成客户端中返回 `Future<void>`（OpenAPI 声明为 `application/pdf`，retrofit 无法表示二进制响应），所以这两个端点必须用 Raw Dio 下载。这是预期行为，不是 bug。

### 验证命令

```bash
# Luminous
cd Luminous
dart run tool/verify_lucent_openapi_sync.dart   # 确认 openapi.json 与生成客户端同步
flutter analyze                                  # 静态分析
flutter test test/report/                        # 报告模块测试
flutter test                                     # 全量测试
```

---

## 实施顺序

```
任务 7 (i18n)        ──┐
任务 3 (预览弹窗)     ──┤── 任务 3/5 依赖 i18n 字符串
任务 5 (分享链路改造)  ──┘
任务 4 (PDF 下载)     ──── 依赖任务 3 的弹窗框架
任务 6 (公开分享页)   ──── 依赖任务 3 的内容组件
任务 8 (验证)        ──── 全部完成后
```

### 建议分批

| 批次 | 任务 | 可并行 |
|---|---|---|
| 第 1 批 | 任务 7 | ✅ 独立 |
| 第 2 批 | 任务 3 + 任务 5 | 顺序（5 依赖 3 的弹窗） |
| 第 3 批 | 任务 4 + 任务 6 | ✅ 并行（都依赖任务 3 的组件） |
| 第 4 批 | 任务 8 | 最后 |

---

## 文件变更清单

### 新增文件（6 个）

| 文件路径 | 任务 | 说明 |
|---|---|---|
| `lib/features/report/presentation/widgets/dialogs/clinic_summary_preview_dialog.dart` | 3, 4, 5 | 预览弹窗 + PDF 下载 + 分享按钮 |
| `lib/features/report/presentation/providers/clinic_summary.dart` | 3, 6 | Riverpod providers |
| `lib/features/report/presentation/pages/clinic_summary_shared.dart` | 6 | 公开分享页 |
| `lib/features/report/presentation/widgets/shared/clinic_summary_content.dart` | 3, 6 | 共享的摘要内容组件 |
| `lib/features/report/routes.dart`（如不存在则内联到 router.dart） | 6 | typed route |
| `lib/features/report/routes.g.dart` | 6 | 生成文件 |

### 修改文件（4 个）

| 文件路径 | 任务 | 改动 |
|---|---|---|
| `lib/core/network/api_paths.dart` | 4, 6 | 新增 2 个 PDF 路径常量 |
| `lib/features/report/presentation/pages/page.dart` | 5 | `clinicShare` 入口改造 |
| `lib/app/router.dart` | 6 | 新增公开路由 + `_publicRoutePrefixes` |
| `lib/l10n/src/report_zh.arb` + `report_en.arb` | 7 | 新增诊所摘要 i18n 字符串 |

### 不修改文件

| 文件 | 原因 |
|---|---|
| `pubspec.yaml` | `share_plus` 已有；`path_provider` 待确认，如有则不改 |
| 后端任何文件 | 所有端点已就绪，无需后端改动 |
| 生成客户端 | 已有全部所需方法，无需重新生成 |

---

## 风险与注意事项

| 风险 | 影响 | 缓解 |
|---|---|---|
| `path_provider` 不在依赖中 | PDF 下载功能无法保存临时文件 | 先检查 `pubspec.yaml`，缺失则添加 |
| 公开路由深链接与认证守卫冲突 | 未登录用户访问 `/report/clinic-summary/:token` 被重定向到 `/login` | 已在 `_publicRoutePrefixes` 注册，redirect guard 会放行 |
| 公开 PDF 下载的 Auth 拦截器 | `skipAuthorization: true` 需确认拦截器支持 | `AuthInterceptor.onRequest` 已检查 `extra['skipAuthorization']`，已有先例（图片上传） |
| `ClinicSummaryDto` 字段 `findings` 可能为 null | 预览弹窗空列表 | `findings ?? <String>[]` 兜底 |
| i18n merge 后 `app_*.arb` 被覆盖 | 直接编辑 `app_*.arb` 的内容丢失 | 遵守 L10n 规则：只编辑 `src/` 片段，然后 merge |
