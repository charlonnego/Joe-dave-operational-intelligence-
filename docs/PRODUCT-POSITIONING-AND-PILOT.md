# Joe & Dave — Product Positioning and SME Pilot Plan

## Positioning

**Joe & Dave helps a growing business keep control of sales, cash collection, stock and purchasing in one workspace.**

Avoid leading with “all-in-one ERP” or claiming parity with mature ERP products. The differentiated entry point is a clear, connected workflow for owners and operations managers who currently spread these records across spreadsheets, messaging apps and disconnected tools.

## Initial ideal customer profile

Recruit 5–10 Nigerian SMEs with:
- A real catalogue of goods or repeatable services.
- At least one person responsible for sales/invoicing and one for stock or purchasing.
- A business owner or manager willing to review weekly reports.
- A manageable first rollout that does not depend on statutory payroll, automated bank feeds or manufacturing cost accounting.

Good pilot segments include small distributors, wholesalers, trade suppliers and multi-person service businesses. Do not start with a heavily regulated or complex multi-entity deployment.

## First three workflows to make excellent

### 1. Quote to cash
Customer → quotation → acceptance → invoice → receipt → outstanding balance.

Acceptance criteria:
- Totals and currency rounding are consistent from quotation to invoice and receipt.
- Partial payments and outstanding balances are clearly represented where supported.
- Printed/downloaded invoice and receipt agree with persisted records.
- Failed requests do not show a success state.

### 2. Purchase to stock
Supplier → purchase order → receipt → stock movement → on-hand quantity.

Acceptance criteria:
- Draft and posted states are visibly different.
- Stock changes only after the correct posting action.
- Duplicate submissions do not double-post stock.
- Item, warehouse and supplier references are validated server-side.

### 3. Operational visibility
Owner dashboard → invoices/collections → stock exceptions → supplier obligations.

Acceptance criteria:
- Every KPI comes from the signed-in tenant's persisted records.
- Missing data is shown as unavailable, not silently treated as zero.
- Every exception links to the records behind it.
- A reviewer can trace totals back to source transactions.

## Pilot sequence

1. Recruit 5–10 businesses; interview each owner before setup.
2. Configure one real workspace per business and train one owner plus one operator.
3. Import only reviewed customer, item and supplier master data.
4. Run the three workflows above for four weeks.
5. Hold a 20-minute weekly review: errors, time saved, missing fields, support burden and willingness to pay.
6. Convert only businesses that complete the workflows into paid design partners after pricing and support terms are agreed.

## Metrics to record

- Time from account creation to first customer and first invoice.
- Percentage of pilot businesses completing quote-to-cash weekly.
- Percentage completing purchase-to-stock weekly.
- Failed or abandoned saves and API error rate.
- Number of support interventions per business.
- Weekly active businesses and active users per business.
- Retention after week 2 and week 4.
- Stated willingness to pay and actual conversion.

Do not publish revenue, time-saved or accuracy claims until measured with consent and a defined sample.

## Suggested launch pricing experiment

Use the draft price points as hypotheses, not a published tariff:
- Starter: ₦5,000/month
- Business: ₦15,000/month
- Professional: ₦35,000/month
- Enterprise: quote after requirements review

Test willingness to pay with actual pilot users. Do not enable paid billing or introduce paid infrastructure until the user explicitly approves the cost and the product can support billing, receipts, cancellations and customer support reliably.

## Explicit exclusions for the pilot

- Statutory payroll filing or tax advice.
- Automated bank payments or bank-feed reconciliation.
- Fully offline financial transactions or background sync.
- Automatic prospect scraping, email verification or sending.
- Manufacturing labour/overhead costing.
- Any guarantee of legal, tax or accounting compliance.

## Exit criteria for public launch

Proceed only after:
- Two-tenant isolation tests pass.
- Invoice-to-receipt and purchase-to-stock E2E tests pass.
- Backup and restore is demonstrated.
- Privacy and account-deletion flows are published and tested.
- Support and incident response have named owners.
- Mobile release gates and Play Console declarations are complete.