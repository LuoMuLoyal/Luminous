import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/health_context/domain/entities/write_inputs.dart';
import 'package:luminous/features/medicine/data/repositories/risk_check.dart';
import 'package:luminous/features/scan/domain/entities/scan_result.dart';
import 'package:luminous/features/scan/presentation/widgets/dialogs/recognize_dialog.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../../auth/test_helpers.dart';
import '../../helpers/mocks/health_context.dart';
import '../../helpers/test_forui_app.dart';

void main() {
  late String tempImagePath;

  setUpAll(() {
    // Create a minimal PNG file for Image.file to load
    final tempDir = Directory.systemTemp;
    final tempFile = File('${tempDir.path}/test_recognize_image.png');
    // 1x1 transparent PNG
    tempFile.writeAsBytesSync([
      0x89,
      0x50,
      0x4E,
      0x47,
      0x0D,
      0x0A,
      0x1A,
      0x0A,
      0x00,
      0x00,
      0x00,
      0x0D,
      0x49,
      0x48,
      0x44,
      0x52,
      0x00,
      0x00,
      0x00,
      0x01,
      0x00,
      0x00,
      0x00,
      0x01,
      0x08,
      0x06,
      0x00,
      0x00,
      0x00,
      0x1F,
      0x15,
      0xC4,
      0x89,
      0x00,
      0x00,
      0x00,
      0x0D,
      0x49,
      0x44,
      0x41,
      0x54,
      0x78,
      0x9C,
      0x63,
      0x00,
      0x01,
      0x00,
      0x00,
      0x05,
      0x00,
      0x01,
      0x0D,
      0x0A,
      0x2D,
      0xB4,
      0x00,
      0x00,
      0x00,
      0x00,
      0x49,
      0x45,
      0x4E,
      0x44,
      0xAE,
      0x42,
      0x60,
      0x82,
    ]);
    tempImagePath = tempFile.path;
  });

  tearDownAll(() {
    File(tempImagePath).deleteSync();
  });

  /// Stub snapshot with a single current medicine (cn source) in the box.
  HealthContextSnapshot boxSnapshotWith(CurrentMedicineItem item) {
    return testHealthSnapshot(currentMedicines: [item]);
  }

  CurrentMedicineItem boxItem({
    String id = 'box-med-1',
    String sourceRefId = 'med-1',
    String displayName = 'Test',
  }) {
    return CurrentMedicineItem(
      id: id,
      source: 'cn',
      sourceRefId: sourceRefId,
      displayName: displayName,
      strengthText: null,
      doseText: null,
      route: null,
      startedAt: null,
      endedAt: null,
      isCurrent: true,
      note: null,
      createdAt: '2026-08-16T00:00:00.000Z',
      updatedAt: '2026-08-16T00:00:00.000Z',
    );
  }

  Future<void> pumpDialog(
    WidgetTester tester, {
    required List<MedicineMatchResult> results,
    MedicineScanMethod method = MedicineScanMethod.ocr,
    String methodLabel = 'OCR',
    VoidCallback? onRetake,
    List<Override> overrides = const [],
  }) async {
    // The dialog is pushed as its own route (sub-route of '/' so the stack
    // has a page beneath it) so pop-then-push exits (查看说明书 /
    // 查看提醒详情) behave like production. The FToaster sits above the
    // navigator (showToaster), mirroring production, so a success toast whose
    // action outlives the dialog survives the dialog being closed.
    final router = GoRouter(
      initialLocation: '/dialog',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(body: Center(child: Text('home'))),
          routes: [
            GoRoute(
              path: 'dialog',
              builder: (_, __) => Scaffold(
                body: MedicineRecognizeDialog(
                  imagePath: tempImagePath,
                  method: method,
                  methodLabel: methodLabel,
                  results: results,
                  onRetake: onRetake ?? () {},
                ),
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/medicine/detail/:source/:id',
          builder: (_, state) => Scaffold(
            body: Center(
              child: Text(
                'medicine-detail:${state.pathParameters['source']}:'
                '${state.pathParameters['id']}',
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/medicine/reminders/:medicineId',
          builder: (_, state) => Scaffold(
            body: Center(
              child: Text(
                'medicine-reminders:${state.pathParameters['medicineId']}',
              ),
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    // No default snapshot override: with the unoverridden auth session the
    // snapshot stays pending (authGuarded), so the dialog's box lookup falls
    // back to an empty map. Tests that need a populated drugbox pass their
    // own `healthContextSnapshotProvider` override.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [...overrides],
        child: TestForuiRouterApp(routerConfig: router, showToaster: true),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  /// Bounded pumps through async provider resolution and toast rendering.
  Future<void> flushAsync(WidgetTester tester, [int times = 6]) async {
    for (var i = 0; i < times; i++) {
      await tester.pump(const Duration(milliseconds: 25));
    }
  }

  MedicineMatchResult result({
    required String name,
    double? confidence,
    MedicineMatchType matchType = MedicineMatchType.nameFuzzy,
    String? id,
  }) {
    return MedicineMatchResult(
      name: name,
      confidence: confidence,
      matchType: matchType,
      id: id,
    );
  }

  group('MedicineRecognizeDialog', () {
    testWidgets('renders dialog title', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpDialog(tester, results: []);

      expect(find.text(l10n.scanResultTitle), findsWidgets);
    });

    testWidgets('renders no result message when results empty', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpDialog(tester, results: []);

      expect(find.text(l10n.scanNoResultTitle), findsOneWidget);
    });

    testWidgets('renders top result name', (tester) async {
      await pumpDialog(
        tester,
        results: [
          result(
            name: '阿莫西林胶囊',
            confidence: 0.95,
            matchType: MedicineMatchType.approvalNumber,
            id: 'med-1',
          ),
        ],
      );

      expect(find.text('阿莫西林胶囊'), findsWidgets);
    });

    testWidgets('renders top result approval number', (tester) async {
      await pumpDialog(
        tester,
        results: [
          const MedicineMatchResult(
            name: '阿莫西林胶囊',
            approvalNumber: '国药准字H12345678',
            confidence: 0.95,
            matchType: MedicineMatchType.approvalNumber,
            id: 'med-1',
          ),
        ],
      );

      expect(find.text('国药准字H12345678'), findsOneWidget);
    });

    testWidgets('AI method renders verify hint and no confidence percentage', (
      tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpDialog(
        tester,
        method: MedicineScanMethod.ai,
        methodLabel: 'AI',
        // AI results carry no confidence — and no percentage must be shown.
        results: [result(name: 'Test', id: 'med-1')],
      );

      expect(find.text(l10n.scanResultVerifyHintAi), findsOneWidget);
      expect(find.text(l10n.scanResultVerifyHintOcr), findsNothing);
      expect(find.textContaining('%'), findsNothing);
    });

    testWidgets('OCR method renders OCR verify hint', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpDialog(
        tester,
        method: MedicineScanMethod.ocr,
        results: [result(name: 'Test', confidence: 0.85, id: 'med-1')],
      );

      expect(find.text(l10n.scanResultVerifyHintOcr), findsOneWidget);
      expect(find.text(l10n.scanResultVerifyHintAi), findsNothing);
      expect(find.textContaining('%'), findsNothing);
    });

    testWidgets('renders retake button', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpDialog(tester, results: []);

      expect(find.text(l10n.scanRetakeAction), findsOneWidget);
    });

    testWidgets('renders add-to-box and view-instructions buttons', (
      tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpDialog(
        tester,
        results: [result(name: 'Test', confidence: 0.9, id: 'med-1')],
      );

      expect(find.text(l10n.medicineSearchAddToBoxAction), findsOneWidget);
      expect(find.text(l10n.scanViewInstructionsAction), findsOneWidget);
    });

    testWidgets('top result follows the sorted ordering', (tester) async {
      await pumpDialog(
        tester,
        results: [
          result(name: 'LowConfidence', confidence: 0.5, id: 'med-low'),
          result(
            name: 'HighConfidence',
            confidence: 0.95,
            matchType: MedicineMatchType.approvalNumber,
            id: 'med-high',
          ),
        ],
      );

      // The top card shows the sorted-first entry; the lower-ranked entry is
      // only inside the (collapsed) candidate list.
      expect(find.text('HighConfidence'), findsWidgets);
      expect(find.text('LowConfidence'), findsNothing);
    });

    testWidgets('equal-confidence candidates keep their input order '
        '(stable sort, F-6 P2-1)', (tester) async {
      // The AI path carries no confidence (all null → equal). The stable
      // sort must preserve the input order, so the top result equals the
      // first candidate-list entry — never an arbitrary reordering. Three
      // equal entries all fit in the dialog's 200px list viewport, so the
      // full order is assertable without scrolling.
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      const names = ['First', 'Second', 'Third'];
      await pumpDialog(
        tester,
        results: [
          for (var i = 0; i < names.length; i++)
            result(name: names[i], id: 'med-$i'),
        ],
      );

      // Top card shows the input-first entry; the others are only in the
      // (collapsed) candidate list.
      expect(find.text('First'), findsWidgets);
      expect(find.text('Second'), findsNothing);
      expect(find.text('Third'), findsNothing);

      // Expanding the list confirms the full input order is kept by the
      // stable sort, with First still on top (matching the top card).
      await tester.tap(find.textContaining('从列表选择其他匹配'));
      await tester.pumpAndSettle();

      final list = find.byType(ListView);
      final positions = <String, double>{};
      for (final name in names) {
        positions[name] = tester
            .getTopLeft(find.descendant(of: list, matching: find.text(name)))
            .dy;
      }
      for (var i = 1; i < names.length; i++) {
        expect(
          positions[names[i - 1]]!,
          lessThan(positions[names[i]]!),
          reason: '${names[i - 1]} must precede ${names[i]} in the list',
        );
      }
    });

    testWidgets('shows candidate list expander when multiple results', (
      tester,
    ) async {
      await pumpDialog(
        tester,
        results: [
          result(name: '药品A', confidence: 0.9, id: 'med-1'),
          result(name: '药品B', confidence: 0.8, id: 'med-2'),
        ],
      );

      expect(find.textContaining('从列表选择其他匹配'), findsOneWidget);
    });

    testWidgets('does not show candidate list expander for single result', (
      tester,
    ) async {
      await pumpDialog(
        tester,
        results: [result(name: '药品A', confidence: 0.9, id: 'med-1')],
      );

      expect(find.textContaining('从列表选择其他匹配'), findsNothing);
    });

    testWidgets('expands candidate list on tap', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await pumpDialog(
        tester,
        results: [
          result(name: '药品A', confidence: 0.9, id: 'med-1'),
          result(name: '药品B', confidence: 0.8, id: 'med-2'),
        ],
      );

      // Candidate list not visible initially
      expect(find.byIcon(SemanticIcons.actionExpand), findsOneWidget);
      expect(find.byIcon(SemanticIcons.actionCollapse), findsNothing);

      // Tap to expand
      await tester.tap(find.textContaining('从列表选择其他匹配'));
      await tester.pumpAndSettle();

      // Now expanded
      expect(find.byIcon(SemanticIcons.actionCollapse), findsOneWidget);
      expect(find.byIcon(SemanticIcons.actionExpand), findsNothing);
    });

    testWidgets('candidate list shows sorted results by confidence', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await pumpDialog(
        tester,
        results: [
          result(name: 'LowConfidence', confidence: 0.5, id: 'med-low'),
          result(
            name: 'HighConfidence',
            confidence: 0.95,
            matchType: MedicineMatchType.approvalNumber,
            id: 'med-high',
          ),
        ],
      );

      // Expand candidate list
      await tester.tap(find.textContaining('从列表选择其他匹配'));
      await tester.pumpAndSettle();

      // HighConfidence should appear (sorted first by confidence desc)
      expect(find.text('HighConfidence'), findsWidgets);
      expect(find.text('LowConfidence'), findsWidgets);
    });

    testWidgets('deduplicates results by name in candidate list', (
      tester,
    ) async {
      await pumpDialog(
        tester,
        results: [
          result(
            name: 'SameDrug',
            confidence: 0.9,
            matchType: MedicineMatchType.approvalNumber,
            id: 'med-1',
          ),
          result(name: 'SameDrug', confidence: 0.8, id: 'med-2'),
        ],
      );

      // With dedup, there's only 1 unique name, so no expander
      expect(find.textContaining('从列表选择其他匹配'), findsNothing);
    });

    testWidgets('renders source label', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpDialog(
        tester,
        results: [result(name: 'Test', confidence: 0.9, id: 'med-1')],
      );

      expect(find.text(l10n.scanResultSourceLabel('OCR')), findsOneWidget);
    });

    testWidgets('add to box writes cn medicine through the shared loop', (
      tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      final fakeRepo = FakeHealthContextRepository()
        ..reflectCreatedMedicine = true;
      await pumpDialog(
        tester,
        overrides: [
          authSessionProvider.overrideWith(() => SignedInAuthSessionNotifier()),
          healthContextRepositoryProvider.overrideWithValue(fakeRepo),
          medicineRiskCheckRepositoryProvider.overrideWithValue(
            FakeMedicineRiskCheckRepository(clearRiskCheckResult),
          ),
        ],
        results: [result(name: 'Test', confidence: 0.9, id: 'med-1')],
      );

      await tester.tap(find.text(l10n.medicineSearchAddToBoxAction));
      await flushAsync(tester);

      final input = fakeRepo.createdCurrentMedicine;
      expect(input, isNotNull);
      expect(input!.source, HealthMedicineSource.cn);
      expect(input.sourceRefId, 'med-1');
      expect(input.displayName, 'Test');

      // The dialog stays open so the success toast is visible on top.
      expect(find.text(l10n.medicineSearchAddedToBoxToast), findsOneWidget);

      // Drain the toast auto-dismiss timer.
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('add to box button is disabled while an add is in flight '
        '(F-6 P2-2)', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      final fakeRepo = FakeHealthContextRepository()
        ..reflectCreatedMedicine = true;
      final gate = Completer<void>();
      fakeRepo.createGate = gate;
      await pumpDialog(
        tester,
        overrides: [
          authSessionProvider.overrideWith(() => SignedInAuthSessionNotifier()),
          healthContextRepositoryProvider.overrideWithValue(fakeRepo),
          medicineRiskCheckRepositoryProvider.overrideWithValue(
            FakeMedicineRiskCheckRepository(clearRiskCheckResult),
          ),
        ],
        results: [result(name: 'Test', confidence: 0.9, id: 'med-1')],
      );

      await tester.tap(find.text(l10n.medicineSearchAddToBoxAction));
      await tester.pump();

      // While the create is held by the gate, the primary button must be
      // disabled so a rapid second tap cannot duplicate the record.
      final addButton = tester.widget<FButton>(
        find.ancestor(
          of: find.text(l10n.medicineSearchAddToBoxAction),
          matching: find.byType(FButton),
        ),
      );
      expect(addButton.onPress, isNull);
      expect(fakeRepo.createdCurrentMedicine, isNull);

      // Release the gate: the add completes and the live snapshot watch
      // flips the dialog into the「已加入」state (button replaced by the
      // reminder-detail action).
      gate.complete();
      await flushAsync(tester);

      expect(fakeRepo.createdCurrentMedicine, isNotNull);
      expect(find.text(l10n.medicineSearchAddToBoxAction), findsNothing);
      expect(find.text(l10n.medicineSearchAlreadyAddedLabel), findsOneWidget);
      expect(find.text(l10n.scanViewReminderAction), findsOneWidget);

      // Drain the toast auto-dismiss timer.
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('add to box shows auth dialog when signed out', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpDialog(
        tester,
        overrides: [
          authSessionProvider.overrideWith(
            () => _SignedOutAuthSessionNotifier(),
          ),
        ],
        results: [result(name: 'Test', confidence: 0.9, id: 'med-1')],
      );

      await tester.tap(find.text(l10n.medicineSearchAddToBoxAction));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      expect(find.byKey(const Key('auth-required-dialog')), findsOneWidget);

      // Cancel keeps the user on the dialog.
      await tester.tap(find.byKey(const Key('auth-required-cancel-action')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('auth-required-dialog')), findsNothing);
      expect(find.text(l10n.medicineSearchAddToBoxAction), findsOneWidget);
    });

    testWidgets('already added result shows added state and opens reminder '
        'detail with the box record id', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpDialog(
        tester,
        overrides: [
          healthContextSnapshotProvider.overrideWith(
            (ref) async => boxSnapshotWith(boxItem()),
          ),
        ],
        results: [result(name: 'Test', confidence: 0.9, id: 'med-1')],
      );

      // Added state: no "add to box", but the already-added badge plus the
      // reminder detail action.
      expect(find.text(l10n.medicineSearchAlreadyAddedLabel), findsOneWidget);
      expect(find.text(l10n.scanViewReminderAction), findsOneWidget);
      expect(find.text(l10n.medicineSearchAddToBoxAction), findsNothing);

      await tester.tap(find.text(l10n.scanViewReminderAction));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Must carry the drugbox record id, not the medicine DB product id.
      expect(find.text('medicine-reminders:box-med-1'), findsOneWidget);
    });

    testWidgets('view instructions opens medicine detail', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpDialog(
        tester,
        results: [result(name: 'Test', confidence: 0.9, id: 'med-1')],
      );

      await tester.tap(find.text(l10n.scanViewInstructionsAction));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('medicine-detail:cn:med-1'), findsOneWidget);
    });

    testWidgets(
      'tapping the set-reminder toast action after closing the dialog does '
      'not push through a deactivated context',
      (tester) async {
        // Regression: the shared add-to-box loop's success toast carries a
        // "set reminder" action bound to the dialog context. If the dialog is
        // closed while the toast is still showing, tapping the action used to
        // push through the deactivated context — registering an Inherited
        // dependency on a dying element, which trips
        // `debugDeactivated`'s `_dependents.isEmpty` assertion.
        final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
        final fakeRepo = FakeHealthContextRepository()
          ..reflectCreatedMedicine = true;
        await pumpDialog(
          tester,
          results: [
            const MedicineMatchResult(
              name: 'Test',
              confidence: null,
              matchType: MedicineMatchType.nameFuzzy,
              id: 'med-1',
            ),
          ],
          overrides: [
            authSessionProvider.overrideWith(
              () => SignedInAuthSessionNotifier(),
            ),
            healthContextRepositoryProvider.overrideWithValue(fakeRepo),
            medicineRiskCheckRepositoryProvider.overrideWithValue(
              FakeMedicineRiskCheckRepository(clearRiskCheckResult),
            ),
            // Mirror the production provider: re-fetch from the repository when
            // the data change bus bumps these topics (the shared loop emits
            // `currentMedicines` after a successful add).
            healthContextSnapshotProvider.overrideWith((ref) {
              ref.watch(
                dataChangeVersionProvider(DataChangeTopic.currentMedicines),
              );
              ref.watch(
                dataChangeVersionProvider(DataChangeTopic.healthContext),
              );
              return ref
                  .read(healthContextRepositoryProvider)
                  .fetchHealthContext();
            }),
          ],
        );

        // Add to box → success toast with the set-reminder action.
        await tester.tap(find.text(l10n.medicineSearchAddToBoxAction));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        expect(
          find.text(l10n.medicineSearchGoToReminderAction),
          findsOneWidget,
        );

        // Close the dialog while the toast is still visible.
        await tester.tap(find.text(l10n.scanCloseAction));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text(l10n.medicineSearchAddToBoxAction), findsNothing);

        // Tap the toast action: the dialog context is deactivated by now. The
        // mounted guard in the shared loop must swallow the tap instead of
        // pushing (any FlutterError here fails the test).
        await tester.tap(find.text(l10n.medicineSearchGoToReminderAction));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        // Let the toast's auto-dismiss timer elapse so the test ends with no
        // pending timers.
        await tester.pump(const Duration(seconds: 2));
        await tester.pump(const Duration(milliseconds: 400));
      },
    );
  });
}

class _SignedOutAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() {
    return const AuthSessionState(isAuthenticated: false, isLoading: false);
  }
}
