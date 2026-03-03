import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'pages/flutter_home.dart';
import 'pages/flutter_detail.dart';

/// MethodChannel para comunicacao com o Ionic/Capacitor
const _channel = MethodChannel('com.example.hybrid/flutter_router');

/// Rota inicial — pode ser sobrescrita pelo Ionic via channel
String _initialRoute = '/flutter-home';

/// Parametros passados pelo Ionic
Map<String, dynamic> _initialParams = {};

/// Configuracao do GoRouter com as rotas Flutter
final _router = GoRouter(
  initialLocation: _initialRoute,
  routes: [
    GoRoute(
      path: '/flutter-home',
      builder: (context, state) => FlutterHomePage(
        params: state.extra as Map<String, dynamic>? ?? _initialParams,
      ),
    ),
    GoRoute(
      path: '/flutter-detail',
      builder: (context, state) => FlutterDetailPage(
        params: state.extra as Map<String, dynamic>? ?? _initialParams,
      ),
    ),
  ],
);

/// Entry point do Flutter module.
/// Chamado pelo FlutterEngine quando o Ionic abre uma tela Flutter.
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Escuta comandos do Ionic (navegacao e parametros)
  _channel.setMethodCallHandler((call) async {
    if (call.method == "navigateTo") {
      final args = Map<String, dynamic>.from(call.arguments as Map);
      _initialParams = Map<String, dynamic>.from(args["params"] ?? {});
      final route = args["route"] as String? ?? "/flutter-home";
      _router.go(route, extra: _initialParams);
    }
    return null;
  });

  runApp(const FlutterHybridApp());
}

class FlutterHybridApp extends StatelessWidget {
  const FlutterHybridApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "Flutter Module",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3880FF)),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}
