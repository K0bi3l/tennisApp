import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projekt/auth_widget.dart';
import 'auth_cubit.dart';
import 'BasicPage.dart';

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return switch (state) {
          SignedInState() => BasicPage(),
          SigningInState() => const Center(child: CircularProgressIndicator()),
          SignedOutState() => AuthWidget(),
        };
      },
    );
  }
}
