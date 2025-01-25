import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projekt/features/auth/services/auth_service.dart';
import 'package:projekt/features/services/tournament_service.dart';
import 'package:projekt/features/tournament_page/confirm_matches/confirm_matches.dart';
import 'package:projekt/features/tournament_page/matches_displayer/matches_displayer.dart';
import 'package:projekt/features/tournament_page/players_widget/widgets/players.dart';
import 'package:projekt/features/tournament_page/tournament_table/widgets/tournament_table.dart';
import '../models/tournament.dart';
import 'cubit/tournament_cubit.dart';

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
                TournamentError() => const Center(
                    child: Text('Unexpected error'),
                  ),
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
            tournamentInfo: widget.tournamentInfo,
          );
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

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.decelerate,
    );
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
              width: 0.7 * MediaQuery.of(context).size.width,
            ),
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
            backgroundColor: Colors.red,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.table_bar),
            label: 'tabela',
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.verified_user),
            label: 'gracze',
            backgroundColor: Colors.blue,
          ),
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
      padding: const EdgeInsets.only(bottom: 15, top: 15),
      child: Center(
        child: child,
      ),
    );
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
              width: 0.4 * MediaQuery.of(context).size.width,
            ),
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
        userId: authService.currentUser!.uid,
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
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Text(
              'Turniej nie może wystartować. Dołączyło ${state.participantsReady} z ${state.participants} uczestników',
            ),
          ),
        ),
      ),
    );
  }
}
