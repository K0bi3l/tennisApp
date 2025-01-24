import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projekt/auth_service.dart';
import 'package:projekt/tournament_list_provider.dart';
import 'package:projekt/tournament_participant.dart';
import 'tournament_form_provider.dart';
import 'tournament.dart';
import 'package:flutter/foundation.dart';
import 'sport_match.dart';
import 'users_list_shuffler.dart';

class TournamentService {
  TournamentService(
      {required this.db,
      required this.authService,
      required this.tournamentData});

  final FirebaseFirestore db;
  final AuthService authService;
  final TournamentListData tournamentData;

  List<Tournament> userTournaments = [];

  Future<void> addUser(String login, String password, String name) async {
    await db.collection('users').doc(authService.currentUser!.uid).set({
      'email': login,
      'password': password.hashCode,
      'name': name,
    });
  }

  Future<String> createTournament(
      String? name,
      TournamentType? type,
      String numOfPlayers,
      String startofTournament,
      String endOfTournament) async {
    final random = Random();
    final code = random.nextInt(899999) + 100000;
    final docRef = await db.collection('tournaments').add({
      'name': name,
      'type': type!.name,
      'playersCount': int.parse(numOfPlayers),
      'startDate': startofTournament,
      'endDate': endOfTournament,
      'code': code.toString(),
      'owner': authService.currentUser!.uid,
      'isScheduled': false,
    });
    final userName = await getUserName(authService.currentUser!.uid);
    await db
        .collection('tournaments')
        .doc(docRef.id)
        .collection('users')
        .doc(authService.currentUser!.uid)
        .set({
      // tu jest zmienione
      'name': userName,
      'points': 0,
      'wins': 0,
      'ties': 0,
      'loses': 0,
    });
    await db
        .collection('users')
        .doc(authService.currentUser!.uid)
        .collection('tournaments')
        .doc(docRef.id.toString())
        .set({
      'name': name,
      'id': docRef.id,
      'type': type.name,
      'playersCount': int.parse(numOfPlayers),
      'startDate': startofTournament,
      'endDate': endOfTournament,
      'code': code.toString(),
    });

    return code.toString();
  }

  Future<String> getUserName(String userId) async {
    final docRef = await db.collection('users').doc(userId).get();

    return docRef.data()!['name'];
  }

