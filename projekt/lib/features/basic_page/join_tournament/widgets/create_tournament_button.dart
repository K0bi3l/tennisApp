import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
