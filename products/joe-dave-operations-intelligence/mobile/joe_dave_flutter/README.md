# Joe&dave native Android client

This directory contains the native Flutter Android application. It does not embed, render, or launch the Joe&dave HTML/PWA inside a WebView.

- Native UI: Flutter Material 3 widgets.
- API: authenticated HTTPS requests to the existing Joe&dave Operations Worker.
- Authentication: existing `/auth/login`, `/auth/register`, `/auth/me`, and `/auth/logout` endpoints.
- Session token: stored in Android shared preferences and sent as a Bearer token.
- Initial screens: sign-in, workspace creation, overview, sales/invoices, customers, inventory and analytics.
- API root: `https://joe-dave-operations-api.uchechukwuanuforo.workers.dev`.

The web/PWA remains a separate product surface. This Flutter client is an initial native foundation and must pass authenticated device tests against real workspace accounts before public release. Dedicated Flutter screens for the remaining web workflows are still required.
