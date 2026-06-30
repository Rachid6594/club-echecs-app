import 'package:flutter/material.dart';

class TournamentDetailScreen extends StatelessWidget {
  const TournamentDetailScreen({super.key});

  static const routeName = '/tournament-detail';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail tournoi')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text('Coupe du Club', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          SizedBox(height: 8),
          Text('Format elimination directe · 16 joueurs max'),
          SizedBox(height: 20),
          _BracketPreview(),
        ],
      ),
    );
  }
}

class _BracketPreview extends StatelessWidget {
  const _BracketPreview();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Tableau tournoi', style: TextStyle(fontWeight: FontWeight.w700)),
            SizedBox(height: 12),
            Text('Quart 1  →  Demi 1'),
            Text('Quart 2  →  Demi 1'),
            Text('Quart 3  →  Demi 2'),
            Text('Quart 4  →  Demi 2'),
          ],
        ),
      ),
    );
  }
}

