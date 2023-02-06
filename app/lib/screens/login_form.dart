import 'package:app/services/auth.dart';
import 'package:app/ui/gradient_button.dart';
import 'package:app/ui/textinput.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../util/string_validations.dart';

class LoginForm extends StatelessWidget {
  final _isLoading = ValueNotifier<bool>(false);

  final _formKey = GlobalKey<FormState>();
  final username = TextEditingController();
  final password = TextEditingController();

  LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    List<Widget> formFields = [
      CustomTextField(
        autofocus: true,
        hintText: "willywonka",
        label: "Username",
        controller: username,
        validator: (value) {
          if (!value.isValidName) {
            return 'Username is invalid.';
          }
          return null;
        },
      ),
      const SizedBox(height: 20),
      CustomTextField(
        hintText: "min. 8 characters",
        label: "Password",
        secret: true,
        controller: password,
        validator: (value) {
          if (!value.isValidPassword) {
            return 'Password is invalid.';
          }
          return null;
        },
      ),
    ];

    Widget form = Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: Column(
              children: formFields,
            ),
          ),
          GradientButton(
            onPressed: () => _submit(context),
            child: const Text(
              'Login',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
            ),
          ),
        ],
      ),
    );

    return ValueListenableBuilder(
      valueListenable: _isLoading,
      builder: (context, loading, _) =>
          loading ? const Center(child: CircularProgressIndicator()) : form,
    );
  }

  Future<void> _submit(BuildContext context) async {
    // Validate returns true if the form is valid, or false otherwise.
    if (_formKey.currentState!.validate()) {
      _isLoading.value = true;
      try {
        await Provider.of<AuthService>(context, listen: false)
            .login(username.text, password.text);
      } catch (e) {
        // TODO: sendErrorDialog util function to show this
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
      _isLoading.value = false;
    }
  }
}
