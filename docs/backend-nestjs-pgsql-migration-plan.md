---
title: "Lucent Backend Migration Summary"
tags:
  - strategy
  - backend
aliases:
  - 后端迁移
  - Lucent迁移
created: 2026-05-25
---

# Lucent Backend Migration Summary

Last updated: 2026-05-25

This file is the Luminous-side coordination note. Backend-specific details now live in the Lucent submodule:

- `Lucent/docs/api-contract.md`: `/api/v1`, response envelope, errors, headers, and JWT identity.
- `Lucent/docs/data-sources.md`: `DrugDataBase` import boundaries.
- `Lucent/docs/migration-roadmap.md`: backend buildout phases and validation gates.

## Decisions

- Target backend: `Lucent/` Git submodule.
- Deprecated backend: `backend/` Express service, kept only as low-priority reference and current `https://devluo.com` legacy baseline.
- Target stack: NestJS + PostgreSQL + Prisma + Redis + Passport JWT.
- API base: versioned routes under `/api/v1`.
- Auth boundary: protected APIs derive user identity from JWT; request-body `userId` is not trusted.
- Data source: `D:\25080\Documents\VSCodeProject\Lumos\DrugDataBase`.

## Response Envelope

Lucent uses a light default envelope:

```json
{
  "code": "OK",
  "message": "",
  "data": {}
}
```

Errors use the same shape with `data: null`.

`meta` appears only when needed, primarily pagination:

```json
{
  "code": "OK",
  "message": "",
  "data": [],
  "meta": {
    "pagination": {
      "page": 1,
      "pageSize": 20,
      "total": 0,
      "totalPages": 0
    }
  }
}
```

`timestamp` stays in server logs by default. `requestId` is returned as the `X-Request-Id` header and logged server-side; clients do not parse it during normal flows.

## Luminous Responsibilities

- Keep Flutter on the legacy Express API until Lucent reaches a stable `/api/v1` contract.
- Add a new Lucent API client layer when switching away from `https://devluo.com`.
- Stop sending `userId` for Lucent protected resources.
- Render structured sections and Markdown returned by Lucent for medicine detail and copilot output.
- Keep `DrugDataBase` out of Git and Flutter assets.

## Legacy Express Role

`backend/` remains useful for:

- Understanding existing behavior.
- Temporary online checks against `https://devluo.com`.
- Data migration source mapping from MongoDB/MySQL.

It is not the place for new backend features.
