# Buyer Review & Handover Checklist

This checklist is intended to help assess the Joe & Dave Operations Intelligence software asset before any sale.

## What the buyer should verify

- [ ] Sign-up, sign-in, sign-out, and account recovery
- [ ] Role-based access, especially HR/payroll restrictions
- [ ] Accounting and finance workflows actually implemented
- [ ] Invoice and receipt generation, print layout, and downloadable output
- [ ] Multi-currency handling and any exchange-rate assumptions
- [ ] API connectivity, error states, and retry behavior
- [ ] Responsive behavior on phone, tablet, desktop, and large displays
- [ ] PWA manifest, service worker, install prompt, and offline behavior (if advertised)
- [ ] Data persistence, backups, and restore procedure
- [ ] Security rules, access policies, and test coverage
- [ ] Deployment reproducibility from a clean checkout
- [ ] Third-party dependency licences and attribution

## Transfer boundaries

The sale agreement should identify separately:
1. Original Joe & Dave code and assets.
2. Upstream ERPNext/Frappe code and other third-party components, which remain under their applicable licences.
3. Cloud hosting, domains, database, email, and API accounts, which may require separate transfer or buyer-owned replacements.
4. Customer/business data, which should not be included unless lawful and explicitly agreed.

## Current technical handover status

The live product has been associated with the custom branch `custom/operations-intelligence` in `charlonnego/erpnext`. The standalone repository was created separately, and this documentation has been committed there. **The application-specific source code has not yet been migrated into this repository or validated as a clean standalone build.**

Do not market the repository as a complete source-code delivery until that work is done.
