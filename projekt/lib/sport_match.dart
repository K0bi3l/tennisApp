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

  String player1;
  String player1Id;
  String player2;
  String player2Id;
  String id;
  String tournamentId;

  int? result1;
  int? result2;
}
