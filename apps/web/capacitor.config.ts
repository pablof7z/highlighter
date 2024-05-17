import type { CapacitorConfig } from '@capacitor/cli';

let config: CapacitorConfig = {
  appId: 'com.highlighter.app',
  appName: 'highlighter',
  webDir: 'build',
  plugins: {
    SplashScreen: {
			launchShowDuration: 1
		},
    PushNotifications: {
      presentationOptions: ["badge", "sound", "alert"]
    },
    Badge: {
      persist: true,
      autoClear: false,
    },
  }
};

if (process.env.NODE_ENV === 'development') {
  config = {
    bundledWebRuntime: false,
    server: {
      // url: "http://192.168.1.115:3000",
      url: "http://10.10.241.7:3000",
      cleartext: true
    },
    ...config
  }
}

export default config;
