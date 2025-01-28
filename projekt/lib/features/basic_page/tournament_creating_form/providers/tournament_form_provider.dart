import 'package:flutter/material.dart';

enum TournamentType { league, bracket }

class MyFormData extends ChangeNotifier {
  MyFormData() {
    type = TournamentType.bracket;
  }
  String? _name;
  String? get name => _name;
  set name(String? value) {
    if (value != _name) {
      _name = value;
      notifyListeners();
    }
  }

  TournamentType? _type;
  TournamentType? get type => _type;
  set type(TournamentType? value) {
    if (value != _type) {
      _type = value;
      notifyListeners();
    }
  }

  Step2Data? _step2data;
  Step2Data? get step2Data => _step2data;
  set step2Data(Step2Data? value) {
    if (value != _step2data) {
      _step2data = value;
      notifyListeners();
    }
  }
}

class Step2Data {}
