import type { CapacitorConfig } from '@capacitor/cli';
import { KeyboardResize, KeyboardStyle } from '@capacitor/keyboard';

let config: CapacitorConfig = {
  appId: 'com.highlighter.app',
  appName: 'highlighter',
  webDir: 'build',
  plugins: {
    SafeArea: {
      enabled: true,
      customColorsForSystemBars: true,
      statusBarColor: '#000000',
      statusBarContent: 'light',
      navigationBarColor: '#000000',
      navigationBarContent: 'light',
      offset: 0,
    },
    Keyboard: {
      resize: KeyboardResize.Native,
      style: KeyboardStyle.Dark,
      resizeOnFullScreen: true,
    },
    SplashScreen: {
			launchShowDuration: 0
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
      url: "http://192.168.1.115:3000",
      // url: "http://10.10.242.180:3000",
      // url: "http://10.8.4.16:3000",
      // url: "http://10.8.4.108:3000",
      cleartext: true
    },
    ...config
  }
}

export default config;