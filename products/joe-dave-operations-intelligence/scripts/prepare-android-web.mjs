import { cp, mkdir, readFile, rm, stat } from 'node:fs/promises';
import { resolve } from 'node:path';

const root = process.cwd();
const out = resolve(root, 'www');
const required = [
  'index.html',
  'operations-modules.js',
  'manifest.webmanifest',
  'icon-192.svg',
  'icon-512.svg',
  'service-worker.js',
  'platform.html',
  'sales-intelligence.html',
  'privacy.html',
  'delete-account.html'
];

await rm(out, { recursive: true, force: true });
await mkdir(out, { recursive: true });
for (const file of required) {
  const source = resolve(root, file);
  const info = await stat(source).catch(() => null);
  if (!info?.isFile()) throw new Error('Required Joe&dave web asset is missing: ' + file);
  await cp(source, resolve(out, file));
}
const html = await readFile(resolve(out, 'index.html'), 'utf8');
if (html.length < 50000 || !html.includes('Operations Intelligence') || !html.includes('operations-modules.js')) {
  throw new Error('Refusing to package a placeholder or incomplete Joe&dave index.html');
}
const apiCheck = html.includes('https://joe-dave-operations-intelligence.pages.dev/api');
if (!apiCheck) throw new Error('Native API base URL was not configured in the bundled application.');
console.log('Prepared bundled Joe&dave web app:', required.join(', '));
console.log('Bundled index.html bytes:', Buffer.byteLength(html));
