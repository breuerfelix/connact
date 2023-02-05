import 'package:flutter/material.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:provider/provider.dart';

import '../services/auth.dart';
import '../services/users.dart';
import '../util/string_validations.dart';

class RegisterForm extends StatelessWidget {
  final _isLoading = ValueNotifier<bool>(false);

  final _formKey = GlobalKey<FormState>();
  final username = TextEditingController();
  final password = TextEditingController();
  final email = TextEditingController();

  RegisterForm({super.key});

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
          _isLoading.value = true;
          try {
            final authService =
                Provider.of<AuthService>(context, listen: false);
            await authService.signUp(username.text, password.text, email.text);
            final usersService = UsersService(authService: authService);
            await usersService.create(userFromJWT((await authService.token)!));
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error: $e")),
            );
          }
          _isLoading.value = false;
        }
      },
      child: const Text('Register'),
    );

    Widget form = Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
              child: Column(
            children: formFields,
          )),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: button),
        ],
      ),
    );

    return ValueListenableBuilder(
      valueListenable: _isLoading,
      builder: (context, loading, _) =>
          loading ? const CircularProgressIndicator() : form,
    );
  }
}

User userFromJWT(String token) {
  final payload = Jwt.parseJwt(token);

  return User(
      username: payload["username"],
      fullname: "",
      dynamicProperties: {"email": payload["email"]});
}
