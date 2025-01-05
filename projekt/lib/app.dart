import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projekt/auth_service.dart';
import 'package:projekt/auth_widget.dart';
import 'package:projekt/tournament_service.dart';
import 'package:provider/provider.dart';
import 'auth_cubit.dart';
import 'BasicPage.dart';

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          Provider(
            create: (context) =>
                AuthService(firebase_auth: FirebaseAuth.instance),
          ),
          BlocProvider(
              create: (context) => AuthCubit(authService: context.read())),
          Provider(
            create: (context) => TournamentService(
                db: FirebaseFirestore.instance, authService: context.read()),
          ),
        ],
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            return switch (state) {
              SignedInState() => BasicPage(state: state),
              SigningInState() =>
                const Center(child: CircularProgressIndicator()),
              SignedOutState() => AuthWidget(),
            };
          },
        ));
  }
}
