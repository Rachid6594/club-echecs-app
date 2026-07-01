import 'package:flutter/material.dart';

import 'game_screen.dart';
import 'game_history_screen.dart';
import 'invitations_screen.dart';
import 'live_matches_screen.dart';
import 'badges_screen.dart';
import 'members_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'rankings_screen.dart';
import 'settings_screen.dart';
import 'tournaments_screen.dart';

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
            onPressed: () =>
                Navigator.pushNamed(context, ProfileScreen.routeName),
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.35,
        children: [
          _HomeTile(
              icon: Icons.people,
              label: 'Membres',
              onTap: () =>
                  Navigator.pushNamed(context, MembersScreen.routeName)),
          _HomeTile(
              icon: Icons.mail,
              label: 'Invitations',
              onTap: () =>
                  Navigator.pushNamed(context, InvitationsScreen.routeName)),
          _HomeTile(
              icon: Icons.grid_on,
              label: 'Parties',
              onTap: () => Navigator.pushNamed(context, GameScreen.routeName)),
          _HomeTile(
              icon: Icons.visibility,
              label: 'En direct',
              onTap: () =>
                  Navigator.pushNamed(context, LiveMatchesScreen.routeName)),
          _HomeTile(
              icon: Icons.emoji_events,
              label: 'Tournois',
              onTap: () =>
                  Navigator.pushNamed(context, TournamentsScreen.routeName)),
          _HomeTile(
              icon: Icons.leaderboard,
              label: 'Classement',
              onTap: () =>
                  Navigator.pushNamed(context, RankingsScreen.routeName)),
          _HomeTile(
              icon: Icons.workspace_premium,
              label: 'Badges',
              onTap: () =>
                  Navigator.pushNamed(context, BadgesScreen.routeName)),
          _HomeTile(
              icon: Icons.notifications,
              label: 'Notifications',
              onTap: () =>
                  Navigator.pushNamed(context, NotificationsScreen.routeName)),
          _HomeTile(
              icon: Icons.history,
              label: 'Historique',
              onTap: () =>
                  Navigator.pushNamed(context, GameHistoryScreen.routeName)),
          _HomeTile(
              icon: Icons.settings,
              label: 'Parametres',
              onTap: () =>
                  Navigator.pushNamed(context, SettingsScreen.routeName)),
        ],
      ),
    );
  }
}

class _HomeTile extends StatelessWidget {
  const _HomeTile({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: DecoratedBox(
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
      ),
    );
  }
}
