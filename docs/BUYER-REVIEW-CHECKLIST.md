# Buyer Review & Handover Checklist

Use this checklist to validate the Joe & Dave asset before sale or production handover.

## Source migration status

- [x] Standalone GitHub repository created
- [x] Product web application and PWA assets copied into `products/joe-dave-operations-intelligence/`
- [x] Cloudflare API Worker and Wrangler configuration copied into `cloudflare/`
- [x] Cloudflare D1 migrations copied into `cloudflare/d1/migrations/`
- [x] Product-level additive SQL migrations copied
- [x] Supabase schema/reference migration copied
- [ ] Clean-checkout build and deployment tested
- [ ] Production credentials and account ownership independently reviewed
- [ ] Authenticated end-to-end workflows passed against the target environment
- [ ] Third-party licence and ownership review completed

## Functional acceptance

- [ ] Sign-up, sign-in, sign-out, and account recovery
- [ ] Role-based access, especially restricted HR/payroll access
- [ ] Accounting and finance workflows
- [ ] Invoice/receipt creation, printing, and downloadable output
- [ ] Currency handling and rounding rules
- [ ] API connectivity, error states, and retries
- [ ] Responsive behavior on phones, tablets, desktops, and large displays
- [ ] PWA manifest, service worker, installation prompt, and offline behavior as advertised
- [ ] Data persistence, backups, and restore procedure
- [ ] Access policies, auditability, and tests

## Transfer boundaries

The sale agreement should distinguish:
1. Original Joe & Dave code and assets.
2. ERPNext/Frappe and other third-party components, under their applicable licences.
3. Cloud hosting, domains, database instances, email, and API accounts, which may need separate transfer or buyer-owned replacements.
4. Customer/business data, which must not be included unless lawful and explicitly agreed.

## Deployment caution

The source files have been copied, but a Git commit is not proof of a successful clean build, production deployment, or full browser-based acceptance test. Verify the account and database IDs in `cloudflare/wrangler.toml` before deploying, keep secrets out of Git, and apply only the migration set for the chosen database backend.

## Commercial pilot and Play release gates

- [ ] Agree a narrow pilot scope: sales/invoicing/receipts, inventory, purchasing and live operational visibility.
- [ ] Recruit 5–10 pilot businesses and obtain written permission to use anonymised feedback; do not copy customer data into demos.
- [ ] Complete a real invoice-to-receipt workflow and a purchase-order-to-stock-receipt workflow in separate test workspaces.
- [ ] Verify two-tenant isolation with two independent accounts, including direct API requests and attempts to access another tenant's IDs.
- [ ] Confirm the same-origin `/api` gateway works in desktop browsers and the Capacitor Android shell.
- [ ] Verify data export, backup and restore using a documented recovery test.
- [ ] Verify account deletion requests through completion, including what data is retained and why.
- [ ] Publish a privacy policy that accurately names the operator, data categories, purposes, processors, retention and contact channel.
- [ ] Generate a signed Android App Bundle targeting API 36 or higher; verify package ID, version code, signing certificate and release build.
- [ ] Complete Play Console Data safety, app access, content rating, target audience, ads declaration (if applicable), account deletion URL and store listing.
- [ ] Run closed testing on real Android devices before production rollout.

**Do not submit to Google Play while any security, account-deletion, privacy-policy, target-API, signing or critical end-to-end gate remains unchecked.**