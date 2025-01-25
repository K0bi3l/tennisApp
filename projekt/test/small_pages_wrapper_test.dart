import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projekt/features/auth/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:projekt/features/tournament_page/tournament_page.dart';
import 'package:provider/provider.dart';
import 'package:projekt/tournament.dart';

void main() {
  group('testy navigation baru dla widoku TournamentPage', () {
    late AuthService authService;
    late MockFirebaseAuth mockAuth;
    late MockUser mockUser;
    late Tournament info;

    setUp(() {
      mockUser = MockUser(email: 'abc@gmail.com', uid: '12345');
      mockAuth = MockFirebaseAuth(signedIn: true, mockUser: mockUser);
      authService = AuthService(firebaseAuth: mockAuth);
      info = Tournament(
          userIds: ['abc', 'bcd'],
          name: 'abc',
          type: 'league',
          startDate: DateTime.now().toString(),
          endDate: DateTime.now().toString(),
          code: '234234',
          id: '1',
          numOfPlayers: 4,
          matches: []);
    });

    testWidgets('check default view', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Provider(
            create: (context) => authService,
            child: SmallReadyTournamentPage(tournamentInfo: info),
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.arrow_right_rounded), findsOne);
    });

    testWidgets('check navbar view change', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Provider(
            create: (context) => authService,
            child: SmallReadyTournamentPage(tournamentInfo: info),
          ),
        ),
      );

      await tester.pump();
      final button = find.byIcon(Icons.verified_user);

      await tester.tap(button);
      await tester.pump();
      await tester.pump();

      expect(find.text('abc'), findsOne);
    });
  });
}
