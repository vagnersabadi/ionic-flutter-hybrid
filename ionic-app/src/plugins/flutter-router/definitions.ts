/**
 * Parâmetros para navegação ao Flutter
 */
export interface FlutterNavigationOptions {
  /**
   * Rota Flutter de destino.
   * Deve corresponder a uma rota registrada no MaterialApp do Flutter.
   * Exemplos: '/flutter-home', '/flutter-detail', '/flutter-cart'
   */
  route: string;

  /**
   * Parâmetros opcionais — passados como:
   * - Android: Activity extras (Bundle)
   * - iOS: initialRoute arguments
   */
  params?: Record<string, string | number | boolean>;
}

/**
 * Resultado retornado quando a tela Flutter é fechada e
 * o controle volta ao Ionic.
 */
export interface FlutterNavigationResult {
  /** Dados retornados pela tela Flutter via MethodChannel */
  data?: Record<string, any>;
  /** true = voltou normalmente; false = cancelou/voltou com back */
  completed: boolean;
}

/**
 * Interface do FlutterRouterPlugin
 */
export interface FlutterRouterPluginInterface {
  /**
   * Navega de uma página Ionic para uma página Flutter.
   * Retorna uma Promise que resolve quando o Flutter fecha a tela
   * e retorna o controle ao Ionic.
   */
  navigateTo(options: FlutterNavigationOptions): Promise<FlutterNavigationResult>;

  /**
   * Fecha a tela Flutter atual e retorna ao Ionic.
   * Geralmente chamado pelo Flutter via MethodChannel,
   * mas pode ser disparado programaticamente.
   */
  goBack(result?: Record<string, any>): Promise<void>;
}
