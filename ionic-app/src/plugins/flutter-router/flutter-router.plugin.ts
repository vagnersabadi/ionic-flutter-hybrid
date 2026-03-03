import { registerPlugin } from '@capacitor/core';
import type { FlutterRouterPluginInterface } from './definitions';

/**
 * FlutterRouterPlugin — Plugin Capacitor customizado
 *
 * Permite navegar de páginas Ionic para páginas Flutter nativas.
 * - Android: abre FlutterActivity com a rota especificada
 * - iOS: apresenta FlutterViewController modalmente
 * - Browser: fallback com alerta informativo
 *
 * Uso:
 *   import { FlutterRouterPlugin } from '../../plugins/flutter-router/flutter-router.plugin';
 *   await FlutterRouterPlugin.navigateTo({ route: '/flutter-home', params: { id: '1' } });
 */
const FlutterRouterPlugin = registerPlugin<FlutterRouterPluginInterface>(
  'FlutterRouter',
  {
    web: () => import('./flutter-router.web').then(m => new m.FlutterRouterWeb())
  }
);

export { FlutterRouterPlugin };
