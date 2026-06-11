# Today AI Analysis Plan

Last updated: 2026-06-11

## Goal

Implement the first real AI-backed user-facing capability for Luminous:

- Today page manual action: `生成今日分析`
- authenticated user only
- backend owns data aggregation, prompting, model call, and output validation
- frontend renders structured AI output instead of today's static placeholder bullets

This slice is intentionally narrower than "AI everywhere".

It does **not** include:

- scheduled proactive AI notifications
- autonomous AI-triggered writes into health records
- weekly/monthly AI summaries
- screenshot OCR / vision import
- medication risk judgment delegated to the model

## Product Decision

Do AI now, but start with **user-triggered Today analysis**, not background proactive advice.

Reason:

- the product's core differentiation is record interpretation and summary, not another raw input form
- Today already has an AI summary surface and a privacy toggle, so there is a clean user-visible landing point
- manual trigger is much lower risk than scheduled AI pushes
- this slice exercises the real AI boundary without immediately introducing job scheduling, notification spam control, or human-trust problems

## Technical Decision

### Use LangChain, not direct OpenAI SDK

For phase 1, use the modern package-split LangChain JS stack inside Lucent:

- `@langchain/openai@1.4.7`
- `@langchain/core@1.1.48`
- `zod@4.4.3`

Do **not** add the direct `openai` SDK for this slice.

Reason:

- the repo already has generic AI env variables (`AI_PROVIDER`, `AI_API_KEY`, `AI_BASE_URL`, `AI_TEXT_MODEL`)
- this slice needs prompt composition plus structured output validation more than raw transport control
- LangChain gives model abstraction plus structured output helpers without forcing a graph runtime too early

### Do not use LangGraph yet

Do **not** add `@langchain/langgraph` in phase 1.

Reason:

- Today analysis is a mostly linear flow:
  1. collect factual signals
  2. compress into prompt input
  3. call one model
  4. validate structured output
  5. return result
- there is no multi-agent workflow, branching state machine, human-in-the-loop checkpoint, or durable execution requirement yet
- introducing graph orchestration now would add shape and concepts before the workflow actually needs them

Re-evaluate LangGraph only when at least one of these becomes real:

- multi-step AI pipelines with retries and branching
- scheduled analysis jobs with resumable state
- screenshot import with OCR/vision -> parse -> verify -> candidate-write flow
- user review checkpoints across several AI steps

## Current Repo Leverage

The repo already has several useful prerequisites:

### Luminous

- Today page already has an AI summary card placeholder and `生成` button
- Settings already exposes `aiSummariesEnabled`
- Today data already merges health-context, daily-record summary, reminders, and dose logs on the client side

### Lucent

- env validation already includes:
  - `AI_PROVIDER`
  - `AI_API_KEY`
  - `AI_BASE_URL`
  - `AI_TEXT_MODEL`
  - `AI_VISION_MODEL`
- user settings contract already includes `aiSummariesEnabled`

This means phase 1 should not start by inventing a broad AI platform. It should wire one concrete Today use case through the existing config/settings seams.

## Scope Boundary

### In Scope

- one authenticated backend endpoint for Today AI analysis
- one structured AI response shape
- one frontend provider + UI state for manual generation
- one policy boundary for safe, low-risk, non-diagnostic summaries

### Out of Scope

- persistence of AI summaries in database
- weekly/monthly report AI
- screenshot vision input
- multilingual free-form prompt authoring UI
- autonomous recommendation notifications
- medication risk inference without source-backed rules

## Backend Design

## Module Shape

Keep it small and direct.

Recommended Lucent feature module:

```text
src/modules/today-analysis/
```

Suggested files:

```text
today-analysis.module.ts
today-analysis.controller.ts
today-analysis.service.ts
today-analysis-context.service.ts
dto/generate-today-analysis.dto.ts
dto/today-analysis-response.dto.ts
dto/today-analysis-item.dto.ts
schemas/today-analysis.schema.ts
prompts/today-analysis.prompt.ts
```

Do **not** create a generic workflow engine or a generic "all AI use cases" abstraction in phase 1.

## Endpoint

Recommended endpoint:

