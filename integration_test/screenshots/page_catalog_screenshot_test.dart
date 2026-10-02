// Page-catalog screenshot harness.
//
// Navigates Luminous to each entry in [screenshotCatalog] using the offline E2E
// fake stack (no backend required), captures a PNG per page onto the device's
// shared storage, and names each file:
//
//     <order>_<group>_<page-id>.png
//
// e.g. `01_shell_today.png`, `12_settings_language.png`.
//
// Run (PowerShell, from `Luminous/`):
//
//     .\scripts\screenshots\capture.ps1
//
// or manually:
//
//     flutter test integration_test/screenshots/page_catalog_screenshot_test.dart `
//       -d emulator-5554
//
// Output goes to `/sdcard/Download/luminous-screenshots/` — deliberately NOT
// the app's own external files dir, because `flutter test` uninstalls the app
// during teardown and that takes the app-private dir with it. See README.md
// next to this file.
import 'dart:io';

import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

import '../support/e2e_test_helpers.dart';
import '../support/screenshot_fixtures.dart';

/// One page to capture.
class ScreenshotTarget {
  const ScreenshotTarget({
    required this.group,
    required this.id,
    required this.route,
    this.note,
    this.auth = CaptureAuth.signedIn,
    this.expectVisible,
    this.prepare,
    this.settle = const Duration(milliseconds: 100),
    this.frames = 8,
  });

  /// Feature group, e.g. `shell`, `settings`, `mine`.
  final String group;

  /// Stable page id, e.g. `today`, `language`. Used in the file name.
  final String id;

  /// GoRouter location to navigate to.
  final String route;

  /// Human-readable description written into the manifest.
  final String? note;

  /// Auth session used while rendering this page.
  ///
  /// Most routes sit behind the router's auth guard, which redirects a
  /// signed-out session to `/login`. Capturing with the default (signed in)
  /// is what makes those pages actually render — with a signed-out session
  /// they all silently produce identical login-page frames. Only the shell
  /// tabs and the explicitly public preview routes are captured signed out.
  final CaptureAuth auth;

  /// Substrings that must be on screen before the capture is taken.
  ///
  /// This is the guard against a silently-empty screenshot: without it the
  /// harness will happily save a login page or an empty state under a
  /// confident-looking file name. Each string should be content that only
  /// appears when the fixture data actually rendered.
  final List<String>? expectVisible;

  /// Optional extra pumping (dialogs, async fakes) before capture.
  final Future<void> Function(WidgetTester tester)? prepare;

  /// Pump step duration.
  final Duration settle;

  /// Number of pump steps used to settle the frame.
  final int frames;
}

/// Auth session a page is captured under.
enum CaptureAuth {
  /// Signed in via [SignedInAuthSessionNotifier] — required for guarded
  /// routes, which otherwise redirect to `/login`.
  signedIn,

  /// Signed out via the no-op session notifier — only meaningful for the
  /// shell tabs and the public preview routes.
  signedOut,
}

