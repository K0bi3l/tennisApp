import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projekt/features/services/tournament_service.dart';

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
