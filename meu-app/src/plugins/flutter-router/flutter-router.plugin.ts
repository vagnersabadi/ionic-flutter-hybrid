import { registerPlugin } from '@capacitor/core';
import type { FlutterRouterPluginInterface } from './definitions';

const FlutterRouterPlugin = registerPlugin<FlutterRouterPluginInterface>('FlutterRouter');

export { FlutterRouterPlugin };
