# Joe&dave beta distribution and Android upgrade route

## Current beta artifact (19 November 2026)

The API 36 Android workflow completed successfully on branch `release/pilot-readiness`.

- Workflow: [Joe&dave Android API 36 build](https://github.com/charlonnego/Joe-dave-operational-intelligence-/actions/runs/44520778023)
- Build run: 39
- Commit: `a68b3b3ba44e78819b046ed9d928b24c5f764ab8`
- Artifact: `joe-dave-android-api36-39`
- Artifact retention: 14 days (expires 3 December 2026)
- Application ID: `com.joedave.operations`
- Target SDK: Android API 36

The artifact contains:
- `apk/debug/app-debug.apk` — installable test APK, signed with the runner's debug key.
- `bundle/release/app-release.aab` — unsigned unless all four upload-key GitHub secrets were configured.

## Important limitation of this first APK

This is a debug-signed beta APK. GitHub-hosted runners generate their debug signing identity in the build environment. Do not assume a later CI build will have the same signing certificate. Android will reject an in-place upgrade if the signing certificate differs. Testers may need to uninstall this first build before installing a later differently signed build; uninstalling can remove local app data.

The Capacitor shell loads the hosted Joe&dave Pages application over HTTPS. An internet connection is required for the live workspace. The APK is not an offline-capable standalone copy of the SaaS.

## Recommended distribution sequence

### Immediate small-group beta

Use TestApp.io for tester invitations, release notes, install links/QR, feedback and issue tracking:
- Portal: https://portal.testapp.io/
- Create one Android app named Joe&dave Operations Intelligence.
- Upload the APK from the workflow artifact ZIP.
- Add a release note that this is an early online-connected pilot.
- Invite a small, trusted group first. Do not upload customer data or production credentials to the distribution portal.
- TestApp.io's free plan currently advertises one app, two team members, unlimited releases and 30-day build retention; check its live terms before relying on the plan.

Alternative one-off direct installation: Diawi (https://www.diawi.com/). Upload the APK, optionally protect the link with a password, and share its install URL/QR. It is a distribution host, not a substitute for structured QA or a permanent release channel.

### Preferred ongoing beta

Use Firebase App Distribution once the owner-controlled Firebase project and CI credentials are configured. It supports tester groups, invitation emails, release feedback and CI distribution. Do not add Firebase service-account credentials to source control.

### Google Play upgrade path

1. Create the Play Console app using the exact package ID `com.joedave.operations`.
2. Enable Play App Signing and retain the upload key securely.
3. Configure these GitHub Actions secrets in the repository:
   - `ANDROID_KEYSTORE_BASE64`
   - `ANDROID_KEYSTORE_PASSWORD`
   - `ANDROID_KEY_ALIAS`
   - `ANDROID_KEY_PASSWORD`
4. Trigger the `Joe&dave Android signed release` workflow manually, or push a version tag such as `joedave-v1.0.1`.
5. Confirm the workflow verifies the APK and AAB signatures and publishes the artifacts.
6. Upload the signed AAB to the Play Console **Internal testing** track first; add a small tester email list and share the Play opt-in link.
7. Promote the tested release to **Closed testing**, then Open testing when the listing and support process are ready, and finally Production after policy and quality gates pass.

Play Store installs then receive updates through Google Play. Keep the same application ID and increment `versionCode` for every release. Never change the upload key casually; retain a secure backup and document its certificate fingerprint. Play App Signing separates the app-signing key Google uses for delivered APKs from the upload key used to submit bundles.

## Release versioning rules

- Keep `applicationId` = `com.joedave.operations`.
- Increment Android `versionCode` on every uploaded build.
- Update `versionName` for human-readable releases.
- Sign every externally distributed update with the same stable certificate.
- Keep the upload keystore and passwords in GitHub Actions secrets only; never commit them.
- Retain each release's SHA-256 checksum and release notes.
- Test upgrade from the previous version without uninstalling, then verify sign-in, workspace data and saved records.

## Pilot feedback checklist

Ask testers to report:
- Device model and Android version.
- Install success/failure and screenshot of any error.
- Sign-up, sign-in, sign-out and password recovery.
- Create customer, quotation, invoice and receipt.
- Purchase order, receive stock and verify stock balance.
- Switch between workspaces and verify no cross-company data is visible.
- Screen layout, slow loading, crashes and confusing workflows.
- Network loss/recovery behaviour. Do not expect financial or stock transactions to work offline.

Do not invite broad public testers until tenant isolation, account deletion processing, final privacy disclosures, backup/restore and core financial workflows have passed acceptance.

## External references

- TestApp.io pricing: https://testapp.io/pricing/
- TestApp.io upload and release guide: https://help.testapp.io/how-to-create-a-release/
- Firebase App Distribution: https://firebase.google.com/docs/app-distribution/
- Diawi Android installation guide: https://www.diawi.com/knowledge-base/Diawi/Getting-started
- Google Play testing tracks: https://support.google.com/googleplay/android-developer/answer/9845334
