# Luminous Roadmap

This document describes the planned evolution of the Luminous Flutter client. It is a living
document, and directions shift as the product and community grow.

## Status

Luminous is at `0.1.0-dev`. The five-tab mobile experience is functional, but no stable release
has shipped. The product direction was re-baselined around a long-term health companion:
low-burden sparse records, inspectable personal context, coverage-aware daily / weekly / monthly
insights, proactive suggestions, and contextual AI answers. Food, water, sleep, mood, symptoms,
activity, and medicine are peer domains. The event-led loop is implemented and remains a useful
high-intensity mode, but it no longer defines the whole product or its north-star metric. The
five-tab structure is the current runtime; changing it waits on user-value research.

**What works today**

- Five-tab shell: Today / Record / Medicine / Review / Mine
- Authentication: credential login, WeChat OAuth (mobile SDK and desktop browser), Apple Sign-In,
  QQ OAuth, Security PIN, and account deletion via email verification code
- Daily records across water, meal, vital, mood, symptom, activity, note, and sleep, with
  quick-add, calendar navigation, and filtering
- Medicine: current medicines list, safety preview with three-tier risk display (confirmed risk /
  confirmed safe / uncovered-uncertain), dose logs, and reminders backed by local notifications
- AI assistant: SSE streaming chat, proposed actions (create / update / delete records, update
  settings), conversation history, context source controls, and Markdown rendering
- Health events: user-confirmed start and end, per-day check-ins, related symptoms / medicines /
  records, and an improved / unchanged / worsened result
- Review tab: event-first review with four sections (what happened / key changes / completed
  actions / next step), history filtering, and a More actions entry for visit summary, PDF, and
  print exports. The older dashboard stays reachable as a compatibility page
- Visit summary: field-level privacy selection (free-text notes off by default), revocable
  seven-day shares storing only a token hash, share management (access count / revocation), and a
  public share page
- Closed-loop measurement: client-reported success-boundary events (suggestion impression, review
  opened, visit summary previewed and exported) on an offline queue with idempotent retry,
  server-authoritative lifecycle events, and an admin-only funnel endpoint that separates the core
  loop from optional exports and suppresses small samples
- Settings: theme (mode and family), locale, accessibility, notifications, data storage, AI
  context, security PIN, and debug-only developer options
- Design system: Forui-based, full zh / en i18n with ARB fragment splitting, shimmer skeletons,
  responsive layout (mobile bottom nav and desktop sidebar), and a semantic colour system
- Offline support: Drift local database with cache-first repositories, `SyncWorker` replay with
  exponential backoff, a pending-sync queue, data-retention cleanup, and Web (WASM SQLite) support
- Error reporting: Sentry integration with a Talker bridge, plus `runZonedGuarded` and
  `FlutterError.onError` crash capture
- Testing: unit and widget tests, integration tests under `integration_test/`, golden tests
  (skipped in CI)
- Legal compliance: in-app document browser (terms / privacy / disclaimer / minor-protection /
  sdk-list / permissions / account-cancellation) with remote-first loading and an asset fallback

Capability-level state, constraints, and invariants live with the code: each feature's
`README.md` states what that feature owns and what it guarantees, and the tests carry the
behavioural assertions.

**What's missing**

- Stable release: still in development
- Proactive coverage for ordinary food, water, sleep, and mood records. These already reach
  context, but they do not yet consistently trigger bounded analysis, and the coverage-aware
  daily / weekly / monthly insight contract is still unwritten
- Deferred polish: assistant session rename and delete, Markdown template upgrade, visit-summary
  templating, and the symptom-medicine timeline
- The legacy report surfaces. Generic AI summaries and composite-style trends persist only on a
  compatibility page pending deletion; data export and suggestion history are real. New
  longitudinal insights must use explicit sources and coverage rather than the legacy report
  semantics

The Flutter desktop and authenticated Web surfaces are frozen for the current release. They are
not treated as permanently discarded product directions either. A separate study has to validate
the large-screen job first (reading and comparing longitudinal health information that is awkward
to inspect on a phone) and the Next.js + Tauri 2 candidate route. Feature parity, distribution,
and productization are not commitments for this release. `Luminous-website` remains the
product/competition site.

---

## Directions

Current priorities follow [Product Vision](docs/product/product-vision.md) and
[MVP Scope](docs/product/product-mvp-scope.md).
[ADR-0007](docs/reference/adr/0007-event-led-sparse-record-product-loop.md) is retained as the
superseded historical decision for the already implemented event-loop program.

### Current Release → `0.1.0`

Finish integration, verification, and release of the existing runtime.

- Fix only the defects that block current integration or release
- Run the full mobile and full-stack release gates
- Keep the Review and Today surfaces consistent with their feature documentation

