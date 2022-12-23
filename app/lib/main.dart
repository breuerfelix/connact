import 'package:app/screens/contacts.dart';
import 'package:app/screens/login.dart';
import 'package:app/screens/profile.dart';
import 'package:app/screens/register.dart';
import 'package:app/screens/splash.dart';
import 'package:app/services/auth.dart';
import 'package:app/services/users.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

// TODO: add splash screen;: https://pub.dev/packages/flutter_native_splash
class MyApp extends StatelessWidget {
  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: ((context) => authService)),
        ChangeNotifierProvider(
            create: (context) => UsersService(authService: authService))
      ],
      child: MaterialApp.router(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        routerConfig: GoRouter(
            refreshListenable: authService,
            redirect: (context, state) async {
              final onLoginPage = state.subloc == RegisterPage.route ||
                  state.subloc == LoginPage.route;

              if (!onLoginPage && !await authService.loggedIn) {
                return LoginPage.route;
              }

              if (onLoginPage && await authService.loggedIn) {
                return ProfilePage.route;
              }

              return null;
            },
            initialLocation: ProfilePage.route,
            routes: [
              GoRoute(
                  path: SplashScreen.route,
                  builder: (context, state) => const SplashScreen()),
              GoRoute(
                  path: ContactsPage.route,
                  builder: (context, state) => const ContactsPage()),
              GoRoute(
                  path: LoginPage.route,
                  builder: (context, state) => LoginPage()),
              GoRoute(
                  path: ProfilePage.route,
                  builder: (context, state) => ProfilePage()),
              GoRoute(
                  path: RegisterPage.route,
                  builder: (context, state) => RegisterPage()),
            ]),
      ),
    );
  }
}
