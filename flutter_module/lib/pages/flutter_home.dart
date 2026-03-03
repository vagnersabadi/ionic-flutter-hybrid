import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

const _channel = MethodChannel('com.example.hybrid/flutter_router');

class FlutterHomePage extends StatelessWidget {
  final Map params;
  const FlutterHomePage({super.key, this.params = const {}});

  Future goBack() async {
    await _channel.invokeMethod('goBack', {'returnedFrom': 'flutter-home'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Home'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: goBack,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Flutter Home Page', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('Tela Flutter — navegada a partir do Ionic via FlutterRouterPlugin.'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/flutter-detail', extra: {'itemId': '1'}),
                child: const Text('Ir para Flutter Detail'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: goBack,
                child: const Text('Voltar ao Ionic'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}