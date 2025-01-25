import 'package:flutter/material.dart';
import 'package:projekt/features/tournament_page/tournament_table/widgets/table_entry.dart';
import 'package:projekt/features/services/tournament_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TournamentTable extends StatelessWidget {
  const TournamentTable(
      {super.key,
      required this.playersCount,
      required this.tournamentId,
      required this.width});

  final int playersCount;
  final String tournamentId;
  final double width;

  @override
  Widget build(BuildContext context) {
    var tournamentService = context.watch<TournamentService>();
    return FutureBuilder(
      future: tournamentService.getTournamentTable(tournamentId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return SizedBox(
            width: width,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(width: 2, color: Colors.black),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: CustomScrollView(
                  slivers: [
                    const SliverToBoxAdapter(
                      child: TableEntry(
                          position: 'm.',
                          name: 'nazwa',
                          color: Colors.white,
                          points: 'PKT',
                          wins: 'W',
                          ties: 'R',
                          loses: 'P'),
                    ),
                    SliverList.separated(
                      itemCount: playersCount,
                      itemBuilder: (context, index) {
                        Color color = Colors.white;
                        if (index <= 2 && playersCount >= 7) {
                          color = Colors.lightGreen;
                        } else if (index >= playersCount - 2 &&
                            playersCount >= 7) {
                          color = Colors.red;
                        }
                        final data = snapshot.data!;
                        return TableEntry(
                            position: (index + 1).toString(),
                            name: snapshot.data![index].name,
                            color: color,
                            points: data[index].points.toString(),
                            wins: data[index].wins.toString(),
                            ties: data[index].ties.toString(),
                            loses: data[index].loses.toString());
                      },
                      separatorBuilder: (context, index) => SizedBox(
                        height: 2,
                        child: ColoredBox(color: Colors.grey.shade300),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