### Completed Event-Loop Program

The former event-led product-loop program (ADR-0007) is **complete**. Workstream 1 (Review
Experience: event-first review, the legacy compatibility route, removal of the composite score,
exports moved into More) and Workstream 2 (Visit Summary and Measurement: revocable
field-level-privacy shares, problem-oriented summary, privacy-minimal product events with the
core loop measured separately from exports, admin funnel) are both shipped and verified. The
plan files have been deleted (实施完毕文件已删); remaining work is tracked in
[`docs/TODO.md`](docs/TODO.md) and the P2/P3 sections below. Completing this program is an
implementation fact, not evidence that users want an event-centred product.

### User-Value Validation

Before changing the five tabs or committing to desktop/Web productization, validate six questions
with real users: low-burden input choice, minimum useful fields, helpful versus annoying proactive
advice, contextual AI versus a generic model, value during non-sick weeks, and trust in
cross-day/month data access. The research material prepared so far, including its adversarial
review of tab-restructuring proposals, is in
[`research/01-用户价值调研/record-review-assistant-纵向洞察归属与Tab验证.md`](research/01-用户价值调研/record-review-assistant-纵向洞察归属与Tab验证.md).
That document is input and a hypothesis list, not a decision: the long-term responsibility and
naming of the five tabs, whether the assistant becomes a top-level entry point, and how
longitudinal insight is carried all wait on this validation.

### P2 → Long-Term Companion Core

Build only the capabilities required to test the companion hypothesis on the stable foundation.

- **Low-Burden Inputs**: compare photo, natural language, one-tap, and verified passive sources
  per domain; do not require one universal input method
- **Coverage-Aware Insight Contract**: daily / weekly / monthly facts, source coverage, limited
  patterns, and an explicit abstain state; no composite score or generic AI report
- **Proactive Companion Triggering**: allow ordinary lifestyle records to trigger bounded
  analysis when evidence and action value are sufficient
- **Health Context and Memory Controls**: separate chat memory from health memory and make cited
  records inspectable, correctable, revocable, and deletable
- **Contextual AI Evaluation**: blind-test structured personal context against no context and
  user-written background before claiming differentiation

### P3 → Adaptive Companion and Platform Research

Extend product capabilities.

- **Suggestion Adaptation**: calibrate timing, frequency, suppression, and feedback through
  controlled experiments; do not optimize only for clicks
- **Red-Flag Rules**: fixed, reviewed rules for high-risk symptom patterns with static safety
  copy and professional-help boundaries
- **Smart Reminder Priority**: context-aware reminder scheduling based on recording patterns and
  confirmation latency (requires Lucent rule extension)
- **Verified Health Bridge**: optional read-only integration only for verified devices, regions,
  services, and developer access; never a core data prerequisite
- **Quick-Entry Widget**: Android home screen and iOS Lock Screen widgets for one-tap water
  logging and medication status
- **Embedded Assistant**: inline AI entry points in Today / Medicine / Review instead of
  standalone-only access
- **Large-Screen Job Study**: validate whether users open Web/desktop to read and compare
  longitudinal information that is awkward to inspect on a phone; Next.js + Tauri 2 remains a
  candidate, not a committed architecture

### Scale & Platform → `2.0.0`

Broaden platform reach and prepare for larger scale.

- **Family Profiles**: multi-user household management, dependent care
- **Wearable**: Wear OS / watchOS companion for quick logging
- **Internationalization**: additional locales, timezone-aware scheduling, region-specific
  health guidelines

---

## Versioning

| Version     | Theme                                       | Status      |
| ----------- | ------------------------------------------- | ----------- |
| `0.1.0-dev` | Current integration and release preparation | In progress |
| `0.1.0`     | Existing runtime release                    | Planned     |
| `0.2.0+`    | Long-term companion core experiments        | Candidate   |
| `1.0.0`     | Stable, user-validated companion loop       | Candidate   |
| `1.1.0`     | Evidence-led refinement                     | Candidate   |
| `1.2.0`     | Adaptive companion / platform expansion     | Candidate   |
| `2.0.0`     | Scale & platform                            | Planned     |

Releases follow [Semantic Versioning](https://semver.org/). Each release passes the full
`flutter analyze` + `flutter test` + `dart run scripts/workflows/daily.dart` gate before publish.

Current product direction and rationale: see
[Product Vision](docs/product/product-vision.md),
[MVP Scope](docs/product/product-mvp-scope.md), and
[Safety & Privacy](docs/product/product-safety-privacy.md).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) and [AGENTS.md](AGENTS.md) for development setup, code
conventions, and documentation rules.

## Feedback

This roadmap is open to discussion. Open an issue with the `roadmap` label to propose changes,
suggest priorities, or flag missing items.
