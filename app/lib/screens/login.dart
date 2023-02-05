import 'package:app/screens/login_form.dart';
import 'package:app/screens/register_form.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  static String route = "/login";

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget tabs = Column(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: const [
            Text(
              "connact",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
            ),
            Text("[contact:connect]",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.6))
          ],
        ),
        const SizedBox(
          height: 50,
        ),
        Container(
          decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(25)),
          child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: const Color(0xFF2f3e46),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black,
              indicatorPadding: const EdgeInsets.all(3),
              splashBorderRadius: BorderRadius.circular(25),
              tabs: const [
                Tab(text: "Login"),
                Tab(text: "Sign up"),
              ]),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TabBarView(
              controller: _tabController,
              children: [
                LoginForm(),
                RegisterForm(),
              ],
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: tabs,
        ),
      ),
    );
  }
}
