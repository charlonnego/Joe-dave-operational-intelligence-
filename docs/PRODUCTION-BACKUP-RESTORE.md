# Production D1 backup and restore runbook

## Current production database observed 9 November 2026

- Database: joe-dave-operations
- Database ID: 239128a2-a17e-4542-83b4-d119598be5fa
- Cloudflare jurisdiction: EU
- Region observed: EEUR
- Tables observed: 62
- Approximate database file size observed: 794,624 bytes
- A current D1 Time Travel bookmark was returned by Cloudflare at verification time.

The presence of a bookmark confirms that Cloudflare returned a recovery point. It does not prove that an export was retained off-account, that a restore has been rehearsed, or that the application has passed post-restore acceptance tests.

## Recovery options

1. **Time Travel restore:** identify a bookmark or timestamp before the incident and restore the production D1 database. This rewinds the live database and is destructive to writes after that point. It must be approved by the incident lead and coordinated with a maintenance window.
2. **SQL export/import:** use the D1 export API in polling mode, securely download the generated D1-compatible SQL dump, store it in an access-controlled encrypted backup location, and import it into a separate recovery database. Cloudflare notes that an export can temporarily make the database unavailable while it runs; do not start one during peak usage without a maintenance plan.
3. **Recovery database rehearsal:** restore the SQL dump into a separately named non-production D1 database, apply the same Worker release and run the acceptance checks below. Do not point the production Worker at the recovery database until an approved cutover.

## Mandatory backup cadence

- Daily encrypted SQL export, retained for 35 days.
- Weekly export retained for 12 weeks.
- Monthly export retained for 12 months, subject to applicable retention law and available storage.
- Record export timestamp, bookmark, database ID, file size, checksum, operator and restore-test outcome.
- Restrict backup access to named operators. Never store database dumps in the public Git repository or an ordinary unencrypted device folder.

## Restore rehearsal checklist

- [ ] Confirm target database ID and jurisdiction; never infer them from a project name.
- [ ] Confirm a recent backup exists and verify its SHA-256 checksum.
- [ ] Create or select an isolated recovery database; never test restore against the live production database.
- [ ] Import the dump and confirm all expected tables and migrations are present.
- [ ] Run integrity checks and compare row counts for core tables (users, businesses, memberships, customers, invoices, invoice lines, receipts, inventory and audit events) without exposing personal data in logs.
- [ ] Deploy the matching Worker version to a non-production endpoint and verify health, login, role isolation, invoice/receipt reads and writes, and exports using synthetic test records.
- [ ] Confirm that no production email, payment, or webhook integrations are triggered.
- [ ] Record recovery point objective (RPO), recovery time objective (RTO), errors and approver.
- [ ] Delete the temporary recovery database only after the test evidence is stored and the data owner approves.

## Current verification status

- [x] Production D1 database metadata read successfully.
- [x] Cloudflare returned a current Time Travel bookmark.
- [ ] Independent encrypted SQL export stored outside Cloudflare.
- [x] Cloudflare Time Travel restore API rehearsed end-to-end on a disposable EU D1 database (9 November 2026): created a sentinel row, captured a bookmark, changed the row, restored the bookmark, verified the original value returned, and deleted the temporary database.
- [ ] Production SQL export restored into an isolated recovery database and full application acceptance tests passed against that restored production snapshot.

**Do not claim a tested backup/restore programme until the last three checks have been completed.** No production restore was attempted during this review. The disposable restore drill verified Cloudflare's Time Travel mechanism only; it did not copy production customer or payroll records, test an SQL dump, or prove the complete production recovery process.