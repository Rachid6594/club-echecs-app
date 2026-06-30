import 'package:flutter/material.dart';

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  static const routeName = '/badges';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Badges')),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.15,
        children: const [
          _BadgeTile(asset: 'assets/badges/novice_i.svg', label: 'Novice I'),
          _BadgeTile(asset: 'assets/badges/first_win.svg', label: 'Premiere victoire'),
          _BadgeTile(asset: 'assets/badges/tournament_champion.svg', label: 'Champion'),
          _BadgeTile(asset: 'assets/badges/legende.svg', label: 'Legende'),
        ],
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.asset, required this.label});

  final String asset;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.workspace_premium, size: 36, color: Color(0xFFD4AF37)),
          const SizedBox(height: 10),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

