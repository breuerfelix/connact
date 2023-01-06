import 'package:app/services/users.dart';
import 'package:app/ui/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  static String route = "/profile";

  final _formKey = GlobalKey<FormState>();
  final ValueNotifier<bool> editing = ValueNotifier(false);

  ProfilePage({super.key});

  // TODO: somehow prevent navigation away from this page in edit mode
  // - maybe RouteObserver

  @override
  Widget build(BuildContext context) {
    final userService = Provider.of<UsersService>(context, listen: false);

    return FutureBuilder(
        future: userService.currentUser,
        builder: (context, snapshot) {
          if (!snapshot.hasData ||
              snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          var user = snapshot.data!;
          if (user.fullname == "") {
            editing.value = true;
          }

          return ValueListenableBuilder(
              valueListenable: editing,
              builder: (context, inEditMode, _) {
                return Scaffold(
                  appBar: AppBar(
                    actions: [
                      IconButton(
                          onPressed: () async {
                            if (inEditMode) {
                              // TODO: add waiting state indication somewhere
                              // TODO: add error handling
                              if (!_formKey.currentState!.validate()) {
                                return;
                              }

                              _formKey.currentState!.save();
                              await userService.update(snapshot.data!);
                            }
                            editing.value = !editing.value;
                          },
                          icon: FaIcon(
                            inEditMode
                                ? FontAwesomeIcons.floppyDisk
                                : FontAwesomeIcons.penToSquare,
                          ))
                    ],
                    title: const Text("Profile"),
                  ),
                  body: Center(
                    child: Form(
                      key: _formKey,
                      child: UserProfile(
                        user: user,
                        inEditMode: inEditMode,
                      ),
                    ),
                  ),
                );
              });
        });
  }
}
