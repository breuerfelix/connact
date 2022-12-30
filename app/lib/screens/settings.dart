import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  static String route = "/settings";

  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("settings")),
    );
  }
}
