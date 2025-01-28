import 'package:bloc_test/bloc_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projekt/features/auth/cubit/auth_cubit.dart';
import 'package:projekt/features/auth/services/auth_service.dart';
import 'package:projekt/features/basic_page/providers/tournament_list_provider.dart';
import 'package:projekt/features/services/tournament_service.dart';

void main() {
  group(
    'authCubit tests',
    () {
      late FakeFirebaseFirestore db;
      late MockFirebaseAuth mockAuth;
      late TournamentService tournamentService;
      late MockUser mockUser;
      late AuthService authService;
      late TournamentListData data;

      setUp(
        () {
          db = FakeFirebaseFirestore();
          data = TournamentListData();
          mockUser = MockUser(uid: '1', email: 'abc@gmail.com');
          mockAuth = MockFirebaseAuth(mockUser: mockUser);
          authService = AuthService(firebaseAuth: mockAuth);
          tournamentService = TournamentService(
            db: db,
            authService: authService,
            tournamentData: data,
          );
        },
      );

      blocTest(
        'test Signing in',
        build: () => AuthCubit(
          authService: authService,
          tournamentService: tournamentService,
        ),
        act: (bloc) => bloc.signInWithEmail('abc@gmail.com', 'abc'),
        expect: () => [SigningInState(), SignedInState(email: 'abc@gmail.com')],
      );

      blocTest(
        'test SingingUp',
        build: () => AuthCubit(
          authService: authService,
          tournamentService: tournamentService,
        ),
        act: (bloc) => bloc.signUp('abc@gmail.com', 'abc', 'abc'),
        expect: () => [
          SignedOutState(message: 'Gratulacje! Udało Ci się zarejestrować!'),
        ],
      );

      blocTest(
        'test SigningOut',
        build: () {
          final mockAuth = MockFirebaseAuth(signedIn: true, mockUser: mockUser);
          authService = AuthService(firebaseAuth: mockAuth);
          return AuthCubit(
            authService: authService,
            tournamentService: tournamentService,
          );
        },
        act: (bloc) => bloc.signOut(),
        expect: () => [SignedOutState()],
      );
    },
  );
}
