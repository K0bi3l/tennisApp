import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projekt/features/services/tournament_service.dart';

class TournamentCubit extends Cubit<TournamentState> {
  TournamentCubit({required this.service, required this.tournamentId})
      : super(TournamentLoading()) {
    if (tournamentId == null) {
      emit(TournamentError());
    } else {
      checkState();
    }
  }

  final TournamentService service;
  final String? tournamentId;

  Future<void> checkState() async {
    if (tournamentId == null) {
      emit(TournamentError());
    } else {
      late int currentCount;
      late int count;
      (currentCount, count) =
          await service.getTournamentUsersCount(tournamentId!);

      if (count == currentCount) {
        final isScheduled = await service.isTournamentScheduled(tournamentId!);
        if (!isScheduled) {
          await service.setScheduledMatchs(tournamentId!);
        }
        emit(TournamentReady());
      } else {
        emit(
          TournamentNotReady(
            participantsReady: currentCount,
            participants: count,
          ),
        );
      }
    }
  }
}

sealed class TournamentState with EquatableMixin {}

class TournamentNotReady extends TournamentState {
  TournamentNotReady({
    required this.participantsReady,
    required this.participants,
  });

  final int participantsReady;
  final int participants;

  @override
  List<Object?> get props => [participantsReady, participants];
}

class TournamentReady extends TournamentState {
  @override
  List<Object?> get props => [];
}

class TournamentLoading extends TournamentState {
  @override
  List<Object?> get props => [];
}

class TournamentError extends TournamentState {
  @override
  List<Object?> get props => [];
}
