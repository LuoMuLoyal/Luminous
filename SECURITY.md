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