  Future<bool> joinTournament(String code) async {
    try {
      String tournamentId = '';
      int playersCount;
      int totalPlayers;

      final query = await db
          .collection('tournaments')
          .where('code', isEqualTo: code)
          .get();

      for (DocumentSnapshot snap in query.docs) {
        tournamentId = snap.id;
      }
      if (tournamentId == '') {
        return false;
      }

      (playersCount, totalPlayers) =
          await getTournamentUsersCount(tournamentId);

      if (playersCount == totalPlayers) {
        return false;
      }

      final doc = db.collection('tournaments').doc(tournamentId);
      await doc.get().then((DocumentSnapshot doc) async {
        final data = doc.data() as Map<String, dynamic>;
        final userName = await getUserName(authService.currentUser!.uid);
        await db
            .collection('tournaments')
            .doc(tournamentId)
            .collection('users')
            .doc(authService.currentUser!.uid)
            .set({
          // tu jest zmienione
          'name': userName,
          'points': 0,
          'wins': 0,
          'ties': 0,
          'loses': 0,
        });
        await db
            .collection('users')
            .doc(authService.currentUser!.uid)
            .collection('tournaments')
            .doc(tournamentId)
            .set({
          'name': data['name'],
          'id': doc.id,
          'type': data['type'],
          'playersCount': data['playersCount'],
          'startDate': data['startDate'],
          'endDate': data['endDate'],
          'code': code.toString(),
        });

        tournamentData.addTournament = Tournament(
            code: code.toString(),
            id: doc.id,
            name: data['name'],
            type: data['type'],
            startDate: data['startDate'],
            endDate: data['endDate'],
            numOfPlayers: data['playersCount']);
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> getUserTournaments() async {
    try {
      List<Tournament> tournaments = [];
      final query = await db
          .collection('users')
          .doc(authService.currentUser!.uid)
          .collection('tournaments')
          .get();

      final List<Map<String, dynamic>> t =
          query.docs.map((doc) => doc.data()).toList();

      for (final tournament in t) {
        tournaments.add(
          Tournament(
            name: tournament['name'],
            type: tournament['type'],
            id: tournament['id'],
            numOfPlayers: tournament['playersCount'],
            startDate: tournament['startDate'].toString(),
            endDate: tournament['endDate'].toString(),
            code: tournament['code'],
          ),
        );
      }
      userTournaments = tournaments;
      tournamentData.tournaments = tournaments;
      return;
    } catch (e) {
      FlutterError.reportError(FlutterErrorDetails(exception: e));
      rethrow;
    }
  }

  Future<Tournament?> getTournamentInfo(String id) async {
    try {
      final query = await db.collection('tournaments').doc(id).get();
      final data = query.data();
      final List<(String, String)> users = await getTournamentUsers(id);
      final ids = users.map((item) => item.$1).toList();
      //final matches = [await getScheduledMatchesForRound(id, 1)];
      final matches = await getScheduledMatches(id);
      final tournament = Tournament(
          id: id,
          userIds: ids,
          code: data!['code'],
          startDate: data['startDate'].toString(),
          endDate: data['endDate'].toString(),
          type: null,
          name: data['name'],
          numOfPlayers: data['playersCount'],
          matches: matches);
      return tournament;
    } catch (e) {
      FlutterError.reportError(FlutterErrorDetails(exception: e));
      rethrow;
    }
  }

  Future<List<(String name, String id)>> getTournamentUsers(
      String tournamentId) async {
    try {
      final query = await db
          .collection('tournaments')
          .doc(tournamentId)
          .collection('users')
          .get();

      List<(String, String)> users = [];

      for (DocumentSnapshot snapshot in query.docs) {
        users.add(
            ((snapshot.data() as Map<String, dynamic>)['name'], snapshot.id));
      }

      return users;
    } catch (e) {
      FlutterError.reportError(FlutterErrorDetails(exception: e));
      rethrow;
    }
  }

  Future<(int currentCount, int count)> getTournamentUsersCount(
      String id) async {
    try {
      final currentParticipantsList = await getTournamentUsers(id);
      final currentCount = currentParticipantsList.length;
      final tournamentInfo = await getTournamentInfo(id);
      if (tournamentInfo == null) {
        throw Exception('turniej nie istnieje!');
      }
      final count = tournamentInfo.numOfPlayers;
      return (currentCount, count);
    } catch (e) {
      FlutterError.reportError(FlutterErrorDetails(exception: e));
      rethrow;
    }
  }

  Future<void> setScheduledMatchs(String tournamentId) async {
    UsersListShuffler shuffler = UsersListShuffler();
    List<(String, String)> users = await getTournamentUsers(tournamentId);
    int usersCount = users.length;
    if (usersCount % 2 != 0) {
      usersCount++;
      users.add(('pauza', 'pauza'));
    }
    final userNames = users.map((user) => user.$1).toList();
    final userIds = users.map((user) => user.$2).toList();
    int rounds = usersCount - 1;
    int matchesInRoundCount = usersCount * 0.5 as int;
    try {
      for (int i = 0; i < rounds; i++) {
        for (int j = 0; j < matchesInRoundCount; j++) {
          await db
              .collection('tournaments')
              .doc(tournamentId)
              .collection('rounds')
              .doc('round ${i + 1}')
              .collection('matches')
              .add({
            'player1': userNames[j],
            'player1Id': userIds[j],
            'player2': userNames[usersCount - 1 - j],
            'player2Id': userIds[usersCount - 1 - j],
            'result1': null,
            'result2': null,
          });
        }
        shuffler.shuffle(users);
      }
    } catch (e) {
      FlutterError.reportError(FlutterErrorDetails(exception: e));
    }
    await db
        .collection('tournaments')
        .doc(tournamentId)
        .update({'isScheduled': true});
  }

  Future<List<List<SportMatch>>> getScheduledMatches(
      String tournamentId) async {
    try {
      final int roundsCount = await getTournamentRoundsCount(tournamentId);
      List<List<SportMatch>> matches = [];
      for (int i = 1; i < roundsCount + 1; i++) {
        final query = await db
            .collection('tournaments')
            .doc(tournamentId)
            .collection('rounds')
            .doc('round $i')
            .collection('matches')
            .get();
        List<SportMatch> matchesInRound = [];
        matchesInRound = query.docs
            .map(
              (doc) => SportMatch(
                tournamentId: tournamentId,
                id: doc.id,
                player1: doc.data()['player1'],
                player1Id: doc.data()['player1Id'],
                player2: doc.data()['player2'],
                player2Id: doc.data()['player2Id'],
                result1: doc.data()['result1'],
                result2: doc.data()['result2'],
              ),
            )
            .toList();
        matches.add(matchesInRound);
      }

      return matches;
    } catch (e) {
      FlutterError.reportError(FlutterErrorDetails(exception: e));
      return [
        List.empty(),
      ];
    }
  }

  Future<int> getTournamentRoundsCount(String tournamentId) async {
    final docRef = await db.collection('tournaments').doc(tournamentId).get();
    if (!docRef.exists) {
      return 0;
    }
    final int count = docRef.data()!['playersCount'];

    return count % 2 == 0 ? count - 1 : count;
  }

  /*Future<List<SportMatch>> getScheduledMatchesForRound(
      String tournamentId, int round) async {
    final docRef = await db
        .collection('tournaments')
        .doc(tournamentId)
        .collection('rounds')
        .get();

    final matches = docRef.docs
        .map((doc) => SportMatch(
            tournamentId: tournamentId,
            id: doc.id,
            player1: doc.data()['player1'],
            player1Id: doc.data()['player1Id'],
            player2: doc.data()['player2'],
            player2Id: doc.data()['player2Id'],
            result1: doc.data()['result1'],
            result2: doc.data()['result2']))
        .toList();

    return matches;
  }*/

  Future<bool> isTournamentScheduled(String tournamentId) async {
    final docRef = await db.collection('tournaments').doc(tournamentId).get();

    final bool isTournamentScheduled = docRef.data()!['isScheduled'];

    return isTournamentScheduled;
  }

  Future<List<TournamentParticipant>> getTournamentTable(
      String tournamentId) async {
    List<TournamentParticipant> table = [];

    final query = await db
        .collection('tournaments')
        .doc(tournamentId)
        .collection('users')
        .get();

    table = query.docs
        .map((doc) => TournamentParticipant(
            name: doc.data()['name'],
            wins: doc.data()['wins'],
            loses: doc.data()['loses'],
            ties: doc.data()['ties'],
            points: doc.data()['points']))
        .toList();
    table.sort((a, b) => b.points.compareTo(a.points));

    return table;
  }

  Future<bool> setMatchScore(
      String tournamentId,
      String matchId,
      int roundNumber,
      String score1,
      String score2,
      String player1Id,
      String player2Id) async {
    try {
      final int firstScore = int.parse(score1);
      final int secondScore = int.parse(score2);
      String winnerId = firstScore > secondScore ? player1Id : player2Id;
      String loserId = firstScore > secondScore ? player2Id : player1Id;
      await addPointsToPlayers(tournamentId, winnerId, loserId);
      await db
          .collection('tournaments')
          .doc(tournamentId)
          .collection('rounds')
          .doc('round $roundNumber')
          .collection('matches')
          .doc(matchId)
          .update({
        'result1': firstScore,
        'result2': secondScore,
      });
      return true;
    } catch (e) {
      FlutterError.reportError(FlutterErrorDetails(exception: e));
      return false;
    }
  }

  Future<void> addPointsToPlayers(
      String tournamentId, String winnerId, String loserId) async {
    var docRef = await db
        .collection('tournaments')
        .doc(tournamentId)
        .collection('users')
        .doc(winnerId)
        .get();

    final int wins = docRef.data()!['wins'];
    final int points = docRef.data()!['points'];

    docRef = await db
        .collection('tournaments')
        .doc(tournamentId)
        .collection('users')
        .doc(loserId)
        .get();

    final int loses = docRef.data()!['loses'];

    await db
        .collection('tournaments')
        .doc(tournamentId)
        .collection('users')
        .doc(loserId)
        .update({
      'loses': loses + 1,
    });

    await db
        .collection('tournaments')
        .doc(tournamentId)
        .collection('users')
        .doc(winnerId)
        .update({
      'wins': wins + 1,
      'points': points + 3,
    });
  }

  /*Future<List<SportMatch>> getUserMatchesToConfirm(String tournamentId, String userId) async {

    final query = await db.collection('tournaments').doc(tournamentId).collection('users').doc(userId).collection('matchesToConfirm').get();

    List<String> matchIds = [];

    for(var doc in query.docs) {
      matchIds.add(doc.data()['matchId']);
    }

    

  }*/
}
