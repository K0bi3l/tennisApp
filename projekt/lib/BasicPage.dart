import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projekt/app.dart';
import 'package:projekt/auth_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projekt/tournament_service.dart';

class BasicPage extends StatelessWidget {
  const BasicPage({required this.state, super.key});

  final SignedInState state;

  @override
  Widget build(BuildContext context) {
    final authCubit = context.watch<AuthCubit>();
    return Scaffold(
        appBar: AppBar(
            title:
                Center(child: Text('Jesteś zalogowany jako ${state.email}'))),
        body: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 100),
                      child: Column(children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 15),
                          child: Text("Twoje turnieje:"),
                        ),
                        TournamentsList(),
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
      onPressed: () => {},
      child: const Text('Stwórz nowy turniej'),
    );
  }
}

class JoinTournamentWidget extends StatelessWidget {
  JoinTournamentWidget({super.key});

  final TextEditingController text = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
                  width: 300,
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
                onPressed: () => {
                  service.joinTournament(text.text).then(
                        (result) => {
                          if (!result)
                            {
                              showDialog(
                                context: context,
                                builder: (context) => const AlertDialog(
                                  title: Text('Niepowodzenie dodania turnieju'),
                                  content: Text(
                                      'Nie udało się dodać turnieju, spróbuj ponownie'),
                                ),
                              ),
                            },
                        },
                      ),
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
  const TournamentsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
          ),
          borderRadius: BorderRadius.circular(15)),
      width: 700,
      height: 700,
      child: CustomScrollView(
        slivers: [
          SliverList.separated(
            itemCount: 100,
            itemBuilder: (context, index) => const TournamentEntry(
              name: 'abc',
              type: 'ab',
            ),
            separatorBuilder: (context, _) => const SizedBox(
              height: 8,
            ),
          )
        ],
      ),
    );
  }
}

class TournamentEntry extends StatelessWidget {
  const TournamentEntry({required this.name, required this.type, super.key});

  final String name;
  final String type;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5),
      child: ElevatedButton(
        onPressed: () => {},
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
