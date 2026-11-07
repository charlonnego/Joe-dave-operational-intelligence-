import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.joedave.operations',
  appName: 'Joe&dave',
  webDir: 'www',
  server: {
    // Keep API requests on the production Pages origin so /api continues
    // through the same-origin Cloudflare Pages Function gateway.
    url: 'https://joe-dave-operations-intelligence.pages.dev',
    cleartext: false,
    androidScheme: 'https'
  },
  android: {
    allowMixedContent: false
  }
};

export default config;
