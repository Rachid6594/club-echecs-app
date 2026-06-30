import 'package:flutter/material.dart';

class RankingsScreen extends StatelessWidget {
  const RankingsScreen({super.key});

  static const routeName = '/rankings';

  @override
  Widget build(BuildContext context) {
    const players = [('Rachid', '120 pts'), ('Awa', '98 pts'), ('Moussa', '74 pts')];
    return Scaffold(
      appBar: AppBar(title: const Text('Classement general')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: players.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) => ListTile(
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Color(0xFFE2E8F0))),
          leading: CircleAvatar(child: Text('${index + 1}')),
          title: Text(players[index].$1),
          subtitle: Text(players[index].$2),
        ),
      ),
    );
  }
}

