# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability, please **do not** open a public issue.

Send a private report to **luomuloyal@outlook.com** with:

- A description of the vulnerability and its potential impact
- Steps to reproduce or a proof-of-concept
- Affected version / commit

We aim to acknowledge reports within **48 hours** and deliver a fix or
mitigation within **7 days** for high-severity issues.

## Scope

The following are in scope:

- Authentication / authorization bypass (credential login, WeChat / Apple OAuth,
  Security PIN elevation flows)
- Sensitive data exposure (PII, health records, OAuth tokens, session data,
  locally stored credentials)
- Insecure local storage of tokens or user data
- Deep-link / URL-scheme injection vectors
- SSRF or XSS via user-generated content (daily record notes, assistant chat
  messages, OCR / vision pipeline output)
- Rate-limiting or abuse vectors on AI assistant endpoints

The following are **out of scope**:

- Self-hosted misconfiguration (unless it stems from a code defect)
- Social engineering
- Physical attacks
- DoS without a demonstrated code-level vector
- Vulnerabilities in the Lucent backend (report those in the
  [Lucent](https://github.com/LuoMuLoyal/Lucent) repository)

## Supported Versions

Only the latest release line receives security fixes. Pre-release versions
(`*-dev`) are not supported.

| Version | Supported |
| ------- | --------- |
| latest  | ✅        |
| `*-dev` | ❌        |

## Security Features

Luminous implements the following security measures:

- Token storage prefers secure storage (`flutter_secure_storage`) with
  desktop/web fallback
- WeChat OAuth desktop login verifies the returned `state` parameter before
  completing login
- Security PIN with biometric elevation for sensitive in-app operations
- No hardcoded API keys, OAuth secrets, or credentials in source code
- Compile-time environment variables for sensitive configuration (`--dart-define`)
- AI assistant proposals require explicit user confirmation before writing data
- User-controlled assistant memory and context source toggles
- Coverage-aware display: missing data is rendered as unknown rather than zero, and thin
  evidence produces an abstention state instead of a weaker claim
- Safety conclusions are never authored by the model — drug risk and red-flag content come
  from rules, leaflets or curated data, and the client renders the model's explanation only
- Field-level authorisation on visit summaries, with free-text notes off by default; the
  preview, exported PDF and public share page all read the same filtered view
- Share links are revocable, expire, store only a token hash, and expose an access count
- Provenance is shown per assertion, so a displayed conclusion can be traced back to its
  source rather than trusted as narration
- Client-side analytics events are a closed union of typed variants with no free-text or
  metadata slot, so they structurally cannot carry health content
- Error reporting sets `sendDefaultPii = false` and disables automatic failed-request
  capture, so Sentry receives no request bodies; the only custom tag added is the backend
  trace id

See [docs/product/product-safety-privacy.md](docs/product/product-safety-privacy.md) for the
product safety boundary in full. Third-party packages and their licences are listed in
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