/// Every page captured by the harness.
///
/// Ordered so the numeric prefix in the file name follows a sensible
/// review order: shell tabs, then record, medicine, mine, settings, misc.
const List<ScreenshotTarget> screenshotCatalog = <ScreenshotTarget>[
  // ------------------------------------------------------------------ shell
  ScreenshotTarget(
    group: 'shell',
    id: 'today',
    auth: CaptureAuth.signedOut,
    route: '/',
    note: 'Today tab — populated dashboard with suggestion cards.',
    expectVisible: ['午间这次降压药还没确认服用', '近 7 天依从率', '苯磺酸氨氯地平片'],
  ),
  ScreenshotTarget(
    group: 'shell',
    id: 'record',
    auth: CaptureAuth.signedOut,
    route: '/record',
    note: 'Record tab.',
  ),
  ScreenshotTarget(
    group: 'shell',
    id: 'medicine',
    auth: CaptureAuth.signedOut,
    route: '/medicine',
    note: 'Medicine tab.',
  ),
  ScreenshotTarget(
    group: 'shell',
    id: 'review',
    auth: CaptureAuth.signedOut,
    route: '/review',
    note: 'Review/Report tab.',
  ),
  ScreenshotTarget(
    group: 'shell',
    id: 'mine',
    auth: CaptureAuth.signedOut,
    route: '/mine',
    note: 'Mine tab.',
  ),

  // ----------------------------------------------------------------- record
  ScreenshotTarget(
    group: 'record',
    id: 'create',
    route: '/record/create',
    note: 'Create daily record.',
  ),
  ScreenshotTarget(
    group: 'record',
    id: 'detail',
    route: '/record/e2e-record-1',
    note: 'Record detail (E2E record id).',
  ),
  ScreenshotTarget(
    group: 'record',
    id: 'edit',
    route: '/record/e2e-record-1/edit',
    note: 'Edit daily record.',
  ),
  ScreenshotTarget(
    group: 'record',
    id: 'quick-entry-settings',
    route: '/record/quick-entry-settings',
    note: 'Quick entry settings.',
  ),
  ScreenshotTarget(
    group: 'record',
    id: 'quick-entry-reorder',
    route: '/record/quick-entry-settings/reorder',
    note: 'Quick entry reorder.',
  ),

  // --------------------------------------------------------------- medicine
  ScreenshotTarget(
    group: 'medicine',
    id: 'search',
    route: '/medicine/search',
    note: 'Medicine search (demo results).',
  ),
  ScreenshotTarget(
    group: 'medicine',
    id: 'detail',
    route: '/medicine/detail/cn/__mock_cn_ibuprofen__',
    note: 'Medicine detail (E2E demo medicine).',
  ),
  ScreenshotTarget(
    group: 'medicine',
    id: 'risk-check',
    route: '/medicine/risk-check',
    note: 'Medicine risk check.',
  ),
  ScreenshotTarget(
    group: 'medicine',
    id: 'reminder-new',
    route: '/medicine/reminders/new',
    note: 'New medicine reminder.',
  ),
  ScreenshotTarget(
    group: 'medicine',
    id: 'reminder-detail',
    route: '/medicine/reminders/e2e-medicine-1',
    note: 'Medicine reminder detail.',
  ),
  ScreenshotTarget(
    group: 'medicine',
    id: 'reminder-edit',
    route: '/medicine/reminders/e2e-medicine-1/edit',
    note: 'Edit medicine reminder.',
  ),

  // ------------------------------------------------------------------- mine
  ScreenshotTarget(
    group: 'mine',
    id: 'allergy-new',
    route: '/mine/allergy/new',
    note: 'New allergy.',
  ),
  ScreenshotTarget(
    group: 'mine',
    id: 'allergy-edit',
    route: '/mine/allergy/e2e-allergy-1/edit',
    note: 'Edit allergy (E2E item).',
  ),
  ScreenshotTarget(
    group: 'mine',
    id: 'condition-new',
    route: '/mine/condition/new',
    note: 'New condition.',
  ),
  ScreenshotTarget(
    group: 'mine',
    id: 'condition-edit',
    route: '/mine/condition/e2e-condition-1/edit',
    note: 'Edit condition (E2E item).',
  ),
  ScreenshotTarget(
    group: 'mine',
    id: 'medicine-new',
    route: '/mine/medicine/new',
    note: 'New current medicine.',
  ),
  ScreenshotTarget(
    group: 'mine',
    id: 'medicine-edit',
    route: '/mine/medicine/e2e-medicine-1/edit',
    note: 'Edit current medicine (E2E item).',
  ),
  ScreenshotTarget(
    group: 'mine',
    id: 'sync-failures',
    route: '/mine/sync/failures',
    note: 'Sync failures.',
  ),

  // --------------------------------------------------------------- settings
  ScreenshotTarget(
    group: 'settings',
    id: 'root',
    route: '/settings',
    note: 'Settings root.',
  ),
  ScreenshotTarget(
    group: 'settings',
    id: 'language',
    route: '/settings/language',
    note: 'Language settings.',
  ),
  ScreenshotTarget(
    group: 'settings',
    id: 'theme',
    route: '/settings/theme',
    note: 'Theme settings.',
  ),
  ScreenshotTarget(
    group: 'settings',
    id: 'more',
    route: '/settings/more',
    note: 'More settings.',
  ),
  ScreenshotTarget(
    group: 'settings',
    id: 'feature-flags',
    route: '/settings/more/feature-flags',
    note: 'Feature flags.',
  ),
  ScreenshotTarget(
    group: 'settings',
    id: 'notifications',
    route: '/settings/notifications',
    note: 'Notification settings.',
  ),
  ScreenshotTarget(
    group: 'settings',
    id: 'notifications-sleep',
    route: '/settings/notifications/sleep',
    note: 'Sleep notification settings.',
  ),
  ScreenshotTarget(
    group: 'settings',
    id: 'notifications-dnd',
    route: '/settings/notifications/dnd',
    note: 'Do-not-disturb settings.',
  ),
  ScreenshotTarget(
    group: 'settings',
    id: 'accessibility',
    route: '/settings/accessibility',
    note: 'Accessibility settings.',
  ),
  ScreenshotTarget(
    group: 'settings',
    id: 'ai',
    route: '/settings/ai',
    note: 'AI settings.',
  ),
  ScreenshotTarget(
    group: 'settings',
    id: 'export',
    route: '/settings/export',
    note: 'Data export settings.',
  ),
  ScreenshotTarget(
    group: 'settings',
    id: 'help',
    route: '/settings/help',
    note: 'Help.',
  ),
  ScreenshotTarget(
    group: 'settings',
    id: 'about',
    route: '/settings/about',
    note: 'About.',
  ),
  ScreenshotTarget(
    group: 'settings',
    id: 'data-storage',
    route: '/settings/data-storage',
    note: 'Data storage settings.',
  ),

  // ------------------------------------------------------------------- misc
  ScreenshotTarget(
    group: 'profile',
    id: 'root',
    route: '/profile',
    note: 'Profile.',
  ),
  ScreenshotTarget(
    group: 'assistant',
    id: 'root',
    route: '/assistant',
    note: 'Assistant.',
  ),
  ScreenshotTarget(
    group: 'health-data',
    id: 'sync',
    route: '/health-sync',
    note: 'Health data sync.',
  ),
  ScreenshotTarget(
    group: 'legal',
    id: 'list',
    route: '/legal',
    note: 'Legal document list.',
  ),
  ScreenshotTarget(
    group: 'legal',
    id: 'detail',
    route: '/legal/terms',
    note: 'Legal document detail.',
  ),
  ScreenshotTarget(
    group: 'notification',
    id: 'list',
    route: '/notifications',
    note: 'Notification list.',
  ),
  ScreenshotTarget(
    group: 'notification',
    id: 'detail',
    route: '/notifications/e2e-notification-1',
    note: 'Notification detail.',
  ),
  ScreenshotTarget(
    group: 'scan',
    id: 'barcode',
    route: '/scan/barcode',
    note: 'Barcode scan.',
  ),
];

