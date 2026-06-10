# Luminous Next Plan

Last updated: 2026-06-10

This file records the next implementation order only. Completed work belongs in `MigrationLog.md`; current facts belong in `Current_State.md`.

## Current Goal

Use the Product_Vision-converged five-tab mobile UI as the baseline, then move into real daily health loops without presenting mock or deferred features as real capability.

## Immediate Work Order

1. **Record form maintenance**
   - Keep selected-date reload, filter mapping, quick-action routing, attachment handling, detail cache invalidation, and timeline time display under regression.
   - Refine type-specific forms only when the Lucent contract exists for that record type.

2. **Report data contract**
   - Keep current Report visuals mock/static until Lucent exposes report/insight/export contracts.
   - Complex charts remain placeholders until the data shape is stable.

3. **Mine and Settings contracts**
   - Wire campus services, privacy permissions, reminder preferences, data export, help, and about only after backend/source contracts exist.

## Deferred But Useful

Keep these code paths hidden and annotated until the matching product/API job is ready:

- After the five-tab UI stabilizes, run a focused truncation pass for English and Chinese button labels, pills, and compact rows across Today, Record, Medicine, Report, and Mine.
- Sleep entry shapes.
- Lightweight mood record shapes.
- Environment signals for contextual Today/Mine use.
- Medicine scan/OCR/photo/barcode/prescription action shapes.

Pregnancy/lactation/special-group medication safety remains active only inside Medicine safety boundaries.

## Do Not Start Yet

- Standalone More tab or generic utility hub.
- Women-health or period management.
- Sport recovery.
- Specialist health packs.
- Smart devices or family profiles.
- Skin recognition or report photo import.
- OCR/barcode/photo/prescription recognition UI or contracts.
- Real push delivery through FCM/APNs.
- Real SMS delivery.
- Backend reminder delivery workers.
- Paid or credentialed external services without explicit approval.
- Environment frontend wiring until the target Today/Mine job is explicit.

## Contract References

- Workspace path `Lucent/docs/public/reminder-contract.md`: reminder boundary.
- Workspace path `Lucent/docs/public/environment-contract.md`: environment snapshot boundary.
- Workspace path `Lucent/docs/public/data-sources.md`: medicine data-source/import strategy.
