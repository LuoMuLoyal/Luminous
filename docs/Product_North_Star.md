# Product North Star

Last updated: 2026-06-07

## Positioning

Luminous is an AI health management and medication-safety companion for college students and young adults in China.

The product does not try to replace doctors, chronic-disease systems, hospital follow-up, or formal psychological diagnosis. Its first stage focuses on common campus and young-adult scenarios: cold and fever medication, late nights, anxiety, irregular diet, menstrual discomfort, sports injury, allergies, alcohol or caffeine intake, and preparing useful summaries for school clinics or counseling services.

Core promise:

> Use medication safety as the foundation, connect daily health records into actionable reminders, self-care suggestions, and explainable reports.

## Primary Platform Strategy

| Platform | Scope |
| --- | --- |
| Mobile app | Primary product. Handles daily recording, reminders, medication safety, AI suggestions, privacy controls, and campus service entry points. |
| Web | Optional lightweight report view. Used for weekly/monthly summaries, export preview, printing, and competition demos. |
| Desktop app | Out of MVP. It does not match fragmented, real-time health recording habits. |
| Watch / speaker / hardware | Future extension only. Do not use them as core proof in the competition version. |

## Bottom Tabs

The mobile product uses five tabs:

| Tab | Role | Core Jobs |
| --- | --- | --- |
| 今日 | Daily health task flow and active suggestion feed | Show today medication, hydration, sleep, mood, diet, menstrual, exercise-recovery, and campus-resource reminders. |
| 记录 | Fast multi-dimensional recording center | Record symptoms, medication, mood, diet, menstrual cycle, hydration, body metrics, sleep, and exercise in one timeline. |
| 用药 | Medication safety core | Search medicines, manage personal medication box, check interaction risks, handle alcohol/caffeine conflicts, and show safety boundaries clearly. |
| 报告 | Health summary and export center | Generate weekly/monthly reports, trend summaries, medication adherence, mood/sleep/diet patterns, and doctor/counselor-friendly summaries. |
| 我的 | Profile, privacy, and service settings | Manage health profile, allergies, current medicines, privacy permissions, campus clinic/counseling resources, notification settings, and account settings. |

Do not use a generic catch-all bottom tab in the north-star architecture. Low-frequency features should be placed under `我的`, entered contextually from `今日`, or deferred to future scope.

## Concept Screens

Long, readable concept screens for the five-tab mobile structure:

| Tab | Concept Image |
| --- | --- |
| 今日 | `docs/assets/product-north-star-tabs-long-v2/tab-1-today-long.png` |
| 记录 | `docs/assets/product-north-star-tabs-long-v2/tab-2-record-long.png` |
| 用药 | `docs/assets/product-north-star-tabs-long-v2/tab-3-medicine-long.png` |
| 报告 | `docs/assets/product-north-star-tabs-long-v2/tab-4-report-long.png` |
| 我的 | `docs/assets/product-north-star-tabs-long-v2/tab-5-mine-long.png` |

## Web Concept Screen

The web concept remains a lightweight report view for weekly summaries, export preview, printing, and competition demos:

| Scope | Concept Image |
| --- | --- |
| Web report view | `docs/assets/product-north-star-web-report-v1.png` |

## MVP Demo Scenarios

1. Cold / fever medication safety
   - User records: "I took ibuprofen and may drink tonight."
   - Luminous explains the risk, keeps a non-diagnostic boundary, and suggests consulting a doctor or pharmacist when needed.

2. Mood and sleep loop
   - User records several anxious days and poor sleep.
   - Luminous shows the trend in `报告`, suggests a short self-care exercise in `今日`, and links to school counseling resources from `我的`.

3. Menstrual cycle plus diet / medication
   - Luminous reminds the user before an expected period, supports symptom and diet records, flags medication cautions, and treats cycle data as sensitive by default.

## Scope Boundaries

MVP includes:

- Mobile-first daily health loop.
- Medication search, medication box, reminders, and explainable safety notices.
- Mood, sleep, diet, hydration, symptom, menstrual, and exercise records as young-adult health context.
- Weekly/monthly reports and export preview.
- Campus clinic, pharmacy, emergency, and psychological support resource entry points.
- Strong privacy controls for psychological and menstrual data.

MVP excludes:

- Elderly family collaboration as a main flow.
- Child medication dosing by weight.
- Skin lesion recognition.
- Full chronic-disease management.
- Smart speaker, watch, and dedicated hardware workflows.
- Complex cancer screening plans or medical-grade diagnostic claims.

## Competition Narrative

Apple Health, Bearable, and Folia are capability benchmarks, not direct China-campus competitors. Domestic products are mostly single-point tools: menstrual tracking, diet tracking, sports tracking, medicine lookup, hospital mini-programs, or device-health dashboards.

Luminous differentiates by using Chinese medication safety as the base layer, then connecting high-frequency young-adult health scenarios into a closed loop:

```text
record -> understand -> remind -> self-intervene -> connect services -> report
```

The first version should prove one complete mobile loop before expanding into more endpoints or older-user family collaboration.
