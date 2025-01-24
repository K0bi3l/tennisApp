import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:projekt/auth_service.dart';
import 'package:projekt/sport_match.dart';
import 'tournament_service.dart';

class ConfirmMatchesCubit extends Cubit<MatchState> {
  ConfirmMatchesCubit(
      {required this.tournamentService,
      required this.authService,
      required this.match})
      : super(WaitingState()) {
    checkAvailibility();
  }

  final TournamentService tournamentService;
  final AuthService authService;
  final SportMatch match;

  Future<void> setMatchScore(
      String tournamentId,
      String matchId,
      int roundNumber,
      String score1,
      String score2,
      String player1Id,
      String player2Id) async {
    final success = await tournamentService.setMatchScore(tournamentId, matchId,
        roundNumber, score1, score2, player1Id, player2Id);
    if (!success) {
      emit(ErrorState());
    } else {
      emit(NotAvailableState());
    }
  }

  void checkAvailibility() {
    String player1Id = match.player1Id;
    String player2Id = match.player2Id;
    if (authService.currentUser!.uid == player1Id ||
        authService.currentUser!.uid == player2Id) {
      emit(AvailableState());
      return;
    } else {
      emit(NotAvailableState());
      return;
    }
  }
}

sealed class MatchState with EquatableMixin {}

class AvailableState extends MatchState {
  AvailableState();
  @override
  get props => [];
}

class NotAvailableState extends MatchState {
  NotAvailableState();
  @override
  get props => [];
}

class WaitingState extends MatchState {
  WaitingState();
  @override
  get props => [];
}

class ErrorState extends MatchState {
  ErrorState();
  @override
  get props => [];
}
