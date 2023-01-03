import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../util/string_validations.dart';

// TODO: use consistent icons (outlines vs black etc.)
// TODO: probably need to configure used schemes for url_launcher: https://pub.dev/packages/url_launcher#configuration

class Options {
  static final map = {
    "phone": OptionData(
      icon: FontAwesomeIcons.phone,
      urlFormatter: (value) => "tel:$value",
    ),
    "facebook": OptionData(
      icon: FontAwesomeIcons.facebook,
      urlFormatter: (value) => "https://facebook.com/$value",
    ),
    "twitter": OptionData(
      icon: FontAwesomeIcons.twitter,
      urlFormatter: (value) => "https://twitter.com/$value",
    ),
    "instagram": OptionData(
      icon: FontAwesomeIcons.instagram,
      urlFormatter: (value) => "https://instagram.com/$value",
    ),
    "email": OptionData(
      icon: FontAwesomeIcons.envelope,
      urlFormatter: (value) => "mailto:$value",
      validator: (value) =>
          value.isValidEmail ? null : "$value is not a valid email",
    ),
  };
}

class OptionData {
  final FormFieldValidator<String>? validator;
  final String Function(String value) urlFormatter;
  final IconData icon;

  OptionData({this.validator, required this.icon, required this.urlFormatter});
}
