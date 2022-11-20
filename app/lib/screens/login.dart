import 'package:app/screens/register.dart';
import 'package:app/services/auth.dart';
import 'package:app/services/users.dart';
import 'package:app/util/options.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:provider/provider.dart';
import '../util/string_validations.dart';

class LoginPage extends StatelessWidget {
  static String route = "/login";
  final _isLoading = ValueNotifier<bool>(false);

  final _formKey = GlobalKey<FormState>();
  final username = TextEditingController();
  final password = TextEditingController();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<TextFormField> formFields = [
      TextFormField(
        autofocus: true,
        decoration: const InputDecoration(hintText: "Username"),
        controller: username,
        // The validator receives the text that the user has entered.
        validator: (value) {
          if (!value.isValidName) {
            return 'Username is invalid.';
          }
          return null;
        },
      ),
      TextFormField(
        // TODO: use two password fields and validate on that
        decoration: const InputDecoration(hintText: "Password"),
        controller: password,
        obscureText: true,
        // The validator receives the text that the user has entered.
        validator: (value) {
          if (!value.isValidPassword) {
            return 'Password is invalid';
          }
          return null;
        },
      ),
    ];

    Widget submitButton = ElevatedButton(
      onPressed: () async {
        // Validate returns true if the form is valid, or false otherwise.
        if (_formKey.currentState!.validate()) {
          _isLoading.value = true;
          try {
            Provider.of<AuthService>(context, listen: false)
                .login(username.text, password.text);
          } catch (e) {
            // TODO: sendErrorDialog util function to show this
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error: $e")),
            );
          }
          _isLoading.value = false;
        }
      },
      child: const Text('Submit'),
    );

    Widget form = Form(
        key: _formKey,
        child: Column(
          children: [
            ...formFields,
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: submitButton,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                  child: const Text('Register instead'),
                  onPressed: () =>
                      Navigator.pushNamed(context, RegisterPage.route)),
            ),
          ],
        ));

    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ValueListenableBuilder(
            valueListenable: _isLoading,
            builder: (context, loading, _) =>
                loading ? const CircularProgressIndicator() : form,
          ),
        ),
      ),
    );
  }
}
