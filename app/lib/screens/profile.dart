import 'package:app/services/users.dart';
import 'package:app/ui/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

enum ProfileState {
  view,
  edit,
  update,
}

class ProfilePage extends StatelessWidget {
  static String route = "/profile";

  final _formKey = GlobalKey<FormState>();
  final ValueNotifier<ProfileState> _state = ValueNotifier(ProfileState.view);

  ProfilePage({super.key});

  // TODO: somehow prevent navigation away from this page in edit mode
  // - maybe RouteObserver

  Widget buildAppBarLoadingSpinner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: IconTheme.of(context).color,
          ),
        ),
      ),
    );
  }

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
            _state.value = ProfileState.edit;
          }

          return ValueListenableBuilder(
              valueListenable: _state,
              builder: (context, state, _) {
                return Scaffold(
                  appBar: AppBar(
                    actions: [
                      Builder(builder: (context) {
                        if (state == ProfileState.update) {
                          return buildAppBarLoadingSpinner(context);
                        }

                        return IconButton(
                            onPressed: () async {
                              if (state == ProfileState.view) {
                                _state.value = ProfileState.edit;
                                return;
                              }

                              if (!_formKey.currentState!.validate()) {
                                return;
                              }

                              _state.value = ProfileState.update;
                              _formKey.currentState!.save();
                              // show loading for at least a second
                              // TODO: add error handling
                              await Future.wait([
                                userService.update(snapshot.data!),
                                Future.delayed(const Duration(seconds: 1))
                              ]);
                              _state.value = ProfileState.view;
                            },
                            icon: FaIcon(
                              state == ProfileState.edit
                                  ? FontAwesomeIcons.floppyDisk
                                  : FontAwesomeIcons.penToSquare,
                            ));
                      }),
                    ],
                    title: const Text("Profile"),
                  ),
                  body: Center(
                    child: Form(
                      key: _formKey,
                      child: UserProfile(
                        user: user,
                        inEditMode: state == ProfileState.edit,
                      ),
                    ),
                  ),
                );
              });
        });
  }
}
