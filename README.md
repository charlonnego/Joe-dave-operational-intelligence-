# Joe & Dave Operations Intelligence

**Live application:** https://joe-dave-operations-intelligence.pages.dev/

Joe & Dave is a business-operations web application with a standalone source boundary in this repository.

## Standalone source layout

- `products/joe-dave-operations-intelligence/` — web application, operational UI, PWA manifest/service worker, product documentation, and additive SQL migrations.
- `cloudflare/worker.js` — API Worker implementation.
- `cloudflare/d1/migrations/` — D1 schema migrations.
- `cloudflare/wrangler.toml` — Worker/D1 deployment configuration.
- `supabase/` — the product's Supabase schema and migration reference.

The source has been copied from the `custom/operations-intelligence` branch of `charlonnego/erpnext` into this standalone repository. The app and API are now represented here without copying the full ERPNext/Frappe framework.

## Important deployment notes

1. Cloudflare Pages should use `products/joe-dave-operations-intelligence` as its build/output root for the static PWA.
2. Deploy the API Worker from the `cloudflare/` directory using Wrangler, after confirming the account and D1 database IDs in `wrangler.toml` belong to the intended deployment.
3. Apply only the database migration set appropriate to the chosen backend. Do not run both D1 and Supabase migrations against the same database.
4. Keep secrets in platform secret storage; never commit API tokens, passwords, or private customer data.
5. Run authenticated end-to-end tests against the target environment before changing production routing or describing the transfer as fully verified.

The existing `wrangler.toml` includes environment identifiers from the source deployment. Confirm them before deploying; this repository migration does not transfer Cloudflare account ownership, databases, domains, or secrets.

## Feature and readiness claims

The source contains workflows for finance, invoices/receipts, purchasing, inventory, HR/payroll, manufacturing, projects and helpdesk. Their presence in source does not mean every workflow is independently validated for production. Known limitations and acceptance checks are documented in `products/joe-dave-operations-intelligence/README.md` and `docs/BUYER-REVIEW-CHECKLIST.md`.

## Ownership and licensing

This repository separates the Joe & Dave implementation from the upstream ERPNext/Frappe codebase. Third-party software remains governed by its own licence and attribution terms. Any sale must distinguish original project code from open-source components and separately address hosting, domain, database, and account transferability.

## Product positioning and launch focus

Joe & Dave is positioned as an **intelligent business operations platform for growing SMEs**. The first commercial wedge is deliberately focused on three connected workflows:

1. **Sales and cash collection** — customers, quotations, invoices, receipts and receivables visibility.
2. **Stock and purchasing control** — item records, warehouses, stock movements, supplier purchasing and receipt posting.
3. **Operational visibility** — trustworthy summaries and exception prompts calculated from the signed-in business's persisted records.

HR/payroll, manufacturing, projects, helpdesk and sales intelligence remain supporting modules. Their presence in the interface must not be marketed as proof of statutory, financial or operational compliance. See the [product README](products/joe-dave-operations-intelligence/README.md), [pilot plan](docs/PRODUCT-POSITIONING-AND-PILOT.md), and [Play release gate](docs/PLAY-STORE-RELEASE-GATE.md).

The core application and operational modules use the same-origin Pages API path (`/api`) so browser and Capacitor traffic follows one gateway. This avoids separate API origins drifting between the core workspace and operational modules.