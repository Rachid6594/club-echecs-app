import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const routeName = '/notifications';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(leading: Icon(Icons.mail), title: Text('Invitation recue'), subtitle: Text('Awa vous invite a jouer.')),
          ListTile(leading: Icon(Icons.emoji_events), title: Text('Tournoi ouvert'), subtitle: Text('Coupe du Club accepte les inscriptions.')),
          ListTile(leading: Icon(Icons.workspace_premium), title: Text('Badge gagne'), subtitle: Text('Premiere victoire debloquee.')),
        ],
      ),
    );
  }
}

