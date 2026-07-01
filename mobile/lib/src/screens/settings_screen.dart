import 'package:flutter/material.dart';

import '../api/api_client.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Parametres')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ListTile(
              leading: Icon(Icons.language),
              title: Text('Langue'),
              subtitle: Text('Francais')),
          const ListTile(
              leading: Icon(Icons.timer),
              title: Text('Cadence par defaut'),
              subtitle: Text('Blitz 5+0')),
          const ListTile(
              leading: Icon(Icons.security),
              title: Text('Securite'),
              subtitle: Text('Backend source de verite')),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: () async {
              await ApiClient().logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, LoginScreen.routeName, (_) => false);
              }
            },
            child: const Text('Se deconnecter'),
          ),
        ],
      ),
    );
  }
}
