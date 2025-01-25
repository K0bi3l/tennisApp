import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projekt/features/auth/cubit/auth_cubit.dart';
import 'package:projekt/features/auth/widgets/auth_widget.dart';
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:projekt/features/auth/services/auth_service.dart';
import 'package:projekt/features/basic_page/providers/tournament_list_provider.dart';
import 'package:projekt/tournament_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MockAuthService extends Mock implements AuthService {}

class MockTournamentService extends Mock implements TournamentService {}

void main() {
  group('', () {
    late MockFirebaseAuth mockAuthentication;
    late AuthService authService;
    late FakeFirebaseFirestore mockDb;
    late TournamentService tournamentService;

    setUp(() {
      mockAuthentication = MockFirebaseAuth();
      mockDb = FakeFirebaseFirestore();
      authService = AuthService(firebaseAuth: mockAuthentication);
      tournamentService = TournamentService(
          db: mockDb,
          authService: authService,
          tournamentData: TournamentListData());
    });

    testWidgets('Test domyślnego widoku logowania',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (context) => AuthCubit(
                authService: authService, tournamentService: tournamentService),
            child: const AuthWidget(),
          ),
        ),
      );

      expect(find.text('Zaloguj się'), findsOneWidget);
    });

    testWidgets('test rejestracji', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (context) => AuthCubit(
                authService: authService, tournamentService: tournamentService),
            child: const AuthWidget(),
          ),
        ),
      );
      final button = find.text('Nie masz konta? Zarejestruj się');
      await tester.tap(button);
      await tester.pump();

      expect(find.text('Masz już konto? Zaloguj się'), findsOneWidget);
      //expect(find.text('Zaloguj się'), findsNothing);
    });

    testWidgets('test walidacji loginu', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (context) => AuthCubit(
                authService: authService, tournamentService: tournamentService),
            child: const AuthWidget(),
          ),
        ),
      );
      await tester.enterText(find.widgetWithText(TextField, 'E-Mail'), 'abc');
      await tester.pump();
      await tester.tap(find.text('Zaloguj się'));
      await tester.pump();
      expect(find.text('Wprowadź poprawny e-mail'), findsOne);
    });

    testWidgets('test walidacji hasła', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (context) => AuthCubit(
                authService: authService, tournamentService: tournamentService),
            child: const AuthWidget(),
          ),
        ),
      );
      await tester.enterText(find.widgetWithText(TextField, 'Hasło'), 'abc');
      await tester.pump();
      await tester.tap(find.text('Zaloguj się'));
      await tester.pump();
      expect(find.text('Hasło musi mieć co najmniej 8 znaków'), findsOne);
    });
  });
}
