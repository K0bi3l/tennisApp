import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:provider/provider.dart';
import 'package:projekt/tournament_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  test('Test metody GetTournaments', () async {
    final mockUser = MockUser(uid: '12345', email: 'a@gmail.com');

    final mockAuth = MockFirebaseAuth(mockUser: mockUser);

    await mockAuth.signInWithEmailAndPassword(
        email: 'a@gmail.com', password: 'password');

    final instance = FakeFirebaseFirestore();

    await instance
        .collection('users')
        .doc('12345')
        .collection('tournaments')
        .add({
      'id': 'sdfdsfdsfsf',
      'name': 'abc',
    });

    await instance
        .collection('users')
        .doc('12345')
        .collection('tournaments')
        .add({
      'id': 'sdfdsfd',
      'name': 'ab',
    });

    //final provider = TournamentService(db: instance, authService: );
  });
}
