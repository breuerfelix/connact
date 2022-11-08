import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth.dart';
import '../util/string_validations.dart';

class RegisterPage extends StatelessWidget {
  static String route = "/register";

  final _formKey = GlobalKey<FormState>();
  final username = TextEditingController();
  final password = TextEditingController();
  final email = TextEditingController();

  RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<TextFormField> formFields = [
      TextFormField(
        autofocus: true,
        decoration: const InputDecoration(hintText: "Email"),
        controller: email,
        // The validator receives the text that the user has entered.
        validator: (value) {
          if (!value.isValidEmail) {
            return 'Email is invalid.';
          }
          return null;
        },
      ),
      TextFormField(
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

    Widget button = ElevatedButton(
      onPressed: () async {
        // Validate returns true if the form is valid, or false otherwise.
        if (_formKey.currentState!.validate()) {
          try {
            await Provider.of<AuthService>(context, listen: false)
                .signUp(username.text, password.text, email.text);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error: $e")),
            );
          }
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
                child: button),
          ],
        ));

    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Center(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: form,
      )),
    );
  }
}
