# Markdown 渲染样式优化方案

> **For agentic workers:** 按本计划任务逐项实施，步骤使用 checkbox（`- [ ]`）跟踪。

**Goal:** 统一 Luminous 全部 6 处 Markdown 渲染点的样式，区分「法律文书（正式文档）」与「AI 生成内容」两套视觉语言，并接入设计系统 token。

**Architecture:** 新增 `lib/core/design/markdown_style.dart` 作为唯一样式工厂，提供 `MarkdownStyle.legal(context)` 与 `MarkdownStyle.ai(context, {background})` 两套 `MarkdownStyleSheet` 预置；6 处调用点从各自的 `fromTheme(...).copyWith(...)` 迁移到工厂。可选抽取 `AppMarkdownBody` widget 封装公共参数（selectable / shrinkWrap）。

**Tech Stack:** Flutter + `flutter_markdown_plus` + Forui（FThemeData / FColors）+ 现有设计 token（`TypographyToken` / `SemanticColor` / `RadiusTokens` / `Spacing`）。

---

## 一、现状盘点：全部 Markdown 渲染点

项目统一使用 `flutter_markdown_plus` 包，共 **6 处** `MarkdownBody` 使用点，全部为 `MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(...)` 的本地定制：

| # | 文件:行 | 场景 | 当前定制 | 内容特征 |
|---|---------|------|---------|---------|
| 1 | `lib/features/legal/presentation/pages/detail.dart:82` | 法律文书详情 | p=level4(h1.7)；h1=level7/w700、h2=level6/w600、h3=level5/w600 + 标题上下 padding | 正式、权威、长文，限宽阅读 |
| 2 | `lib/features/assistant/presentation/widgets/shared/message_bubble.dart:92` | AI 聊天气泡（助手回复） | p=level4(前景色)；blockquote=level3(mutedForeground) | 对话，气泡背景 `colors.secondary`，非流式才渲染 |
| 3 | `lib/features/today/presentation/widgets/sections/summary.dart:122` | Today 页 AI 健康摘要 | p=level3/w600 | 卡片内紧凑展示，强调摘要 |
| 4 | `lib/features/today/presentation/widgets/sections/suggestion_interactive.dart:278,287` | Today 建议的 reason + boundary | p=level4；boundary p=level3(mutedForeground) | `primary.subtle` 容器内，reason 为主、boundary 为辅 |
| 5 | `lib/features/report/presentation/widgets/sections/ai_summary.dart:152` | 报告页 AI 总结 | p=level4/w700 | AppDivider 分隔的报告正文，强调总结 |
| 6 | `lib/features/settings/presentation/pages/help.dart:270` | 帮助页 FAQ 答案 | p=level4(h1.6) | FCollapsible 内，本地维护内容 |

## 二、现状问题

1. **样式分散重复**：6 处各自 `fromTheme(...).copyWith(...)`，无统一入口；新增渲染点容易遗漏定制，风格漂移不可控。
2. **未区分场景**：法律文书与 AI 内容共用同一基础样式。法律文书需要权威、宽松、强层级；AI 内容需要对话感、紧凑、重点突出（列表/引用/代码）。
3. **代码块与行内代码未定制**：依赖 `fromTheme` 的 Material 默认值，与 Forui 主题（背景、圆角、字体）不协调。
4. **链接 / 引用 / 列表 / 表格未定制**：默认样式在浅色、深色、高对比度下与设计语言不一致。
5. **高对比度模式未覆盖**：`HighContrastColors`（`lib/core/design/high_contrast.dart`）未接入 markdown。
6. **AI 气泡背景适配缺失**：气泡背景是 `colors.secondary`（助手）或 `primary.muted`（用户），`fromTheme` 默认的引用边框、代码背景不感知气泡底色。

## 三、方案总览

### 3.1 两套视觉语言

