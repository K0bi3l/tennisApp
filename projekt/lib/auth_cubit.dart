import 'package:flutter/material.dart';
import 'dart:async';
import 'auth_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required this.authService}) : super(authService.stateFromAuth) {
    emit(authService.stateFromAuth);
  }

  final AuthService authService;

  Future<void> signInWithEmail(String email, String password) async {
    emit(SigningInState());
    final result = await authService.signInWithEmail(email, password);

    switch (result) {
      case SignInResult.invalidEmail:
        emit(SignedOutState(error: 'This email address is invalid.'));
      case SignInResult.userDisabled:
        emit(SignedOutState(error: 'This user has been banned.'));
      case SignInResult.userNotFound:
        await _trySignUp(email, password);
      case SignInResult.wrongPassword:
        emit(SignedOutState(error: 'Invalid credentials.'));
      case SignInResult.success:
        emit(SignedInState(email: email));
    }
  }

  Future<void> _trySignUp(String email, String password) async {
    await authService.signUpWithEmail(email, password);
  }

  Future<void> signOut() async {
    await authService.signOut();
    emit(SignedOutState());
  }

  @override
  Future<void> close() async {
    return super.close();
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
