import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../util/string_validations.dart';

// TODO: use consistent icons (outlines vs black etc.)

class Options {
  static final map = {
    "phone": OptionData(icon: FontAwesomeIcons.phone),
    "facebook": OptionData(icon: FontAwesomeIcons.facebook),
    "twitter": OptionData(icon: FontAwesomeIcons.twitter),
    "instagram": OptionData(icon: FontAwesomeIcons.instagram),
    "email": OptionData(
      icon: FontAwesomeIcons.envelope,
      validator: (value) =>
          value.isValidEmail ? null : "$value is not a valid email",
    ),
  };
}

class OptionData {
  final FormFieldValidator<String>? validator;
  final IconData icon;

  OptionData({this.validator, required this.icon});
}
