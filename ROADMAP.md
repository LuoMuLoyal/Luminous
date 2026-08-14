# Luminous Roadmap

This document describes the planned evolution of the Luminous Flutter client.
It is a living document — directions shift as the product and community grow.

## Status

Luminous is currently at `0.1.0-dev`. The core mobile experience is functional
with all five tabs active, but the project has not yet shipped a stable release.
The product direction has been re-baselined around time-bounded health events,
sparse records, proactive guidance, event-first review, and privacy-minimal
closed-loop measurement; the fifth tab's user task is now Review and the
previous general report/dashboard model is retained only as a legacy
compatibility page under More. The product-loop program (ADR-0011) is complete:
the loop from event start → suggestion impression/action → outcome → review
open is measured end-to-end, and the optional visit summary is field-level
privacy-controlled with revocable shares.

**What works today**

- Five-tab shell: Today / Record / Medicine / Report / Mine
- Authentication: credential login + WeChat OAuth (mobile SDK + desktop
  browser), Apple Sign-In, QQ OAuth, Security PIN, OAuth-only account deletion
  via email verification code
- Daily records: water, meal, vital, mood, symptom, activity, note, sleep —
  with quick-add, calendar navigation, and filtering
- Medicine: current medicines list, safety preview with three-tier risk
  display (confirmed risk / confirmed safe / uncovered-uncertain), dose logs,
  reminders with local notifications
- AI assistant: SSE streaming chat, proposed actions (create / update / delete
  records, update settings), conversation history, context source controls,
  Markdown rendering for AI-generated text
- Health events: user-confirmed start/end, per-day check-ins, related
  symptoms/medicines/records, and improved/unchanged/worsened result
- Review (fifth tab): event-first review view with four sections (what
  happened / key changes / completed actions / next step), history filtering,
  and More actions for visit summary, PDF and print exports; the old dashboard
  remains reachable via a legacy compatibility page
- Visit summary: field-level privacy selection (free-text notes off by
  default), revocable 7-day shares with token-hash-only storage, share
  management (access count / revocation), public share page
- Closed-loop measurement: client-reported success-boundary events
  (suggestion impression / review opened / visit summary previewed+exported,
  offline queue + idempotent retry), server-authoritative lifecycle events,
  and an admin-only funnel endpoint (core loop vs optional exports separated,
  small-sample suppression)
- Reports: AI-driven summaries, trend visualization (fl_chart), data export,
  suggestion history (lifecycle-aware: active / expired / dismissed)
- Settings: theme (mode + family), locale, accessibility, notifications, data
  storage, AI context, security PIN, developer options (debug-only)
- Design system: Forui-based, full i18n (zh / en) with ARB fragment splitting,
  shimmer skeletons, responsive layout (mobile + desktop sidebar), semantic
  color system
- Infrastructure: Riverpod state management (with `@riverpod` code generation),
  GoRouter navigation (with `go_router_builder` type-safe routes), generated
  OpenAPI client, GitHub Actions CI, git hooks, daily/fullstack check scripts
- Offline support: Drift local database with cache-first repositories,
  SyncWorker with exponential backoff, pending sync queue, data retention
  cleanup, Web platform (WASM SQLite) support
- Error reporting: Sentry integration with Talker bridge, `runZonedGuarded`
  + `FlutterError.onError` crash capture
- Testing: 2294 unit/widget tests, Patrol-based integration tests, golden
  tests (CI-skipped), doc coverage gate
- Legal compliance: in-app legal document browser (terms / privacy /
  disclaimer / minor-protection / sdk-list / permissions / account-cancellation)
  with remote-first + assets fallback

**What's missing**

- Stable release — still in dev phase
- Real medicine barcode / OCR / prescription recognition flow
- Push notification delivery (pending Lucent FCM/APNs)
- Deferred polish: AI session rename/delete, Markdown template upgrade,
  visit-summary templating, symptom-medicine timeline (see `docs/00-current/TODO.md`)
