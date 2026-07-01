import 'package:flutter/material.dart';

import 'badges_screen.dart';
import 'game_history_screen.dart';
import 'game_screen.dart';
import 'invitations_screen.dart';
import 'live_matches_screen.dart';
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
        title: const Text('Club Echecs'),
        actions: [
          IconButton(
            tooltip: 'Profil',
            onPressed: () =>
                Navigator.pushNamed(context, ProfileScreen.routeName),
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const _HeroPanel(),
          const SizedBox(height: 16),
          const _SectionTitle(title: 'Jouer maintenant'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ActionCard(
                  icon: Icons.grid_on,
                  title: 'Partie rapide',
                  subtitle: 'Lancer une table',
                  color: const Color(0xFF2563EB),
                  onTap: () =>
                      Navigator.pushNamed(context, GameScreen.routeName),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionCard(
                  icon: Icons.visibility,
                  title: 'En direct',
                  subtitle: 'Voir les matchs',
                  color: const Color(0xFF16A34A),
                  onTap: () =>
                      Navigator.pushNamed(context, LiveMatchesScreen.routeName),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _SectionTitle(title: 'Club'),
          const SizedBox(height: 10),
          _MenuGrid(
            items: [
              _MenuItem(
                icon: Icons.people_alt_outlined,
                label: 'Membres',
                onTap: () =>
                    Navigator.pushNamed(context, MembersScreen.routeName),
              ),
              _MenuItem(
                icon: Icons.mail_outline,
                label: 'Invitations',
                onTap: () =>
                    Navigator.pushNamed(context, InvitationsScreen.routeName),
              ),
              _MenuItem(
                icon: Icons.emoji_events_outlined,
                label: 'Tournois',
                onTap: () =>
                    Navigator.pushNamed(context, TournamentsScreen.routeName),
              ),
              _MenuItem(
                icon: Icons.leaderboard_outlined,
                label: 'Classement',
                onTap: () =>
                    Navigator.pushNamed(context, RankingsScreen.routeName),
              ),
              _MenuItem(
                icon: Icons.workspace_premium_outlined,
                label: 'Badges',
                onTap: () =>
                    Navigator.pushNamed(context, BadgesScreen.routeName),
              ),
              _MenuItem(
                icon: Icons.notifications_outlined,
                label: 'Notifications',
                onTap: () =>
                    Navigator.pushNamed(context, NotificationsScreen.routeName),
              ),
              _MenuItem(
                icon: Icons.history,
                label: 'Historique',
                onTap: () =>
                    Navigator.pushNamed(context, GameHistoryScreen.routeName),
              ),
              _MenuItem(
                icon: Icons.settings_outlined,
                label: 'Parametres',
                onTap: () =>
                    Navigator.pushNamed(context, SettingsScreen.routeName),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.casino_outlined,
                    color: Color(0xFF0F172A),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bienvenue au club',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Defie, progresse, suis les competitions.',
                        style: TextStyle(color: Color(0xFFCBD5E1)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(
                  child: _StatChip(
                    label: 'Rang',
                    value: 'Novice I',
                    icon: Icons.star,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _StatChip(
                    label: 'Points',
                    value: '0',
                    icon: Icons.scoreboard,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _StatChip(
                    label: 'Club',
                    value: 'Actif',
                    icon: Icons.verified,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 62),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFFD4AF37)),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
          ),
          Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuGrid extends StatelessWidget {
  const _MenuGrid({required this.items});

  final List<_MenuItem> items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.85,
      ),
      itemBuilder: (context, index) => _MenuTile(item: items[index]),
    );
  }
}

class _MenuItem {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.item});

  final _MenuItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  item.icon,
                  size: 20,
                  color: const Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
