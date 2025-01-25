import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projekt/auth_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projekt/tournament_list_provider.dart';
import 'package:projekt/tournament_service.dart';
import 'package:go_router/go_router.dart';

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

    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 500), curve: Curves.decelerate);
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
                backgroundColor: Colors.red),
            BottomNavigationBarItem(
              icon: Icon(Icons.abc),
              label: 'Dodaj turniej',
              backgroundColor: Colors.green,
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber,
          onTap: _onItemTapped),
    );
  }
}

class SmallBasicPage2 extends StatelessWidget {
  const SmallBasicPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CreateTournamentButton(),
          const SizedBox(
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
      child: Column(children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 15),
          child: Text("Twoje turnieje:"),
        ),
        TournamentsList(width: MediaQuery.of(context).size.width * 0.7),
      ]),
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
                      child: Column(children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 15),
                          child: Text("Twoje turnieje:"),
                        ),
                        TournamentsList(width: width * 0.4),
                      ]),
                    ),
                    Flexible(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const CreateTournamentButton(),
                            const SizedBox(
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
                  child: const Text('Wyloguj się')),
            ],
          ),
        ));
  }
}

class CreateTournamentButton extends StatelessWidget {
  const CreateTournamentButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => {context.push('/create')},
      child: const Text('Stwórz nowy turniej'),
    );
  }
}

class JoinTournamentWidget extends StatelessWidget {
  JoinTournamentWidget({super.key});

  final TextEditingController text = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final TournamentService service = context.watch<TournamentService>();
    return Card(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 15),
            child: Center(
              child: Text('Dodaj turniej'),
            ),
          ),
          const SizedBox(
            height: 24,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: SizedBox(
                  width: width * 0.2,
                  child: TextField(
                    controller: text,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(6),
                      FilteringTextInputFormatter.allow(RegExp(r'\d*')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'wprowadź kod do turnieju',
                      border: OutlineInputBorder(),
                      hintText: ' 6 cyfrowy kod',
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  try {
                    service.joinTournament(text.text).then(
                          (result) => {
                            if (!result)
                              {
                                showDialog(
                                  context: context,
                                  builder: (context) => const AlertDialog(
                                    title:
                                        Text('Niepowodzenie dodania turnieju'),
                                    content: Text(
                                        'Nie udało się dodać turnieju, spróbuj ponownie'),
                                  ),
                                ),
                              }
                            else
                              {}
                          },
                        );
                    text.text = '';
                  } catch (e) {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          AlertDialog(title: Text(e.toString())),
                    );
                  }
                },
                child: const Text('Dodaj'),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class TournamentsList extends StatelessWidget {
  const TournamentsList({super.key, required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final service = context.watch<TournamentService>();
    final data = context.watch<TournamentListData>();
    return FutureBuilder(
        future: service.getUserTournaments(),
        builder: (context, snapshot) {
          return Container(
            decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                ),
                borderRadius: BorderRadius.circular(15)),
            width: width,
            height: height * 0.8,
            child: CustomScrollView(
              slivers: [
                SliverList.separated(
                  itemCount: data.tournaments!.length,
                  itemBuilder: (context, index) => TournamentEntry(
                    name: data.tournaments![index].name,
                    type: data.tournaments![index].type!,
                    id: data.tournaments![index].id,
                  ),
                  separatorBuilder: (context, _) => const SizedBox(
                    height: 8,
                  ),
                )
              ],
            ),
          );
        });
  }
}

class TournamentEntry extends StatelessWidget {
  const TournamentEntry(
      {required this.name, required this.type, required this.id, super.key});

  final String name;
  final String type;
  final String id;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5),
      child: ElevatedButton(
        onPressed: () {
          context.push('/tournament/$id');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              name,
              style: const TextStyle(fontSize: 24),
            ),
            Text(
              type,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
