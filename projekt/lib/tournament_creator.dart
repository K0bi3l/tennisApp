import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'tournament_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'tournament_form_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

const List<String> list = ['puchar', 'turniej ligowy'];

class Page1 extends StatelessWidget {
  Page1({super.key});

  final _formKey = GlobalKey<FormState>();
  final _tournamentNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final MyFormData data = context.watch<MyFormData>();
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('Krok 1 z 2'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                controller: _tournamentNameController,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(30),
                ],
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text('podaj nazwę turnieju'),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Musisz podać nazwę turnieju';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              const TournamentDropdownMenu(),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => {
                  if (_formKey.currentState?.validate() ?? false)
                    {
                      data.name = _tournamentNameController.text,
                      context.push('/create/stage2'),
                    }
                },
                child: const Text('Przejdź dalej'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TournamentDropdownMenu extends StatefulWidget {
  const TournamentDropdownMenu({super.key});

  @override
  TournamentDropdownMenuState createState() => TournamentDropdownMenuState();
}

typedef MenuEntry = DropdownMenuEntry<String>;

class TournamentDropdownMenuState extends State<TournamentDropdownMenu> {
  final List<MenuEntry> menuEntries = UnmodifiableListView<MenuEntry>(list
      .map<MenuEntry>((String name) => MenuEntry(value: name, label: name)));

  late String dropdownValue;

  @override
  void initState() {
    dropdownValue = list.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<MyFormData>();
    data.type = TournamentType.bracket;
    return DropdownMenu(
      dropdownMenuEntries: menuEntries,
      initialSelection: dropdownValue,
      onSelected: (String? value) {
        setState(
          () {
            dropdownValue = value!;
          },
        );
        data.type =
            value == 'puchar' ? TournamentType.bracket : TournamentType.league;
      },
    );
  }
}

class LeagueTournamentPage2 extends StatefulWidget {
  const LeagueTournamentPage2({super.key});

  @override
  LeagueTournamentPage2State createState() => LeagueTournamentPage2State();
}

class LeagueTournamentPage2State extends State<LeagueTournamentPage2> {
  final _formKey = GlobalKey<FormState>();
  String _selectedBeginningDate = 'Wybierz datę rozpoczęcia turnieju';
  String _selectedEndingDate = 'Wybierz datę zakończenia turnieju';
  DateTime? firstDate;
  DateTime? lastDate;
  final numberController = TextEditingController();
  String? errorMessage;

  Future<DateTime?> _selectDateEnd(BuildContext context) async {
    final DateTime? d = await showDatePicker(
      context: context,
      initialDate: firstDate,
      firstDate: firstDate!,
      lastDate: DateTime(2030),
    );
    if (d != null) {
      return d;
    } else {
      return null;
    }
  }

  Future<DateTime?> _selectDateStart(BuildContext context) async {
    final DateTime? d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (d != null) {
      return d;
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<TournamentService>();
    final data = context.watch<MyFormData>();
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('Krok 2 z 2'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(10),
                        child: Text('Podaj daty odbywania się turnieju'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            DateTime? d = await _selectDateStart(context);
                            if (d != null) {
                              final DateFormat formatter =
                                  DateFormat('dd-MM-yyyy');
                              final String formatted = formatter.format(d);
                              final date = d.add(
                                const Duration(days: 1),
                              );
                              setState(() {
                                _selectedBeginningDate = formatted;
                                firstDate = date;
                              });
                            }
                          } catch (e) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(
                                  e.toString(),
                                ),
                              ),
                            );
                          }
                        },
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(_selectedBeginningDate),
                              const Icon(Icons.calendar_today),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: firstDate != null
                            ? () async {
                                DateTime? d = await _selectDateEnd(context);
                                if (d != null) {
                                  final DateFormat formatter =
                                      DateFormat('dd-MM-yyyy');
                                  final String formatted = formatter.format(d);
                                  setState(() {
                                    _selectedEndingDate = formatted;
                                    lastDate = d;
                                  });
                                }
                              }
                            : null,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(_selectedEndingDate),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                      Builder(builder: (context) {
                        return errorMessage == null
                            ? const SizedBox(height: 10)
                            : Padding(
                                padding: const EdgeInsets.all(10),
                                child: Center(
                                  child: Text(
                                    errorMessage!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: numberController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text('Podaj ilość uczestników'),
                  ),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(3),
                    FilteringTextInputFormatter.allow(RegExp(r'\d*')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Podaj ilość uczestników';
                    }
                    try {
                      final num = int.parse(value);
                      if (num > 64) {
                        return 'Maksymalna liczba uczestników to 64';
                      }
                      if (num <= 1) {
                        return 'Turniej musi mieć co najmniej dwóch uczestników';
                      }
                    } catch (e) {
                      return 'Podaj prawidłową wartość w przedziale od 1 do 64';
                    }
                    return null;
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        if (_formKey.currentState?.validate() ?? false) {
                          String code = '';
                          if (lastDate == null) {
                            setState(() {
                              errorMessage =
                                  'Aby utworzyć turniej musisz podać daty odbywania się zawodów! ';
                            });
                            return;
                          } else {
                            errorMessage = null;
                          }
                          code = await service.createTournament(
                              data.name,
                              data.type,
                              numberController.text,
                              _selectedBeginningDate,
                              _selectedEndingDate);
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Udało się utworzyć turniej!'),
                              content: Text(
                                  'Oto kod dołączenia do turnieju: $code. Przekaż go uczestnikom, aby mogli do niego dołączyć'),
                            ),
                          );
                        }
                      } catch (e) {
                        showDialog(
                          context: context,
                          builder: (context) =>
                              AlertDialog(title: Text(e.toString())),
                        );
                      }
                    },
                    child: const Text('Utwórz turniej'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
