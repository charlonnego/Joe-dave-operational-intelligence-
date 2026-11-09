-- Additive privacy-request support. Does not alter or delete existing business records.
CREATE TABLE IF NOT EXISTS jd_account_deletion_requests (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  business_id TEXT,
  email_snapshot TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','cancelled','processed')),
  reason TEXT NOT NULL DEFAULT '',
  requested_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
  scheduled_for TEXT NOT NULL,
  processed_at TEXT
);
CREATE INDEX IF NOT EXISTS idx_jd_account_deletion_user_status
  ON jd_account_deletion_requests(user_id, status, requested_at DESC);
CREATE UNIQUE INDEX IF NOT EXISTS idx_jd_account_deletion_one_pending
  ON jd_account_deletion_requests(user_id) WHERE status='pending';