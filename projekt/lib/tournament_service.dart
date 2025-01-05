import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:projekt/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'app.dart';
import 'package:flutter/material.dart';
import 'tournament_form_provider.dart';

class TournamentService {
  TournamentService({required this.db, required this.authService});

  final FirebaseFirestore db;
  final AuthService authService;

  Future<(String id, String code)> createTournament(
      String? name,
      TournamentType? type,
      String numOfPlayers,
      String startofTournament,
      String endOfTournament) async {
    final random = Random();
    final code = random.nextInt(899999) + 1000000;
    final docRef = await db.collection('tournaments').add({
      'name': name,
      'type': type,
      'number of players': int.parse(numOfPlayers),
      'starting date': startofTournament,
      'ending date': endOfTournament,
      'code': code.toString(),
      'owner': authService.currentUser!.uid,
    });
    await db
        .collection('users')
        .doc(authService.currentUser!.uid)
        .collection('tournaments')
        .doc(docRef.id.toString())
        .set({
      'name': name,
      'id': docRef.id,
    });

    return (docRef.id, code.toString());
  }

  Future<bool> joinTournament(String code) async {
    try {
      String tournamentId = '';
      await db
          .collection('tournaments')
          .where('code', isEqualTo: code)
          .get()
          .then(
        (QuerySnapshot snapshot) {
          for (DocumentSnapshot snap in snapshot.docs) {
            tournamentId = (snap.data() as Map<String, dynamic>)['id'];
          }
          if (tournamentId == '') {
            return false;
          }
        },
      );
      final doc = db.collection('tournaments').doc(tournamentId);
      await doc.get().then((DocumentSnapshot doc) async {
        final data = doc.data() as Map<String, dynamic>;
        final code = data['code'];
        await db
            .collection('users')
            .doc(authService.currentUser!.uid)
            .collection('tournaments')
            .doc(tournamentId)
            .set({
          'name': data['name'],
          'id': tournamentId,
        });
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}