```text
POST /api/v1/user/today-analysis/generate
```

Protected by JWT.

Request body:

```json
{
  "date": "2026-06-11"
}
```

Notes:

- `date` should be optional and default to "today" on the backend
- keeping `date` in the contract helps deterministic tests

Response shape:

```json
{
  "code": 0,
  "message": "",
  "data": {
    "date": "2026-06-11",
    "generatedAt": "2026-06-11T10:23:45.000Z",
    "summary": "今日记录主要集中在饮水和用药，仍有一项待确认。",
    "bullets": [
      {
        "kind": "medication",
        "text": "还有 1 项今日用药待确认，先核对是否已经服用。"
      },
      {
        "kind": "hydration",
        "text": "今日饮水仍未达目标，建议下午和晚间各补 1 次。"
      },
      {
        "kind": "sleep",
        "text": "今天还没有睡眠数据，今晚记录后总结会更完整。"
      }
    ],
    "actionLabel": "查看今日记录",
    "confidenceNote": "仅基于今日已记录数据生成，不构成诊断或治疗建议。"
  }
}
```

## Backend Data Aggregation

The model should not receive raw repository dumps if rule-compressed facts are available.

Build a compact server-side context with:

- target date
- water:
  - completed count
  - target count
  - remaining count
- medication:
  - medicine count
  - pending count
  - next dose time
  - next medicine display name
- daily record summary by kind
- top recent today records:
  - max 8 items
  - fields limited to `kind`, `title`, `value`, `unit`, `note`, `occurredAt`
  - trimmed text lengths
- current medicine names:
  - max 5
- optional health-context flags only when they are directly useful and low risk:
  - active allergy count
  - current medicine count

Do **not** send:

- full profile blobs
- attachments/images
- long free-form notes without truncation
- historical multi-day records in phase 1

## Model Invocation Strategy

Use LangChain structured output with Zod schema.

High-level flow:

1. aggregate factual Today context
2. create compact prompt input JSON
3. invoke chat model through `@langchain/openai`
4. parse structured output through Zod
5. run final post-validation:
   - max lengths
   - bullet count
   - allowed kinds
   - no empty text
6. return normalized DTO

Recommended runtime constraints:

- timeout around 10 seconds
- 1 model call only
- no tools
- no memory
- no retrieval step in phase 1

## Prompt Design

### System Prompt

Use a fixed server-owned system prompt, not frontend-authored text.

Suggested direction:

```text
You are generating a low-risk daily health summary for a university student.

Use only the supplied JSON facts.
Do not invent missing data.
Do not diagnose diseases.
Do not recommend starting, stopping, increasing, or decreasing medicine doses.
Do not present medication risk judgments unless they are explicitly present in the provided facts.
Prefer concrete, low-risk self-management suggestions such as hydration, rest, logging, and checking whether a planned dose was already taken.
If data is missing, say that the summary is limited by missing records.
Return only structured output that matches the schema.
```

### User Prompt Payload

Send a compact JSON payload, for example:

```json
{
  "date": "2026-06-11",
  "water": {
    "completedCount": 4,
    "targetCount": 8,
    "remainingCount": 4
  },
  "medication": {
    "medicineCount": 2,
    "pendingCount": 1,
    "nextDoseTimeLabel": "20:00",
    "nextMedicineName": "维生素B族"
  },
  "recordSummary": [
    { "kind": "water", "count": 4 },
    { "kind": "meal", "count": 2 },
    { "kind": "symptom", "count": 1 }
  ],
  "recentRecords": [
    {
      "kind": "symptom",
      "title": "头痛",
      "note": "下午开始",
      "occurredAt": "2026-06-11"
    }
  ]
}
```

### Structured Output Schema

Use a strict Zod schema similar to:

```ts
z.object({
  summary: z.string().min(1).max(120),
  bullets: z.array(
    z.object({
      kind: z.enum(["medication", "hydration", "sleep", "general"]),
      text: z.string().min(1).max(80),
    }),
  ).min(2).max(3),
  actionLabel: z.string().min(1).max(24),
  confidenceNote: z.string().min(1).max(80),
})
```

