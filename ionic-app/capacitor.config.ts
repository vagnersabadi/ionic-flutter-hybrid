import { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.example.ionicflutterhybrid',
  appName: 'IonicFlutterHybrid',
  webDir: 'www',
  plugins: {
    FlutterRouter: {
      flutterModulePath: '../flutter_module',
    }
  }
};

export default config;