- Contract debt: the four clinic-summary section keys remain required in the
  Lucent contract (client deserializes with placeholders)

Desktop and the full authenticated Web app are intentionally frozen. Their
existing code remains, but feature parity, distribution, and productization are
not roadmap commitments. `Luminous-website` remains the product/competition site.

---

## Directions

Current priorities follow
[ADR-0011](docs/02-reference/adr/0011-event-led-sparse-record-product-loop.md)
and [Product Context](CONTEXT.md); the archived brainstorm remains historical input.

### Current Release → `0.1.0`

Finish integration, verification, and release of the existing runtime.

- Fix only defects that block current integration or release
- Run the full mobile and full-stack release gates
- Keep current-state documentation honest about existing Report and Today behavior

### Product Loop Program

The event-led product-loop program (ADR-0011) is **complete**. Workstream 1
(Review Experience — event-first review, `/report` compatibility, removal of
the composite score, exports moved into More) and Workstream 2 (Visit Summary
and Measurement — revocable field-level-privacy shares, problem-oriented
summary, privacy-minimal product events with the core loop measured separately
from exports, admin funnel) are both shipped and verified. The plan files have
been deleted (实施完毕文件已删); remaining work is tracked in
[`docs/00-current/TODO.md`](docs/00-current/TODO.md) and the P2/P3 sections
below.

### P2 → `1.1.0`

Harden the experience and add high-value features on the stable foundation.

- **Review Validation** — verify that users open event reviews and complete the
  single result question; generic weekly/monthly report usage is not assumed
- **Symptom-Medicine Timeline** — event-scoped evidence view with explicit data
  coverage and no unsupported causal claims
- **Visit Summary Hardening** — optional, problem-oriented export under Review
  > More, with field-level privacy controls and access measurement

### P3 → `1.2.0+`

Extend product capabilities.

- **Red-Flag Rules** — fixed rule table for high-risk symptom patterns (fever,
  allergic reaction, breathing difficulty) with static safety copy
- **Smart Reminder Priority** — context-aware reminder scheduling based on
  recording patterns and confirmation latency (requires Lucent rule extension)
- **Verified Health Bridge** — optional read-only integration only for verified
  devices, regions, services, and developer access; never a core data prerequisite
- **Quick-Entry Widget** — Android home screen + iOS Lock Screen widgets for
  one-tap water logging and medication status
- **Embedded Assistant** — inline AI entry points in Today / Medicine / Review
  instead of standalone-only access

### Scale & Platform → `2.0.0`

Broaden platform reach and prepare for larger scale.

- **Family Profiles** — multi-user household management, dependent care
- **Wearable** — Wear OS / watchOS companion for quick logging
- **Internationalization** — additional locales, timezone-aware scheduling,
  region-specific health guidelines

---

## Versioning

| Version  | Theme                | Status      |
| -------- | -------------------- | ----------- |
| `0.1.0-dev` | Current integration and release preparation | In progress |
| `0.1.0`     | Existing runtime release | Planned     |
| `0.2.0+`    | Event-led sparse-record product loop | Planned     |
| `1.0.0`     | Stable validated product loop | Planned     |
| `1.1.0`     | P2 feature polish    | Planned     |
| `1.2.0`     | P3 feature expansion | Planned     |
| `2.0.0`     | Scale & platform     | Planned     |

Releases follow [Semantic Versioning](https://semver.org/). Each release passes
the full `flutter analyze` + `flutter test` + `dart run scripts/run_daily_checks.dart`
gate before publish.

Current product direction and rationale: see
[Product Vision](docs/01-product/Product_Vision.md),
[MVP Scope](docs/01-product/Product_MVP_Scope.md), and
[Product Context](CONTEXT.md).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) and [AGENTS.md](AGENTS.md) for
development setup, code conventions, and documentation rules.

## Feedback

This roadmap is open to discussion. Open an issue with the `roadmap` label to
propose changes, suggest priorities, or flag missing items.