Post-validation should still run after model parsing.

## Safety Rules

The backend must reject or rewrite unsafe output before it reaches the client.

Disallow outputs that:

- diagnose a disease
- instruct dosage change
- tell the user to stop medication
- claim certainty from missing data
- mention unsupported risk mechanisms not present in source-backed facts

If output parsing or policy validation fails:

- return a controlled fallback summary
- do not leak raw model text to the client

Fallback can be rule-based and deterministic.

## Frontend Design

## Data Flow

Luminous should add a dedicated provider for Today AI generation, separate from the existing `todayDashboardProvider`.

Recommended shape:

```text
lib/features/today/presentation/providers/today_ai_analysis_provider.dart
lib/features/today/data/datasources/today_ai_remote_data_source.dart
lib/features/today/domain/entities/today_ai_analysis.dart
```

Phase 1 behavior:

- Today page loads as usual from `todayDashboardProvider`
- AI card starts in placeholder or idle state
- tapping `生成`:
  - checks auth
  - checks `aiSummariesEnabled`
  - calls backend endpoint
  - replaces placeholder bullets with generated content

Do not block the rest of Today page on AI call failure.

## UI State Rules

States needed:

- `idle`
- `loading`
- `success`
- `error`
- `disabled-by-user-setting`

If `aiSummariesEnabled == false`:

- disable generate action or route to settings hint
- backend must still enforce the setting

## Minimal UI Changes

Keep the current Today AI card shape.

Phase 1 UI changes should be limited to:

- button loading state
- real generated summary + bullets
- controlled fallback/error text

Do not redesign the whole Today page as part of AI wiring.

## Dependency Plan

### Lucent

Add:

- `@langchain/openai@1.4.7`
- `@langchain/core@1.1.48`
- `zod@4.4.3`

Do not add:

- `@langchain/langgraph`
- direct `openai` SDK
- vector DB / retrieval stack
- OCR / vision dependencies

### Luminous

Phase 1 should not need new production dependencies.

Use existing:

- `dio`
- `riverpod`
- generated OpenAPI client after Lucent contract export

## Environment / Configuration

Lucent already has the right env keys for phase 1:

- `AI_PROVIDER`
- `AI_API_KEY`
- `AI_BASE_URL`
- `AI_TEXT_MODEL`

Implementation should:

- support `AI_PROVIDER=openai`
- fail fast when AI is requested but provider/model/key are missing
- keep model selection behind env, not hardcoded in controller code

Do not hardcode a provider-specific model name in source.

## Verification Plan

### Lucent

- unit test prompt-input builder
- unit test structured output validator
- unit test fallback behavior when model output is invalid
- controller test:
  - authenticated success
  - signed-out unauthorized
  - `aiSummariesEnabled=false` rejected
  - provider misconfigured -> controlled 5xx or domain error

Recommended commands:

```bash
cd Lucent
pnpm lint:check
pnpm build
pnpm test:ci
pnpm export:openapi
```

### Luminous

- provider test for idle/loading/success/error
- widget test for Today AI card state transitions
- existing Today page tests stay green

Recommended commands:

```bash
cd Luminous
flutter analyze
flutter test
```

## Milestones

### Phase 1 - Contract and backend skeleton

- add Lucent Today AI endpoint
- add DTO/schema/prompt scaffolding
- wire LangChain runtime and config validation

### Phase 2 - Safe generation path

- implement factual Today context builder
- implement model call + structured parsing
- implement policy validation + fallback

### Phase 3 - Frontend wiring

- add Luminous entity/provider/data source
- replace Today AI placeholder button behavior with real API call
- keep page-local nonblocking loading/error UX

### Phase 4 - Verification and docs

- backend tests
- frontend tests
- OpenAPI export + Luminous client regeneration
- update `docs/Current_State.md`, `docs/Next_Plan.md`, and migration log after implementation

## Follow-Up After Phase 1

After Today AI analysis is stable, the next AI slices should be:

1. weekly/monthly summary based on backend-computed aggregates
2. natural language -> candidate records
3. screenshot -> candidate structured input

Only revisit scheduled proactive AI advice after the manual analysis path proves stable and useful.
