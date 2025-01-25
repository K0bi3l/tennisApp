import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../providers/tournament_form_provider.dart';
import 'package:go_router/go_router.dart';

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
