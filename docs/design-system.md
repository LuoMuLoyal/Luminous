---
title: "全局设计规范"
tags:
  - design
  - tokens
created: 2026-05-29
---

# Luminous 全局设计规范

> 基于 Apple 设计语言，统一管理颜色、间距、字号、圆角、阴影。
> 所有组件必须引用 token 常量，禁止写魔数。

---

## 颜色系统

### 主色（跟随主题切换，定义在 `AppThemeSpec`）

| Token            | 默认值(softGlow) | 用途                 |
| ---------------- | ---------------- | -------------------- |
| `lightPrimary`   | `#66BB6A` 柔和绿 | 主 CTA、链接、选中态 |
| `lightSecondary` | `#A5D6A7` 薄荷绿 | 辅助强调、装饰       |
| `lightTertiary`  | `#FFD54F` 暖金   | 第三强调、标签       |
| `darkPrimary`    | `#A5D6A7` 浅绿   | 暗色模式主色         |
| `darkSurface`    | `#14231A` 绿黑   | 暗色卡片背景         |

### 固定色（`AppUiConstants`，不随主题变）

| Token                  | 值        | 用途             |
| ---------------------- | --------- | ---------------- |
| `PAGE_BACKGROUND`      | `#F5FAF5` | 亮色页面背景     |
| `PAGE_BACKGROUND_DARK` | `#0B1A0E` | 暗色页面背景     |
| `TAB_INACTIVE`         | `#7A8B7A` | 未选中 Tab       |
| `TEXT_PRIMARY`         | `#1D1F1D` | 主要文字（近黑） |
| `TEXT_SECONDARY`       | `#6B7B6B` | 次要文字         |
| `TEXT_MUTED`           | `#94A394` | 辅助/禁用文字    |
| `TEXT_PRIMARY_DARK`    | `#F2F6F2` | 暗色主要文字     |
| `DIVIDER`              | `#E2EBE2` | 分割线           |
| `BORDER`               | `#E4ECE4` | 卡片描边         |
| `BORDER_DARK`          | `#324432` | 暗色描边         |
| `SUCCESS`              | `#66BB6A` | 成功             |
| `WARNING`              | `#FFA726` | 警告             |
| `ERROR`                | `#EF5350` | 错误             |
| `INFO`                 | `#42A5F5` | 信息             |

### 使用原则

- 仅 `AppThemeSpec` 中的颜色随主题切换
- `AppUiConstants` 中的颜色全局固定
- 语义色（SUCCESS/WARNING/ERROR/INFO）不随主题变

---

## 间距系统（`AppSpacing`，4px 网格）

| Token       | 值   | 用途                    |
| ----------- | ---- | ----------------------- |
| `xxs`       | 4px  | 图标与文字间距          |
| `xs`        | 8px  | 组件内元素间距          |
| `sm`        | 12px | 列表项内、卡片内容      |
| `md`        | 16px | 页面水平边距            |
| `lg`        | 20px | 卡片间距                |
| `xl`        | 24px | 大区块间距              |
| `xxl`       | 32px | 页面段落间距            |
| `section`   | 48px | 段落间距                |
| `sectionLg` | 64px | 全宽区块内边距          |
| `tile`      | 80px | 全宽 Tile（Apple 风格） |

### 预设 EdgeInsets

| Token          | 值              | 用途         |
| -------------- | --------------- | ------------ |
| `hPage`        | H:16            | 页面水平边距 |
| `allPage`      | 16              | 页面全向     |
| `allCard`      | 12              | 卡片全向     |
| `cardContent`  | L12 T10 R12 B12 | 卡片内容     |
| `inputContent` | H14 V14         | 输入框       |

### 预设 SizedBox

| Token                   | 用途     |
| ----------------------- | -------- |
| `gapXxs` ~ `gapSection` | 垂直间距 |
| `gapWXxs` ~ `gapWMd`    | 水平间距 |

---

## 字号系统（`AppTypography`）

| Token          | 值     | 用途                 |
| -------------- | ------ | -------------------- |
| `micro`        | 10px   | 法律声明             |
| `tab`          | 12px   | Tab 标签、脚注       |
| `caption`      | 13px   | 副标题、chip 文字    |
| `bodySmall`    | 14px   | 次要正文             |
| `body`         | 15px   | 正文                 |
| `bodyLarge`    | 17px   | 主正文（Apple 标准） |
| `button`       | 18px   | 按钮                 |
| `tagline`      | 21px   | 标题副文案           |
| `lead`         | 24px   | 引导文字             |
| `display`      | 34px   | 区块标题             |
| `displayLarge` | 40px   | 大标题               |
| `hero`         | 56px   | Hero 标题            |
| `cardTitle`    | 13.8px | 卡片产品名           |
| `cardMeta`     | 12.2px | 卡片规格信息         |

---

## 圆角系统（`AppRadius`）

| Token       | 值     | 用途              |
| ----------- | ------ | ----------------- |
| `none`      | 0px    | 全宽 Tile         |
| `tight`     | 6px    | 复选框、紧凑 chip |
| `sm`        | 8px    | 小按钮、内嵌图片  |
| `chip`      | 12px   | chip              |
| `small`     | 14px   | 文本按钮          |
| `input`     | 16px   | 输入框、普通按钮  |
| `card`      | 18px   | 卡片              |
| `container` | 24px   | 大容器            |
| `pill`      | 9999px | 胶囊按钮          |

### 预设 BorderRadius

| Token             | 等于                          |
| ----------------- | ----------------------------- |
| `tightRadius`     | `BorderRadius.circular(6)`    |
| `smRadius`        | `BorderRadius.circular(8)`    |
| `chipRadius`      | `BorderRadius.circular(12)`   |
| `inputRadius`     | `BorderRadius.circular(16)`   |
| `cardRadius`      | `BorderRadius.circular(18)`   |
| `containerRadius` | `BorderRadius.circular(24)`   |
| `pillRadius`      | `BorderRadius.circular(9999)` |

---

## 阴影系统（`AppShadow`）

| Token              | 效果                   | 用途                                 |
| ------------------ | ---------------------- | ------------------------------------ |
| `product`          | `0x38000000` 30px 3,5  | 产品图阴影（Apple 唯一 drop-shadow） |
| `card`             | `0x120F172A` 14px 0,7  | 卡片悬浮                             |
| `surface`          | `0x33000000` 18px 0,10 | Toast、浮层                          |
| `surfaceLight`     | `0x0F0F172A` 16px 0,7  | 亮色卡片                             |
| `authCard`         | `0x100F172A` 12px 0,6  | 登录卡                               |
| `bottomBar(color)` | 动态                   | 底部导航                             |

---

## 代码引用示例

```dart
import 'package:luminous/shared/design_tokens/app_spacing.dart';
import 'package:luminous/shared/design_tokens/app_radius.dart';
import 'package:luminous/shared/design_tokens/app_shadow.dart';
import 'package:luminous/shared/design_tokens/app_typography.dart';
import 'package:luminous/constants/app_ui_constants.dart';

// ❌ 禁止
Container(
  padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(20),
    color: Color(0xFFF5FAF5),
  ),
  child: Text('...', style: TextStyle(fontSize: 15)),
);

// ✅ 正确
Container(
  padding: AppSpacing.allCard,
  decoration: BoxDecoration(
    borderRadius: AppRadius.cardRadius,
    color: AppUiConstants.PAGE_BACKGROUND,
  ),
  child: Text('...', style: TextStyle(fontSize: AppTypography.body)),
);
```
