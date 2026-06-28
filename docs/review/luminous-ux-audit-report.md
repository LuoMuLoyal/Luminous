# Luminous UX Audit Report

**Repository**: `https://github.com/LuoMuLoyal/Luminous.git` (refactor branch)  
**Audit Date**: 2026-06-27  
**Auditor**: Deep UX Review (Lumi Assistant)  
**Scope**: Fake data exposure, clickable feedback, navigation/routing, back buttons, deferred features, general UX

---

## Executive Summary

This audit identifies **0 Critical**, **12 High**, **11 Medium**, and **8 Low** severity issues. The most severe problems are:

1. **Inconsistent shell route architecture** — some sub-pages keep bottom nav, others don't, with no clear logic
2. **Numerous no-op and dead-end interactions** where users tap but nothing meaningful happens
3. **Back button behavior is inconsistent and unreliable** across sub-pages and shell branches

---

## 1. FAKE DATA / MOCK DATA ISSUES

### 🟠 HIGH-1: Mock Repository Fake Data Not Marked as Placeholder
**Severity**: High  
**Files**:
- `lib/features/today/data/repositories/mock_today_repository.dart`
- `lib/features/medicine/data/repositories/mock_medicine_workspace_repository.dart`
- `lib/features/record/data/repositories/mock_record_repository.dart`
- `lib/features/report/data/repositories/mock_report_repository.dart`
- `lib/features/mine/data/repositories/mock_mine_repository.dart`
- `lib/features/search/data/repositories/mock/mock_repository.dart`

**Description**: Mock repositories contain hardcoded fake data that looks production-realistic. Examples:
- `displayName: 'Lumi User'`
- `email: 'lumi@example.com'`
- `DateTime(2026, 6, 6)` — dates that could be real
- `metricAdherence: '92%'`
- `id: 'mock-drug-1'`
- Fake medicine names in Chinese: `布洛芬缓释胶囊`, `对乙酰氨基酚片`

**Recommendation**: Add clear `[PLACEHOLDER]` or `[DEMO]` markers to all mock strings, or use obviously fake values like `__mock_user__`, `placeholder@example.com`, `Mock Medicine Name`. Better yet, remove mock data from production builds entirely via compile-time flags.

---

### 🟠 HIGH-2: Search Returns Mock Results with Fake IDs
**Severity**: High  
**File**: `lib/features/search/data/repositories/mock/mock_repository.dart`

**Description**: The mock search repository returns results with IDs like `'mock-drug-1'` and `'mock-drug-2'`. If a user selects these and tries to add them, the `sourceRefId` will contain mock IDs that may fail on the backend or create corrupted data.

**Code**:
```dart
return [
  MedicineSearchResult(
    id: 'mock-drug-1',  // ← Fake ID that could be sent to backend
    name: '布洛芬缓释胶囊',
    source: MedicineSearchSource.cn,
  ),
];
```

**Recommendation**: Either make the search repository throw "not implemented" in production, or ensure mock data is clearly distinguishable and never persisted.

---

### 🟡 MEDIUM-1: Report Page Uses Mock Data for Date Range Label During Loading/Error
**Severity**: Medium  
**File**: `lib/features/report/presentation/pages/report_page.dart`

**Description**: Even when loading or in error state, the date range label is computed from `MockReportRepository.previewDashboard.startDate` / `endDate`. This leaks mock dates into the UI chrome.

**Code**:
```dart
loading: () => reportDashboardDateRangeLabel(
  context,
  MockReportRepository.previewDashboard.startDate,  // ← Mock date leak
  MockReportRepository.previewDashboard.endDate,
),
```

**Recommendation**: Show a placeholder string like `--` or `Loading...` instead of mock dates.

---

## 2. CLICKABLE ELEMENTS WITHOUT PROPER FEEDBACK

### 🟠 HIGH-3: Today Empty State Action is a No-Op
**Severity**: High  
**File**: `lib/features/today/presentation/widgets/today_dashboard_view.dart`

**Description**: The `TodayEmptyView` has an action button with a completely empty callback. Users see a button but tapping it does nothing.

