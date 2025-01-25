import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projekt/features/tournament_page/matches_displayer/schedule_page/match_widgets/cubit/confirm_matches_cubit.dart';
import 'package:projekt/features/tournament_page/matches_displayer/schedule_page/match_widgets/widgets/open_match_entry.dart';
import 'package:projekt/features/tournament_page/models/sport_match.dart';

class MatchEntryWrapper extends StatelessWidget {
  const MatchEntryWrapper({
    super.key,
    required this.match,
    required this.closedChild,
    required this.roundNumber,
  });

  final SportMatch match;
  final Widget closedChild;
  final int roundNumber;

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      transitionType: ContainerTransitionType.fadeThrough,
      transitionDuration: const Duration(seconds: 1),
      closedColor: Theme.of(context).canvasColor,
      openElevation: 0,
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      openBuilder: (context, closedContainer) {
        return BlocProvider(
          create: (_) => ConfirmMatchesCubit(
              tournamentService: context.watch(),
              authService: context.watch(),
              match: match),
          child: BlocBuilder<ConfirmMatchesCubit, MatchState>(
            builder: (context, state) {
              return switch (state) {
                ErrorState() => const Placeholder(),
                WaitingState() => const CircularProgressIndicator(),
                NotAvailableState() => OpenMatchEntry(
                    match: match, roundNumber: roundNumber, available: false),
                AvailableState() => OpenMatchEntry(
                    match: match, roundNumber: roundNumber, available: true),
              };
            },
          ),
        );
      },
      closedBuilder: (context, openContainer) {
        return ElevatedButton(
          onPressed: openContainer,
          child: closedChild,
        );
      },
    );
  }
}

class MatchEntry extends StatelessWidget {
  const MatchEntry({required this.match, super.key});

  final SportMatch match;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('${match.player1} : ${match.player2}'),
          if (match.result1 == null || match.result2 == null)
            const Text('Wynik nie wpisany')
          else
            Text('${match.result1} : ${match.result2}'),
        ],
      ),
    );
  }
}
