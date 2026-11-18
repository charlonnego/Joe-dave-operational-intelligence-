-- Joe&dave sales intelligence: evidence, campaigns, approval queue, replies and suppressions.
-- No mailbox connection or outbound sending is enabled by this migration.
CREATE TABLE IF NOT EXISTS jd_sales_signals (
 id TEXT PRIMARY KEY, business_id TEXT NOT NULL REFERENCES jd_businesses(id) ON DELETE CASCADE,
 lead_id TEXT REFERENCES jd_crm_leads(id) ON DELETE SET NULL,
 company_name TEXT NOT NULL, signal_type TEXT NOT NULL CHECK(signal_type IN ('hiring','expansion','new_location','technology_gap','service_problem','funding','contract_award','other')),
 summary TEXT NOT NULL, source_url TEXT, observed_at TEXT NOT NULL,
 created_by TEXT REFERENCES jd_users(id), created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS jd_sales_signals_business_date ON jd_sales_signals(business_id,observed_at DESC);
CREATE TABLE IF NOT EXISTS jd_sales_campaigns (
 id TEXT PRIMARY KEY, business_id TEXT NOT NULL REFERENCES jd_businesses(id) ON DELETE CASCADE,
 name TEXT NOT NULL, audience_description TEXT NOT NULL, offer_summary TEXT NOT NULL,
 status TEXT NOT NULL DEFAULT 'planning' CHECK(status IN ('planning','active','paused','completed')),
 created_by TEXT REFERENCES jd_users(id), created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS jd_sales_campaigns_business_date ON jd_sales_campaigns(business_id,created_at DESC);
CREATE TABLE IF NOT EXISTS jd_sales_outbox (
 id TEXT PRIMARY KEY, business_id TEXT NOT NULL REFERENCES jd_businesses(id) ON DELETE CASCADE,
 campaign_id TEXT REFERENCES jd_sales_campaigns(id) ON DELETE SET NULL,
 lead_id TEXT NOT NULL REFERENCES jd_crm_leads(id) ON DELETE CASCADE,
 to_email TEXT NOT NULL, subject TEXT NOT NULL, body TEXT NOT NULL,
 evidence_signal_id TEXT REFERENCES jd_sales_signals(id) ON DELETE SET NULL,
 status TEXT NOT NULL DEFAULT 'draft' CHECK(status IN ('draft','approved','rejected')),
 created_by TEXT REFERENCES jd_users(id), reviewed_by TEXT REFERENCES jd_users(id),
 reviewed_at TEXT, created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS jd_sales_outbox_business_status ON jd_sales_outbox(business_id,status,created_at DESC);
CREATE TABLE IF NOT EXISTS jd_sales_replies (
 id TEXT PRIMARY KEY, business_id TEXT NOT NULL REFERENCES jd_businesses(id) ON DELETE CASCADE,
 lead_id TEXT REFERENCES jd_crm_leads(id) ON DELETE SET NULL, from_email TEXT NOT NULL,
 body TEXT NOT NULL, intent TEXT NOT NULL DEFAULT 'unclassified',
 status TEXT NOT NULL DEFAULT 'needs_review' CHECK(status IN ('needs_review','replied','closed')),
 received_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP, reply_draft TEXT
);
CREATE INDEX IF NOT EXISTS jd_sales_replies_business_date ON jd_sales_replies(business_id,received_at DESC);
CREATE TABLE IF NOT EXISTS jd_sales_suppressions (
 id TEXT PRIMARY KEY, business_id TEXT NOT NULL REFERENCES jd_businesses(id) ON DELETE CASCADE,
 email TEXT NOT NULL, reason TEXT NOT NULL DEFAULT 'User requested no further contact',
 created_by TEXT REFERENCES jd_users(id), created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
 UNIQUE(business_id,email)
);
CREATE INDEX IF NOT EXISTS jd_sales_suppressions_email ON jd_sales_suppressions(business_id,email);