**Code**:
```dart
AppStateMessageView(
  title: l10n.todayEmptyTitle,
  description: l10n.todayEmptyDescription,
  actionLabel: l10n.todayEmptyAction,
  onAction: () {},  // ← NO-OP
  tone: AppStateTone.success,
),
```

**Recommendation**: Either navigate to a relevant creation flow (`/record/create`), or hide the action button if there's nothing to do.

---

### 🟠 HIGH-4: Today Recommendation "View More" Just Refreshes
**Severity**: High  
**File**: `lib/features/today/presentation/widgets/today_recommendation_section.dart`

**Description**: The section header shows a "View More" action that, when tapped, merely refreshes the recommendations instead of navigating to a dedicated recommendations page or expanding the list.

**Code**:
```dart
TodaySection(
  title: l10n.todayRecommendationSectionTitle,
  actionLabel: l10n.todayViewMoreAction,
  onAction: () => _refresh(ref),  // ← Just refreshes, doesn't "view more"
),
```

**Recommendation**: Remove the misleading "View More" label and change to a refresh icon, or implement a full recommendations page.

---

### 🟠 HIGH-5: Today Recommendation Rows Show Toast on Tap Instead of Navigating
**Severity**: High  
**File**: `lib/features/today/presentation/widgets/today_recommendation_section.dart`

**Description**: Each recommendation row is tappable (`InkWell`) but tapping only shows a toast with the action text (e.g., "Learn More", "Complete"). No actual navigation or action occurs. This is a dead-end interaction.

**Code**:
```dart
InkWell(
  onTap: () => AppToast.show(context, item.action),  // ← Shows "Learn More" as toast, does nothing
),
```

**Recommendation**: Implement actual navigation — medicine recommendations go to medicine page, sleep recommendations go to record create, etc. Or remove the `InkWell` if not actionable.

---

### 🟠 HIGH-6: Medicine Reminder Quick Action Fallback Shows Tooltip Toast
**Severity**: High  
**File**: `lib/features/medicine/presentation/widgets/medicine_mobile_quick_operations_section.dart`

**Description**: When `onCreateReminder` is null, tapping the reminder quick action shows a generic tooltip toast instead of navigating to reminder creation or explaining why it's unavailable.

**Code**:
```dart
_QuickOperation(
  onTap: onCreateReminder ??
      () => AppToast.show(context, l10n.medicineNotificationsTooltip),  // ← Unhelpful toast
),
```

**Recommendation**: Always navigate to `/medicine/reminders/create` or show a proper empty-state explanation.

---

### 🟢 LOW-1: Medicine DrugBox Medication Row Shows Toast When ID is Null
**Severity**: Low  
**File**: `lib/features/medicine/presentation/widgets/medicine_mobile_drugbox_section.dart`

**Description**: If `currentMedicineId` is null, tapping a medication row shows `AppToast.show(context, l10n.medicineOpenPlanItemToast)`. This is acceptable fallback behavior but indicates data quality issues upstream.

**Code**:
```dart
onTap: () {
  if (currentMedicineId == null) {
    AppToast.show(context, l10n.medicineOpenPlanItemToast);
    return;
  }
  // ...
},
```

**Recommendation**: Ensure `currentMedicineId` is always populated in the workspace provider, or hide non-navigable items.

---

## 3. PAGE NAVIGATION & ROUTING ISSUES

### 🟠 HIGH-7: Inconsistent Shell Route Architecture
**Severity**: High  
**File**: `lib/app/router.dart`

**Description**: The navigation architecture is inconsistent:

| Page | Inside ShellRoute? | Bottom Nav Visible? |
|------|-------------------|---------------------|
| `/record/create` | ✅ Yes | ✅ Yes |
| `/record/:id` | ✅ Yes | ✅ Yes |
| `/record/:id/edit` | ✅ Yes | ✅ Yes |
| `/medicine/search` | ❌ No | ❌ No |
| `/medicine/risk-check` | ❌ No | ❌ No |
| `/medicine/reminders/create` | ❌ No | ❌ No |
| `/medicine/reminders/:id` | ❌ No | ❌ No |
| `/medicine/reminders/:id/edit` | ❌ No | ❌ No |

Record sub-pages keep the bottom navigation, but Medicine sub-pages lose it. There's no UX rationale for this difference — both are creation/detail flows.

