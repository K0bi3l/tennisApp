import 'package:projekt/tournament_form_provider.dart';
import 'package:hive/hive.dart';
import 'sport_match.dart';

class Tournament {
  Tournament(
      {required this.id,
      required this.name,
      required this.type,
      required this.startDate,
      required this.endDate,
      required this.numOfPlayers,
      required this.code,
      this.userIds,
      this.matches});

  final String id;
  final String name;
  final String? type;
  final String startDate;
  final String endDate;
  final int numOfPlayers;
  final String code;
  final List<String>? userIds;
  final List<List<SportMatch>>? matches;
}

@HiveType(typeId: 0)
class TournamentDTO {
  TournamentDTO({required this.id, required this.name, required this.type});

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final TournamentType? type;
}
