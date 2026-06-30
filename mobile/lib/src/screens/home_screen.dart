import 'package:flutter/material.dart';

import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const routeName = '/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil joueur'),
        actions: [
          IconButton(
            tooltip: 'Profil',
            onPressed: () => Navigator.pushNamed(context, ProfileScreen.routeName),
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        children: const [
          _HomeTile(icon: Icons.people, label: 'Membres'),
          _HomeTile(icon: Icons.mail, label: 'Invitations'),
          _HomeTile(icon: Icons.grid_on, label: 'Parties'),
          _HomeTile(icon: Icons.emoji_events, label: 'Tournois'),
          _HomeTile(icon: Icons.leaderboard, label: 'Classement'),
          _HomeTile(icon: Icons.workspace_premium, label: 'Badges'),
        ],
      ),
    );
  }
}

class _HomeTile extends StatelessWidget {
  const _HomeTile({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 34, color: const Color(0xFF2563EB)),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

