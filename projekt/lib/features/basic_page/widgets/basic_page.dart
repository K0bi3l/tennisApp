import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projekt/features/auth/cubit/auth_cubit.dart';
import 'package:projekt/features/basic_page/join_tournament/widgets/create_tournament_button.dart';
import 'package:projekt/features/basic_page/join_tournament/widgets/join_tournament_widget.dart';
import 'package:projekt/features/basic_page/join_tournament/widgets/tournaments_list.dart';

class BasicPage extends StatelessWidget {
  const BasicPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return const BigBasicPage();
        } else {
          return const SmallBasicPage();
        }
      },
    );
  }
}

class SmallBasicPage extends StatefulWidget {
  const SmallBasicPage({super.key});

  @override
  SmallBasicPageState createState() => SmallBasicPageState();
}

class SmallBasicPageState extends State<SmallBasicPage> {
  int _selectedIndex = 0;

  late PageController _pageController;

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

  final _widgetOptions = <Widget>[
    const SmallBasicPage1(),
    const SmallBasicPage2(),
  ];

  @override
  Widget build(BuildContext context) {
    final authCubit = context.watch<AuthCubit>();
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('${authCubit.userEmail}'),
        ),
      ),
      body: Center(
        child: PageView(
          controller: _pageController,
          children: [
            ..._widgetOptions,
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.data_array),
            label: 'Twoje turnieje',
            backgroundColor: Colors.red,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.abc),
            label: 'Dodaj turniej',
            backgroundColor: Colors.green,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber,
        onTap: _onItemTapped,
      ),
    );
  }
}

class SmallBasicPage2 extends StatelessWidget {
  const SmallBasicPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CreateTournamentButton(),
          SizedBox(
            height: 24,
          ),
          JoinTournamentWidget(),
        ],
      ),
    );
  }
}

class SmallBasicPage1 extends StatelessWidget {
  const SmallBasicPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 15),
            child: Text('Twoje turnieje:'),
          ),
          TournamentsList(width: MediaQuery.of(context).size.width * 0.7),
        ],
      ),
    );
  }
}

class BigBasicPage extends StatelessWidget {
  const BigBasicPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final authCubit = context.watch<AuthCubit>();
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('Jesteś zalogowany jako ${authCubit.userEmail}'),
        ),
      ), //mozna tu zmienic
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 100),
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 15),
                          child: Text('Twoje turnieje:'),
                        ),
                        TournamentsList(width: width * 0.4),
                      ],
                    ),
                  ),
                  const Flexible(
                    child: Padding(
                      padding: EdgeInsets.only(left: 30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CreateTournamentButton(),
                          SizedBox(
                            height: 24,
                          ),
                          JoinTournamentWidget(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => authCubit.signOut(),
              child: const Text('Wyloguj się'),
            ),
          ],
        ),
      ),
    );
  }
}