**Recommendation**: Decide on a consistent pattern. Typically, creation and detail pages should either all be inside the shell (keeping bottom nav) or all be top-level routes (full-screen). For a health app, full-screen with a clear back button is usually better for focus.

---

### 🟠 HIGH-8: Settings, Assistant, Notifications as Shell Branches Without Bottom Nav
**Severity**: High  
**File**: `lib/app/router.dart`, `lib/features/shell/presentation/shell_branch.dart`

**Description**: `settings` (index 5), `assistant` (index 6), and `notifications` (index 7) are `StatefulShellBranch`es, but `ShellBranch.showBottomNav` returns `false` for indices > 4. This means entering these branches removes the bottom nav entirely. However, these pages are accessed from within other tabs (e.g., Settings from Mine, Assistant from Settings), causing a jarring transition where the bottom nav disappears.

**Code**:
```dart
enum ShellBranch {
  today(0), record(1), medicine(2), report(3), mine(4),
  settings(5), assistant(6), notifications(7);

  bool get showBottomNav => index <= 4;  // ← settings/assistant/notifications lose nav
}
```

**Recommendation**: Either add Settings/Assistant to the bottom nav as overflow items, or make them top-level routes (outside `StatefulShellRoute`) so the transition is intentional rather than surprising.

---

### 🟡 MEDIUM-4: `/mine/medicine/new` Redirects to SearchPage
**Severity**: Medium  
**File**: `lib/app/router.dart`

**Description**: The route `/mine/medicine/new` is defined but its builder just returns `SearchPage`. This is confusing — the URL says "mine/medicine/new" but the page is the global medicine search. Also, this route is outside the shell, so bottom nav disappears.

**Code**:
```dart
GoRoute(
  path: '/mine/medicine/new',
  builder: (context, state) => const SearchPage(),  // ← Not a "new medicine" page, just search
),
```

**Recommendation**: Rename the route to `/medicine/search` or create a proper "add medicine" flow page.

---

### 🟡 MEDIUM-5: Report Page Navigates to Record Tab on Metric Selection
**Severity**: Medium  
**File**: `lib/features/report/presentation/pages/report_page.dart`

**Description**: Tapping a metric in the report dashboard switches to the Record tab via `ref.read(shellProvider.notifier).selectTab(1)`. This is a cross-tab navigation that may lose the user's report context. The user expects to see record details filtered by the metric, not just the generic record tab.

**Code**:
```dart
void _openRecordFilter(BuildContext context, WidgetRef ref, ReportDataKind kind) {
  // ...
  ref.read(shellProvider.notifier).selectTab(1);  // ← Jumps to Record tab, loses report context
}
```

**Recommendation**: Push a filtered record view on top of the current context instead of switching tabs, or ensure the filter is applied and visible when switching.

---

### 🟢 LOW-2: Login Route for Current Location May Not Return Properly
**Severity**: Low  
**Files**: Multiple files use `loginRouteForCurrentLocation(context)` and `loginRouteForReturnTo('/path')`

**Description**: Various auth-required gates use helper functions to compute login return URLs. If these helpers don't properly encode the return path, users may not return to their original location after login.

**Recommendation**: Verify `loginRouteForCurrentLocation` and `loginRouteForReturnTo` implementations handle URL encoding correctly.

---

## 4. RETURN KEY / BACK BUTTON ISSUES

### 🟠 HIGH-9: AuthBackButton Uses Navigator.canPop Which is Unreliable with go_router ShellRoutes
**Severity**: High  
**File**: `lib/features/auth/presentation/widgets/auth_back_button.dart`

**Description**: `AuthBackButton` uses `Navigator.of(context).canPop()` to decide whether to `context.pop()` or `context.go('/')`. In `go_router`'s `StatefulShellRoute`, the navigator stack behavior is complex — `canPop()` may return true even when popping would exit the app or behave unexpectedly.

**Code**:
```dart
IconButton(
  onPressed: () {
    if (Navigator.of(context).canPop()) {  // ← Unreliable with go_router ShellRoute
      context.pop();
    } else {
      context.go('/');
    }
  },
),
```

