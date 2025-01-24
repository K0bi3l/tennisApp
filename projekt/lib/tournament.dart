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
