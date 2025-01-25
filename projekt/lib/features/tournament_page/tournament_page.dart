import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projekt/features/auth/services/auth_service.dart';
import 'package:projekt/features/tournament_page/confirm_matches_cubit.dart';
import 'package:projekt/features/tournament_page/sport_match.dart';
import 'package:projekt/tournament_service.dart';
import '../../tournament.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'tournament_cubit.dart';
import 'package:animations/animations.dart';
import 'package:go_router/go_router.dart';

class TournamentPage extends StatelessWidget {
  const TournamentPage({required this.tournamentId, super.key});

  final String tournamentId;

  @override
  Widget build(BuildContext context) {
    final service = context.watch<TournamentService>();
    return FutureBuilder(
      future: service.getTournamentInfo(tournamentId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return BlocBuilder<TournamentCubit, TournamentState>(
            builder: (context, state) {
              return switch (state) {
                TournamentLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                TournamentNotReady() => NotReadyTournamentPage(state: state),
                TournamentReady() =>
                  ReadyTournamentPage(tournamentInfo: snapshot.data!),
              };
            },
          );
        }
      },
    );
  }
}

class ReadyTournamentPage extends StatefulWidget {
  const ReadyTournamentPage({super.key, required this.tournamentInfo});

  final Tournament tournamentInfo;

  @override
  ReadyTournamentPageState createState() => ReadyTournamentPageState();
}

class ReadyTournamentPageState extends State<ReadyTournamentPage> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1500) {
          return BigReadyTournamentPage(tournamentInfo: widget.tournamentInfo);
        } else {
          return SmallReadyTournamentPage(
              tournamentInfo: widget.tournamentInfo);
        }
      },
    );
  }
}

class SmallReadyTournamentPage extends StatefulWidget {
  const SmallReadyTournamentPage({super.key, required this.tournamentInfo});

  final Tournament tournamentInfo;

  @override
  SmallReadyTournamentPageState createState() =>
      SmallReadyTournamentPageState();
}

class SmallReadyTournamentPageState extends State<SmallReadyTournamentPage> {
  late PageController _pageController;
  int _selectedIndex = 0;

  @override
  void initState() {
    _pageController = PageController();

    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(widget.tournamentInfo.name),
        ),
      ),
      body: PageView(
        controller: _pageController,
        children: [
          SmallPagesWrapper(
            child: MatchesDisplayer(
                matches: widget.tournamentInfo.matches ?? [],
                width: 0.7 * MediaQuery.of(context).size.width),
          ),
          SmallPagesWrapper(
            child: TournamentTable(
              playersCount: widget.tournamentInfo.numOfPlayers,
              tournamentId: widget.tournamentInfo.id,
              width: MediaQuery.of(context).size.width * 0.8,
            ),
          ),
          SmallPagesWrapper(
            child: Players(playersInfo: widget.tournamentInfo.userIds!),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.sports_tennis),
              label: 'Mecze',
              backgroundColor: Colors.red),
          BottomNavigationBarItem(
            icon: Icon(Icons.table_bar),
            label: 'tabela',
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.verified_user),
              label: 'gracze',
              backgroundColor: Colors.blue),
        ],
        selectedItemColor: Colors.amber,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: ConfirmMatchesWidgetWrapper(
        tournamentId: widget.tournamentInfo.id,
        userId: authService.currentUser!.uid,
      ),
    );
  }
}

class SmallPagesWrapper extends StatelessWidget {
  const SmallPagesWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 40, top: 40),
        child: Center(
          child: child,
        ));
  }
}

class BigReadyTournamentPage extends StatefulWidget {
  const BigReadyTournamentPage({required this.tournamentInfo, super.key});

  final Tournament tournamentInfo;

  @override
  BigReadyTournamentPageState createState() => BigReadyTournamentPageState();
}

