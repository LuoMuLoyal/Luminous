# Permission Usage Statement

Last updated: 2026-07-21

## Overview

To provide health management features, Luminous requires the following system permissions. This statement is published in accordance with app store review requirements and applicable regulations.

## Android Permissions

| Permission | Purpose | Required |
|------------|---------|----------|
| `INTERNET` | Network communication to sync health data with the backend server | Required |
| `CAMERA` | Taking photos of medicine packages, prescriptions, or reference images for recognition and recording | Optional (requested when using camera features) |
| `RECORD_AUDIO` | Voice input for recording health journals | Optional (requested when using voice features) |
| `POST_NOTIFICATIONS` | Sending medication reminders and health alerts as local notifications (Android 13+) | Optional (notifications will not appear if denied) |
| `SCHEDULE_EXACT_ALARM` | Scheduling precise medication reminder notifications (Android 12+) | Optional (reminders may be delayed if denied) |
| `RECEIVE_BOOT_COMPLETED` | Restoring scheduled medication reminders after device reboot | Automatically granted |
| `READ_EXTERNAL_STORAGE` | Reading images from the system gallery (Android 12 and below only) | Optional (requested when selecting images) |

## iOS Permissions

| Permission | Purpose | Required |
|------------|---------|----------|
| `NSCameraUsageDescription` | Taking photos of medicine packages, prescriptions, or reference images for recognition and recording | Optional (requested when using camera features) |
| `NSMicrophoneUsageDescription` | Voice input for recording health journals | Optional (requested when using voice features) |
| `NSPhotoLibraryUsageDescription` | Selecting medicine package, avatar, or reference images from the photo library | Optional (requested when selecting images) |
| `NSPhotoLibraryAddUsageDescription` | Saving recognition results or reference images to the photo library | Optional (requested when saving images) |

## Permission Management

### Impact of Denying Permissions

- **Denying Camera**: Camera functionality will be unavailable, but images can still be selected from the photo library.
- **Denying Microphone**: Voice input will be unavailable; keyboard input can be used instead.
- **Denying Notifications**: Local notifications for medication and health reminders will not be displayed.
- **Denying Photo Library**: Images cannot be selected from the photo library.

### How to Change Permission Settings

- **Android**: System Settings → Apps → Luminous → Permissions
- **iOS**: System Settings → Privacy & Security → Corresponding permission → Luminous

## Data Security Commitment

- All permissions are requested when the user actively uses the corresponding feature; no silent background access.
- Camera and microphone data is processed only during user operation; no background recording or photography.
- Image data is processed locally or transmitted to servers via encrypted channels; it will not be leaked to third parties.
