import 'package:app/screens/login.dart';
import 'package:app/screens/profile.dart';
import 'package:app/screens/register.dart';
import 'package:app/services/users.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth.dart';

class SplashScreen extends StatelessWidget {
  static String route = "/splash";

  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(builder: (context, service, child) {
      return FutureBuilder(
          future: service.loggedIn,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }

            // TODO: replace with proper routing instead of this
            // to fix some bugs
            if (snapshot.data!) {
              return ChangeNotifierProvider<UsersService>(
                create: (context) => UsersService(authService: service),
                child: ProfilePage(),
              );
            }
            return LoginPage();
          });
    });
  }
}
