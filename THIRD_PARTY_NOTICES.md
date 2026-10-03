# Third-Party Notices

Luminous itself is licensed under the [MIT License](LICENSE).

Luminous is built on third-party open-source software. This file records the components the app
depends on and the platforms it targets, together with their licences. It is a notice of provenance,
not a modification of any upstream licence: each package remains under its own terms, and the
upstream `LICENSE` file inside each package is authoritative.

Version ranges below follow `pubspec.yaml`. Patch-level versions move as dependencies are updated
and are deliberately not pinned here — resolve the exact version from `pubspec.lock` for any given
checkout.

## Framework and language

| Component | Used for | Licence |
| --- | --- | --- |
| [Flutter](https://flutter.dev) / [Dart](https://dart.dev) | UI framework and language, including `flutter_localizations` | BSD-3-Clause |
| [Forui](https://forui.dev) (`forui`, `forui_hooks`, `forui_lucide`, `forui_phosphor`) | UI component library and theming | MIT |
| [Riverpod](https://riverpod.dev) (`flutter_riverpod`, `hooks_riverpod`, `riverpod_annotation`) | State management | MIT |
| [GoRouter](https://pub.dev/packages/go_router) | Declarative routing | BSD-3-Clause |
| [flutter_hooks](https://pub.dev/packages/flutter_hooks) | Hook primitives | MIT |
| [fpdart](https://pub.dev/packages/fpdart) | Functional result and option types | MIT |

## Data, storage and networking

| Component | Used for | Licence |
| --- | --- | --- |
| [Drift](https://drift.simonbinder.eu) (`drift`, `drift_dev`) + [sqlite3_flutter_libs](https://pub.dev/packages/sqlite3_flutter_libs) | Local database, cache-first reads and the pending-sync queue | MIT |
| [Dio](https://pub.dev/packages/dio) | HTTP client | MIT |
| [shared_preferences](https://pub.dev/packages/shared_preferences) | Non-sensitive local preferences | BSD-3-Clause |
| [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) | Secure token storage | BSD-3-Clause |
| [path_provider](https://pub.dev/packages/path_provider) | Platform directories | BSD-3-Clause |
| [connectivity_plus](https://pub.dev/packages/connectivity_plus) | Connectivity state | BSD-3-Clause |
| [cached_network_image](https://pub.dev/packages/cached_network_image) + [octo_image](https://pub.dev/packages/octo_image) | Image caching and placeholders | MIT |
| [flutter_image_compress](https://pub.dev/packages/flutter_image_compress) | Client-side image compression | MIT |
| [crypto](https://pub.dev/packages/crypto) | Hashing primitives | BSD-3-Clause |
| [clock](https://pub.dev/packages/clock) | Injectable time source | Apache-2.0 |

## UI, content and media

| Component | Used for | Licence |
| --- | --- | --- |
| [fl_chart](https://pub.dev/packages/fl_chart) | Trend and distribution charts | MIT |
| [table_calendar](https://pub.dev/packages/table_calendar) | Calendar and timeline navigation | Apache-2.0 |
| [shimmer](https://pub.dev/packages/shimmer) | Loading skeletons | BSD-3-Clause |
| [flutter_animate](https://pub.dev/packages/flutter_animate) | Declarative animation | BSD-3-Clause |
| [timeline_tile](https://pub.dev/packages/timeline_tile) | Timeline layout | MIT |
| [flutter_slidable](https://pub.dev/packages/flutter_slidable) | Swipe actions on list rows | MIT |
| [flutter_svg](https://pub.dev/packages/flutter_svg) | SVG rendering | MIT |
| [flutter_markdown_plus](https://pub.dev/packages/flutter_markdown_plus) | Markdown rendering for AI output | BSD-3-Clause |
| [crop_your_image](https://pub.dev/packages/crop_your_image) | Image cropping in the capture flow | Apache-2.0 |
| [flow_ui](https://pub.dev/packages/flow_ui) | Canvas-based flow visuals | MIT |
| [material_ui](https://pub.dev/packages/material_ui) | Material icon and surface primitives not yet superseded by Forui | BSD-3-Clause |
| [intl](https://pub.dev/packages/intl) | Date, number and locale formatting | BSD-3-Clause |
| [email_validator](https://pub.dev/packages/email_validator) | Email format validation | MIT |
| [units_converter](https://pub.dev/packages/units_converter) | Unit conversion | MIT |

## Device capabilities

| Component | Used for | Licence |
| --- | --- | --- |
| [image_picker](https://pub.dev/packages/image_picker) | Camera and gallery capture | BSD-3-Clause |
| [mobile_scanner](https://pub.dev/packages/mobile_scanner) | Barcode scanning | BSD-3-Clause |
| [permission_handler](https://pub.dev/packages/permission_handler) | Runtime permission requests | MIT |
| `paddle_ocr_native` (local package under `pkgs/`) | On-device OCR for medicine box recognition | Apache-2.0 |
| [health](https://pub.dev/packages/health) | Read-only health-platform synchronisation | MIT |
| [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) | Local reminder scheduling and delivery | BSD-3-Clause |
| [timezone](https://pub.dev/packages/timezone) | Timezone data for scheduled notifications | BSD-3-Clause (timezone database carries its own public-domain terms) |
| [jpush_flutter](https://pub.dev/packages/jpush_flutter) | Push notification channel | MIT |
| [url_launcher](https://pub.dev/packages/url_launcher) | Opening external links | BSD-3-Clause |
| [share_plus](https://pub.dev/packages/share_plus) | System share sheet | BSD-3-Clause |
| [window_manager](https://pub.dev/packages/window_manager) | Desktop window sizing for the desktop target | MIT |
| [package_info_plus](https://pub.dev/packages/package_info_plus) | App version metadata | BSD-3-Clause |

## Authentication

| Component | Used for | Licence |
| --- | --- | --- |
| [fluwx](https://pub.dev/packages/fluwx) | WeChat OAuth through the WeChat SDK | Apache-2.0 |
| [sign_in_with_apple](https://pub.dev/packages/sign_in_with_apple) | Sign in with Apple | MIT |

## Observability

| Component | Used for | Licence |
| --- | --- | --- |
| [Sentry](https://sentry.io) (`sentry`, `sentry_flutter`, `sentry_dio`) | Crash and error reporting | MIT |
| [Talker](https://pub.dev/packages/talker_flutter) | Unified logging with runtime level filtering | MIT |

## Code generation and tooling (development only)

| Component | Used for | Licence |
| --- | --- | --- |
| [build_runner](https://pub.dev/packages/build_runner) | Code generation driver | BSD-3-Clause |
| [freezed](https://pub.dev/packages/freezed) (`freezed`, `freezed_annotation`) | Immutable state and union types | MIT |
| [json_serializable](https://pub.dev/packages/json_serializable) | JSON serialisation | BSD-3-Clause |
| [riverpod_generator](https://pub.dev/packages/riverpod_generator) | Provider code generation | MIT |
| [go_router_builder](https://pub.dev/packages/go_router_builder) | Type-safe route generation | BSD-3-Clause |
| [mocktail](https://pub.dev/packages/mocktail) | Test doubles | MIT |
| [network_image_mock](https://pub.dev/packages/network_image_mock) | Network image test doubles | BSD-3-Clause |
| [flutter_lints](https://pub.dev/packages/flutter_lints) | Lint rule set | BSD-3-Clause |
| [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons) / [flutter_native_splash](https://pub.dev/packages/flutter_native_splash) | Icon and splash generation | MIT |
| [device_info_plus](https://pub.dev/packages/device_info_plus) | Device metadata in tooling and diagnostics | BSD-3-Clause |

## Platform runtimes

| Component | Used for | Licence |
| --- | --- | --- |
| [Android SDK / AndroidX](https://developer.android.com) | Target platform (minSdk 26) and platform libraries | Apache-2.0 |
| WeChat Open SDK (Android / iOS) | WeChat OAuth on mobile, reached through `fluwx` | WeChat Open Platform terms; not redistributed by this repository |

## Generated API client

`generated/lucent_api/` is generated from the OpenAPI contract published by
[Lucent](https://github.com/LuoMuLoyal/Lucent). It is not a third-party dependency: it is this
project's own generated code, produced by `openapi_retrofit_generator` and `build_runner` from the
contract source of truth.

## Reporting

If you believe a package is listed with the wrong licence, or a dependency is missing, please open
an issue. Licence corrections are treated as documentation defects.