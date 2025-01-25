import 'package:projekt/tournament_service.dart';
import 'dart:async';
import '../services/auth_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required this.authService, required this.tournamentService})
      : super(authService.stateFromAuth) {
    userEmail = authService.currentUser?.email;
    emit(authService.stateFromAuth);
  }

  final AuthService authService;
  final TournamentService tournamentService;
  String? userEmail;

  Future<void> signInWithEmail(String email, String password) async {
    emit(SigningInState());
    final result = await authService.signInWithEmail(email, password);

    switch (result) {
      case SignInResult.invalidEmail:
        emit(SignedOutState(error: 'This email address is invalid.'));
      case SignInResult.userDisabled:
        emit(SignedOutState(error: 'This user has been banned.'));
      case SignInResult.userNotFound:
        emit(SignedOutState(error: 'nie ma takiego użytkownika'));
      case SignInResult.wrongPassword:
        emit(SignedOutState(error: 'Invalid credentials.'));
      case SignInResult.success:
        userEmail = email;
        await tournamentService.getUserTournaments();
        emit(SignedInState(email: email));
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    emit(SigningInState());
    final result = await authService.signUpWithEmail(email, password);
    if (result == true) {
      await authService.signInWithEmail(email, password);
      tournamentService.addUser(
          email, password, name); //przenieść do auth service
      emit(SignedOutState());
    } else {
      emit(SignedOutState(error: 'nastąpił błąd przy rejestracji'));
    }
  }

  Future<void> signOut() async {
    await authService.signOut();
    userEmail = null;
    emit(SignedOutState());
  }
}

extension on AuthService {
  AuthState get stateFromAuth =>
      isSignedIn ? SignedInState(email: userEmail) : SignedOutState();
}

sealed class AuthState with EquatableMixin {}

class SignedInState extends AuthState {
  SignedInState({required this.email});

  final String email;

  @override
  List<Object?> get props => [email];
}

class SigningInState extends AuthState {
  @override
  List<Object?> get props => [];
}

class SignedOutState extends AuthState {
  SignedOutState({this.error});

  final String? error;

  @override
  List<Object?> get props => [error];
}
