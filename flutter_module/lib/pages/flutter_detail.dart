import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _channel = MethodChannel('com.example.hybrid/flutter_router');

class FlutterDetailPage extends StatelessWidget {
  final Map params;
  const FlutterDetailPage({super.key, this.params = const {}});

  Future goBack() async {
    await _channel.invokeMethod('goBack', {'returnedFrom': 'flutter-detail'});
  }

  @override
  Widget build(BuildContext context) {
    final title = params['title'] as String? ?? 'Detalhe';
    final itemId = params['itemId'] as String? ?? '-';
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).canPop() ? Navigator.of(context).pop() : goBack(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFF54C5F8), borderRadius: BorderRadius.circular(20)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.flutter_dash, color: Colors.white, size: 18),
                SizedBox(width: 6),
                Text('Tela Flutter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ]),
            ),
            const SizedBox(height: 24),
            Text('Flutter Detail — Item #' + itemId, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('Esta e a pagina de detalhe Flutter. Pode ser acessada tanto pelo Ionic quanto pelo Flutter Home.'),
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Item ID'),
                subtitle: Text(itemId),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: goBack,
                child: const Text('Fechar e Voltar ao Ionic'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}