import 'package:flutter/material.dart';

import '../api/api_client.dart';

class GameHistoryScreen extends StatefulWidget {
  const GameHistoryScreen({super.key});

  static const routeName = '/game-history';

  @override
  State<GameHistoryScreen> createState() => _GameHistoryScreenState();
}

class _GameHistoryScreenState extends State<GameHistoryScreen> {
  late final Future<List<dynamic>> _games = ApiClient().getList(
    '/app/games/history/',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historique des parties')),
      body: FutureBuilder<List<dynamic>>(
        future: _games,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Historique indisponible: ${snapshot.error}'),
            );
          }
          final games = snapshot.data ?? [];
          if (games.isEmpty) {
            return const Center(child: Text('Aucune partie dans Supabase.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: games.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final game = games[index] as Map<String, dynamic>;
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(
                  '${game['white_username'] ?? 'Blancs'} vs ${game['black_username'] ?? 'Noirs'}',
                ),
                subtitle: Text(
                  '${game['status']} | ${game['result'] ?? 'en cours'}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
