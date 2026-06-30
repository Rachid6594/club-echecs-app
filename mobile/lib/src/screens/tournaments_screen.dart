import 'package:flutter/material.dart';

import '../api/api_client.dart';
import 'tournament_detail_screen.dart';

class TournamentsScreen extends StatefulWidget {
  const TournamentsScreen({super.key});

  static const routeName = '/tournaments';

  @override
  State<TournamentsScreen> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends State<TournamentsScreen> {
  late final Future<List<dynamic>> _tournaments = ApiClient().getList('/admin/tournaments/');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tournois')),
      body: FutureBuilder<List<dynamic>>(
        future: _tournaments,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Tournois indisponibles: ${snapshot.error}'));
          }
          final tournaments = snapshot.data ?? [];
          if (tournaments.isEmpty) return const Center(child: Text('Aucun tournoi dans Supabase.'));
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: tournaments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final tournament = tournaments[index] as Map<String, dynamic>;
              return ListTile(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Color(0xFFE2E8F0))),
                leading: const Icon(Icons.emoji_events, color: Color(0xFFD4AF37)),
                title: Text(tournament['name']?.toString() ?? 'Tournoi'),
                subtitle: Text('${tournament['format']} · ${tournament['status']}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pushNamed(context, TournamentDetailScreen.routeName),
              );
            },
          );
        },
      ),
    );
  }
}
