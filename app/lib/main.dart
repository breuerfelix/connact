import 'package:app/screens/contacts.dart';
import 'package:app/screens/login.dart';
import 'package:app/screens/profile.dart';
import 'package:app/screens/register.dart';
import 'package:app/screens/share.dart';
import 'package:app/services/auth.dart';
import 'package:app/services/users.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../util/string_casing.dart';

void main() {
  runApp(const MyApp());
}

// TODO: add splash screen;: https://pub.dev/packages/flutter_native_splash
class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
                path: LoginPage.route,
                pageBuilder: (context, state) =>
                    NoTransitionPage(child: LoginPage()),
              ),
              GoRoute(
                  path: RegisterPage.route,
                  pageBuilder: (context, state) =>
                      NoTransitionPage(child: RegisterPage())),
              ShellRoute(builder: _pageScaffoldBuilder, routes: [
                GoRoute(
                    path: ContactsPage.route,
                    pageBuilder: (context, state) =>
                        const NoTransitionPage(child: ContactsPage())),
                GoRoute(
                    path: ProfilePage.route,
                    pageBuilder: (context, state) =>
                        NoTransitionPage(child: ProfilePage())),
                GoRoute(
                    path: SharePage.route,
                    pageBuilder: (context, state) =>
                        const NoTransitionPage(child: SharePage())),
              ]),
            ]),
      ),
    );
  }

// NOTE: this is now using nested scaffolds which is not supported
// in every scenario but still there's no real alternative when
// changing the AppBar and navigating with bottom navigation bar.
// See https://github.com/flutter/flutter/issues/23106.
// https://stackoverflow.com/questions/64618050/is-it-correct-to-have-nested-scaffold-in-flutter
  Widget _pageScaffoldBuilder(
      BuildContext context, GoRouterState state, Widget child) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }
}

BottomNavigationBar _buildBottomNavigationBar(BuildContext context) {
  final pageToIcon = {
    ContactsPage.route: FontAwesomeIcons.addressBook,
    SharePage.route: FontAwesomeIcons.share,
    ProfilePage.route: FontAwesomeIcons.person,
  };

  return BottomNavigationBar(
      currentIndex: pageToIcon.keys
          .toList()
          .indexWhere((element) => element == GoRouter.of(context).location),
      onTap: (index) => context.go(pageToIcon.keys.elementAt(index)),
      items: pageToIcon.entries
          .map((p) => BottomNavigationBarItem(
              icon: Icon(p.value), label: p.key.split('/').last.capitalize()))
          .toList());
}
