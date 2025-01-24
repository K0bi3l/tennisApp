import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:projekt/tournament_creator.dart';
import 'package:projekt/tournament_cubit.dart';
import 'package:projekt/tournament_form_provider.dart';
import 'package:projekt/tournament_list_provider.dart';
import 'package:projekt/tournament_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:projekt/firebase_options.dart';
import 'app.dart';
import 'package:go_router/go_router.dart';
import 'basic_page.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_cubit.dart';
import 'auth_service.dart';
import 'tournament_service.dart';

void main() {
  runApp(const _App());
}

class _App extends StatefulWidget {
  const _App();

  @override
  State<_App> createState() => _AppState();
}

class _AppState extends State<_App> {
  final _initialization =
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        return switch (snapshot.connectionState) {
          ConnectionState.done => MultiProvider(
              providers: [
                ChangeNotifierProvider(
                  create: (context) => TournamentListData(),
                ),
                Provider(
                  create: (context) =>
                      AuthService(firebaseAuth: FirebaseAuth.instance),
                ),
                Provider(
                  create: (context) => TournamentService(
                    db: FirebaseFirestore.instance,
                    authService: context.read(),
                    tournamentData: context.read(),
                  ),
                ),
                BlocProvider(
                  create: (context) => AuthCubit(
                      authService: context.read(),
                      tournamentService: context.read()),
                ),
                ChangeNotifierProvider(
                  create: (context) => MyFormData(),
                ),
              ],
              child: MaterialApp.router(
                routerConfig: _router,
                locale: const Locale('pl'),
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('en'),
                  Locale('pl'),
                ],
                title: 'Tennis App',
                theme: ThemeData.from(
                    colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.purple,
                  dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
                )),
              ),
            ),
          _ => const MaterialApp(
              home: Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        };
      },
    );
  }
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const App(), //MyApp(),
      routes: [
        GoRoute(
          path: 'home',
          builder: (context, state) => const BasicPage(),
        ),
        GoRoute(
          path: 'create',
          builder: (context, state) => Page1(),
          routes: [
            GoRoute(
              path: 'stage2',
              builder: (context, state) => const LeagueTournamentPage2(),
            ),
          ],
        ),
        GoRoute(
          path: 'tournament/:tournamentId',
          builder: (context, state) {
            final String? id = state.pathParameters['tournamentId'];
            return BlocProvider(
              create: (_) =>
                  TournamentCubit(service: context.read(), tournamentId: id),
              child: TournamentPage(tournamentId: id!),
            );
          },
        ),
      ],
    ),
  ],
);
