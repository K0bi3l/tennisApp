import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum SignInResult {
  invalidEmail,
  userDisabled,
  userNotFound,
  wrongPassword,
  success,
}

class AuthService {
  const AuthService({required this.firebaseAuth});

  final FirebaseAuth firebaseAuth;

  bool get isSignedIn => currentUser != null;

  User? get currentUser => firebaseAuth.currentUser;

  String get userEmail => currentUser!.email!;

  Future<bool> signUpWithEmail(String email, String password) async {
    if (isSignedIn) {
      return false;
    }
    try {
      await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      FlutterError.reportError(FlutterErrorDetails(exception: e));
    }

    return true;
  }

  Future<SignInResult> signInWithEmail(String email, String password) async {
    if (isSignedIn) {
      await firebaseAuth.signOut();
    }

    try {
      await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return SignInResult.success;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          return SignInResult.invalidEmail;
        case 'user-disabled':
          return SignInResult.userDisabled;
        case 'user-not-found' || 'invalid-credential':
          return SignInResult.userNotFound;
        case 'wrong-password':
          return SignInResult.wrongPassword;
        default:
          rethrow;
      }
    }
  }

  Future<void> signOut() async {
    if (isSignedIn) {
      await firebaseAuth.signOut();
    }
  }
}
