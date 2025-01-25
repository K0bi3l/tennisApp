import 'package:flutter/material.dart';
import '../../models/tournament.dart';

class TournamentListData extends ChangeNotifier {
  List<Tournament>? get tournaments => _tournaments;
  set tournaments(List<Tournament>? value) {
    if (value != _tournaments) {
      _tournaments = value;
      notifyListeners();
    }
  }

  Tournament? get addTournament => _addTournament;
  set addTournament(Tournament? value) {
    if (value != null) {
      _tournaments!.add(value);
      notifyListeners();
    }
  }

  Tournament? _addTournament;

  List<Tournament>? _tournaments = [];
}
