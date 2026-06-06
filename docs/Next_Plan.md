# Lumos Next Plan

Last updated: 2026-06-06

## Current Goal

Move from a stable five-tab baseline into real daily health loops without presenting mock features as real.

## Next Useful Work

1. Build the Luminous image upload flow for daily records using Lucent's Tencent COS presigned upload endpoint.
2. Implement local notification scheduling using the reminder contract, keeping push delivery out of scope.
3. Implement Lucent environment snapshot static reference data and wire More to the real endpoint.
4. Expand daily-record detail UX after the image upload flow is stable.
5. Keep auth/account deferred TODOs explicit until product/security decisions are made.

## Active Planning References

- `docs/superpowers/plans/2026-06-06-thirty-day-lumos-deepseek-plan.md`
- `docs/superpowers/plans/next-month-backlog.md`
- `../Lucent/docs/public/ROADMAP.md`
- `../Lucent/docs/public/reminder-contract.md`
- `../Lucent/docs/public/environment-contract.md`

## Do Not Start Yet

- Real push delivery through FCM/APNs.
- OCR/barcode scanning.
- Family profiles.
- Smart device registry.
- Watch companion app.
- Paid or credentialed external services without explicit approval.
