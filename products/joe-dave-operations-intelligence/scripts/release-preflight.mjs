import { readFileSync, existsSync } from 'node:fs';
import { resolve } from 'node:path';

const root = process.cwd();
const read = (p) => readFileSync(resolve(root, p), 'utf8');
const checks = [];
const pass = (name, detail='') => checks.push({status:'PASS',name,detail});
const block = (name, detail) => checks.push({status:'BLOCK',name,detail});
const fail = (name, detail) => checks.push({status:'FAIL',name,detail});

for (const p of ['index.html','operations-modules.js','manifest.webmanifest','service-worker.js','capacitor.config.ts']) {
  if (existsSync(resolve(root,p))) pass('Required PWA source exists',p);
  else fail('Required PWA source exists',p+' is missing');
}

const index = read('index.html');
const ops = read('operations-modules.js');
const manifestText = read('manifest.webmanifest');
const sw = read('service-worker.js');
const cap = read('capacitor.config.ts');

if (index.includes("const API='/api'") && index.includes("fetch('/api/health'")) pass('Core app uses same-origin API gateway');
else fail('Core app uses same-origin API gateway','Expected /api and /api/health');

if (ops.includes("const API='/api'") && !ops.includes('workers.dev')) pass('Operational modules use same-origin API gateway');
else fail('Operational modules use same-origin API gateway','Remove direct Worker origins; use /api');

try {
  const manifest = JSON.parse(manifestText);
  if (manifest.name && manifest.short_name && manifest.start_url && Array.isArray(manifest.icons) && manifest.icons.length >= 2) pass('PWA manifest parses and declares app icons');
  else fail('PWA manifest parses and declares app icons','Required name, short_name, start_url and at least two icons');
} catch (error) {
  fail('PWA manifest parses and declares app icons',error.message);
}

if (sw.includes('url.pathname.startsWith("/api/")') || sw.includes("url.pathname.startsWith('/api/')")) pass('Service worker excludes API requests from shell caching');
else fail('Service worker excludes API requests from shell caching','API responses must not be cached by the app shell');

if (/appId:\s*['"][^'"]+['"]/.test(cap) && /appName:\s*['"][^'"]+['"]/.test(cap) && /https:\/\//.test(cap) && /cleartext:\s*false/.test(cap)) pass('Capacitor identity and HTTPS remote origin configured');
else fail('Capacitor identity and HTTPS remote origin configured','Review appId, appName, HTTPS server URL and cleartext=false');

const gradlePath = 'android/app/build.gradle';
const gradleKtsPath = 'android/app/build.gradle.kts';
const nativeGradle = existsSync(resolve(root,gradlePath)) ? read(gradlePath) : existsSync(resolve(root,gradleKtsPath)) ? read(gradleKtsPath) : null;
if (!nativeGradle) block('Android native release project present','Android project is not checked into this product directory; generate/sync it, then configure release signing and API 36+.');
else if (/targetSdk(?:Version)?\s*(?:=\s*)?36/.test(nativeGradle) || /targetSdk\s*=\s*36/.test(nativeGradle)) pass('Android target SDK is API 36+');
else block('Android target SDK is API 36+','Native Gradle config was found, but API 36+ was not confirmed.');

const failures = checks.filter(x=>x.status==='FAIL').length;
const blockers = checks.filter(x=>x.status==='BLOCK').length;
for (const item of checks) console.log(`[${item.status}] ${item.name}${item.detail?' — '+item.detail:''}`);
console.log(`\nPreflight: ${checks.length-blockers-failures} passed, ${blockers} blocked, ${failures} failed.`);
if (failures) process.exitCode = 1;
else if (blockers) process.exitCode = 2;
