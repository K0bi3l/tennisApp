import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:projekt/features/services/tournament_service.dart';
import 'package:projekt/features/tournament_page/models/sport_match.dart';

class OpenMatchEntry extends StatelessWidget {
  OpenMatchEntry({
    super.key,
    required this.match,
    required this.roundNumber,
    required this.available,
  });
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
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
              ),
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
                                  match.player2Id,
                                );
                                if (result == false) {
                                  if (context.mounted) {
                                    await showDialog(
                                      context: context,
                                      builder: (context) => const SnackBar(
                                        content:
                                            Text('Nie udało się dodać wyniku'),
                                      ),
                                    );
                                  }
                                } else {
                                  if (context.mounted) {
                                    context.pop();
                                  }
                                }
                              } catch (e) {
                                FlutterError.reportError(
                                  FlutterErrorDetails(exception: e),
                                );
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
