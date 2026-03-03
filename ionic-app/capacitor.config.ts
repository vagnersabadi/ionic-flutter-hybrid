import { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.example.ionicflutterhybrid',
  appName: 'IonicFlutterHybrid',
  webDir: 'www',
  plugins: {
    FlutterRouter: {
      flutterModulePath: '../flutter_module', // not necessary if the Flutter module is in the same workspace, but can be used to specify a custom path
    }
  }
};

export default config;
