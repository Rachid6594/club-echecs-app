import 'package:flutter/material.dart';

import 'login_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  color: Color(0xFF0F172A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sports_esports,
                  color: Color(0xFFD4AF37),
                  size: 44,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Club Echecs',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text('Competition, classement, parties en direct'),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () => Navigator.pushReplacementNamed(
                  context,
                  LoginScreen.routeName,
                ),
                child: const Text('Entrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