**Recommendation**: Use `GoRouter.of(context).canPop()` instead of `Navigator.of(context).canPop()`, or explicitly define back behavior per page. Even better: use `context.pop()` with a fallback to `context.go('/today')` (not `/`, which is the splash screen).

---

### 🟠 HIGH-10: SearchPage Has No Back Button
**Severity**: High  
**File**: `lib/features/search/presentation/pages/search_page.dart`

**Description**: `SearchPage` uses a bare `Scaffold` with only a `body`. There is no app bar, no back button, and no close button. On iOS especially, users expect a way to dismiss/dismiss the search. The only way out is the system back gesture/button.

**Code**:
```dart
class SearchPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: MedicineSearchView(...),  // ← No app bar, no back button
    );
  }
}
```

**Recommendation**: Add an `AppBar` with a back/close button, or wrap in `PageScaffoldShell` with `SettingsBackButton`.

---

### 🟠 HIGH-11: Inconsistent Back Button Naming and Usage
**Severity**: High  
**Files**: Multiple

**Description**: The codebase uses two different back button widgets interchangeably:
- `AuthBackButton` — used on Record pages (create, detail, edit)
- `SettingsBackButton` — used on Medicine pages (risk-check, reminder detail/edit), Assistant, Settings

Both appear to do the same thing (back arrow) but have different names, suggesting copy-paste without consolidation. This makes maintenance harder and may cause behavioral drift.

**Recommendation**: Consolidate into a single `AppBackButton` widget used consistently across all sub-pages.

---

### 🟡 MEDIUM-6: Assistant Page Back Button May Pop to Empty Shell
**Severity**: Medium  
**File**: `lib/features/assistant/presentation/pages/assistant_page.dart`

**Description**: Assistant uses `SettingsBackButton(onTap: () => context.pop())`. But Assistant is a shell branch — popping from it may exit the app or go to an unexpected shell branch instead of returning to the previous tab.

**Code**:
```dart
leading: SettingsBackButton(onTap: () => context.pop()),
```

**Recommendation**: Use explicit navigation like `context.go('/today')` or `context.go('/mine')` depending on entry point, or track the previous route.

---

### 🟡 MEDIUM-7: Record Detail Edit Button Pushes Instead of Navigating Within Shell
**Severity**: Medium  
**File**: `lib/features/record/presentation/pages/record_detail.dart`

**Description**: The edit button uses `context.push('/record/$id/edit')`. Since `/record/:id/edit` is inside the shell route, `push` creates a nested navigation stack within the shell. This may cause unexpected back behavior.

**Code**:
```dart
IconButton(
  onPressed: () => context.push('/record/$id/edit'),  // ← Nested push inside shell
),
```

**Recommendation**: Use `context.go()` for sibling routes within the same shell branch, or verify that `push` + `pop` works correctly with state restoration.

---

### 🟢 LOW-3: Settings Page Back Button Goes Nowhere Useful
**Severity**: Low  
**File**: `lib/features/settings/presentation/pages/settings_page.dart`

**Description**: Settings is accessed from Mine tab but has its own shell branch. The back button pops from the Settings shell branch, which likely returns to the Mine tab (index 4), but this depends on go_router's internal state management.

**Recommendation**: Verify the back behavior in practice and ensure users return to Mine tab, not an empty state.

---

## 5. DEFERRED / MVP FEATURE CONFUSION

### 🟡 MEDIUM-8: Deferred Scan Quick Actions is Empty but Referenced
**Severity**: Medium  
**File**: `lib/features/medicine/data/repositories/mock_medicine_workspace_repository.dart`

**Description**: `deferredScanQuickActions` is an empty list marked as "Deferred by Product_Vision MVP". The workspace model has a `quickActions` field that's always empty. While no UI currently renders quick actions (since the list is empty), the data model and repository still carry this field, which may confuse future developers.

**Code**:
```dart
static const deferredScanQuickActions = <MedicineQuickAction>[];
// quickActions: deferredScanQuickActions,  // Deferred by Product_Vision MVP
```

**Recommendation**: Remove the `quickActions` field from the workspace entity entirely until the feature is implemented, or clearly document it as reserved.

---

### 🟢 LOW-4: MedicineCopyKey.quickActionCameraTitle is Deferred but May Be Referenced
**Severity**: Low  
**File**: `lib/features/medicine/presentation/widgets/medicine_copy.dart` (not read, but referenced)

