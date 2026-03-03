export interface FlutterNavigationOptions {
  route: string;
  params?: Record<string, string | number | boolean>;
}

export interface FlutterNavigationResult {
  data?: Record<string, unknown>;
  completed: boolean;
}

export interface FlutterRouterPluginInterface {
  navigateTo(options: FlutterNavigationOptions): Promise<FlutterNavigationResult>;
  goBack(result?: Record<string, unknown>): Promise<void>;
}
