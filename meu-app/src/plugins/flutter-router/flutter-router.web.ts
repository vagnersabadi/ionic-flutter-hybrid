import { WebPlugin } from '@capacitor/core';
import type {
  FlutterNavigationOptions,
  FlutterNavigationResult,
  FlutterRouterPluginInterface,
} from './definitions';

export class FlutterRouterWeb extends WebPlugin implements FlutterRouterPluginInterface {
  async navigateTo(_options: FlutterNavigationOptions): Promise<FlutterNavigationResult> {
    return {
      completed: false,
      data: { reason: 'Flutter navigation is only available on native Android/iOS' },
    };
  }

  async goBack(_result?: Record<string, unknown>): Promise<void> {
    return;
  }
}
