import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projekt/features/services/tournament_service.dart';

class TournamentCubit extends Cubit<TournamentState> {
  TournamentCubit({required this.service, required this.tournamentId})
      : super(TournamentLoading()) {
    if (tournamentId == null) {
      FlutterError.reportError(
        FlutterErrorDetails(exception: Exception('bład w cubicie')),
      );
    }
    checkState();
  }

  final TournamentService service;
  final String? tournamentId;

  Future<void> checkState() async {
    if (tournamentId == null) {
      throw Exception('Turniej nie istnieje!');
    }
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
