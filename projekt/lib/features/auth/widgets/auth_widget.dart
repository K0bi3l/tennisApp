import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projekt/features/auth/cubit/auth_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthWidget extends StatefulWidget {
  const AuthWidget({super.key});

  @override
  AuthWidgetState createState() => AuthWidgetState();
}

class AuthWidgetState extends State<AuthWidget> {
  bool _isLogin = true;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authCubit = context.watch<AuthCubit>();
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-Mail',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Podaj E-mail';
                    }
                    final emailRegex =
                        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Wprowadź poprawny e-mail';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Hasło',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Podaj hasło';
                    } else if (value.length < 8) {
                      return 'Hasło musi mieć co najmniej 8 znaków';
                    } else if (value.toLowerCase() == value) {
                      return 'Hasło musi zawierać co najmniej jedną wielką literę';
                    } else if (!value.contains(RegExp(r'\d'))) {
                      return 'Hasło musi zawierać co najmniej jedną cyfrę';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                if (!_isLogin) ...[
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Powtórz hasło',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Powtórz hasło';
                      } else if (value != _passwordController.text) {
                        return 'Powtórzone hasło nie jest takie samo jak oryginalne';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Wprowadź swoją nazwę użytkownika',
                      border: OutlineInputBorder(),
                    ),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(20),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      try {
                        if (_isLogin) {
                          authCubit.signInWithEmail(
                              _emailController.text, _passwordController.text);
                        } else {
                          authCubit.signUp(_emailController.text,
                              _passwordController.text, _nameController.text);
                        }
                      } catch (e) {
                        showDialog(
                          context: context,
                          builder: (context) =>
                              AlertDialog(title: Text(e.toString())),
                        );
                      }
                    }
                  },
                  child: Text(_isLogin ? 'Zaloguj się' : 'Zarejestruj się'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                    });
                  },
                  child: Text(_isLogin
                      ? 'Nie masz konta? Zarejestruj się'
                      : 'Masz już konto? Zaloguj się'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
