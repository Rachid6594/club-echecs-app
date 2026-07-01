import 'package:flutter/material.dart';

import 'screens/badges_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/game_history_screen.dart';
import 'screens/home_screen.dart';
import 'screens/game_screen.dart';
import 'screens/invitations_screen.dart';
import 'screens/live_matches_screen.dart';
import 'screens/login_screen.dart';
import 'screens/member_detail_screen.dart';
import 'screens/members_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/rankings_screen.dart';
import 'screens/register_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/spectator_screen.dart';
import 'screens/tournament_detail_screen.dart';
import 'screens/tournaments_screen.dart';

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
        ForgotPasswordScreen.routeName: (_) => const ForgotPasswordScreen(),
        HomeScreen.routeName: (_) => const HomeScreen(),
        ProfileScreen.routeName: (_) => const ProfileScreen(),
        MembersScreen.routeName: (_) => const MembersScreen(),
        MemberDetailScreen.routeName: (_) => const MemberDetailScreen(),
        InvitationsScreen.routeName: (_) => const InvitationsScreen(),
        GameHistoryScreen.routeName: (_) => const GameHistoryScreen(),
        SettingsScreen.routeName: (_) => const SettingsScreen(),
        GameScreen.routeName: (_) => const GameScreen(),
        LiveMatchesScreen.routeName: (_) => const LiveMatchesScreen(),
        SpectatorScreen.routeName: (_) => const SpectatorScreen(),
        TournamentsScreen.routeName: (_) => const TournamentsScreen(),
        TournamentDetailScreen.routeName: (_) => const TournamentDetailScreen(),
        RankingsScreen.routeName: (_) => const RankingsScreen(),
        BadgesScreen.routeName: (_) => const BadgesScreen(),
        NotificationsScreen.routeName: (_) => const NotificationsScreen(),
      },
    );
  }
}
