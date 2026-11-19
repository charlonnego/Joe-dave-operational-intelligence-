import { readFileSync, existsSync } from 'node:fs';
import { resolve } from 'node:path';

const root = process.cwd();
const read = (p) => readFileSync(resolve(root, p), 'utf8');
const checks = [];
const pass = (name, detail='') => checks.push({status:'PASS',name,detail});
const block = (name, detail) => checks.push({status:'BLOCK',name,detail});
const fail = (name, detail) => checks.push({status:'FAIL',name,detail});

for (const p of ['index.html','operations-modules.js','manifest.webmanifest','service-worker.js','capacitor.config.ts','functions/api/[[path]].js','privacy.html','delete-account.html']) {
  if (existsSync(resolve(root,p))) pass('Required PWA source exists',p);
  else fail('Required PWA source exists',p+' is missing');
}

const index = read('index.html');
const ops = read('operations-modules.js');
const manifestText = read('manifest.webmanifest');
const sw = read('service-worker.js');
const cap = read('capacitor.config.ts');
const gateway = read('functions/api/[[path]].js');
const privacy = read('privacy.html');
const deletionPage = read('delete-account.html');

if (index.includes("const API='/api'") && index.includes("fetch('/api/health'")) pass('Core app uses same-origin API gateway');
else fail('Core app uses same-origin API gateway','Expected /api and /api/health');

if (ops.includes("const API='/api'") && !ops.includes('workers.dev')) pass('Operational modules use same-origin API gateway');
else fail('Operational modules use same-origin API gateway','Remove direct Worker origins; use /api');

if (gateway.includes('incoming.pathname.replace') && gateway.includes('fetch(new Request(upstream.toString(), init))')) pass('Pages API gateway proxies requests to the Worker');
else fail('Pages API gateway proxies requests to the Worker','Check the Pages Functions catch-all route');

if (privacy.includes('publish its registered legal identity') || privacy.includes('Before broad commercial launch')) block('Privacy policy operator identity and contact complete','The operator legal identity, registered address and dedicated privacy contact still need to be supplied and verified.');
else pass('Privacy policy has no pre-launch identity placeholder','The business owner must still verify the legal name, address and contact details before submission.');

if (privacy.includes('/delete-account.html') && deletionPage.includes("/auth/login") && deletionPage.includes("/account/deletion-request")) pass('External account-deletion request page is linked and calls authenticated API');
else fail('External account-deletion request page is linked and calls authenticated API','Verify privacy link, account sign-in and deletion-request API calls.');

try {
  const manifest = JSON.parse(manifestText);
  if (manifest.name && manifest.short_name && manifest.start_url && Array.isArray(manifest.icons) && manifest.icons.length >= 2) pass('PWA manifest parses and declares app icons');
  else fail('PWA manifest parses and declares app icons','Required name, short_name, start_url and at least two icons');
} catch (error) {
  fail('PWA manifest parses and declares app icons',error.message);
}

if (sw.includes('url.pathname.startsWith("/api/")') || sw.includes("url.pathname.startsWith('/api/')")) pass('Service worker excludes API requests from shell caching');
else fail('Service worker excludes API requests from shell caching','API responses must not be cached by the app shell');

if (/appId:\s*['"][^'"]+['"]/.test(cap) && /appName:\s*['"][^'"]+['"]/.test(cap) && /webDir:\s*['"]www['"]/.test(cap) && !/server:\s*\{[\s\S]*?url:/.test(cap)) pass('Capacitor bundles local web assets without remote app loading');
else fail('Capacitor bundles local web assets without remote app loading','Set webDir to www and remove server.url so the APK does not load the website remotely.');
if (index.includes('https://joe-dave-operations-intelligence.pages.dev/api')) pass('Native app API points to the production Pages gateway');
else fail('Native app API points to the production Pages gateway','Configure the native runtime to call the Pages API gateway.');

const gradleCandidates = ['android/app/build.gradle','android/app/build.gradle.kts','android/variables.gradle'];
const nativeGradle = gradleCandidates.find(p=>existsSync(resolve(root,p)));
const gradleText = nativeGradle ? read(nativeGradle) : null;
const sdkMatch = gradleText && (gradleText.match(/targetSdk(?:Version)?\s*(?:=\s*)?(\d+)/) || gradleText.match(/targetSdk\s*=\s*(\d+)/));
if (!gradleText) block('Android native release project present','Android project is not checked into this product directory; generate/sync it, then configure release signing and API 36+.');
else if (sdkMatch && Number(sdkMatch[1]) >= 36) pass('Android target SDK is API 36+');
else block('Android target SDK is API 36+','Native Gradle config was found, but API 36+ was not confirmed.');

const failures = checks.filter(x=>x.status==='FAIL').length;
const blockers = checks.filter(x=>x.status==='BLOCK').length;
for (const item of checks) console.log(`[${item.status}] ${item.name}${item.detail?' — '+item.detail:''}`);
console.log(`\nPreflight: ${checks.length-blockers-failures} passed, ${blockers} blocked, ${failures} failed.`);
if (failures) process.exitCode = 1;
else if (blockers) process.exitCode = 2;
