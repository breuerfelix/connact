import 'package:app/screens/login.dart';
import 'package:app/screens/profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth.dart';

class SplashScreen extends StatelessWidget {
  static String route = "/splash";

  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(builder: (context, value, child) {
      return FutureBuilder(
          future: value.loggedIn,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }

            if (snapshot.data!) {
              return const ProfilePage();
            }
            return LoginPage();
          });
    });
  }
}
