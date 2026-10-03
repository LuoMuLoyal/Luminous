# Page-catalog screenshot generator

Renders every page in the app's screenshot catalog at the Pixel 8 Pro frame
(1344×2992 px @ dpr 3) **with simulated data**, on the host, in well under a
minute — plus a set of extra captures for capabilities whose interesting state
only exists after a tap (proposal confirmation, expanded tool sources, the photo
recognition dialog).

This is not the e2e path. The Android `integration_test` harness needs an
emulator and roughly 3 s per page; `flutter_test` drives a fake clock and
rasterizes on the host, so the whole set finishes in one pass.

## Run

```powershell
cd Luminous
flutter test tool/screenshots/generate.dart --update-goldens
```

Outputs land in `outputs/screenshots/` (gitignored):

- `NN_group_page.png` — one PNG per catalog page, then the extras numbered on
- `MANIFEST.md` — file → group/page/route → rendered-text count
- `_rendered_text.txt` — every string each page rendered, for diffing runs

To iterate on a few pages, filter by test name:

```powershell
flutter test tool/screenshots/generate.dart --update-goldens --plain-name "reminder"
```

Then tile the results into contact sheets:

```powershell
python tool/screenshots/contact_sheet.py outputs/screenshots build/contact
```

## How it works

`generate.dart` imports only the **catalog constants** from
`integration_test/screenshots/page_catalog_screenshot_test.dart` — the list of
routes and file names. It does not import or reuse any e2e fixture, page
helper, or fake data.

For each catalog entry it:

1. sets the frame size and device pixel ratio on `tester.view`;
2. builds a fresh `ProviderContainer` with `retry: null` (see below) and mounts
   `LuminousApp`;
3. navigates with `router.go(...)` (taps would be far more brittle across ~45
   pages);
4. pumps until settled and captures via `matchesGoldenFile`.

### Extra captures

The catalog is one shot per route, so `_extraCaptures` adds states that a
single at-rest route cannot show. They reuse the same pump/capture path and are
numbered after the catalog (`46`–`54`):

| Shot | Surface |
| --- | --- |
| `46_assistant_write_proposal` | `create_daily_record` draft awaiting confirmation |
| `47_assistant_write_confirmed` | the same proposal after the server-side approve |
| `48_assistant_source_detail` | source strip expanded: coverage / confidence / ambiguities / citation |
| `49_assistant_capabilities` | capability panel tool list (incl. a non-permitted tool) |
| `50_assistant_conversations` | conversation drawer with recent conversations |
| `51_assistant_replaced_answer` | regenerated answer: the superseded bubble greyed with「已替换」 |
| `52_scan_photo_method_picker` | OCR vs AI recognition method sheet |
| `53_scan_photo_recognize_ocr` | OCR-path recognition result |
| `54_scan_photo_recognize_ai` | AI-path result with the candidate list expanded |

Extras drive real widgets (`showMedicineBoxScanSheet`, `MedicineRecognizeDialog`,
`AssistantProposalCard`) — none of them is a screenshot-only mock-up, and the
assistant fixture is injected through `SimulatedAssistantRepository(conversation:)`
rather than by editing `lib/`.

Two details make the scan extras work:

- **Dialog host context.** The app's `Localizations`/`Navigator` live *inside*
  `LuminousApp`, so the root element has neither. `_hostContext` takes the
  navigator's first child, which is what a real `onPress` callback receives.
- **Image decode.** `Image.file` reads asynchronously and never completes in the
  fake-async zone, so the 60×60 box thumbnail captures blank. The generator
  synthesises the photo and precaches the `FileImage` inside `tester.runAsync`
  first.

### Things that will bite you

- **Fake clock, not wall clock.** `tester.pump(Duration)` advances a fake clock,
  which is why a page takes ~0.7 s on the host instead of ~3 s on a device.
  Anything compared against `clock.now()` (e.g. a proposal's `expiresAt`) must
  be anchored to the real clock, or the card renders as expired.
- **Fonts.** `flutter_test` rasterizes with a test font that draws every glyph as
  an empty box. Real faces must be registered under the exact family names the
  app asks for — notably `packages/forui/Inter` for CJK, plus the Forui
  Lucide/Phosphor icon families. Registering a CJK face under a made-up name
  silently does nothing. The generator reads the CJK face from the host
  (`C:\Windows\Fonts`), so the captures are not portable beyond Windows without
  adjusting `_cjkFontCandidates`.
- **`matchesGoldenFile` is the only usable raster path.** Manual
  `RepaintBoundary.toImage` + pump deadlocks in this binding
  (flutter/flutter#49317).
- **Pending timers fail the capture.** `AutomatedTestWidgetsFlutterBinding`
  asserts that no timer outlives the widget tree. Two causes were fixed here:
  Riverpod's auto-retry timers (disabled with `ProviderContainer(retry: ...)`)
  and disposal registered via `addTearDown`, which runs *after* the invariant
  check. Disposal now happens inside the test body, followed by explicit
  `pump(Duration.zero)` / `pump(1s)` / `pump(5s)` drains.
- **Plugin channels.** Without stubs, the bootstrap throws
  `MissingPluginException` for `window_manager`, `path_provider`,
  `package_info`, `connectivity`, `permission_handler`, and `mobile_scanner`.
  All are stubbed in `_installPlatformStubs()`. `PermissionStatus` and the
  scanner's authorization state are **positional ints** (`1` = granted /
  authorized); the scanner's `state` method returns that int, while `start`
  returns the view configuration.
- **Placeholder ids.** The catalog points at e2e fixture ids
  (`e2e-allergy-1`, `__mock_cn_ibuprofen__`, …). `_resolveRoute` rewrites those
  onto the simulated dataset so the committed catalog stays untouched.

## Simulated data

All content under `simulated_fakes_*.dart` is authored for this generator: a
plausible mid-use account (陈静, 2026 dates, 高血压 + 2 型糖尿病, three current
medicines, penicillin/pollen allergies). **No e2e fixture is reused**, and
cross-page coherence is deliberately not a goal — only that every page renders
populated rather than as an empty/error state.

- `simulated_fakes_shell_a.dart` — Today / Record / DailyRecord / Review dashboards
- `simulated_fakes_shell_b.dart` — Mine / medicine box / health context / suggestions
- `simulated_fakes_misc.dart` — notifications, reminders, assistant, health sync,
  search, risk check, legal, support, settings, scan, medicine detail
- `simulated_fakes_review.dart` — event review + review history
- `simulated_fakes_assistant.dart` — the extra assistant conversations (pending /
  confirmed write proposal, rich tool envelope, replaced answer) and the
  medicine-box recognition results

Review-section fixtures must use the **real contract fact codes**
(`health_event`, `observed_changes`, `completed_actions`, `active_check_in`);
a wrong code renders the section's "暂时无法展示这部分内容" fallback. The same
applies to assistant tool ids: `localizeToolName` maps a fixed set, and an
unknown id falls back to the raw id.

`_ensureBoxPhoto` draws the recognition dialog's box "photo" into the system
temp directory at capture time, so there is no committed binary; it is fixture
decoration, not app content.

### Why the auth and reminder providers are overridden directly

Two seams read a different provider than the obvious repository:

- The five shell tabs render signed-out unless `authSessionProvider` is
  overridden, so the generator installs a simulated signed-in session.
- The reminder pages read `medicineReminderRemoteDataSourceProvider` rather than
  `reminderRepositoryProvider`, so overriding only the repository leaves them on
  the real network path. The generators override the presentation providers too.

