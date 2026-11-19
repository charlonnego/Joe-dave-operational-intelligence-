import { existsSync, readFileSync, writeFileSync } from 'node:fs';
import { resolve } from 'node:path';
const required = ['ANDROID_KEYSTORE_BASE64', 'ANDROID_KEYSTORE_PASSWORD', 'ANDROID_KEY_ALIAS', 'ANDROID_KEY_PASSWORD'];
const present = required.filter(key => Boolean(process.env[key]));
if (present.length === 0) {
  console.log('No Android upload-key secrets configured; release AAB will be unsigned and cannot be submitted to Google Play.');
  process.exit(0);
}
if (present.length !== required.length) throw new Error('Android upload signing is only partially configured. Set all four ANDROID_KEYSTORE_* secrets.');
const gradlePath = resolve('android/app/build.gradle');
if (!existsSync(gradlePath)) throw new Error('Android app Gradle file not found.');
const keyPath = resolve('android/app/joe-dave-upload.jks');
const keyBytes = Buffer.from(process.env.ANDROID_KEYSTORE_BASE64, 'base64');
if (keyBytes.length < 512) throw new Error('Decoded upload keystore is unexpectedly small.');
writeFileSync(keyPath, keyBytes, { mode: 0o600 });
let gradle = readFileSync(gradlePath, 'utf8');
if (gradle.includes('signingConfigs.release')) throw new Error('Release signing is already configured; refusing to duplicate it.');
if (!/android\s*\{/.test(gradle) || !/buildTypes\s*\{\s*release\s*\{/.test(gradle)) throw new Error('Could not safely locate Android release build configuration.');
const signingBlock = '\n    signingConfigs {\n        release {\n            storeFile file("joe-dave-upload.jks")\n            storePassword System.getenv("ANDROID_KEYSTORE_PASSWORD")\n            keyAlias System.getenv("ANDROID_KEY_ALIAS")\n            keyPassword System.getenv("ANDROID_KEY_PASSWORD")\n        }\n    }\n';
gradle = gradle.replace(/android\s*\{/, match => match + signingBlock);
gradle = gradle.replace(/(buildTypes\s*\{\s*release\s*\{)/, '$1\n            signingConfig signingConfigs.release');
writeFileSync(gradlePath, gradle);
console.log('Configured release signing using repository secrets; keystore remains outside Git.');
