# Assistant Naming Refactor

## Goal

Rename the frontend `ai_chat` feature to `assistant`, align route/service/type
names with the current standalone assistant workspace, and sync the generated
client after the Lucent API rename.

## Non-Goals

- Do not change user-setting storage keys in this refactor.
- Do not mix visual redesign or behavior changes into the naming pass unless
  required to keep the app compiling.

## Mapping Baseline

- `features/ai_chat` -> `features/assistant`
- `AiChatPage` -> `AssistantPage`
- `AiChatController` -> `AssistantController`
- `AiChatState` -> `AssistantState`
- `AiChatSendErrorType` -> `AssistantSendErrorType`
- `AiChatContextPermissions` -> `AssistantContextAccess`
- `LucentAiChatRepository` -> `LucentAssistantRepository`
- openapi-generated `AIChatApi` usage -> generated `AssistantApi` usage if the
  backend rename produces that surface

## Likely Affected Files

- `lib/features/ai_chat/**`
- `lib/app/router.dart`
- `lib/core/network/lucent_network_providers.dart`
- `test/ai_chat/**`
- `docs/Current_State.md`
- `docs/Next_Plan.md`
- `docs/migration-log/2026-06-18.md`
- generated `packages/lucent_openapi/**`

## Validation

- `flutter analyze`
- `flutter test test/assistant/assistant_page_test.dart test/settings/user_settings_controller_test.dart test/settings/settings_page_test.dart`

## Expected Observable Result

- `/assistant` keeps the same product entry but is backed by consistently named
  assistant feature code.
- Frontend source and generated client stop exposing `ai_chat` as the main
  product concept.
