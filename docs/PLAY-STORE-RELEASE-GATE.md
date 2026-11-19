# Google Play release gate — Joe & Dave

**Current status: BLOCKED — do not submit yet.**

New Android apps and app updates must target **Android 16 / API 36 or higher** under Google's policy effective 31 August 2026. Source: https://support.google.com/googleplay/android-developer/answer/11926878

## Repository evidence at the time this gate was added

- Capacitor configuration exists and identifies the app as `com.joedave.operations`.
- The web application is configured to load the hosted Pages application over HTTPS.
- The product directory has the Capacitor package and PWA manifest/service worker.
- The Android native project and its Gradle target SDK/release signing configuration were not present at the inspected paths. A signed Android App Bundle therefore has not been verified.
- The published privacy policy still contains a pre-launch instruction to add the operator's registered legal identity, address and dedicated privacy contact.
- The current account-deletion endpoint records a pending request and permits cancellation; no request-processing/deletion executor was found in the inspected Worker source. The actual deletion and legally required retention process must be implemented and tested.
- A successful Pages or Worker deployment would not prove Android packaging, device compatibility, privacy compliance or end-to-end acceptance.

## Required before submission

### Native Android build
- [ ] Generate and commit/review the Capacitor Android project.
- [ ] Set `targetSdk` to 36 or higher and confirm the merged release manifest.
- [ ] Set and verify `minSdk` based on supported device requirements.
- [ ] Configure release signing securely; keep keystore and passwords outside Git.
- [ ] Increment versionCode/versionName and build a signed `.aab`.
- [ ] Verify package ID `com.joedave.operations` and signing certificate fingerprint.
- [ ] Test install, update, uninstall/reinstall and deep links on physical devices.
- [ ] Verify login, workspace switch, invoice creation, receipt posting, stock and purchasing flows on Android.
- [ ] Verify poor-network and offline messaging. Local notes are device-only; financial transactions are not offline-capable.

### Security and data
- [ ] Test sign-up, sign-in, sign-out, session expiry and account recovery.
- [ ] Prove tenant isolation with at least two unrelated businesses, including direct API ID-guessing attempts.
- [ ] Verify role restrictions for owner, admin, accountant, sales, inventory, HR and viewer.
- [ ] Review Worker routes, input validation, rate limits, CORS and audit events.
- [ ] Run a real backup and restore exercise.
- [ ] Implement and test account-deletion request processing through completion (the current API only records/cancels a pending request), including identity checks, shared-workspace ownership, retained business records, backups and user notification.

### Store policy and listing
- [ ] Publish a public privacy policy with the operator's registered legal identity, registered address and dedicated privacy contact, accurately describing data collected, processing purposes, retention, sharing and security.
- [ ] Add a working public account-deletion URL and an in-app deletion path where applicable.
- [ ] Complete Data safety, app access instructions, content rating, target audience and ads declarations.
- [ ] Prepare store icon, screenshots from the real app, short description, full description and support contact.
- [ ] Complete internal/closed testing and resolve all critical or high-severity issues.

## Submission stop conditions

Do not submit if any of these remain true:
- Android target API 36+ is not verified.
- No signed release AAB exists.
- The privacy policy or account-deletion route is unavailable or inaccurate.
- Tenant isolation or role enforcement has not passed.
- Critical quote-to-cash or purchase-to-stock workflows fail.
- A screen displays fabricated/sample business KPIs as real customer data.

## What this gate does not certify

The source-level preflight script checks a small set of repository invariants. It is not a penetration test, legal review, Play Console submission, production backup, device test or proof of successful deployment.