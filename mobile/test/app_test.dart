import 'package:club_echecs_mobile/src/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('splash navigates to login', (tester) async {
    await tester.pumpWidget(const ClubEchecsApp());

    expect(find.text('Club Echecs'), findsOneWidget);

    await tester.tap(find.text('Entrer'));
    await tester.pumpAndSettle();

    expect(find.text('Connexion'), findsOneWidget);
  });

  testWidgets('login can navigate to register and home', (tester) async {
    await tester.pumpWidget(const ClubEchecsApp());
    await tester.tap(find.text('Entrer'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Creer un compte'));
    await tester.pumpAndSettle();

    expect(find.text('Inscription'), findsOneWidget);

    await tester.tap(find.text('Creer mon compte'));
    await tester.pumpAndSettle();

    expect(find.text('Accueil joueur'), findsOneWidget);
    expect(find.text('Membres'), findsOneWidget);
  });

  testWidgets('home opens profile', (tester) async {
    await tester.pumpWidget(const ClubEchecsApp());
    await tester.tap(find.text('Entrer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Profil'));
    await tester.pumpAndSettle();

    expect(find.text('Profil joueur'), findsOneWidget);
    expect(find.text('Novice I'), findsOneWidget);
  });
}
