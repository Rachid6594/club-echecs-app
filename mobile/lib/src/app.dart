import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/game_screen.dart';
import 'screens/live_matches_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/register_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/spectator_screen.dart';

class ClubEchecsApp extends StatelessWidget {
  const ClubEchecsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Club Echecs',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          primary: const Color(0xFF2563EB),
          secondary: const Color(0xFFD4AF37),
          surface: const Color(0xFFF8FAFC),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        useMaterial3: true,
      ),
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (_) => const SplashScreen(),
        LoginScreen.routeName: (_) => const LoginScreen(),
        RegisterScreen.routeName: (_) => const RegisterScreen(),
        HomeScreen.routeName: (_) => const HomeScreen(),
        ProfileScreen.routeName: (_) => const ProfileScreen(),
        GameScreen.routeName: (_) => const GameScreen(),
        LiveMatchesScreen.routeName: (_) => const LiveMatchesScreen(),
        SpectatorScreen.routeName: (_) => const SpectatorScreen(),
      },
    );
  }
}

