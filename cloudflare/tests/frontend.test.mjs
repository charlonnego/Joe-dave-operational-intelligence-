import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import { spawnSync } from "node:child_process";

const path = "products/joe-dave-operations-intelligence/index.html";
const html = fs.readFileSync(path, "utf8");

test("all inline browser scripts parse as JavaScript modules", () => {
  const scripts = [...html.matchAll(/<script\b[^>]*>([\s\S]*?)<\/script>/gi)].map(m => m[1]).filter(s => s.trim());
  assert.ok(scripts.length >= 2, "expected the main app and API integration scripts");
  for (const [index, script] of scripts.entries()) {
    const result = spawnSync(process.execPath, ["--input-type=module", "--check"], { input: script, encoding: "utf8" });
    assert.equal(result.status, 0, "inline script " + (index + 1) + " failed syntax check: " + result.stderr);
  }
});

test("every navigation target has a matching section", () => {
  const nav = [...html.matchAll(/data-page="([^"]+)"/g)].map(m => m[1]);
  const pages = new Set([...html.matchAll(/id="page-([^"]+)"/g)].map(m => m[1]));
  for (const page of nav) assert.ok(pages.has(page), "missing section for nav target: " + page);
});

test("live business modules are wired to the API", () => {
  for (const route of ["/auth/register", "/customers", "/invoices", "/inventory/import", "/suppliers", "/expenses", "/purchase-orders", "/supplier-bills", "/bank-transactions/import", "/accounting-periods", "/reports/trial-balance", "/analytics", "/business", "/receipts"]) {
    assert.ok(html.includes(route), "missing UI API integration for " + route);
  }
});

test("branding, professional document export and data analysis controls exist", () => {
  for (const fragment of ["brand-logo-file", "invoice_template", "receipt_template", "invoice-pdf", "invoice-jpg", "receipt-pdf", "receipt-jpg", "analytics-chart", "analytics-monthly-table", "analytics-insights", "api('/analytics')"]) {
    assert.ok(html.includes(fragment), "missing document/analytics feature: " + fragment);
  }
});

test("every visible page has navigation and there are no orphan placeholder sections", () => {
  const nav = [...html.matchAll(/data-page="([^"]+)"/g)].map(m => m[1]);
  const pages = [...html.matchAll(/id="page-([^"]+)"/g)].map(m => m[1]);
  assert.deepEqual(pages.filter(page => !nav.includes(page)), []);
  assert.ok(!html.includes('id="page-operations"'), "obsolete planned-workflows page must not ship");
});

test("all operational modules have matching live UI roots and authenticated Worker definitions", () => {
  const modules = fs.readFileSync("products/joe-dave-operations-intelligence/operations-modules.js", "utf8");
  const worker = fs.readFileSync("cloudflare/worker.js", "utf8");
  const resources = [
    "inventory/items", "inventory/warehouses", "inventory/lots", "inventory/movements", "inventory/counts",
    "crm/leads", "selling/quotations", "selling/orders",
    "buying/suppliers", "buying/requests", "buying/orders", "buying/receipts", "buying/invoices",
    "hr/employees", "hr/attendance", "hr/leave", "hr/claims", "hr/payroll",
    "manufacturing/boms", "manufacturing/orders", "manufacturing/work-centers", "manufacturing/job-cards",
    "projects/projects", "projects/tasks", "projects/timesheets",
    "support/tickets", "support/messages", "support/articles"
  ];
  assert.equal(resources.length, 28);
  for (const resource of resources) {
    assert.ok(modules.includes("'" + resource + "':{title:"), "missing UI resource " + resource);
    assert.ok(worker.includes('"' + resource + '":{table:'), "missing authenticated Worker resource " + resource);
  }
  for (const page of ["ops-inventory", "ops-selling", "ops-buying", "ops-hr", "ops-manufacturing", "ops-projects", "ops-support"]) {
    assert.ok(html.includes('id="page-' + page + '"'), "missing visible page " + page);
    assert.ok(html.includes('id="' + page + '-root"'), "missing live module root " + page);
  }
});

test("every operational form field is accepted by its authenticated Worker resource", () => {
  const modules = fs.readFileSync("products/joe-dave-operations-intelligence/operations-modules.js", "utf8");
  const worker = fs.readFileSync("cloudflare/worker.js", "utf8");
  const uiBlock = modules.match(/const defs=\{([\s\S]*?)\n\};/);
  const apiBlock = worker.match(/const opsDefs=\{([\s\S]*?)\n  \};/);
  assert.ok(uiBlock && apiBlock, "module maps must remain parseable");
  const uiDefs = [...uiBlock[1].matchAll(/'([^']+)':\{title:'[^']+',fields:\[([\s\S]*?)\]\}/g)];
  const apiDefs = new Map([...apiBlock[1].matchAll(/"([^"]+)":\{table:"[^"]+",key:"[^"]+",fields:\[([^\]]*)\]/g)]
    .map(m => [m[1], new Set([...m[2].matchAll(/"([^"]+)"/g)].map(x => x[1]))]));
  assert.equal(uiDefs.length, 28);
  for (const match of uiDefs) {
    const resource = match[1], allowed = apiDefs.get(resource);
    assert.ok(allowed, "missing API definition for " + resource);
    for (const field of [...match[2].matchAll(/\['([^']+)'/g)].map(x => x[1])) {
      assert.ok(allowed.has(field), resource + " form field is not accepted by the API: " + field);
    }
  }
});

test("operational modules use the same persistent authenticated session as the main app", () => {
  const modules = fs.readFileSync("products/joe-dave-operations-intelligence/operations-modules.js", "utf8");
  assert.ok(modules.includes("function getToken(){return localStorage.getItem('jd_session')"), "operational modules must read the main app's persistent session");
  assert.ok(modules.includes("'Authorization':'Bearer '+t"), "operational requests must send the bearer session token");
  assert.ok(modules.includes("function localMode(){return false}"), "operational workflows must not fall back to local simulation");
  assert.doesNotMatch(modules, /function localRequest\(/, "operational workflows must not silently write simulated device-only records");
  assert.doesNotMatch(modules, /LOCAL-DRAFT-|LOCAL-PO-|LOCAL-SO-/, "operational IDs must come from the live API");
});
