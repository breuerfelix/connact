import 'package:app/services/users.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  static String route = "/profile";

  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: FutureBuilder(
        future: Provider.of<UsersService>(context, listen: false).currentUser,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error: ${snapshot.error}")),
              );
            });
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return _buildUserProfile(snapshot.data!);
        },
      ),
    );
  }

  Widget _buildUserProfile(User user) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text("username: ${user.username}"),
          Text("email: ${user.email}"),
        ],
      ),
    );
  }
}
