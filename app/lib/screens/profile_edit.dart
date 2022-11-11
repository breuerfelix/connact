import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth.dart';
import '../services/users.dart';
import '../util/string_validations.dart';

class ProfileEditDialog extends StatelessWidget {
  final User? currentUser;

  final _isLoading = ValueNotifier<bool>(false);

  final _formKey = GlobalKey<FormState>();
  final fullname = TextEditingController();

  ProfileEditDialog({super.key, this.currentUser});

  @override
  Widget build(BuildContext context) {
    List<TextFormField> formFields = [
      TextFormField(
        decoration: const InputDecoration(hintText: "fullName"),
        controller: fullname,
        // initialValue: currentUser?.fullname,
        validator: (value) {
          if (!value.isValidName) {
            return 'Username is invalid.';
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
            if (currentUser == null) {
              await Provider.of<UsersService>(context, listen: false)
                  .create(fullname.text);
            } else {
              await Provider.of<UsersService>(context, listen: false)
                  .create(fullname.text);
            }
          } catch (e) {
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
                child: button),
          ],
        ));

    return ValueListenableBuilder(
      valueListenable: _isLoading,
      builder: (context, loading, _) =>
          loading ? const CircularProgressIndicator() : form,
    );
  }
}
