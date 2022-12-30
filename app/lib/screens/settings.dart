import 'package:app/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  static String route = "/settings";

  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Ink(
          decoration: ShapeDecoration(
            shape: const CircleBorder(),
            color: Theme.of(context).errorColor,
          ),
          child: IconButton(
            iconSize: 50,
            color: Colors.white,
            onPressed: () =>
                Provider.of<AuthService>(context, listen: false).logout(),
            icon: const FaIcon(FontAwesomeIcons.powerOff),
          ),
        ),
      ),
    );
  }
}
