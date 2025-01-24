class SportMatch {
  SportMatch(
      {required this.player1,
      required this.player1Id,
      required this.player2,
      required this.player2Id,
      this.result1,
      this.result2,
      required this.id,
      required this.tournamentId});

  final String player1;
  final String player1Id;
  final String player2;
  final String player2Id;
  final String id;
  final String tournamentId;

  int? result1;
  int? result2;
}
