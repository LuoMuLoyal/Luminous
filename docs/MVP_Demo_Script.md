# Luminous MVP Demo Script

Last updated: 2026-06-17

This file is a short operator script for demo and defense use only. It does not define product scope; use `Product_Vision.md`, `Current_State.md`, and `Next_Plan.md` for source-of-truth product rules.

For pre-demo deploy/runtime checks and demo-account baseline, use `MVP_Demo_Baseline.md` first.

## Demo Goal

Show one trustworthy mobile MVP loop:

1. record a real daily fact
2. let Today/Medicine interpret that fact within a bounded safety scope
3. generate a usable report/export artifact

Do not rely on deferred capabilities such as OCR, voice, dynamic nearby-care lookup, or broad AI medical judgment.

## Recommended Path

### 1. Login and baseline

- Open the mobile app and sign in with the prepared demo account.
- Land on the five-tab shell: `today / record / medicine / report / mine`.
- Say explicitly:
  - mobile is the current product surface
  - web and campus-resource completeness are not part of the current MVP promise

### 2. Record one concrete health fact

- Go to `Record`.
- Add one or two simple entries that are easy to explain, for example:
  - water
  - symptom
  - sleep
- If showing NLP intake:
  - enter one short natural-language note
  - confirm candidate records before saving
- Say explicitly:
  - AI can propose structured candidates
  - candidates are user-confirmed before entering the final record timeline

### 3. Show Today summary as bounded interpretation

- Go to `Today`.
- Trigger or reveal the Today AI summary card.
- Explain that:
  - the summary only uses recorded/authorized data
  - it gives low-risk guidance, not diagnosis
  - streaming output is supported, but the final card still resolves to a bounded structured result

### 4. Show Medicine as the safety entry

- Go to `Medicine`.
- Open the quick safety check or the full risk-check page.
- Highlight:
  - findings
  - coverage summary
  - explicit unknown/unchecked boundary when source detail is missing
- Then open `Search`, add one medicine, and show the pre-add risk precheck sheet if findings or coverage gaps exist.
- Say explicitly:
  - this is a bounded rule-backed safety explanation layer
  - it does not claim broad cross-source normalization
  - it does not let AI make freeform medical decisions

### 5. Show Report and export

- Go to `Report`.
- Show:
  - real dashboard content
  - AI summary generation
  - PDF export entry
- Use one real export path during demo:
  - `给校医院 / hospital + pdf + last_7_days`
- If showing `monthly` or `print`, describe them as existing real PDF flows, but keep the narrative focused on the already rehearsed export path.

### 6. Close on boundary, not hype

- End with:
  - Luminous is a proactive campus health assistant, not an AI doctor
  - medication safety is the trusted entry, not the whole ceiling
  - the current MVP proves: record -> summarize -> bounded safety check -> export/shareable artifact

## Do Not Say

- Do not say the app can diagnose diseases.
- Do not say the app can automatically adjust medication timing or dosage.
- Do not say campus/help resources are universally complete for every school.
- Do not imply OCR, barcode, voice, screenshot intake, or nearby-care map discovery are already part of this MVP.
- Do not present unchecked medicine coverage as “safe”.

## Demo Prep Checklist

- `powershell -ExecutionPolicy Bypass -File tool/run_daily_checks.ps1`
- `powershell -ExecutionPolicy Bypass -File tool/run_fullstack_checks.ps1`
- Confirm one demo account can:
  - sign in
  - create at least one record
  - open Medicine risk check
  - trigger one search precheck path
  - generate Today/Report AI summaries
  - request one PDF export successfully
