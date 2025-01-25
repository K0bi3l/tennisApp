class TournamentParticipant {
  TournamentParticipant(
      {required this.name,
      required this.points,
      required this.wins,
      required this.ties,
      required this.loses});

  String name;
  int points;
  int wins;
  int ties;
  int loses;
}
