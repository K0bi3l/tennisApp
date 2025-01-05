import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projekt/app.dart';
import 'tournament_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'tournament_form_provider.dart';

class TournamentCreatorForm extends StatefulWidget {
  const TournamentCreatorForm({super.key});

  @override
  State<StatefulWidget> createState() => TournamentCreatorFormState();
}

const List<String> list = ['puchar', 'turniej ligowy'];

class TournamentCreatorFormState extends State<TournamentCreatorForm> {
  final int currentStep = 0;
  final pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('Utwórz turniej'),
        ),
      ),
      body: Page1(),
    );
  }
}

class Page1 extends StatelessWidget {
  Page1({super.key});

  final _formKey = GlobalKey<FormState>();
  final _tournamentNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final TournamentService service = context.watch<TournamentService>();
    final MyFormData data = context.watch<MyFormData>();
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('Krok 1 z 2'),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
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
              },
            ),
            const TournamentDropdownMenu(),
            ElevatedButton(
              onPressed: () => {
                if (_formKey.currentState?.validate() ?? false)
                  {
                    data.name = _tournamentNameController.text,
                    //context.push('/form/stage2'),
                  }
              },
              child: const Text('Przejdź dalej'),
            ),
          ],
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

  String dropdownValue = list.first;
  @override
  Widget build(BuildContext context) {
    final data = context.watch<MyFormData>();
    return DropdownMenu(
      dropdownMenuEntries: menuEntries,
      initialSelection: dropdownValue,
      onSelected: (String? value) {
        setState(
          () {
            dropdownValue = value!;
          },
        );
        data.type = (value == 'puchar')
            ? TournamentType.bracket
            : TournamentType.league;
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
  final GlobalKey _key = GlobalKey<FormState>();
  String _selectedBeginningDate = 'Wybierz datę rozpoczęcia turnieju';
  String _selectedEndingDate = 'Wybierz datę zakończenia turnieju';
  final numberController = TextEditingController();

  Future<String?> _selectDate(BuildContext context) async {
    final DateTime? d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime(2020),
    );
    if (d != null) {
      return d.toString();
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<TournamentService>();
    final data = context.watch<MyFormData>();
    return Form(
      key: _key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Podaj daty odbywania się turnieju'),
                InkWell(
                  onTap: () async {
                    String? s = await _selectDate(context);
                    if (s != null) {
                      setState(() {
                        _selectedBeginningDate = s;
                      });
                    }
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_selectedBeginningDate),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                InkWell(
                  onTap: () async {
                    String? s = await _selectDate(context);
                    if (s != null) {
                      setState(() {
                        _selectedEndingDate = s;
                      });
                    }
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_selectedEndingDate),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
                if (num == 1) {
                  return 'Turniej musi mieć co najmniej dwóch uczestników';
                }
              } catch (e) {
                return 'Podaj prawidłową wartość w przedziale od 1 do 64';
              }
            },
          ),
          ElevatedButton(
            onPressed: () async {
              final String id;
              String code;
              (id, code) = await service.createTournament(
                  data.name,
                  data.type,
                  numberController.text,
                  _selectedBeginningDate,
                  _selectedEndingDate);
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Udało się utworzyć turniej!'),
                  content: Text(
                      'Oto kod dołączenia do turnieju: $code. Przekaż go uczestnikom, aby mogli do niego dołączyć'),
                ),
              );
              //context.push('tournament/${id}')
            },
            child: const Text('Utwórz turniej'),
          ),
        ],
      ),
    );
  }
}
