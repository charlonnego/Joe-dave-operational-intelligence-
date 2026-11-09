# Joe&dave plans and entitlements

**Published pricing proposal — NGN, 9 November 2026.** These are the product's intended public plan definitions. Subscription checkout, automatic renewals, plan enforcement and payment collection remain disabled until a payment provider, tax treatment, billing support and server-side entitlement checks have been completed and tested. Existing pilot workspaces are not charged or downgraded by this document.

| Plan | Monthly | Annual (2 months free) | Users | Customers | Invoices/month | Active inventory items |
|---|---:|---:|---:|---:|---:|---:|
| Free | ₦0 | ₦0 | 1 | 50 | 25 | 100 |
| Starter | ₦7,500 | ₦75,000 | 3 | 500 | 500 | 1,000 |
| Growth | ₦20,000 | ₦200,000 | 10 | 2,500 | 2,500 | 10,000 |
| Business | ₦45,000 | ₦450,000 | 25 | 10,000 | 10,000 | 50,000 |

## Included capabilities

- **Free:** business profile, customer directory, invoices and receipts, basic expenses, inventory register, basic dashboard, branded PDF/JPG exports.
- **Starter:** everything in Free, plus accountant and sales roles, purchase orders, supplier records, recurring export templates and expanded usage limits.
- **Growth:** everything in Starter, plus HR records, attendance and leave, payroll preparation (base-salary calculation only), projects, timesheets, buying and manufacturing workflows, and advanced analytics.
- **Business:** everything in Growth, plus 25 named users, priority support target, multi-team operating procedures and higher limits. Custom onboarding or data migration is quoted separately.

## Commercial rules

1. Prices are per business workspace, not per user, unless a written enterprise quote says otherwise.
2. Annual billing is prepaid. The annual price equals ten monthly payments.
3. Prices exclude applicable taxes and any separately quoted implementation, migration, training or third-party fees.
4. No automatic overage charges. A workspace approaching a limit should be notified; new record creation should be blocked with an export/support path only after server-side enforcement is released.
5. No payment data is collected by the current pilot. No plan should be activated by changing a browser value or directly editing a client-side label.
6. A plan change becomes effective only after a verified payment-provider webhook and server-side entitlement update. Failed/cancelled payments must not erase existing records; access should become read-only after a documented grace period.
7. Payroll statutory calculations, tax filing, bank payments, email invitations and full multi-branch consolidation are not represented as included production capabilities until independently validated.

## Implementation gate

Before accepting payment, implement and test: payment provider checkout and signed webhooks; server-side plan/limit checks on every write; upgrade/downgrade and cancellation lifecycle; receipts/tax invoices; renewal failure grace period; refund process; plan audit events; and clear terms. The current API deliberately reports billing_enabled=false.