/// Sanitises a string for use in a file name.
String slug(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
}

/// Builds the formatted output file name, e.g. `07_record_create.png`.
String screenshotFileName(int index, ScreenshotTarget target) {
  final ordinal = (index + 1).toString().padLeft(2, '0');
  return '${ordinal}_${slug(target.group)}_${slug(target.id)}.png';
}

/// Device-side output directory, relative to external storage.
///
/// This is the app's own external files dir, resolved at runtime through
/// `path_provider`. It is the only location the app may write to under Android
/// scoped storage — `/sdcard/Download` is owned by a different UID and fails
/// with EACCES.
///
/// It is deleted when `flutter test` uninstalls the app at teardown, so the
/// PNGs must be pulled while the run is still holding (see
/// [screenshotPullWindowSeconds]).
const String deviceOutputDirSuffix =
    'Android/data/com.dev.luminous/files/screenshots';

/// Groups captured by the current run.
///
/// Narrowed to `shell` while iterating on populated fixture data; widen to all
/// groups once the Today page capture is confirmed correct.
const Set<String> screenshotOnlyGroups = {'shell'};

/// Seconds the run stays alive after the last capture so the PNGs can be
/// pulled off the device before teardown uninstalls the app.
const int screenshotPullWindowSeconds = 45;

/// Pumps up to [frames] × [step], stopping early once no frames are scheduled.
///
/// `pumpAndSettle` would hang on pages with an indefinite animation (a
/// spinner, a marquee, a shimmer skeleton), so settle manually with a bound.
Future<void> pumpUntilSettledOrTimeout(
  WidgetTester tester,
  Duration step,
  int frames,
) async {
  for (var f = 0; f < frames; f += 1) {
    await tester.pump(step);
    if (!tester.binding.hasScheduledFrame) {
      // Give one more frame so the last build/layout lands before capture.
      await tester.pump(step);
      return;
    }
  }
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Directory? outputDir;
  final manifest = StringBuffer()
    ..writeln('# Luminous screenshot manifest')
    ..writeln()
    ..writeln('| File | Group | Page | Route | Note |')
    ..writeln('| --- | --- | --- | --- | --- |');

  setUpAll(() async {
    // Resolve the app's own external files dir through path_provider rather
    // than hardcoding `/sdcard/Android/data/<appId>/files`: the literal path
    // does not exist until the platform channel creates it, and creating it
    // by hand fails with EACCES under scoped storage.
    final base =
        await getExternalStorageDirectory() ??
        await getApplicationDocumentsDirectory();
    outputDir = Directory('${base.path}/screenshots')
      ..createSync(recursive: true);
    // ignore: avoid_print
    print('SCREENSHOT_DIR=${outputDir!.path}');
  });

  for (var i = 0; i < screenshotCatalog.length; i += 1) {
    final target = screenshotCatalog[i];
    final fileName = screenshotFileName(i, target);

    // Temporary focus: iterate on the Today page alone before spending a full
    // 45-page run. Remove this guard once the populated capture is confirmed.
    if (!screenshotOnlyGroups.contains(target.group)) continue;

    testWidgets('capture ${target.group}/${target.id}', (tester) async {
      final container = await pumpOfflineApp(
        tester,
        authSessionOverride: target.auth == CaptureAuth.signedIn
            ? SignedInAuthSessionNotifier.new
            : null,
        authRepository: E2eLucentAuthRepository(),
        todayRepository: const FixtureTodayRepository(),
        todaySuggestionBundle: buildPopulatedSuggestionBundle(),
      );

      // Route directly rather than tapping through the UI: the catalog covers
      // ~45 pages, and tapping would be far more brittle than `go`.
      container.read(appRouterProvider).go(target.route);

      // Pump generously: several pages resolve async fake data or run entry
      // animations, and a short settle captures a half-built frame.
      await pumpUntilSettledOrTimeout(tester, target.settle, target.frames);

      if (target.prepare != null) {
        await target.prepare!(tester);
      }

      // Guard against silently capturing an empty state (or the login page the
      // router redirects to): assert this page's populated content actually
      // rendered before spending a capture on it.
      if (target.expectVisible != null) {
        for (final text in target.expectVisible!) {
          expect(
            find.textContaining(text),
            findsWidgets,
            reason:
                'Page ${target.group}/${target.id} did not render the '
                'populated content "$text" — the capture would be an empty '
                'state or an auth redirect, not the real page.',
          );
        }
      }

      // On Android the Flutter surface must be converted to an image before
      // takeScreenshot will produce pixels.
      await binding.convertFlutterSurfaceToImage();
      await pumpUntilSettledOrTimeout(tester, target.settle, target.frames);

      final bytes = await binding.takeScreenshot(
        fileName.replaceAll('.png', ''),
      );

      final file = File('${outputDir!.path}/$fileName');
      await file.writeAsBytes(bytes, flush: true);

      manifest.writeln(
        '| `$fileName` | ${target.group} | ${target.id} | '
        '`${target.route}` | ${target.note ?? ''} |',
      );

      // ignore: avoid_print
      print('CAPTURED $fileName (${bytes.length} bytes)');
    });
  }

  tearDownAll(() async {
    if (outputDir != null) {
      await File(
        '${outputDir!.path}/MANIFEST.md',
      ).writeAsString(manifest.toString(), flush: true);
      // ignore: avoid_print
      print('MANIFEST=${outputDir!.path}/MANIFEST.md');

      // `flutter test` uninstalls the app at the end of the run, which deletes
      // this directory along with every screenshot in it. Waiting for the
      // capture script to place a sentinel keeps the app alive long enough to
      // pull the PNGs; without it the run deletes its own output.
      //
      // The wait ends early as soon as the sentinel exists, so an interactive
      // run is not held hostage for the full window.
      final sentinel = File('${outputDir!.path}/.pull-complete');
      // ignore: avoid_print
      print('READY_FOR_PULL ${outputDir!.path}');
      // ignore: avoid_print
      print('Write ${sentinel.path} to release the hold.');

      final deadline = DateTime.now().add(
        const Duration(seconds: screenshotPullWindowSeconds),
      );
      while (DateTime.now().isBefore(deadline)) {
        if (sentinel.existsSync()) {
          // ignore: avoid_print
          print('PULL_CONFIRMED — releasing');
          return;
        }
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }
      // ignore: avoid_print
      print('PULL_WINDOW_EXPIRED');
    }
  });
}
