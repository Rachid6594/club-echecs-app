import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const routeName = '/profile';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil joueur')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          CircleAvatar(radius: 42, child: Icon(Icons.person, size: 42)),
          SizedBox(height: 16),
          Center(child: Text('Joueur du club', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700))),
          SizedBox(height: 24),
          ListTile(leading: Icon(Icons.star), title: Text('Rang'), subtitle: Text('Novice I')),
          ListTile(leading: Icon(Icons.scoreboard), title: Text('Points'), subtitle: Text('0')),
          ListTile(leading: Icon(Icons.workspace_premium), title: Text('Badges'), subtitle: Text('Premiere saison')),
        ],
      ),
    );
  }
}

