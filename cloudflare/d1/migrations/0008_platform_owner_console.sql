CREATE TABLE IF NOT EXISTS jd_platform_controls (
 business_id TEXT PRIMARY KEY REFERENCES jd_businesses(id) ON DELETE CASCADE,
 plan_code TEXT NOT NULL DEFAULT 'free' CHECK(plan_code IN ('free','starter','growth','business')),
 access_status TEXT NOT NULL DEFAULT 'active' CHECK(access_status IN ('active','suspended')),
 updated_by TEXT REFERENCES jd_users(id),
 updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);
CREATE INDEX IF NOT EXISTS idx_jd_platform_controls_plan ON jd_platform_controls(plan_code,access_status);
INSERT OR IGNORE INTO jd_platform_controls(business_id,plan_code,access_status)
 SELECT b.id,
 CASE s.plan_code WHEN 'starter' THEN 'starter' WHEN 'business' THEN 'growth' WHEN 'professional' THEN 'business' ELSE 'free' END,
 CASE WHEN s.status='cancelled' THEN 'suspended' ELSE 'active' END
 FROM jd_businesses b LEFT JOIN jd_business_subscriptions s ON s.business_id=b.id;