import 'package:flutter/material.dart';

class SpectatorScreen extends StatelessWidget {
  const SpectatorScreen({super.key});

  static const routeName = '/spectator';

  @override
  Widget build(BuildContext context) {
    final match =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
        {};
    final white = match['white_username']?.toString() ?? 'Blancs';
    final black = match['black_username']?.toString() ?? 'Noirs';
    final status = match['status']?.toString() ?? 'active';
    return Scaffold(
      appBar: AppBar(title: const Text('Vue spectateur')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.remove_red_eye, color: Color(0xFF2563EB)),
            title: Text('$white vs $black'),
            subtitle: Text('Statut $status | vues totales'),
          ),
          const SizedBox(height: 12),
          AspectRatio(
            aspectRatio: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Center(child: Text('Echiquier spectateur')),
            ),
          ),
        ],
      ),
    );
  }
}
