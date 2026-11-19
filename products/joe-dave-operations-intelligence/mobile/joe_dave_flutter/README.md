# Joe&dave native Flutter client

This directory contains the native Flutter application. It does not embed, render, or launch the Joe&dave HTML/PWA inside a WebView.

- Native UI: Flutter Material 3 widgets.
- API: authenticated HTTPS requests to the existing Joe&dave Operations Worker.
- Authentication: existing `/auth/login`, `/auth/register`, `/auth/me`, and `/auth/logout` endpoints.
- Session token: stored in Android shared preferences and sent as a Bearer token.
- API root: `https://joe-dave-operations-api.uchechukwuanuforo.workers.dev`.
- Web/PWA: remains a separate product surface and must be preserved.

## Android build outputs

The quality workflow now creates optimized release builds rather than shipping the oversized debug APK:

- **Per-ABI APKs** (`armeabi-v7a`, `arm64-v8a`, `x86_64`) for smaller device-specific testing downloads.
- **Android App Bundle (AAB)** for Google Play distribution. Google Play generates device-optimized APKs from the bundle.
- Dart obfuscation is enabled and the matching symbol files are retained as a separate CI artifact for crash-symbolication.

Release-mode Flutter builds apply compiler optimizations and tree-shake unused icon fonts. ABI splitting avoids putting all CPU architectures into each test APK. Do not remove application features or assets merely to reduce file size. Keep the symbol artifact safely; it is needed to decode obfuscated production crash reports.

The CI artifacts are build outputs, not proof of production signing. A Play Store release still requires a protected upload key/signing configuration, key management, store policy checks, and real-device regression. Never commit keystores or passwords.

## Native platform project bootstrap

The repository currently does not contain committed `android/` or `ios/` platform project directories. The CI workflow generates those scaffolds temporarily to validate and build the Flutter source; it does not commit them.

Before a local Android build, run from this directory:

```bash
flutter create --platforms=android,ios --org com.joedave --project-name joe_dave_operations .
flutter pub get
flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/symbols
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols
```

Inspect the generated Android Gradle configuration and confirm the compile/target SDK meet current Google Play requirements before submission. Do not overwrite an existing signed release project or its signing configuration.

## Release status

This is not yet a complete store-ready ERP client. Dedicated Flutter screens and parity tests are still required for the remaining web workflows. The platform owner API is guarded by the Worker `PLATFORM_OWNER_EMAIL` setting; the owner menu is not an authorization boundary.

No signed production APK/AAB or signed iOS archive is produced by the current pre-release workflow. Android signing, iOS signing, store metadata, real-device regression, account deletion, privacy/legal publication and live subscription billing are separate release gates.