import 'package:flutter/material.dart';

import '../api/api_client.dart';

class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});

  static const routeName = '/badges';

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  late final Future<List<dynamic>> _badges =
      ApiClient().getList('/app/badges/');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Badges')),
      body: FutureBuilder<List<dynamic>>(
        future: _badges,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Badges indisponibles: ${snapshot.error}'));
          }
          final badges = snapshot.data ?? [];
          if (badges.isEmpty) {
            return const Center(child: Text('Aucun badge dans Supabase.'));
          }
          return GridView.count(
            padding: const EdgeInsets.all(16),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.15,
            children: [
              for (final item in badges)
                _BadgeTile(
                    label: (item as Map<String, dynamic>)['name']?.toString() ??
                        'Badge'),
            ],
          );
        },
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.workspace_premium,
              size: 36, color: Color(0xFFD4AF37)),
          const SizedBox(height: 10),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
