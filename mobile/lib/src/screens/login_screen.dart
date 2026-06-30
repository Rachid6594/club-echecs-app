import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const routeName = '/login';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const TextField(decoration: InputDecoration(labelText: 'Email')),
          const SizedBox(height: 12),
          const TextField(obscureText: true, decoration: InputDecoration(labelText: 'Mot de passe')),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => Navigator.pushReplacementNamed(context, HomeScreen.routeName),
            child: const Text('Se connecter'),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, RegisterScreen.routeName),
            child: const Text('Creer un compte'),
          ),
        ],
      ),
    );
  }
}