**Description**: The comment indicates `MedicineCopyKey.quickActionCameraTitle` is deferred. If any widget still references this localization key, it may show a missing translation or placeholder text.

**Recommendation**: Search for all references to `quickActionCameraTitle` and remove or guard them behind feature flags.

---

## 6. GENERAL UX PROBLEMS

### 🟠 HIGH-12: Today Recommendation Error State is Completely Hidden
**Severity**: High  
**File**: `lib/features/today/presentation/widgets/today_recommendation_section.dart`

**Description**: On error, the widget returns `const SizedBox.shrink()` — the entire section disappears with no error message, no retry button, and no indication that something went wrong.

**Code**:
```dart
error: (_, __) => const SizedBox.shrink(),  // ← Completely hidden on error
```

**Recommendation**: Show an `AppStateErrorView` with a retry action, or at minimum show the section title with an error indicator.

---

### 🟠 HIGH-13: Medicine Risk Check Error Description is Empty String
**Severity**: High  
**File**: `lib/features/medicine/presentation/pages/reminder/medicine_reminder_detail_page.dart`

**Description**: The error view for reminder detail has an empty description string, giving users no information about what went wrong.

**Code**:
```dart
error: (_, __) => AppStateErrorView(
  title: l10n.medicineReminderNotFoundTitle,
  description: '',  // ← Empty description
  // ...
),
```

**Recommendation**: Provide a meaningful error description or use a generic fallback message.

---

### 🟡 MEDIUM-9: Report Page Error State Lacks Back Button
**Severity**: Medium  
**File**: `lib/features/report/presentation/pages/report_page.dart`

**Description**: The error state is rendered inside a `DecoratedBox` with `SafeArea` but has no back button or navigation. If this is a top-level route error, users are stranded.

**Code**:
```dart
error: (error, _) {
  return DecoratedBox(
    decoration: BoxDecoration(color: surface.canvasSoft),
    child: SafeArea(
      bottom: false,
      child: AppStateErrorView(...),  // ← No back button
    ),
  );
}
```

**Recommendation**: Add a back/return button or ensure the error view includes navigation to a safe fallback route.

---

### 🟡 MEDIUM-10: Settings Privacy Row Toggles Without Confirmation
**Severity**: Medium  
**File**: `lib/features/settings/presentation/pages/settings_page.dart`

**Description**: Tapping the data sharing consent row immediately toggles the value without any confirmation dialog. For a privacy-sensitive health app, this is risky.

**Code**:
```dart
onTap: () {
  final value = !(settings?.dataSharingConsent ?? false);
  ref.read(userSettingsControllerProvider.notifier).setDataSharingConsent(value);
},
```

**Recommendation**: Add a confirmation dialog before changing privacy settings, especially for data sharing.

---

### 🟡 MEDIUM-12: Medicine Reminder Edit Page Prefills Without User Confirmation
**Severity**: Medium  
**File**: `lib/features/medicine/presentation/pages/reminder/medicine_reminder_edit_page.dart`

**Description**: The edit page automatically prefills form data from existing reminders via `_tryPrefill()`. While convenient, if the prefill logic has bugs or loads wrong data, users may save incorrect reminders without realizing.

**Recommendation**: Add a visual indicator when data is prefilled, or require explicit confirmation before prefill.

---

### 🟢 LOW-5: PageScaffoldShell Doesn't Handle Bottom SafeArea for FloatingActionButton
**Severity**: Low  
**File**: `lib/core/widgets/page_scaffold_shell.dart`

**Description**: When `floatingActionButton` is provided, it's positioned at `bottom: AppSpacingTokens.lg` without considering bottom safe area (notch, home indicator). On iPhones with home indicators, the FAB may be obscured.

**Code**:
```dart
Positioned(
  right: AppSpacingTokens.lg,
  bottom: AppSpacingTokens.lg,  // ← No safe area padding
  child: floatingActionButton!,
),
```

**Recommendation**: Add `MediaQuery.paddingOf(context).bottom` to the bottom position.

---

### 🟢 LOW-6: ShellPage Doesn't Preserve Scroll Position Across Tabs
**Severity**: Low  
**File**: `lib/features/shell/presentation/shell_page.dart`