| 维度 | `legal`（法律文书 / 正式文档 / FAQ） | `ai`（对话 / 摘要 / 建议 / 报告总结） |
|------|-------------------------------------|--------------------------------------|
| 气质 | 权威、正式、阅读优先 | 对话感、紧凑、重点突出 |
| 正文字号/行高 | level4 (16px) / 1.7 | level4 (16px) / 1.6 |
| 标题层级 | 强层级（h1→h3 递减 + 大段距） | 弱化（h1 少见，收敛到 h2/h3） |
| 引用 | 中性左条 + muted 文字 | primary 色左条 + muted 文字 |
| 列表 | 标准 bullet（foreground） | primary 色 bullet，紧凑间距 |
| 行内代码 | 主题背景 + 圆角 + 等宽字体 | 同左，背景随气泡/容器底色淡化 |
| 代码块 | 主题 secondary 背景 + 圆角 + 横向滚动 | 同左 + 更明显边框 |
| 链接 | primary + 下划线 | primary + 下划线 + 加粗可选 |
| 表格 | 边框 `colors.border` + 表头 secondary 底 | 同左 |
| 分割线 | `colors.border` | 同左 |
| 高对比度 | 接入 `HighContrastColors` | 同左 |

### 3.2 详细样式规格（token 级映射）

统一基线（两套共用）：`MarkdownStyleSheet` 的 `code` / `codeblock` / `a` / `blockquote` / `table` / `hr` / `ul` / `ol` / `li` / `strong` / `em`。

**代码（行内 + 块级）**
- 字体栈：`ui.monospace`（`dart:ui`），fallback 系统等宽。
- 行内 `code`：`background: colors.secondary`、圆角 `RadiusTokens.level2` (6)、padding `EdgeInsets.symmetric(horizontal: 4, vertical: 1)`、字号 = 正文 −1（level3）。
- 块级 `codeblock`：`background: colors.secondary`、圆角 `RadiusTokens.level3` (8)、padding `Spacing.level3` (10)、`codeblockPadding` 包裹、`codeblockDecoration` 使用 `colors.border` 细边框。

**链接 `a`**
- 颜色 `colors.primary`、`decoration: TextDecoration.underline`。
- ai 变体：`fontWeight: FontWeight.w600`（可配置参数 `emphasizeLinks`）。

**引用 `blockquote`**
- legal：`border: Border(left: BorderSide(color: colors.borderStrong, width: 4))`、文字 `colors.mutedForeground`。
- ai：左条 `colors.primary`（width 4）、文字 muted，`blockquotePadding` 左侧加大。

**标题**
- legal：h1=level7/w700、h2=level6/w600、h3=level5/w600；`h1Padding` top=level6、`h2Padding` top=level5、`h3Padding` top=level4；h1 下加 `colors.border` 细分隔线（`borderBottom` 可选参数）。
- ai：h1=level6/w700、h2=level5/w600、h3=level4/w600；padding 减一档（level5/level4/level3）。

**列表**
- legal：`ul`/`ol` 使用默认 bullet 色（foreground），`li` 间距 `Spacing.level1`。
- ai：bullet 色 `colors.primary`（通过 `listBullet` / `listBulletPadding` 定制），间距 level1。

**表格 / 分割线**
- `tableBorder: TableBorder.all(color: colors.border)`；表头 `headerDecoration: BoxDecoration(color: colors.secondary)`；单元格 padding `Spacing.level2`。
- `horizontalRuleDecoration: BoxDecoration(border: Border(top: BorderSide(color: colors.border)))`。

**高对比度**
- 当 `context.theme` 处于高对比度覆盖时（设计系统以 `HighContrastColors` 常量替换 FColors），工厂内判断：`a` 用 `HighContrastColors.lightForeground/darkForeground`（按 `Theme.of(context).brightness`），`blockquote` 左条用 `lightBorder/darkBorder`，代码背景用 `colors.secondary`（已由主题替换）。

## 四、架构设计（文件结构）

