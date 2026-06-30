import 'package:flutter/material.dart';

import 'home_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  static const routeName = '/register';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inscription')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const TextField(decoration: InputDecoration(labelText: 'Nom utilisateur')),
          const SizedBox(height: 12),
          const TextField(decoration: InputDecoration(labelText: 'Nom affiche')),
          const SizedBox(height: 12),
          const TextField(decoration: InputDecoration(labelText: 'Email')),
          const SizedBox(height: 12),
          const TextField(obscureText: true, decoration: InputDecoration(labelText: 'Mot de passe')),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => Navigator.pushReplacementNamed(context, HomeScreen.routeName),
            child: const Text('Creer mon compte'),
          ),
        ],
      ),
    );
  }
}

