import 'package:app/screens/profile_edit.dart';
import 'package:app/services/users.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  static String route = "/profile";

  ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Consumer<UsersService>(
        builder: (context, service, child) => FutureBuilder(
          future: service.currentUser,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              // user not initialized yet on first app load
              if (snapshot.error is NotFoundException) {
                return Center(
                  child: ProfileEditDialog(),
                );
              }

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
      ),
    );
  }

  Widget _buildUserProfile(User user) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text("username: ${user.username}"),
          Text("fullName: ${user.fullname}"),
        ],
      ),
    );
  }
}
