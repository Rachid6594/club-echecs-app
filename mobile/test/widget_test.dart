import 'package:flutter_test/flutter_test.dart';

import 'package:club_echecs_mobile/src/app.dart';

void main() {
  testWidgets('app boots to login after splash', (WidgetTester tester) async {
    await tester.pumpWidget(const ClubEchecsApp());

    expect(find.text('Club Echecs'), findsOneWidget);

    await tester.tap(find.text('Entrer'));
    await tester.pumpAndSettle();

    expect(find.text('Connexion'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
  });
}