class BigReadyTournamentPageState extends State<BigReadyTournamentPage> {
  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(widget.tournamentInfo.name),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(50),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Players(
              playersInfo: widget.tournamentInfo.userIds!,
            ),
            MatchesDisplayer(
                matches: widget.tournamentInfo.matches,
                width: 0.4 * MediaQuery.of(context).size.width),
            TournamentTable(
              playersCount: widget.tournamentInfo.numOfPlayers,
              tournamentId: widget.tournamentInfo.id,
              width: MediaQuery.of(context).size.width * 0.2,
            ),
          ],
        ),
      ),
      floatingActionButton: ConfirmMatchesWidgetWrapper(
          tournamentId: widget.tournamentInfo.id,
          userId: authService.currentUser!.uid),
    );
  }
}

class ConfirmMatchesWidgetWrapper extends StatelessWidget {
  const ConfirmMatchesWidgetWrapper(
      {super.key, required this.tournamentId, required this.userId});

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

class MatchesDisplayer extends StatefulWidget {
  const MatchesDisplayer(
      {super.key, required this.matches, required this.width});

  final double width;

  final List<List<SportMatch>>? matches;
  @override
  MatchesDisplayerState createState() => MatchesDisplayerState();
}

class MatchesDisplayerState extends State<MatchesDisplayer>
    with TickerProviderStateMixin {
  int _currentPageIndex = 0;
  late CustomPageController _pageViewController;

  @override
  void initState() {
    super.initState();
    _pageViewController =
        CustomPageController(maxScroll: widget.matches!.length - 1);
  }

  @override
  void dispose() {
    super.dispose();
    _pageViewController.dispose();
  }

  void scroll(int index, bool next) {
    _pageViewController.animateToPage(
      index + (next ? 1 : -1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void onPageChanged(int currentPageIndex) {
    setState(() {
      _currentPageIndex = currentPageIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.matches == null) {
      return const Placeholder();
    }
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SizedBox(
            height: height,
            width: widget.width,
            child: PageView.builder(
              itemCount: widget.matches!.length,
              controller: _pageViewController,
              onPageChanged: onPageChanged,
              itemBuilder: (item, builder) {
                return SchedulePage(
                    currentRound: _currentPageIndex + 1,
                    height: height,
                    width: widget.width,
                    matches: widget.matches![_currentPageIndex]);
              },
            ),
          ),
          PageIndicator(currentIndex: _currentPageIndex, scroll: scroll),
        ],
      ),
    );
  }
}

class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.currentIndex,
    required this.scroll,
  });

  final int currentIndex;
  final void Function(int, bool) scroll;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () => scroll(currentIndex, false),
              icon: const Icon(
                Icons.arrow_left_rounded,
                size: 32,
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            IconButton(
              onPressed: () => scroll(currentIndex, true),
              icon: const Icon(
                Icons.arrow_right_rounded,
                size: 32,
              ),
            ),
          ],
        ));
  }
}

class CustomPageController extends PageController {
  CustomPageController({required this.maxScroll});

  final int maxScroll;

