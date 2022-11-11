import 'package:app/screens/contacts.dart';
import 'package:app/screens/login.dart';
import 'package:app/screens/profile.dart';
import 'package:app/screens/register.dart';
import 'package:app/screens/splash.dart';
import 'package:app/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: ((context) => AuthService()))],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: SplashScreen.route,
        routes: {
          SplashScreen.route: (context) => const SplashScreen(),
          ContactsPage.route: (context) => const ContactsPage(),
          LoginPage.route: (context) => LoginPage(),
          ProfilePage.route: (context) => ProfilePage(),
          RegisterPage.route: (context) => RegisterPage(),
        },
      ),
    );
  }
}
