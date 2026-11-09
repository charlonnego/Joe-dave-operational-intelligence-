import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';

const read = path => readFileSync(new URL(path, import.meta.url), 'utf8');

test('membership migration permits HR without weakening existing roles', () => {
  const migration = read('../d1/migrations/0006_hr_membership_role.sql');
  assert.match(migration, /'owner','admin','accountant','sales','inventory','viewer','hr'/);
  assert.match(migration, /INSERT INTO jd_business_memberships_new[\s\S]*SELECT id,business_id,user_id,role,invited_by,created_at FROM jd_business_memberships/);
  assert.match(migration, /jd_membership_keep_owner_before_delete/);
  assert.match(migration, /jd_membership_keep_owner_before_update/);
});

test('password hashing uses the documented work factor and upgrades older hashes after successful login', () => {
  const worker = read('../worker.js');
  assert.match(worker, /const PASSWORD_ITERATIONS=210000;/);
  assert.match(worker, /UPDATE jd_users SET password_hash=\?/);
});

test('HR claims are shared only with HR and accounting roles in the API role gate', () => {
  const worker = read('../worker.js');
  assert.match(worker, /if\(group==="hr"\)return sub==="claims"\?\["hr","accountant"\]\.includes\(role\):role==="hr";/);
});

test('operational UI always uses the authenticated live API and never local-only records', () => {
  const ui = read('../../products/joe-dave-operations-intelligence/operations-modules.js');
  assert.match(ui, /function localMode\(\)\{return false\}/);
  assert.match(ui, /'Authorization':'Bearer '\+t/);
  assert.doesNotMatch(ui, /function localRequest\(/);
  assert.doesNotMatch(ui, /LOCAL MODE|LOCAL-DRAFT-|LOCAL-PO-|LOCAL-SO-/);
});

test('responsive shell exposes an accessible collapsible module menu and phone/tablet/large-display layouts', () => {
  const html = read('../../products/joe-dave-operations-intelligence/index.html');
  assert.match(html, /id="nav-toggle"/);
  assert.match(html, /aria-controls="navwrap"/);
  assert.match(html, /@media\(max-width:480px\)/);
  assert.match(html, /@media\(max-width:900px\)/);
  assert.match(html, /@media\(min-width:1600px\)/);
  assert.match(html, /@media\(min-width:2200px\)/);
});


test('mobile command centre exposes direct invoice, customer and inventory actions', () => {
  const html = read('../../products/joe-dave-operations-intelligence/index.html');
  assert.match(html, /class="hero-actions"[^>]*aria-label="Quick business actions"/);
  assert.match(html, /data-go="invoices">＋ Create invoice/);
  assert.match(html, /data-go="customers">＋ Add customer/);
  assert.match(html, /data-go="inventory">Import inventory/);
});

test('invoice drafts are saved per business on-device and restored without being sent to the API', () => {
  const html = read('../../products/joe-dave-operations-intelligence/index.html');
  assert.match(html, /jd_invoice_draft_v1_.*business\.id/);
  assert.match(html, /function saveInvoiceDraft\(\)/);
  assert.match(html, /function restoreInvoiceDraft\(\)/);
  assert.match(html, /Invoice created\. Your local draft has been cleared\./);
  assert.match(html, /not sent to the cloud until you create it/);
});

test('temporary network failures do not erase a persisted session, and password visibility is user-controlled', () => {
  const html = read('../../products/joe-dave-operations-intelligence/index.html');
  assert.match(html, /Your saved session is still on this device/);
  assert.match(html, /auth-password-toggle/);
  assert.match(html, /aria-pressed/);
});

test('account deletion is an authenticated, password-confirmed, cancellable request and does not erase business records', () => {
  const worker = read('../worker.js');
  const migration = read('../d1/migrations/0007_privacy_requests.sql');
  const html = read('../../products/joe-dave-operations-intelligence/index.html');
  assert.match(worker, /path==="\\/account\\/deletion-request"&&req\\.method==="POST"/);
  assert.match(worker, /confirmation!=="DELETE MY ACCOUNT"/);
  assert.match(worker, /verifyPassword\\(b\\.password,account\\.password_hash\\)/);
  assert.match(worker, /scheduledFor=new Date\\(Date\\.now\\(\\)\\+30\\*86400000\\)/);
  assert.match(worker, /status='cancelled'/);
  assert.match(migration, /CREATE TABLE IF NOT EXISTS jd_account_deletion_requests/);
  assert.match(html, /id="account-deletion-form"/);
  assert.match(html, /privacy\.html/);
  assert.doesNotMatch(worker, /DELETE FROM jd_(invoices|receipts|customers|businesses)/);
});

test('pricing is explicit but cannot enable charges or claim that plan enforcement is live', () => {
  const plans = read('../../docs/SAAS-PLANS-AND-ENTITLEMENTS.md');
  const html = read('../../products/joe-dave-operations-intelligence/index.html');
  const worker = read('../worker.js');
  assert.match(plans, /Starter/);
  assert.match(plans, /Growth/);
  assert.match(plans, /Business/);
  assert.match(plans, /billing_enabled:false/);
  assert.match(html, /₦7,500/);
  assert.match(html, /₦20,000/);
  assert.match(html, /₦45,000/);
  assert.match(worker, /billing_enabled:false/);
});

test('first-run onboarding highlights the next unfinished real-data step', () => {
  const html = read('../../products/joe-dave-operations-intelligence/index.html');
  assert.match(html, /id="jd-onboarding-next"/);
  assert.match(html, /Recommended next step/);
  assert.match(html, /Setup complete/);
  assert.match(html, /Nothing is pre-filled with demo data/);
});
