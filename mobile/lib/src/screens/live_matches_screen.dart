import 'package:flutter/material.dart';

import 'spectator_screen.dart';

class LiveMatchesScreen extends StatelessWidget {
  const LiveMatchesScreen({super.key});

  static const routeName = '/live-matches';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Matchs en direct')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) => ListTile(
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Color(0xFFE2E8F0))),
          leading: const Icon(Icons.visibility, color: Color(0xFF2563EB)),
          title: Text('Table ${index + 1}'),
          subtitle: const Text('Blancs vs Noirs'),
          trailing: const Text('12 vues'),
          onTap: () => Navigator.pushNamed(context, SpectatorScreen.routeName),
        ),
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemCount: 3,
      ),
    );
  }
}

