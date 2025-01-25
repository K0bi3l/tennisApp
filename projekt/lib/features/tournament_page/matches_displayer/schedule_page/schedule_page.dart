import 'package:flutter/material.dart';
import 'package:projekt/features/tournament_page/matches_displayer/schedule_page/match_widgets/widgets/match_entry.dart';
import 'package:projekt/features/tournament_page/models/sport_match.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage(
      {required this.currentRound,
      required this.height,
      required this.matches,
      required this.width,
      super.key});

  final int currentRound;
  final double height;
  final double width;
  final List<SportMatch> matches;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Runda $currentRound'),
        const SizedBox(height: 10),
        SizedBox(
          height: 0.7 * height,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: SizedBox(
              width: 700,
              child: CustomScrollView(
                slivers: [
                  SliverList.builder(
                    itemCount: matches.length,
                    itemBuilder: (context, index) {
                      return MatchEntryWrapper(
                        roundNumber: currentRound,
                        match: matches[index],
                        closedChild: MatchEntry(match: matches[index]),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
