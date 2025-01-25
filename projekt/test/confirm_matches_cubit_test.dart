import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:projekt/features/auth/services/auth_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:projekt/features/tournament_page/matches_displayer/schedule_page/match_widgets/cubit/confirm_matches_cubit.dart';
import 'package:projekt/features/tournament_page/models/sport_match.dart';
import 'package:projekt/features/basic_page/providers/tournament_list_provider.dart';
import 'package:projekt/features/services/tournament_service.dart';

class MockTournamentService extends Mock implements TournamentService {}

void main() {
  group('ConfirmMatchesCubit', () {
    late MockUser mockUser1;
    late MockUser mockUser2;
    late TournamentListData listData;
    late FakeFirebaseFirestore mockFirestore;
    late SportMatch mockMatch1;
    late SportMatch mockMatch2;

    setUp(() {
      mockUser1 = MockUser(uid: '12345', email: '12345@gmail.com');
      mockUser2 = MockUser(uid: '67890', email: '67890@gmail.com');
      listData = TournamentListData();
      mockMatch1 = SportMatch(
          player1: '12345',
          player2: '67890',
          player1Id: '12345',
          player2Id: '67890',
          id: 'match1',
          tournamentId: 'tournament1');
      mockMatch2 = SportMatch(
          player1: 'afsfdsf',
          player2: 'dsfljksdfkl',
          player1Id: 'dflsdjfdsk',
          player2Id: 'dslfjdshjfh',
          id: 'match1',
          tournamentId: 'tournament1');
      mockFirestore = FakeFirebaseFirestore();
      mockFirestore
          .collection('tournaments')
          .doc('tournament1')
          .collection('rounds')
          .doc('round 1')
          .collection('matches')
          .doc('match1')
          .set({
        'player1': '12345@gmail.com',
        'player2': '67890@gmail.com',
        'player1Id': '12345',
        'player2Id': '67890',
        'result1': null,
        'result2': null,
      });
      mockFirestore
          .collection('tournaments')
          .doc('tournament1')
          .collection('users')
          .doc('12345')
          .set({
        'loses': 0,
        'wins': 0,
        'ties': 0,
        'points': 0,
        'name': '12345',
      });
      mockFirestore
          .collection('tournaments')
          .doc('tournament1')
          .collection('users')
          .doc('67890')
          .set({
        'loses': 0,
        'wins': 0,
        'ties': 0,
        'points': 0,
        'name': '67890',
      });
    });

    test('test inicjalizacji z dobrym id ', () {
      MockFirebaseAuth mockAuth1 =
          MockFirebaseAuth(signedIn: true, mockUser: mockUser1);
      AuthService authService1 = AuthService(firebaseAuth: mockAuth1);
      TournamentService tournamentService1 = TournamentService(
          db: mockFirestore,
          authService: authService1,
          tournamentData: listData);

      ConfirmMatchesCubit cubit = ConfirmMatchesCubit(
          tournamentService: tournamentService1,
          authService: authService1,
          match: mockMatch1);

      expect(cubit.state, AvailableState());
    });

    test('test inicjalizacji ze złym id', () {
      MockFirebaseAuth mockAuth2 =
          MockFirebaseAuth(signedIn: true, mockUser: mockUser2);
      AuthService authService2 = AuthService(firebaseAuth: mockAuth2);
      TournamentService tournamentService2 = TournamentService(
          db: mockFirestore,
          authService: authService2,
          tournamentData: listData);
      ConfirmMatchesCubit cubit = ConfirmMatchesCubit(
          tournamentService: tournamentService2,
          authService: authService2,
          match: mockMatch2);

      expect(cubit.state, NotAvailableState());
    });

    test('test dodania wyniku do meczu bez wyniku', () async {
      MockFirebaseAuth mockAuth1 =
          MockFirebaseAuth(signedIn: true, mockUser: mockUser1);
      AuthService authService1 = AuthService(firebaseAuth: mockAuth1);
      TournamentService tournamentService1 = TournamentService(
          db: mockFirestore,
          authService: authService1,
          tournamentData: listData);

      ConfirmMatchesCubit cubit = ConfirmMatchesCubit(
          tournamentService: tournamentService1,
          authService: authService1,
          match: mockMatch1);
      await cubit.setMatchScore(
          mockMatch1.tournamentId,
          mockMatch1.id,
          1,
          2.toString(),
          1.toString(),
          mockMatch1.player1Id,
          mockMatch1.player2Id);
      expect(cubit.state, NotAvailableState());
    });
  });
}