  @override
  Future<void> animateToPage(int page,
      {required Duration duration, required Curve curve}) async {
    if (page >= 0 && page <= maxScroll) {
      await super.animateToPage(page, duration: duration, curve: curve);
    }
  }
}

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
                      }),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class OpenMatchEntry extends StatelessWidget {
  OpenMatchEntry(
      {super.key,
      required this.match,
      required this.roundNumber,
      required this.available});
  final TextEditingController _result1Controller = TextEditingController();
  final TextEditingController _result2Controller = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final SportMatch match;
  final int roundNumber;
  final bool available;

  @override
  Widget build(BuildContext context) {
    //final matchCubit = context.watch<ConfirmMatchesCubit>();
    final tournamentService = context.watch<TournamentService>();
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return SizedBox(
      height: height, // zajmuje całą wysokość ekranu
      child: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.pop(),
                  )),
              const Text(
                'Dodaj wynik meczu',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(match.player1),
                  SizedBox(width: width * 0.1),
                  const Text(':'),
                  SizedBox(width: width * 0.1),
                  Text(match.player2),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: width * 0.3,
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Podaj wynik 1 zawodnika',
                        border: OutlineInputBorder(),
                      ),
                      controller: _result1Controller,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'\d*')),
                        LengthLimitingTextInputFormatter(2),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'podaj wynik';
                        }
                        if (value[0] == '0' && value.length > 1) {
                          return 'Wynik nie może zaczynac się od zera';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: width * 0.2),
                  SizedBox(
                    width: width * 0.3,
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Podaj wynik 2 zawodnika',
                        border: OutlineInputBorder(),
                      ),
                      controller: _result2Controller,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'\d*')),
                        LengthLimitingTextInputFormatter(2),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'podaj wynik';
                        }
                        if (value[0] == '0' && value.length > 1) {
                          return 'Wynik nie może zaczynac się od zera';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ElevatedButton(
                    onPressed: available
                        ? () async {
                            if (formKey.currentState?.validate() ?? false) {
                              try {
                                final result =
                                    await tournamentService.setMatchScore(
                                        match.tournamentId,
                                        match.id,
                                        roundNumber,
                                        _result1Controller.text,
                                        _result2Controller.text,
                                        match.player1Id,
                                        match.player2Id);
                                if (result == false) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => const SnackBar(
                                      content:
                                          Text('Nie udało się dodać wyniku'),
                                    ),
                                  );
                                } else {
                                  context.pop();
                                }
                              } catch (e) {
                                FlutterError.reportError(
                                    FlutterErrorDetails(exception: e));
                              }
                            }
                          }
                        : null,
                    child: const Text(
                      'Zaakceptuj wynik',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MatchEntryWrapper extends StatelessWidget {
  const MatchEntryWrapper(
      {super.key,
      required this.match,
      required this.closedChild,
      required this.roundNumber});

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

class Players extends StatelessWidget {
  const Players({required this.playersInfo, super.key});

  final List<String> playersInfo;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: SizedBox(
        width: 400,
        child: CustomScrollView(
          slivers: [
            SliverList.builder(
              itemCount: playersInfo.length,
              itemBuilder: (context, index) => PlayerEntry(
                name: playersInfo[index],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlayerEntry extends StatelessWidget {
  const PlayerEntry({required this.name, super.key});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ElevatedButton(
        onPressed: () {},
        child: Center(
          child: Text(name),
        ),
      ),
    );
  }
}

class NotReadyTournamentPage extends StatelessWidget {
  const NotReadyTournamentPage({required this.state, super.key});

  final TournamentNotReady state;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Text(
                'Turniej nie może wystartować. Dołączyło ${state.participantsReady} z ${state.participants} uczestników'),
          ),
        ),
      ),
    );
  }
}

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
    //final height = MediaQuery.of(context).size.height * 0.8;
    //final width = MediaQuery.of(context).size.width * 0.2;
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
                      child: PersonTableEntry(
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
                        return PersonTableEntry(
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

class PersonTableEntry extends StatelessWidget {
  const PersonTableEntry(
      {super.key,
      required this.position,
      required this.name,
      required this.color,
      required this.points,
      required this.wins,
      required this.ties,
      required this.loses});

  final String position;
  final String name;
  final Color color;
  final String points;
  final String wins;
  final String ties;
  final String loses;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: DecoratedBox(
        decoration: BoxDecoration(
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(10)),
        child: Table(
          columnWidths: const {
            0: FixedColumnWidth(20), // Pozycja
            1: FlexColumnWidth(40), // Nazwa gracza
            2: FixedColumnWidth(50), // Punkty
            3: FixedColumnWidth(50), // Wygrane
            4: FixedColumnWidth(50), // Remisy
            5: FixedColumnWidth(50), // Przegrane
          },
          border: TableBorder.symmetric(
            inside: BorderSide(color: Colors.grey.shade400),
          ),
          children: [
            TableRow(
              children: [
                Center(child: Text(position)),
                Center(child: Text(name)),
                Center(child: Text(points)),
                Center(child: Text(wins)),
                Center(child: Text(ties)),
                Center(child: Text(loses)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
