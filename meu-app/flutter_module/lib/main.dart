import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _channel = MethodChannel('com.example.hybrid/flutter_router');

void main() => runApp(const HybridApp());

class HybridApp extends StatelessWidget {
  const HybridApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Hybrid',
      initialRoute: '/flutter-home',
      routes: {
        '/flutter-home': (_) => const FlutterHomePage(),
      },
    );
  }
}

class FlutterHomePage extends StatelessWidget {
  const FlutterHomePage({super.key});

  Future<void> _goBackToIonic() async {
    await _channel.invokeMethod('goBack', {'returnedFrom': 'flutter-home'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Home')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Página Flutter aberta pelo Ionic',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text('Use o botão abaixo para voltar ao Ionic.'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _goBackToIonic,
                child: const Text('Voltar para Ionic'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
