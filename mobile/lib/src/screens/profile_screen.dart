import 'package:flutter/material.dart';

import '../api/api_client.dart';
import 'badges_screen.dart';
import 'game_history_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static const routeName = '/profile';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final Future<Map<String, dynamic>> _profile = ApiClient().getMap(
    '/app/me/',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil joueur')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profile,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Profil indisponible: ${snapshot.error}'),
            );
          }
          final payload = snapshot.data ?? {};
          final user = (payload['user'] as Map<String, dynamic>?) ?? {};
          final profile = (payload['profile'] as Map<String, dynamic>?) ?? {};
          final ranking = (payload['ranking'] as Map<String, dynamic>?) ?? {};
          final name =
              profile['display_name']?.toString() ??
              user['display_name']?.toString() ??
              user['username']?.toString() ??
              'Joueur du club';
          final rankName =
              ranking['rank_name']?.toString() ??
              user['rank_name']?.toString() ??
              'Novice I';
          final points = ranking['points'] ?? user['points'] ?? 0;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const CircleAvatar(
                radius: 42,
                child: Icon(Icons.person, size: 42),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.star),
                title: const Text('Rang'),
                subtitle: Text(rankName),
              ),
              ListTile(
                leading: const Icon(Icons.scoreboard),
                title: const Text('Points'),
                subtitle: Text('$points'),
              ),
              ListTile(
                leading: const Icon(Icons.mail),
                title: const Text('Email'),
                subtitle: Text(user['email']?.toString() ?? '-'),
              ),
              const Divider(height: 32),
              ListTile(
                leading: const Icon(Icons.workspace_premium),
                title: const Text('Badges'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    Navigator.pushNamed(context, BadgesScreen.routeName),
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Historique des parties'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    Navigator.pushNamed(context, GameHistoryScreen.routeName),
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Parametres'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    Navigator.pushNamed(context, SettingsScreen.routeName),
              ),
            ],
          );
        },
      ),
    );
  }
}
