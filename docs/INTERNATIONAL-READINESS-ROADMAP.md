# Joe&dave — international product and store-readiness roadmap

**Target markets:** United States, United Kingdom, Germany (with a later wider EU rollout).
**Product model:** multi-tenant business operations SaaS with web, Android and iOS clients.
**Release principle:** one authoritative API and permission model; web and mobile are separate clients with equivalent business workflows.

## Operator details supplied by the owner

- Customer-facing business name: **Joe and dave**.
- Intended operating / business location: **New York, USA**.
- These details may be used for product configuration and draft business-facing copy.
- They do **not** establish a registered legal entity name, a complete postal address, a state of incorporation/registration, a privacy contact email, or a tax identification number. Do not publish invented legal particulars or claim New York registration based only on the location supplied.
- Before publishing binding Terms, Privacy Notice, DPA, billing/tax disclosures or store privacy declarations, confirm the registered entity (if any), full postal address, privacy/support contact, data controller identity and applicable tax registrations. If Joe and dave is a sole proprietorship or trade name, the legal contracting party must be described accurately.

## 1. Product quality bar

- Preserve the existing HTML/PWA experience as the web product and visual reference; do not replace it with a reduced mobile interface.
- Native Flutter Android and iOS clients must provide the same core workflows and consistent navigation.
- Mobile primary navigation: Overview, Sales, Inventory and More. More exposes the full module catalogue and owner-only platform tools.
- Keep the Platform Owner Console separate from each customer's business workspace. The API must enforce owner identity for every read and mutation; hiding a menu item is not security.
- Complete role-based access for owner, workspace owner/admin, accountant, sales, inventory, HR and read-only users.
- Verify tenant isolation at the API/database layer, audit sensitive actions, rate-limit authentication and privileged operations, and never use sample KPIs as real customer data.
- Support accessible typography, screen readers, keyboard navigation on web, responsive layouts, clear validation, useful empty/error/loading states and localization-ready text.

## 2. Internationalization and accounting

- Implement locale-aware dates, numbers, decimal separators, time zones and pluralization.
- Support English (US/UK) and German (de-DE); keep translations outside UI source code.
- Support USD, GBP, EUR and NGN with ISO 4217 currency codes. Store money as integer minor units plus currency code; never mix currencies in a total without an explicit conversion and rate record.
- Configure each workspace's country, legal name, address, tax identifiers, fiscal year, base currency and time zone.
- Build configurable tax rules rather than hard-coding one VAT rate. Support tax-inclusive/exclusive pricing, exemptions, reverse-charge handling where applicable, tax rates effective by date, credit notes and auditable tax calculations.
- Review country-specific chart-of-accounts, invoice numbering, required invoice fields, payroll and employment workflows with qualified local advisers before enabling those features in each market.

## 3. Privacy, security and trust

- Publish accurate privacy notices, terms, data-processing terms, subprocessors and retention schedules.
- For EU/German customers, assess GDPR applicability, lawful bases, data-subject rights, processor/controller roles, international transfers, security measures and the need for an EU representative. Offering services to people in the EU can bring a non-EU provider within GDPR scope.
- Assess UK GDPR and Data Protection Act obligations for UK customers.
- Assess US federal and applicable state privacy requirements, including state consumer privacy rights where thresholds and scope apply.
- Provide in-product export and deletion request workflows. A request queue alone is not deletion: implement verified processing, retention exceptions, backup expiry, audit evidence and user notification.
- Require MFA for privileged accounts, least-privilege access, secure session expiry/revocation, secret rotation, encryption in transit and at rest, monitored backups and tested restore procedures.
- Complete an independent security review and penetration test before claiming enterprise-grade security.

## 4. Commercial readiness

- Choose a payment provider that can onboard the actual operating legal entity and settle in the target currencies. Confirm supported countries, recurring billing, tax handling, refunds, chargebacks and payout costs before integration.
- Implement subscription lifecycle states (trial, active, past due, cancelled, suspended), webhook signature verification, idempotency, invoices/receipts and reconciliation.
- Do not mark a workspace as paid solely because an administrator manually changes its plan.
- Publish transparent USD, GBP and EUR pricing, renewal/cancellation terms, support SLA and a clear sales/demo route.
- Provide customer onboarding, import templates, help centre, support contact and a documented upgrade/rollback path.

## 5. Google Play and Apple App Store

### Google Play
- Build a signed Android App Bundle (AAB), verify signing certificate and package identity, and preserve the upload key securely.
- New app submissions and updates must target Android 16 / API 36 or higher from 31 August 2026.
- Complete Data safety, content rating, app access instructions, store listing, privacy policy and account deletion declarations.
- If the Play developer account is a personal account created after 13 November 2023, complete the required closed test with at least 12 opted-in testers for 14 continuous days before applying for production access.
- Test install/update, session restore, sign-out, offline/error handling, file export, accessibility and all core workflows on physical Android devices.

### Apple App Store
- Build the actual Flutter iOS app on macOS/Xcode; a Capacitor simulator workflow is not a substitute for the Flutter iOS client.
- Configure Apple Developer membership, bundle ID, signing certificate/provisioning, App Store Connect record and TestFlight.
- Supply an active review account or full-featured demo mode, accurate metadata, support URL, privacy policy, privacy disclosures and in-app account deletion where account creation is supported.
- Test on real iPhone and iPad devices, including safe areas, keyboard, file export/share, deep links, authentication and subscription flows.

## 6. Current repository blockers to clear

- The Flutter client and its platform owner API currently live on `release/pilot-readiness`, which is 90 commits ahead of `main`. Do not merge that entire branch into production without a reviewed integration plan.
- The owner API requires the Cloudflare Worker secret `PLATFORM_OWNER_EMAIL`; verify it is configured to the designated owner address in the intended production environment.
- The Worker currently reports that billing is not connected; administrative plan assignment is not payment collection.
- Existing release notes identify incomplete account-deletion processing and a privacy policy requiring the operator's registered legal identity, address and privacy contact.
- Android release signing secrets must be configured securely before a signed production APK/AAB can be generated.
- The Flutter iOS client requires its own successful macOS simulator build, device tests and signed App Store archive.
- The new Flutter quality workflow must pass before merging the mobile navigation/owner-console changes.

## 7. Release gates

1. **Engineering:** CI green; no critical/high defects; tenant isolation and role tests pass; backups restore; all critical business workflows pass.
2. **Commercial:** payment and subscription lifecycle tested; customer support and pricing published; tax advice obtained for target sales model.
3. **Privacy/security:** policies accurate; deletion completed end-to-end; security assessment and incident response documented.
4. **Mobile:** signed AAB and signed iOS archive; real-device regression tests; store metadata and review access ready.
5. **Launch:** staged rollout, crash/ANR monitoring, support escalation and rollback plan active.

Passing a source-code check is not the same as production readiness or store approval. No launch claim should be made until each gate has evidence.
