import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.joedave.operations',
  appName: 'Joe&dave',
  // The full PWA is copied into www before cap sync. Do not set server.url:
  // that would replace the bundled app with a remote website.
  webDir: 'www',
  android: {
    allowMixedContent: false
  }
};

export default config;
