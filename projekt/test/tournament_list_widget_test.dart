import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projekt/features/auth/services/auth_service.dart';
import 'package:projekt/features/basic_page/join_and_create_tournaments/widgets/tournaments_list.dart';
import 'package:projekt/features/basic_page/providers/tournament_list_provider.dart';
import 'package:projekt/features/models/tournament.dart';
import 'package:projekt/features/services/tournament_service.dart';
import 'package:provider/provider.dart';

void main() {
  group('', () {
    late MockFirebaseAuth mockAuthentication;
    late AuthService authService;
    late FakeFirebaseFirestore mockDb;
    late TournamentListData data;
    late MockUser user;

    setUp(() {
      data = TournamentListData();
      user = MockUser(email: 'abc@gmail.com', uid: 'abc');
      mockAuthentication = MockFirebaseAuth(signedIn: true, mockUser: user);
      mockDb = FakeFirebaseFirestore();

      authService = AuthService(firebaseAuth: mockAuthentication);
    });

    testWidgets('Test widoczności turnieju wczytanego z bazy ', (tester) async {
      await mockDb
          .collection('users')
          .doc(user.uid)
          .collection('tournaments')
          .doc('1')
          .set({
        'code': '234567',
        'startDate': DateTime.now(),
        'endDate': DateTime.now(),
        'id': '1',
        'name': 'test',
        'playersCount': 4,
        'type': 'league',
      });

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (context) => data,
              ),
              Provider(
                create: (context) => TournamentService(
                  db: mockDb,
                  authService: authService,
                  tournamentData: data,
                ),
              ),
            ],
            child: const TournamentsList(width: 1000),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();

      final button = find.byType(TournamentEntry);

      expect(button, findsOneWidget);
    });

    testWidgets('Test braku turniejów', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (context) => data,
              ),
              Provider(
                create: (context) => TournamentService(
                  db: mockDb,
                  authService: authService,
                  tournamentData: data,
                ),
              ),
            ],
            child: const TournamentsList(width: 1000),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();

      expect(find.byType(TournamentEntry), findsNothing);
    });

    testWidgets('Test widoczności turnieju dodanego przez dataProvider',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (context) => data,
              ),
              Provider(
                create: (context) => TournamentService(
                  db: mockDb,
                  authService: authService,
                  tournamentData: data,
                ),
              ),
            ],
            child: const TournamentsList(width: 1000),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();

      data.addTournament = Tournament(
        code: '234324',
        name: 'abc',
        startDate: DateTime.now().toString(),
        endDate: DateTime.now().toString(),
        type: 'League',
        numOfPlayers: 4,
        id: '1',
      );

      await tester.pump();

      expect(find.byType(TournamentEntry), findsOneWidget);
    });

    testWidgets(
        'test połączenia wejścia z bazy danych i dodania przez dataSource',
        (tester) async {
      await mockDb
          .collection('users')
          .doc(user.uid)
          .collection('tournaments')
          .doc('1')
          .set({
        'code': '234567',
        'startDate': DateTime.now(),
        'endDate': DateTime.now(),
        'id': '1',
        'name': 'test',
        'playersCount': 4,
        'type': 'league',
      });

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (context) => data,
              ),
              Provider(
                create: (context) => TournamentService(
                  db: mockDb,
                  authService: authService,
                  tournamentData: data,
                ),
              ),
            ],
            child: const TournamentsList(width: 1000),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();

      data.addTournament = Tournament(
        code: '234324',
        name: 'abc',
        startDate: DateTime.now().toString(),
        endDate: DateTime.now().toString(),
        type: 'League',
        numOfPlayers: 4,
        id: '1',
      );

      await tester.pump();

      expect(find.byType(TournamentEntry), findsExactly(2));
    });
  });
}
