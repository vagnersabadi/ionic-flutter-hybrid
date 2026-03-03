import { WebPlugin } from '@capacitor/core';
import type {
  FlutterRouterPluginInterface,
  FlutterNavigationOptions,
  FlutterNavigationResult
} from './definitions';

/**
 * Implementação Web (browser) do FlutterRouterPlugin.
 *
 * Usado apenas em ambiente de browser durante desenvolvimento.
 * Exibe um diálogo explicando que a navegação Flutter não está
 * disponível no browser — funciona apenas no app nativo.
 */
export class FlutterRouterWeb extends WebPlugin implements FlutterRouterPluginInterface {

  async navigateTo(options: FlutterNavigationOptions): Promise<FlutterNavigationResult> {
    console.warn('[FlutterRouter] Flutter navigation is not available in the browser.');
    console.info('[FlutterRouter] Would navigate to route:', options.route, 'with params:', options.params);

    if (typeof window !== 'undefined') {
      const paramsStr = options.params
        ? JSON.stringify(options.params, null, 2)
        : 'nenhum';

      window.alert(
        `[FlutterRouter — Fallback Browser]\n\n` +
        `Rota: ${options.route}\n` +
        `Params: ${paramsStr}\n\n` +
        `Esta navegacao abre uma tela Flutter no app nativo.\n` +
        `Execute no device ou emulador Android/iOS para testar.`
      );
    }

    return { completed: false };
  }

  async goBack(_result?: Record<string, any>): Promise<void> {
    console.warn('[FlutterRouter] goBack() nao disponivel no browser.');
  }
}
