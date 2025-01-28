import 'package:bloc_test/bloc_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projekt/features/auth/services/auth_service.dart';
import 'package:projekt/features/basic_page/providers/tournament_list_provider.dart';
import 'package:projekt/features/services/tournament_service.dart';
import 'package:projekt/features/tournament_page/cubit/tournament_cubit.dart';

void main() {
  group('testy cubitu tournament_cubit', () {
    late MockFirebaseAuth auth;
    late FakeFirebaseFirestore db;
    late AuthService authService;
    late TournamentService service;
    late TournamentListData data;

    setUp(
      () {
        auth = MockFirebaseAuth();
        db = FakeFirebaseFirestore();
        db.collection('tournaments').doc('1').set({
          'code': '345344',
          'startDate': DateTime.now().toString(),
          'endDate': DateTime.now().toString(),
          'isScheduled': false,
          'name': '1',
          'owner': 'dsfdsf',
          'playersCount': 2,
          'type': 'bracket',
        });
        db
            .collection('tournaments')
            .doc('1')
            .collection('users')
            .doc('user1')
            .set({
          'name': 'user1',
          'wins': 0,
          'ties': 0,
          'loses': 0,
          'points': 0,
        });
        data = TournamentListData();
        auth = MockFirebaseAuth();
        authService = AuthService(firebaseAuth: auth);
        service = TournamentService(
          db: db,
          authService: authService,
          tournamentData: data,
        );
      },
    );

    blocTest<TournamentCubit, TournamentState>(
      'test initial state - tournament not ready',
      build: () => TournamentCubit(service: service, tournamentId: '1'),
      expect: () => [TournamentNotReady(participantsReady: 1, participants: 2)],
    );
    blocTest<TournamentCubit, TournamentState>(
      'test initial state - tournament ready',
      build: () {
        db
            .collection('tournaments')
            .doc('1')
            .collection('users')
            .doc('user2')
            .set({
          'name': 'user2',
          'wins': 0,
          'ties': 0,
          'loses': 0,
          'points': 0,
        });
        return TournamentCubit(service: service, tournamentId: '1');
      },
      expect: () => [TournamentReady()],
    );
  });
}