```
lib/core/design/
├── markdown_style.dart          # 新增：样式工厂（唯一入口）
└── design.dart                  # 修改：导出 markdown_style.dart

lib/features/
├── legal/presentation/pages/detail.dart              # 改：MarkdownStyle.legal(context)
├── settings/presentation/pages/help.dart             # 改：MarkdownStyle.legal(context)
├── assistant/presentation/widgets/shared/message_bubble.dart  # 改：MarkdownStyle.ai(context, background: background)
├── today/presentation/widgets/sections/summary.dart  # 改：MarkdownStyle.ai(context, paragraphWeight: w600)
├── today/presentation/widgets/sections/suggestion_interactive.dart  # 改：MarkdownStyle.ai(context) / boundary 变体
└── report/presentation/widgets/sections/ai_summary.dart  # 改：MarkdownStyle.ai(context, paragraphWeight: w700)
```

`MarkdownStyle` 工厂签名（预设计，供任务引用）：

```dart
// lib/core/design/markdown_style.dart
import 'package:flutter/widgets.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

abstract final class MarkdownStyle {
  /// 正式文档（法律文书 / FAQ）：宽松行距、强标题层级、中性引用。
  static MarkdownStyleSheet legal(BuildContext context);

  /// AI 生成内容（对话 / 摘要 / 建议 / 报告总结）：紧凑、primary 强调、气泡背景感知。
  /// [background] 传入气泡/容器背景色，用于代码、引用在浅色容器上的对比度适配。
  static MarkdownStyleSheet ai(
    BuildContext context, {
    Color? background,
    FontWeight? paragraphWeight,
    bool emphasizeLinks = false,
  });
}
```

调用点统一形如：

```dart
MarkdownBody(
  data: content,
  selectable: true,
  styleSheet: MarkdownStyle.legal(context), // 或 MarkdownStyle.ai(context, background: bg)
)
```

## 五、实施任务

> 前置说明：本仓库提交 pre-commit 会跑 `flutter analyze` + 文档检查（`scripts/check_doc_coverage.dart`），涉及 `lib/core/design/**` 需同时更新 `docs/03-logs/migration-log/` 与相关 reference 文档。

### Task 1: 新增样式工厂 `markdown_style.dart`

**Files:**
- Create: `lib/core/design/markdown_style.dart`
- Modify: `lib/core/design/design.dart`（追加 export）
- Test: `test/core/design/markdown_style_test.dart`

- [ ] **Step 1: 写失败测试**

```dart
// test/core/design/markdown_style_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/design/design.dart';

void main() {
  testWidgets('legal 样式：正文 level4、行高 1.7', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (context) {
      final sheet = MarkdownStyle.legal(context);
      return SizedBox(child: Text('x', style: sheet.p));
    })));
    final context = tester.element(find.byType(SizedBox));
    final sheet = MarkdownStyle.legal(context);
    expect(sheet.p?.fontSize, 16);
    expect(sheet.p?.height, 1.7);
  });

  testWidgets('ai 样式：blockquote 使用 primary 色左条', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (context) {
      return const SizedBox();
    })));
    final context = tester.element(find.byType(SizedBox));
    final sheet = MarkdownStyle.ai(context);
    final border = sheet.blockquote?.border;
    expect(border, isNotNull);
    expect(border?.left.width, 4);
  });

  testWidgets('ai 样式支持 paragraphWeight 参数', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (context) {
      return const SizedBox();
    })));
    final context = tester.element(find.byType(SizedBox));
    final sheet = MarkdownStyle.ai(context, paragraphWeight: FontWeight.w700);
    expect(sheet.p?.fontWeight, FontWeight.w700);
  });
}
```

- [ ] **Step 2: 运行测试确认失败**

Run: `flutter test test/core/design/markdown_style_test.dart`
Expected: FAIL（`MarkdownStyle` 未定义）

- [ ] **Step 3: 实现工厂**

