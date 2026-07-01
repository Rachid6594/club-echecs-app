import 'package:flutter/material.dart';

import '../api/api_client.dart';
import 'spectator_screen.dart';

class LiveMatchesScreen extends StatefulWidget {
  const LiveMatchesScreen({super.key});

  static const routeName = '/live-matches';

  @override
  State<LiveMatchesScreen> createState() => _LiveMatchesScreenState();
}

class _LiveMatchesScreenState extends State<LiveMatchesScreen> {
  late final Future<List<dynamic>> _matches =
      ApiClient().getList('/app/live-matches/');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Matchs en direct')),
      body: FutureBuilder<List<dynamic>>(
        future: _matches,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Matchs indisponibles: ${snapshot.error}'));
          }
          final matches = snapshot.data ?? [];
          if (matches.isEmpty) {
            return const Center(
                child: Text('Aucun match en direct dans Supabase.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: matches.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final match = matches[index] as Map<String, dynamic>;
              return ListTile(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Color(0xFFE2E8F0))),
                leading: const Icon(Icons.visibility, color: Color(0xFF2563EB)),
                title: Text(match['tournament_name']?.toString() ??
                    'Table ${index + 1}'),
                subtitle: Text(
                    '${match['white_username'] ?? 'Blancs'} vs ${match['black_username'] ?? 'Noirs'}'),
                trailing: Text(match['status']?.toString() ?? ''),
                onTap: () => Navigator.pushNamed(
                    context, SpectatorScreen.routeName,
                    arguments: match),
              );
            },
          );
        },
      ),
    );
  }
}
