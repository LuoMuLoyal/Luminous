# AI Chat Write Intent + Record Fast Entry

Last updated: 2026-06-18

## Goal

Drive the next Luminous assistant slice after the current chat foundation:

- consume the expanded Lucent read-tool capability truth
- render backend-provided write proposals as explicit confirmation cards
- prepare the later Record fast-entry UX without mixing it into the first
  backend contract step

## Assumptions

- Lucent remains the single authority for tool availability and proposal shape.
- The current standalone `/assistant` page remains the main interaction surface.
- Existing Record create/edit flows remain the execution path after user
  confirmation at first; do not create a second hidden write path just for AI.
- `note` should be presented as a custom/free record entry instead of adding a
  second parallel record kind.
- Mood should get an IA placeholder later, but it is not the main focus of this
  implementation slice.

## Likely Files

- `lib/features/ai_chat/**`
- `lib/features/record/**`
- `lib/core/network/**`
- `lib/l10n/app_*.arb`
- `test/features/ai_chat/**`
- `test/features/record/**`
- `docs/Next_Plan.md`
- `docs/Current_State.md`

## Phase Breakdown

### Phase A: Assistant Contract Consumption

- update assistant models/client mapping for the expanded capability and
  proposal contract
- localize new tool names and proposal card copy
- keep unsupported/reserved tools clearly marked instead of guessing

Phase A direction correction:

- “历史 AI” in the product means Today/Report historical AI summaries
- assistant recent conversations remain useful for restore/list/open UX, but
  they should not be presented as the user’s historical AI summaries
- cross-conversation assistant memory should be explicit and user-controlled,
  with a settings toggle instead of being implied by persisted chat sessions

### Phase B: Confirmation Cards

- render `proposedActions` under the assistant reply
- support:
  - confirm
  - edit before confirm
  - dismiss/cancel
- route confirmed actions back into existing product write flows

### Phase C: Record Fast Entry

- quick action tap opens a lightweight fast-entry surface first
- common items can be written in one tap after explicit user action
- “more” opens the full create/edit form
- present `note` to users as custom entry
- leave a reserved mood entry point without expanding it into a full workflow

## Validation

- `flutter analyze`
- focused widget tests for proposal cards and confirmation states
- focused widget/tests for Record quick-entry behavior when implemented
- one manual signed-in emulator pass for:
  - assistant proposal rendering
  - user confirmation -> existing write flow
  - cancel/edit-before-confirm

## Expected Observable Outcome

- the assistant can propose concrete actions without silently changing data
- users can understand exactly what the assistant wants to write or modify
- the later Record fast-entry work has a compatible contract instead of needing
  to be redesigned mid-implementation
