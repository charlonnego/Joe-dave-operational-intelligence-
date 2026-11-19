import { existsSync, readFileSync, writeFileSync, statSync } from 'node:fs';
import { resolve } from 'node:path';
const configPath = resolve('capacitor.config.ts');
const gradlePath = resolve('android/variables.gradle');
const appGradlePath = resolve('android/app/build.gradle');
if (!existsSync(configPath) || !existsSync(gradlePath) || !existsSync(appGradlePath)) throw new Error('Capacitor Android project generation did not create the expected Gradle files.');
const config = readFileSync(configPath, 'utf8');
const bundledIndex = resolve('www/index.html');
if (!existsSync(bundledIndex) || statSync(bundledIndex).size < 50000) {
  throw new Error('The real Joe&dave app is not bundled in www/index.html; refusing to build a placeholder APK.');
}
const bundledHtml = readFileSync(bundledIndex, 'utf8');
if (!bundledHtml.includes('operations-modules.js') || !bundledHtml.includes('https://joe-dave-operations-intelligence.pages.dev/api')) {
  throw new Error('Bundled app is missing operational modules or the native API gateway configuration.');
}
if (config.includes('server:') && /server:\\s*\\{[\\s\\S]*?url:/.test(config)) {
  throw new Error('Capacitor server.url must not be configured; the app must load bundled assets.');
}
if (!config.includes("appId: 'com.joedave.operations'")) throw new Error('Unexpected Android application ID.');
let variables = readFileSync(gradlePath, 'utf8');
if (/targetSdkVersion\s*=\s*36\b/.test(variables)) console.log('Android target SDK is already 36.');
else if (/targetSdkVersion\s*=\s*\d+/.test(variables)) {
  variables = variables.replace(/targetSdkVersion\s*=\s*\d+/, 'targetSdkVersion = 36');
  writeFileSync(gradlePath, variables);
  console.log('Set targetSdkVersion to 36.');
} else throw new Error('Could not find targetSdkVersion in android/variables.gradle; refusing to build with an unknown target API.');
const appGradle = readFileSync(appGradlePath, 'utf8');
if (!appGradle.includes('com.joedave.operations')) throw new Error('Generated Gradle project does not contain the expected application ID.');
console.log('Android project identity verified: com.joedave.operations');
