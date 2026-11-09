# Android and iOS release readiness

## Android

The existing Android debug build workflow is not a Play Store release. A production release requires a private upload/signing keystore and passwords stored as GitHub Actions secrets, never committed to the repository.

Required GitHub Actions secrets:
- ANDROID_KEYSTORE_BASE64 — base64-encoded JKS/PKCS12 keystore
- ANDROID_KEYSTORE_PASSWORD
- ANDROID_KEY_ALIAS
- ANDROID_KEY_PASSWORD

Release workflow must build both a signed APK (direct testing/distribution) and signed Android App Bundle (Google Play), verify signatures with apksigner verify --verbose and jarsigner -verify, generate SHA-256 checksums, and upload immutable artifacts. The signing key must be backed up offline in an approved password manager/secure vault. Never create or rotate a production signing key without confirming Play App Signing ownership and recovery.

## iOS

The current project is a hosted web/PWA with an Android Capacitor wrapper. iOS work is not complete merely by adding an iOS directory. Required:
- Apple Developer Program membership and Team ID.
- Bundle identifier ownership and App Store Connect app record.
- Distribution certificate/private key and provisioning profile (or a reviewed Xcode Cloud / App Store Connect API key setup).
- macOS runner/Xcode and tested Capacitor iOS project.
- iPhone/iPad layout, safe-area, file export/share, camera/photo permissions (only if used), push-notification capability (only if used), deep-link and login/session tests.
- Privacy nutrition labels, support URL, privacy policy URL, account deletion availability, screenshots, age rating and App Review notes.

## Current blockers

No Android signing keystore/secrets or Apple Developer signing credentials were available in the repository workflow context at the time of this implementation. Therefore this repository can be prepared for release signing, but a signed production APK/AAB and an App Store archive cannot be truthfully reported as produced until the owner supplies/configures those credentials and the release workflows pass.