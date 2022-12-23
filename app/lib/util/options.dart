import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// TODO: use consistent icons (outlines vs black etc.)

class Options {
  static final map = {
    "phone": OptionData(icon: FontAwesomeIcons.phone),
    "facebook": OptionData(icon: FontAwesomeIcons.facebook),
    "twitter":
        OptionData(icon: FontAwesomeIcons.twitter, idFormatter: (id) => "@$id"),
    "instagram": OptionData(icon: FontAwesomeIcons.instagram),
    "email": OptionData(
        icon: FontAwesomeIcons.envelope,
        formFieldValidator: (value) =>
            value.isValidEmail ? null : "$value is not a valid email"),
  };
}

class OptionData {
  late final FormFieldValidator<String> validator;
  final IconData icon;
  late final String Function(String id) identityFormatter;

  OptionData({formFieldValidator, required this.icon, idFormatter}) {
    validator = formFieldValidator ?? (value) => null;
    identityFormatter = idFormatter ?? (id) => id;
  }
}
