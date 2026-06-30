import 'package:flutter/material.dart';

import 'tournament_detail_screen.dart';

class TournamentsScreen extends StatelessWidget {
  const TournamentsScreen({super.key});

  static const routeName = '/tournaments';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tournois')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Color(0xFFE2E8F0))),
            leading: const Icon(Icons.emoji_events, color: Color(0xFFD4AF37)),
            title: const Text('Coupe du Club'),
            subtitle: const Text('Elimination directe · inscriptions ouvertes'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, TournamentDetailScreen.routeName),
          ),
        ],
      ),
    );
  }
}

