# Third-Party SDK List

Last updated: 2026-07-21

## Overview

To provide a complete user experience, Luminous uses the following third-party SDKs. This list is published in accordance with applicable regulations.

## SDK List

### 1. Flutter Framework

- **Provider**: Google LLC
- **Purpose**: Application framework providing cross-platform UI rendering
- **Data Collected**: Device model, OS version (for app operation)
- **Privacy Policy**: https://flutter.dev/security

### 2. Sentry SDK

- **Provider**: Functional Software, Inc. (Sentry)
- **Purpose**: Crash monitoring and error tracking
- **Data Collected**: Device model, OS version, app crash logs, IP address
- **Privacy Policy**: https://sentry.io/privacy/

### 3. Dio (HTTP Client)

- **Provider**: Dart open-source community
- **Purpose**: Network request handling
- **Data Collected**: Does not actively collect personal information (serves as a network communication library)

### 4. fluwx (WeChat SDK)

- **Provider**: Tencent Holdings Limited
- **Purpose**: WeChat login and sharing
- **Data Collected**: Device identifier, WeChat OpenID (only when using WeChat login)
- **Privacy Policy**: https://privacy.qq.com/

### 5. Sign in with Apple

- **Provider**: Apple Inc.
- **Purpose**: Apple account sign-in
- **Data Collected**: Apple ID identifier, email (only when using Apple sign-in)
- **Privacy Policy**: https://www.apple.com/legal/privacy/

### 6. flutter_local_notifications

- **Provider**: Dart open-source community
- **Purpose**: Local notifications and medication reminder push
- **Data Collected**: Does not actively collect personal information (only invokes system notification APIs)

### 7. mobile_scanner

- **Provider**: Dart open-source community
- **Purpose**: Medicine barcode scanning
- **Data Collected**: Camera feed (only processed when the user actively scans; not stored or uploaded)

### 8. share_plus

- **Provider**: Dart open-source community
- **Purpose**: Sharing clinic summary PDFs and other content to other apps
- **Data Collected**: Does not actively collect personal information

### 9. google_mlkit_text_recognition

- **Provider**: Google LLC
- **Purpose**: OCR text recognition (for medicine package identification)
- **Data Collected**: Text content from images (processed locally only when the user actively uses the feature; not uploaded to servers)
- **Privacy Policy**: https://policies.google.com/privacy

## Update Notes

This list will be updated as application dependencies change. If you find any omissions or have questions, please contact us via "Help & Support" in the App.
