import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomTextField extends StatelessWidget {
  String hintText;
  String label;
  bool autofocus;
  TextEditingController? controller;
  String? Function(String?)? validator;
  bool secret;

  late ValueNotifier<bool> _obscureText;

  CustomTextField({
    super.key,
    this.autofocus = false,
    this.secret = false,
    required this.hintText,
    required this.label,
    this.controller,
    this.validator,
  }) {
    _obscureText = ValueNotifier(secret);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 5),
        ValueListenableBuilder(
            valueListenable: _obscureText,
            builder: (context, obscureText, __) {
              return TextFormField(
                obscureText: obscureText,
                autofocus: autofocus,
                cursorColor: Theme.of(context).colorScheme.secondary,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25)),
                  hintText: hintText,
                  isDense: true,
                  suffixIcon: !secret
                      ? null
                      : IconButton(
                          splashRadius: 20,
                          onPressed: () =>
                              _obscureText.value = !_obscureText.value,
                          icon: FaIcon(
                            obscureText
                                ? FontAwesomeIcons.eye
                                : FontAwesomeIcons.eyeSlash,
                          ),
                        ),
                ),
                maxLines: 1,
                controller: controller,
                // The validator receives the text that the user has entered.
                validator: validator,
              );
            }),
      ],
    );
  }
}
