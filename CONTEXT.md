# Luminous

Luminous is a personal health copilot centered on trusted medication safety and structured daily health records. This context defines the product terms used for meal-analysis flows so frontend, backend, and AI features use the same language.

## Language

**Meal Record**:
A daily record whose primary subject is one eating occasion, such as breakfast, lunch, dinner, or a snack. It is the parent container for meal analysis, attached images, food items, and nutrition estimate data.
_Avoid_: Food photo, dish entry, nutrition row

**Meal Analysis**:
The asynchronous backend workflow that turns a meal record's attached image into structured meal data. It includes visual description, food-item extraction, food-table matching, nutrition estimation, and meal commentary generation.
_Avoid_: Food RAG, nutrition chat, image OCR

**Food Item**:
One recognized edible item within a meal record, such as rice, egg, or stir-fried vegetables. Food items are the unit matched against the food composition table.
_Avoid_: Ingredient decomposition, raw material unit

**Nutrition Estimate**:
A structured, non-authoritative nutrition summary derived from matched food items and the food composition table. It is explicitly an estimate rather than a user-confirmed fact.
_Avoid_: Exact nutrition, final nutrition fact, diagnosis

**Meal Commentary**:
A short rule-based summary of a meal's estimated nutrition profile, such as protein being relatively sufficient or sodium possibly being high. It is generated from structured estimate data, not directly from free-form model judgment.
_Avoid_: AI opinion, health verdict, diagnosis

**Analysis Status**:
The lifecycle state of a meal analysis result stored on a meal record. The initial planned states are `analyzing`, `unconfirmed`, `confirmed`, and `analysis_failed`.
_Avoid_: Sync save status, upload status

**Confirmed Meal Analysis**:
A meal analysis result that the user has reviewed and accepted, optionally after editing recognized food items or portions. Confirmed analysis is preferred over unconfirmed analysis in longer-horizon summaries.
_Avoid_: Auto-approved result, final diagnosis
