# Joe&dave native Flutter client

This directory contains the native Flutter application source. It does not embed, render, or launch the Joe&dave HTML/PWA inside a WebView.

- Native UI: Flutter Material 3 widgets.
- API: authenticated HTTPS requests to the existing Joe&dave Operations Worker.
- Authentication: existing `/auth/login`, `/auth/register`, `/auth/me`, and `/auth/logout` endpoints.
- Session token: stored in Android shared preferences and sent as a Bearer token.
- API root: `https://joe-dave-operations-api.uchechukwuanuforo.workers.dev`.
- Web/PWA: remains a separate product surface and must be preserved.

## Native platform project bootstrap

The repository currently does not contain committed `android/` or `ios/` platform project directories. The CI workflow generates those scaffolds temporarily to validate the Flutter source; it does not commit them and does not create a release APK.

Before a local Android build, run from this directory:

```bash
flutter create --platforms=android,ios --org com.joedave --project-name joe_dave_operations .
flutter pub get
```

Then verify the generated Android Gradle configuration uses compile/target SDK 36 or later before a store build. Do not overwrite an existing signed release project or its signing configuration.

## Release status

This is not yet a complete store-ready ERP client. Dedicated Flutter screens and parity tests are still required for the remaining web workflows. The platform owner API is guarded by the Worker `PLATFORM_OWNER_EMAIL` setting; the owner menu is not an authorization boundary.

No signed APK/AAB or signed iOS archive is produced by the pre-release quality workflow. Android signing, iOS signing, store metadata, real-device regression, account deletion, privacy/legal publication and live subscription billing are separate release gates.