**Description**: The `ShellPage` uses `StatefulShellRoute.indexedStack` which preserves widget state, but individual list views use `PageStorageKey` for scroll position. Verify that scroll position is actually restored when returning to a tab.

**Recommendation**: Test scroll position restoration across all tabs and ensure `PageStorageKey` values are unique and consistent.

---

### 🟢 LOW-7: Medicine Reminder Delete Button Enabled When No Reminders Exist
**Severity**: Low  
**File**: `lib/features/medicine/presentation/pages/reminder/medicine_reminder_detail_page.dart`

**Description**: The delete button's `onPressed` is set to `null` when `reminders.isEmpty`, which correctly disables it. However, the button is still visible and clickable-looking (just greyed out). Consider hiding it entirely when there's nothing to delete.

**Code**:
```dart
FilledButton.icon(
  onPressed: reminders.isEmpty ? null : () async { ... },  // ← null when empty
),
```

**Recommendation**: Hide the delete button entirely when there are no reminders, or show an empty-state message instead.

---

### 🟢 LOW-8: Today Dashboard Uses Fixed Padding for Bottom Nav
**Severity**: Low  
**File**: `lib/features/today/presentation/widgets/today_dashboard_view.dart`

**Description**: The mobile dashboard adds `AppSpacingTokens.x5l + AppSpacingTokens.xs` bottom padding to account for the bottom nav, but this is a hardcoded guess. If bottom nav height changes (e.g., on different devices or with more tabs), content may be cut off or have too much padding.

**Code**:
```dart
padding: const EdgeInsets.fromLTRB(
  AppSpacingTokens.md, AppSpacingTokens.md,
  AppSpacingTokens.md, AppSpacingTokens.x5l + AppSpacingTokens.xs,  // ← Hardcoded
),
```

**Recommendation**: Use `MediaQuery.paddingOf(context).bottom` or measure the actual bottom nav height.

---

## Appendix: Quick Reference — Issues by File

| File | Issues | Severities |
|------|--------|------------|
| `lib/app/router.dart` | HIGH-7, HIGH-8 | High |
| `lib/features/auth/presentation/widgets/auth_back_button.dart` | HIGH-9 | High |
| `lib/features/today/presentation/pages/today_page.dart` | — | — |
| `lib/features/today/presentation/widgets/today_dashboard_view.dart` | HIGH-3, LOW-8 | High, Low |
| `lib/features/today/presentation/widgets/today_recommendation_section.dart` | HIGH-4, HIGH-5 | High |
| `lib/features/record/presentation/pages/record_page.dart` | — | — |
| `lib/features/record/presentation/pages/record_detail.dart` | MED-7 | Medium |
| `lib/features/medicine/presentation/pages/medicine_page.dart` | — | — |
| `lib/features/medicine/presentation/widgets/medicine_mobile_quick_operations_section.dart` | HIGH-6 | High |
| `lib/features/medicine/presentation/widgets/medicine_mobile_drugbox_section.dart` | LOW-1, LOW-7 | Low |
| `lib/features/medicine/presentation/pages/medicine_risk_check_page.dart` | — | — |
| `lib/features/medicine/presentation/pages/reminder/medicine_reminder_detail_page.dart` | HIGH-13, LOW-7 | High, Low |
| `lib/features/medicine/presentation/pages/reminder/medicine_reminder_edit_page.dart` | MED-12 | Medium |
| `lib/features/report/presentation/pages/report_page.dart` | MED-1, MED-5, MED-9 | Medium |
| `lib/features/mine/presentation/pages/mine_page.dart` | — | — |
| `lib/features/search/presentation/pages/search_page.dart` | HIGH-10 | High |
| `lib/features/settings/presentation/pages/settings_page.dart` | MED-10 | Medium |
| `lib/features/assistant/presentation/pages/assistant_page.dart` | MED-6 | Medium |
| `lib/core/widgets/page_scaffold_shell.dart` | LOW-5 | Low |
| `lib/features/shell/presentation/shell_page.dart` | LOW-6 | Low |
| Various mock repositories | HIGH-1, HIGH-2 | High |

---

*End of Report*