```dart
// lib/core/design/markdown_style.dart
import 'dart:ui' show FontWeight, TextStyle;

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:forui/forui.dart';

import 'high_contrast.dart';
import 'radius.dart';
import 'spacing.dart';
import 'typography.dart';

abstract final class MarkdownStyle {
  /// 正式文档（法律文书 / FAQ）：宽松行距、强标题层级、中性引用。
  static MarkdownStyleSheet legal(BuildContext context) {
    final base = MarkdownStyleSheet.fromTheme(Theme.of(context));
    final colors = context.theme.colors;
    return base.copyWith(
      p: TypographyToken.level4.body(context).copyWith(height: 1.7),
      h1: TypographyToken.level7.body(context).copyWith(fontWeight: FontWeight.w700),
      h2: TypographyToken.level6.body(context).copyWith(fontWeight: FontWeight.w600),
      h3: TypographyToken.level5.body(context).copyWith(fontWeight: FontWeight.w600),
      h1Padding: const EdgeInsets.only(top: Spacing.level6),
      h2Padding: const EdgeInsets.only(top: Spacing.level5),
      h3Padding: const EdgeInsets.only(top: Spacing.level4),
      blockquote: TypographyToken.level4
          .body(context)
          .copyWith(color: colors.mutedForeground),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: colors.borderStrong, width: 4),
        ),
      ),
      blockquotePadding: const EdgeInsets.only(left: Spacing.level3),
      code: TypographyToken.level3.body(context).copyWith(
        fontFamily: 'monospace',
        backgroundColor: colors.secondary,
      ),
      codeblock: TypographyToken.level3.body(context).copyWith(
        fontFamily: 'monospace',
        color: colors.foreground,
        backgroundColor: colors.secondary,
      ),
      codeblockPadding: const EdgeInsets.all(Spacing.level3),
      codeblockDecoration: BoxDecoration(
        color: colors.secondary,
        borderRadius: BorderRadius.circular(RadiusTokens.level3),
        border: Border.all(color: colors.border),
      ),
      a: TypographyToken.level4.body(context).copyWith(
        color: colors.primary,
        decoration: TextDecoration.underline,
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.border)),
      ),
      tableBorder: TableBorder.all(color: colors.border),
      tableHead: TypographyToken.level4.body(context).copyWith(
        fontWeight: FontWeight.w600,
      ),
      tableHeadDecoration: BoxDecoration(color: colors.secondary),
      tableBody: TypographyToken.level4.body(context),
      tableCellsPadding: const EdgeInsets.all(Spacing.level2),
    );
  }

  /// AI 生成内容（对话 / 摘要 / 建议 / 报告总结）：紧凑、primary 强调、气泡背景感知。
  static MarkdownStyleSheet ai(
    BuildContext context, {
    Color? background,
    FontWeight? paragraphWeight,
    bool emphasizeLinks = false,
  }) {
    final base = MarkdownStyleSheet.fromTheme(Theme.of(context));
    final colors = context.theme.colors;
    final codeBg = background ?? colors.secondary;
    return base.copyWith(
      p: TypographyToken.level4
          .body(context)
          .copyWith(height: 1.6, fontWeight: paragraphWeight),
      h1: TypographyToken.level6.body(context).copyWith(fontWeight: FontWeight.w700),
      h2: TypographyToken.level5.body(context).copyWith(fontWeight: FontWeight.w600),
      h3: TypographyToken.level4.body(context).copyWith(fontWeight: FontWeight.w600),
      h1Padding: const EdgeInsets.only(top: Spacing.level5),
      h2Padding: const EdgeInsets.only(top: Spacing.level4),
      h3Padding: const EdgeInsets.only(top: Spacing.level3),
      blockquote: TypographyToken.level4
          .body(context)
          .copyWith(color: colors.mutedForeground),
      blockquoteDecoration: BoxDecoration(
        border: Border(left: BorderSide(color: colors.primary, width: 4)),
      ),
      blockquotePadding: const EdgeInsets.only(left: Spacing.level3),
      listBullet: colors.primary,
      code: TypographyToken.level3.body(context).copyWith(
        fontFamily: 'monospace',
        backgroundColor: codeBg,
      ),
      codeblock: TypographyToken.level3.body(context).copyWith(
        fontFamily: 'monospace',
        color: colors.foreground,
        backgroundColor: codeBg,
      ),
      codeblockPadding: const EdgeInsets.all(Spacing.level3),
      codeblockDecoration: BoxDecoration(
        color: codeBg,
        borderRadius: BorderRadius.circular(RadiusTokens.level3),
        border: Border.all(color: colors.border),
      ),
      a: TypographyToken.level4.body(context).copyWith(
        color: colors.primary,
        decoration: TextDecoration.underline,
        fontWeight: emphasizeLinks ? FontWeight.w600 : null,
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.border)),
      ),
      tableBorder: TableBorder.all(color: colors.border),
      tableHead: TypographyToken.level4.body(context).copyWith(
        fontWeight: FontWeight.w600,
      ),
      tableHeadDecoration: BoxDecoration(color: colors.secondary),
      tableBody: TypographyToken.level4.body(context),
      tableCellsPadding: const EdgeInsets.all(Spacing.level2),
    );
  }
}
```

