import 'package:flutter/material.dart';

import '../api/api_client.dart';

class RankingsScreen extends StatefulWidget {
  const RankingsScreen({super.key});

  static const routeName = '/rankings';

  @override
  State<RankingsScreen> createState() => _RankingsScreenState();
}

class _RankingsScreenState extends State<RankingsScreen> {
  late final Future<List<dynamic>> _rankings = ApiClient().getList(
    '/app/rankings/',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Classement general')),
      body: FutureBuilder<List<dynamic>>(
        future: _rankings,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Classement indisponible: ${snapshot.error}'),
            );
          }
          final rankings = snapshot.data ?? [];
          if (rankings.isEmpty) {
            return const Center(child: Text('Aucun classement dans Supabase.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: rankings.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final ranking = rankings[index] as Map<String, dynamic>;
              return ListTile(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(
                  ranking['display_name']?.toString() ??
                      ranking['username']?.toString() ??
                      'Joueur',
                ),
                subtitle: Text(
                  '${ranking['points']} pts | ${ranking['rank_name']}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
