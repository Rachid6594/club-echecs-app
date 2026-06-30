import 'package:flutter/material.dart';

class SpectatorScreen extends StatelessWidget {
  const SpectatorScreen({super.key});

  static const routeName = '/spectator';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vue spectateur')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ListTile(
            leading: Icon(Icons.remove_red_eye, color: Color(0xFF2563EB)),
            title: Text('Spectateurs en direct'),
            subtitle: Text('8 connectes · 42 vues totales'),
          ),
          const SizedBox(height: 12),
          AspectRatio(
            aspectRatio: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: const Center(child: Text('Echiquier spectateur')),
            ),
          ),
        ],
      ),
    );
  }
}