- [ ] **Step 4: 更新 `design.dart` 导出**

在 `lib/core/design/design.dart` 追加：`export 'markdown_style.dart';`

- [ ] **Step 5: 运行测试确认通过**

Run: `flutter test test/core/design/markdown_style_test.dart`
Expected: PASS（3 用例）

- [ ] **Step 6: 提交**

```bash
git add lib/core/design/markdown_style.dart lib/core/design/design.dart test/core/design/markdown_style_test.dart
git commit -m "feat(design): 新增 Markdown 样式工厂（legal / ai 两套预置）"
```

### Task 2: 法律文书详情接入 `legal`

**Files:**
- Modify: `lib/features/legal/presentation/pages/detail.dart:82-104`
- Test: `test/legal/legal_detail_page_test.dart`（如存在则追加断言，否则跳过）

- [ ] **Step 1: 替换样式**

将 `detail.dart` 的 `MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(...)` 整体替换为：

```dart
MarkdownBody(
  data: doc.content,
  selectable: true,
  shrinkWrap: true,
  styleSheet: MarkdownStyle.legal(context),
),
```

- [ ] **Step 2: 运行相关测试**

Run: `flutter test test/legal`
Expected: PASS（无回归）

- [ ] **Step 3: 提交**

```bash
git add lib/features/legal/presentation/pages/detail.dart
git commit -m "refactor(legal): 法律文书接入 MarkdownStyle.legal"
```

### Task 3: 帮助页 FAQ 接入 `legal`

**Files:**
- Modify: `lib/features/settings/presentation/pages/help.dart:270-280`

- [ ] **Step 1: 替换样式**

```dart
child: MarkdownBody(
  data: widget.item.answer,
  selectable: true,
  shrinkWrap: true,
  styleSheet: MarkdownStyle.legal(context),
),
```

- [ ] **Step 2: 运行测试**

Run: `flutter test test/settings`
Expected: PASS（既有 FAQ 失败用例若仍失败，属改动前既有问题，记录即可）

- [ ] **Step 3: 提交**

```bash
git add lib/features/settings/presentation/pages/help.dart
git commit -m "refactor(settings): FAQ 接入 MarkdownStyle.legal"
```

### Task 4: AI 聊天气泡接入 `ai`（带气泡背景）

**Files:**
- Modify: `lib/features/assistant/presentation/widgets/shared/message_bubble.dart:92-106`

- [ ] **Step 1: 替换样式**

```dart
else
  MarkdownBody(
    data: content,
    selectable: true,
    styleSheet: MarkdownStyle.ai(context, background: background),
  ),
```

（`background` 为该文件上方已计算的助手气泡背景 `colors.secondary`；用户消息仍为纯 `SelectableText`，不渲染 Markdown，保持不变。）

- [ ] **Step 2: 运行测试**

Run: `flutter test test/assistant`
Expected: PASS

- [ ] **Step 3: 提交**

```bash
git add lib/features/assistant/presentation/widgets/shared/message_bubble.dart
git commit -m "refactor(assistant): 消息气泡接入 MarkdownStyle.ai 并适配气泡背景"
```

