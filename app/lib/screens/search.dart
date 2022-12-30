import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  static String route = "/search";

  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("search")),
    );
  }
}
