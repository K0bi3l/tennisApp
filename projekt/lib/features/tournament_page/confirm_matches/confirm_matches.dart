import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:projekt/features/tournament_page/models/sport_match.dart';

class ConfirmMatchesWidgetWrapper extends StatelessWidget {
  const ConfirmMatchesWidgetWrapper({
    super.key,
    required this.tournamentId,
    required this.userId,
  });

  final String tournamentId;
  final String userId;

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      closedShape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      transitionType: ContainerTransitionType.fadeThrough,
      transitionDuration: const Duration(seconds: 1),
      closedBuilder: (context, openContainer) {
        return FloatingActionButton.large(
          onPressed: openContainer,
          child: const Center(
            child: Text(
              'Potwierdź wyniki',
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
      openBuilder: (context, closedContainer) {
        return const Placeholder(); //ConfirmMatchesOpen(tournamentId: tournamentId, userId: userId);
      },
    );
  }
}

/*class ConfirmMatchesOpen extends StatelessWidget {
  const ConfirmMatchesOpen({super.key,required this.tournamentId,required this.userId});

  final String tournamentId;
  final String userId;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return FutureBuilder(
      future: ,
      builder:(context, snapshot) {
     return Padding(padding: const EdgeInsets.all(30),
    child: Column(
      children: [
        const Align(alignment: Alignment.topCenter,
        child: Text('Potwierdź wyniki swoich meczów'),),
        Center(child: SizedBox(
          width: width * 0.6,
        height: height * 0.7,
        child: DecoratedBox(decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
           ),
           child: ListView.builder(
            //itemCount: snapshot.data.length,
            itemBuilder:(context, index) =>  ConfirmMatchEntry(match: snapshot.data[index]),
            ),
            ),
            ),
            ),
      ],
    ),);
  },);}
}*/

class ConfirmMatchEntry extends StatelessWidget {
  const ConfirmMatchEntry({super.key, required this.match});

  final SportMatch match;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Column(
              children: [
                Row(
                  children: [
                    Text(match.player1),
                    const SizedBox(width: 20),
                    const Text(':'),
                    const SizedBox(
                      width: 20,
                    ),
                    Text(match.player2),
                  ],
                ),
                Row(
                  children: [
                    Text(match.result1.toString()),
                    Text(match.result2.toString()),
                  ],
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.check),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