### Task 5: Today 摘要与建议接入 `ai`

**Files:**
- Modify: `lib/features/today/presentation/widgets/sections/summary.dart:122-131`
- Modify: `lib/features/today/presentation/widgets/sections/suggestion_interactive.dart:278-297`

- [ ] **Step 1: Today 摘要（保留 w600 强调）**

```dart
MarkdownBody(
  data: content.summary!,
  selectable: true,
  styleSheet: MarkdownStyle.ai(context, paragraphWeight: FontWeight.w600),
),
```

- [ ] **Step 2: 建议 reason（默认）与 boundary（muted 变体）**

reason：

```dart
MarkdownBody(
  data: explanation.reason,
  selectable: true,
  styleSheet: MarkdownStyle.ai(context),
),
```

boundary（次要信息，保持 muted 弱化——工厂 ai 无 muted 参数，此处保留局部 copyWith 覆盖段落色）：

```dart
MarkdownBody(
  data: explanation.boundary,
  selectable: true,
  styleSheet: MarkdownStyle.ai(context).copyWith(
    p: TypographyToken.level3
        .body(context)
        .copyWith(color: colors.mutedForeground),
  ),
),
```

- [ ] **Step 3: 运行测试**

Run: `flutter test test/today`
Expected: PASS

- [ ] **Step 4: 提交**

```bash
git add lib/features/today/presentation/widgets/sections/summary.dart lib/features/today/presentation/widgets/sections/suggestion_interactive.dart
git commit -m "refactor(today): AI 摘要与建议接入 MarkdownStyle.ai"
```

### Task 6: 报告 AI 总结接入 `ai`（w700 强调）

**Files:**
- Modify: `lib/features/report/presentation/widgets/sections/ai_summary.dart:152-161`

- [ ] **Step 1: 替换样式**

```dart
child: MarkdownBody(
  data: content.summaryText!,
  selectable: true,
  styleSheet: MarkdownStyle.ai(context, paragraphWeight: FontWeight.w700),
),
```

- [ ] **Step 2: 运行测试**

Run: `flutter test test/report`
Expected: PASS

- [ ] **Step 3: 提交**

```bash
git add lib/features/report/presentation/widgets/sections/ai_summary.dart
git commit -m "refactor(report): 报告 AI 总结接入 MarkdownStyle.ai"
```

### Task 7: 文档更新（migration log + reference）

**Files:**
- Create: `docs/03-logs/migration-log/2026-08-03.md`（若同日已存在则追加小节）
- Modify: `docs/02-reference/data-layer.md` 或 `docs/02-reference/Design_System.md`（按 doc-map 规则命中项）

- [ ] **Step 1: 追加迁移日志小节**

记录：新增 `lib/core/design/markdown_style.dart` 工厂（legal/ai 两套）、6 处调用点迁移、高对比度与气泡背景适配。

- [ ] **Step 2: 运行文档检查**

Run: `dart run scripts/check_doc_coverage.dart --warning-only`
Expected: 无 required 缺失

- [ ] **Step 3: 提交**

```bash
git add docs/
git commit -m "docs: 记录 Markdown 渲染样式统一与场景区分"
```

## 六、验收标准

1. `lib/core/design/markdown_style.dart` 为唯一 `MarkdownStyleSheet` 来源；全仓 grep `MarkdownStyleSheet.fromTheme` 只剩工厂内部一处。
2. 6 处渲染点分别引用 `MarkdownStyle.legal` / `MarkdownStyle.ai`（boundary 与摘要保留局部参数化覆盖）。
3. 法律文书：行高 1.7、h1-h3 强层级、中性引用；AI 内容：行高 1.6、primary 引用条与 bullet、代码块圆角 + 等宽字体 + 主题背景。
4. 深浅色 + 高对比度模式下文字对比度可用；AI 气泡内代码/引用背景与气泡底色协调。
5. `flutter analyze` 无 issue；`flutter test` 相关套件全绿。
6. 文档检查通过（migration log + doc-map 命中项更新）。
