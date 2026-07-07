# Mine Page Mobile Redesign

Date: 2026-07-07
Repo: `Luminous`
Scope: mobile `Mine` root page only

## Goal

Rebuild the Mine page from a mixed dashboard into a clear profile-readiness hub.

The page should answer three questions in order:

1. Who is this page for right now?
2. Is the profile ready enough to support safer health guidance?
3. What is the next action the user should take?

## Context

Luminous is positioned as a proactive personal health assistant, with medication safety as the trusted entry point and structured personal data as the foundation for summaries, reminders, explanations, and reports.

That means the Mine page should not behave like a generic settings landing page or a mini dashboard. It should behave like the user's profile readiness center: identity, health archive completeness, authorization, and account/privacy controls.

## Current Problems

### 1. First-screen priority is broken

The current screen shows all of these with similar visual weight:

- sign-in hint
- account card
- three-column status overview
- health archive list
- privacy banner

The user cannot tell which area is the primary task.

### 2. The status overview is in the wrong layer

`过敏史 / 当前用药 / 分享控制` is currently surfaced as a large three-column summary card.

This is structurally wrong:

- `过敏史` and `当前用药` are health archive content
- `分享控制` is an account/privacy control

They should not be grouped as the same level of information.

### 3. Signed-out preview semantics are noisy

Current signed-out content can look partially real and partially mock.

For this redesign, treat that as a mock-stage artifact, not the primary structure problem. The redesign must still reduce confusion by making preview/signed-out messaging subordinate to the main profile card instead of giving it its own competing card.

### 4. Privacy messaging is over-weighted

The privacy notice currently looks like a promotional banner. It competes with more important tasks such as profile completion and archive maintenance.

## Design Direction

Use a single readiness-first layout:

- one primary card that defines the current profile state
- one main archive section that exposes the real information architecture
- one secondary account/privacy section

The page should stop looking like "several unrelated cards" and start looking like "one profile state + two structured groups".

## Recommended Structure

### 1. Top Bar

Keep:

- title: `我的`
- notifications action
- settings action

No extra banner at the top.

### 2. Primary Card: Profile Readiness

This becomes the only first-screen hero card.

Contents:

- avatar / identity
- state label: signed in / preview
- completeness progress
- one-line next-step explanation
- primary CTA
- optional secondary contextual text

Examples:

- signed out preview:
  - `个人档案尚未解锁`
  - `登录后查看你的真实基础信息、过敏史和当前用药`
  - primary CTA: `登录查看`
- signed in incomplete:
  - `还差 1 项关键信息`
  - `补充紧急联系人后，分享和就诊摘要会更完整`
  - primary CTA: `去完善`
- signed in ready:
  - `档案已基本就绪`
  - `你可以继续维护档案并管理隐私授权`
  - primary CTA: `管理档案`

Rules:

- the existing standalone sign-in hint is removed from the page body
- completeness stays in this card, not split into a separate notice above the archive
- if there are specific gaps, show at most 2 concise missing items here

### 3. Main Section: Health Archive

This becomes the page's core information architecture.

Use `FTileGroup + FTile`.

Entries:

- 基础信息
- 过敏史
- 当前用药
- 紧急联系人

Each row should show:

- icon
- title
- concise subtitle
- status text with explicit words, not color only
- chevron

Rules:

- `已完善 / 待补充 / 未开始` must be explicit text
- status should not rely on red/gray alone
- rows remain actionable and should feel like the real center of the page

### 4. Secondary Section: Account & Privacy

Move account/privacy controls out of the archive summary layer.

Use another `FTileGroup + FTile`.

Entries:

- 分享控制
- 隐私政策
- 账户与安全

This section is secondary, below archive.

### 5. Remove the Current Three-Column Overview

Delete the current `MineStatusOverview` large three-column card from the mobile layout.

Reason:

- it consumes too much prime space
- it mixes unrelated domains
- it duplicates information that belongs in archive or privacy groups
- it weakens the page's core task hierarchy

If some summary value still matters, fold it into the primary card as short inline status text instead of keeping a full card.

## State Model

### Signed Out

- primary card explains preview state
- archive rows can still be shown, but must read as preview structure rather than user-specific truth
- no separate top sign-in banner
- no fake confidence signals such as strongly affirmative completion language

### Signed In But Incomplete

- primary card emphasizes missing items and action
- archive section exposes exactly where to complete data
- privacy section remains secondary

### Signed In And Ready

- primary card shifts from unlock language to maintenance language
- archive remains first secondary section

## Forui Usage

Prefer existing Forui components directly:

- top bar: existing `AppTopBar`
- main surfaces: `FCard`
- progress: `FDeterminateProgress`
- state labels: `FBadge`
- grouped navigation: `FTileGroup` + `FTile`
- optional inline callout: `FAlert` only if truly necessary

Avoid adding custom wrappers when stock Forui primitives already fit.

## Implementation Notes

Expected code changes:

- `lib/features/mine/presentation/pages/page.dart`
  - remove standalone top `SignInHintBanner` from mobile content path
- `lib/features/mine/presentation/widgets/views/dashboard_view.dart`
  - reorder sections to hero -> archive -> account/privacy
  - remove mobile `MineStatusOverview`
  - merge completeness messaging into hero
- `lib/features/mine/presentation/widgets/sections/account_hero.dart`
  - expand into readiness card
- `lib/features/mine/presentation/widgets/sections/archive_section.dart`
  - strengthen status wording and keep it as the main structured section
- `lib/features/mine/presentation/widgets/sections/service_privacy.dart`
  - restyle into lower-priority account/privacy group or tile list
- `lib/features/mine/presentation/widgets/sections/status_overview.dart`
  - remove from mobile layout; likely retire if no longer needed anywhere

## Out of Scope

- redesigning desktop Mine layout
- solving final signed-out mock data strategy across the entire app
- changing backend data contracts
- rebuilding settings subpages

## Success Criteria

- first screen has exactly one clear primary card
- user can tell within 3 seconds what the page wants them to do next
- health archive is the main body of the page
- privacy/account controls no longer compete with archive actions
- signed-out state feels like gated preview, not broken mixed data
