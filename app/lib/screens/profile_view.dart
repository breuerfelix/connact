import 'package:app/services/users.dart';
import 'package:app/ui/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileViewPage extends StatelessWidget {
  static String route = "/profiles/:username";
  final String username;

  const ProfileViewPage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    final userService = Provider.of<UsersService>(context, listen: false);

    return Center(
      child: FutureBuilder(
        future: userService.get(username),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("Could not load user");
          }

          if (!snapshot.hasData ||
              snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          var user = snapshot.data!;
          return Scaffold(body: UserProfile(user: user));
        },
      ),
    );
  }
}
