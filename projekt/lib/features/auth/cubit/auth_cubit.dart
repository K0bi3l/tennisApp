import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projekt/features/services/tournament_service.dart';
import '../services/auth_service.dart';

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
        emit(SignedOutState(message: 'Ten adres e-mail jest niewłaściwy.'));
      case SignInResult.userDisabled:
        emit(SignedOutState(message: 'Ten użytkownik jest zbanowany.'));
      case SignInResult.userNotFound:
        emit(SignedOutState(message: 'nie ma takiego użytkownika'));
      case SignInResult.wrongPassword:
        emit(SignedOutState(message: 'Niewłaściwe dane.'));
      case SignInResult.success:
        userEmail = email;
        await tournamentService.getUserTournaments();
        emit(SignedInState(email: email));
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    final result = await authService.signUpWithEmail(email, password);
    if (result == true) {
      await tournamentService.addUser(
        email,
        password,
        name,
      );
      emit(
        SignedOutState(message: 'Gratulacje! Udało Ci się zarejestrować!'),
      );
    } else {
      emit(
        SignedOutState(message: 'Rejestracja nieudana, spróbuj ponownie'),
      );
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
  SignedOutState({this.message});

  final String? message;

  @override
  List<Object?> get props => [message];
}
