# Luminous Roadmap

This document describes the planned evolution of the Luminous Flutter client.
It is a living document — directions shift as the product and community grow.

## Status

Luminous is currently at `0.1.0-dev`. The core mobile experience is functional
with all five tabs active, but the project has not yet shipped a stable release.
The product direction has been re-baselined around a long-term health companion:
low-burden sparse records, inspectable personal context, coverage-aware daily /
weekly / monthly insights, proactive suggestions, and contextual AI answers.
Food, water, sleep, mood, symptoms, activity, and medicine are peer domains.
The previously planned event-led loop is implemented and remains a useful
high-intensity mode, but it no longer defines the whole product or its north-star
metric. The five-tab structure remains the current runtime and will be discussed
separately after user-value research.

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
- Legacy reports: generic AI summaries and composite-style trends remain only
  on a compatibility surface pending deletion; data export and suggestion
  history are real. New longitudinal insights must use explicit sources and
  coverage rather than reuse the legacy report semantics.
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
  visit-summary templating, symptom-medicine timeline (see `docs/TODO.md`)
- Long-term companion gap: ordinary food, water, sleep, and mood records can
  enter context but do not yet consistently trigger proactive analysis; a new
  coverage-aware daily / weekly / monthly insight contract is still required

The existing Flutter desktop and authenticated Web surfaces remain frozen for
the current release, but desktop/Web are no longer treated as permanently
discarded product directions. A separate study must first validate the large-
screen job (reading and comparing longitudinal health information that is hard
to inspect on mobile) and the Next.js + Tauri 2 candidate route. Feature parity,
distribution, and productization are not current release commitments.
`Luminous-website` remains the product/competition site.

---

## Directions

Current priorities follow
[Product Vision](docs/product/Product_Vision.md) and
[Product Context](CONTEXT.md). [ADR-0007](docs/reference/adr/0007-event-led-sparse-record-product-loop.md)
is retained as the superseded historical decision for the already implemented
event-loop program.

### Current Release → `0.1.0`

Finish integration, verification, and release of the existing runtime.

- Fix only defects that block current integration or release
- Run the full mobile and full-stack release gates
- Keep current-state documentation honest about existing Report and Today behavior

### Completed Event-Loop Program

The former event-led product-loop program (ADR-0011) is **complete**. Workstream 1
(Review Experience — event-first review, `/report` compatibility, removal of
the composite score, exports moved into More) and Workstream 2 (Visit Summary
and Measurement — revocable field-level-privacy shares, problem-oriented
summary, privacy-minimal product events with the core loop measured separately
from exports, admin funnel) are both shipped and verified. The plan files have
been deleted (实施完毕文件已删); remaining work is tracked in
[`docs/TODO.md`](docs/TODO.md) and the P2/P3 sections
below. Completion of this program is an implementation fact, not evidence that
users want an event-centred product.

### User-Value Validation

Before changing the five tabs or committing to desktop/Web productization,
validate six questions with real users: low-burden input choice, minimum useful
fields, helpful versus annoying proactive advice, contextual AI versus a generic
model, value during non-sick weeks, and trust in cross-day/month data access.
Use the study design in
[`research/00-市场调研/05-长期健康伙伴用户价值验证.md`](research/00-市场调研/05-长期健康伙伴用户价值验证.md).

### P2 → Long-Term Companion Core

Build only the capabilities required to test the companion hypothesis on the
stable foundation.

- **Low-Burden Inputs** — compare photo, natural language, one-tap, and verified
  passive sources per domain; do not require one universal input method
- **Coverage-Aware Insight Contract** — daily / weekly / monthly facts, source
  coverage, limited patterns, and an explicit abstain state; no composite score
  or generic AI report
- **Proactive Companion Triggering** — allow ordinary lifestyle records to
  trigger bounded analysis when evidence and action value are sufficient
- **Health Context and Memory Controls** — separate chat memory from health
  memory and make cited records inspectable, correctable, revocable, and deletable
- **Contextual AI Evaluation** — blind-test structured personal context against
  no context and user-written background before claiming differentiation

### P3 → Adaptive Companion and Platform Research

Extend product capabilities.

- **Suggestion Adaptation** — calibrate timing, frequency, suppression, and
  feedback through controlled experiments; do not optimize only for clicks
- **Red-Flag Rules** — fixed, reviewed rules for high-risk symptom patterns with
  static safety copy and professional-help boundaries
- **Smart Reminder Priority** — context-aware reminder scheduling based on
  recording patterns and confirmation latency (requires Lucent rule extension)
- **Verified Health Bridge** — optional read-only integration only for verified
  devices, regions, services, and developer access; never a core data prerequisite
- **Quick-Entry Widget** — Android home screen + iOS Lock Screen widgets for
  one-tap water logging and medication status
- **Embedded Assistant** — inline AI entry points in Today / Medicine / Review
  instead of standalone-only access
- **Large-Screen Job Study** — validate whether users open Web/desktop to read
  and compare longitudinal information that is hard to inspect on mobile;
  Next.js + Tauri 2 remains a candidate, not a committed architecture

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
| `0.2.0+`    | Long-term companion core experiments | Candidate |
| `1.0.0`     | Stable, user-validated companion loop | Candidate |
| `1.1.0`     | Evidence-led refinement | Candidate |
| `1.2.0`     | Adaptive companion / platform expansion | Candidate |
| `2.0.0`     | Scale & platform     | Planned     |

Releases follow [Semantic Versioning](https://semver.org/). Each release passes
the full `flutter analyze` + `flutter test` + `dart run scripts/run_daily_checks.dart`
gate before publish.

Current product direction and rationale: see
[Product Vision](docs/product/Product_Vision.md),
[MVP Scope](docs/product/Product_MVP_Scope.md), and
[Product Context](CONTEXT.md).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) and [AGENTS.md](AGENTS.md) for
development setup, code conventions, and documentation rules.

## Feedback

This roadmap is open to discussion. Open an issue with the `roadmap` label to
propose changes, suggest priorities, or flag missing items.
