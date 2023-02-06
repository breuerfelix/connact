import 'package:app/screens/contacts.dart';
import 'package:app/screens/login.dart';
import 'package:app/screens/profile.dart';
import 'package:app/screens/profile_view.dart';
import 'package:app/screens/search.dart';
import 'package:app/screens/settings.dart';
import 'package:app/screens/share.dart';
import 'package:app/services/auth.dart';
import 'package:app/services/users.dart';
import 'package:app/ui/colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'util/string_casing.dart';

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
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ThemeData().colorScheme.copyWith(
                primary: ColorTheme.primary,
                secondary: ColorTheme.highlight,
              ),
          // seems like we need to statically set that now: https://github.com/material-foundation/flutter-packages/issues/35
          fontFamily: "Montserrat",
        ),
        routerConfig: GoRouter(
            refreshListenable: authService,
            redirect: (context, state) async {
              final onLoginPage = state.subloc == LoginPage.route;

              if (!onLoginPage && !await authService.loggedIn) {
                // would be nice to clear the navigation stack here
                // see https://github.com/flutter/flutter/issues/114131
                return LoginPage.route;
              }

              if (onLoginPage && await authService.loggedIn) {
                return SharePage.route;
              }

              return null;
            },
            initialLocation: SharePage.route,
            routes: [
              GoRoute(
                path: LoginPage.route,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: LoginPage()),
              ),
              ShellRoute(builder: _pageScaffoldBuilder, routes: [
                ...{
                  ContactsPage.route: const ContactsPage(),
                  ProfilePage.route: ProfilePage(),
                  SharePage.route: const SharePage(),
                  SettingsPage.route: const SettingsPage(),
                  SearchPage.route: SearchPage(),
                }
                    .entries
                    .map((p) => GoRoute(
                          path: p.key,
                          pageBuilder: (context, state) =>
                              NoTransitionPage(child: p.value),
                        ))
                    .toList(),
                GoRoute(
                  path: ProfileViewPage.route,
                  builder: (context, state) =>
                      ProfileViewPage(username: state.params["username"]!),
                ),
              ])
            ]),
      ),
    );
  }

// NOTE: this is now using nested scaffolds which is not supported
// in every scenario but still there's no real alternative when
// changing the AppBar and navigating with bottom navigation bar.
// See https://github.com/flutter/flutter/issues/23106.
// https://stackoverflow.com/questions/64618050/is-it-correct-to-have-nested-scaffold-in-flutter
//
// The bottom app bar is trying to emulate this layout:
// https://www.uplabs.com/posts/bottom-navigation-bar-ui-kit-29531c96-5562-47c5-acec-3b52618e4af3.
  Widget _pageScaffoldBuilder(
      BuildContext context, GoRouterState state, Widget child) {
    Map<String, IconData> pageToIcon = {
      SettingsPage.route: FontAwesomeIcons.sliders,
      SearchPage.route: FontAwesomeIcons.magnifyingGlass,
      SharePage.route: FontAwesomeIcons.handshakeSimple,
      ProfilePage.route: FontAwesomeIcons.person,
      ContactsPage.route: FontAwesomeIcons.addressBook,
    };
    assert(pageToIcon.length.isOdd);

    final middlePageIndex = (pageToIcon.length / 2).floor();
    final middlePageKey = pageToIcon.keys.elementAt(middlePageIndex);
    List<Widget> bottomBarItems = pageToIcon.entries
        .map<Widget>((entry) => entry.key == middlePageKey
            // replacing middle one to keep row spacing correct
            // middle one is instead in the FAB
            ? const SizedBox.shrink()
            : _bottomButton(context, entry.key, entry.value))
        .toList();

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 5,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: bottomBarItems,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(middlePageKey),
        tooltip: middlePageKey,
        child: FaIcon(pageToIcon[middlePageKey]),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

Widget _bottomButton(BuildContext context, String page, IconData icon) {
  final pageActive = GoRouter.of(context).location == page;
  final color = pageActive
      ? Theme.of(context).colorScheme.secondary
      : Theme.of(context).colorScheme.primary;
  return Tooltip(
    message: page,
    child: SizedBox.fromSize(
      size: const Size(60, 60),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => context.go(page),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              icon,
              size: 25,
              color: color,
            ), // <-- Icon
            Text(
              page.split('/').last.capitalize(),
              style:
                  Theme.of(context).textTheme.caption!.copyWith(color: color),
            ), // <-- Text
          ],
        ),
      ),
    ),
  );
}
