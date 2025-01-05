import 'package:firebase_auth/firebase_auth.dart';

enum SignInResult {
  invalidEmail,
  userDisabled,
  userNotFound,
  wrongPassword,
  success,
}

class AuthService {
  const AuthService({required this.firebase_auth});

  final FirebaseAuth firebase_auth;

  bool get isSignedIn => currentUser != null;

  User? get currentUser => firebase_auth.currentUser;

  String get userEmail => currentUser!.email!;

  Future<bool> signUpWithEmail(String email, String password) async {
    if (isSignedIn) {
      return false;
    }

    await firebase_auth.createUserWithEmailAndPassword(
        email: email, password: password);

    return true;
  }

  Future<SignInResult> signInWithEmail(String email, String password) async {
    if (isSignedIn) {
      await firebase_auth.signOut();
    }

    try {
      await firebase_auth.signInWithEmailAndPassword(
          email: email, password: password);
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
      await firebase_auth.signOut();
    }
  }
}
