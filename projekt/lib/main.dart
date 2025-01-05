import 'auth_widget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:projekt/firebase_options.dart';
import 'app.dart';

void main() {
  runApp(const _App());
}

class _App extends StatefulWidget {
  const _App();

  @override
  State<_App> createState() => _AppState();
}

class _AppState extends State<_App> {
  final _initialization =
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tennis App',
      theme: ThemeData.from(
          colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.purple,
        dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
      )),
      home: FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          return switch (snapshot.connectionState) {
            ConnectionState.done => App(),
            _ => const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              )
          };
        },
      ),
    );
  }
}
