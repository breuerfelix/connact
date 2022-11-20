import 'dart:async';
import 'dart:ui';

import 'package:app/services/users.dart';
import 'package:app/util/options.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import 'contact_card.dart';

// TODO: make fullname editable
// TODO: open link on tab
// TODO: add option to remove dynamicProperties

class ProfilePage extends StatelessWidget {
  static String route = "/profile";
  final ValueNotifier<bool> editing = ValueNotifier(false);
  final StreamController<User> controller = StreamController.broadcast();

  ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    var userService = Provider.of<UsersService>(context);
    userService.currentUser.then(
      (user) => controller.add(user),
      onError: (error) => controller.addError(error),
    );

    return Scaffold(
      appBar: AppBar(
          title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(),
          const Text("Profile"),
          StreamBuilder(
              stream: controller.stream,
              builder: (context, snapshot) {
                return IconButton(
                  onPressed: () async {
                    editing.value = !editing.value;
                    if (!editing.value && snapshot.hasData) {
                      // TODO: add waiting state indication somewhere
                      // TODO: add error handling
                      // FIXME: need to create user on initial load instead of update
                      await userService.update(snapshot.data!);
                    }
                  },
                  icon: ValueListenableBuilder(
                      valueListenable: editing,
                      builder: (context, editing, child) {
                        return FaIcon(
                          editing
                              ? FontAwesomeIcons.floppyDisk
                              : FontAwesomeIcons.penToSquare,
                        );
                      }),
                );
              })
        ],
      )),
      body: StreamBuilder(
        stream: controller.stream,
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

          return _buildUserProfile(context, snapshot.data!);
        },
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context, User user) {
    return Center(
        child: ValueListenableBuilder(
            valueListenable: editing,
            builder: (context, editing, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Welcome back @${user.username}!",
                      style: Theme.of(context).textTheme.headline4),
                  CircleAvatar(
                    maxRadius: 100,
                    backgroundColor: Colors.transparent,
                    backgroundImage: NetworkImage(
                        "https://avatars.dicebear.com/api/personas/${user.username}.png"),
                  ),
                  Text(
                    user.fullname,
                    style: Theme.of(context).textTheme.headline4,
                  ),

                  // TODO: updateUser on save
                  ...user.dynamicProperties.entries.map((prop) => ContactCard(
                        icon: Options.map[prop.key]!.icon,
                        identity: Options.map[prop.key]!
                            .identityFormatter(prop.value),
                        onChange: (value) {
                          user.dynamicProperties[prop.key] = value;
                        },
                        editState: editing,
                      )),

                  // TODO: there's probably something better than this
                  !editing
                      ? Container()
                      : SelfReplacingButton(
                          icon: Icon(Icons.add),
                          actions: Options.map.keys
                              .where((element) =>
                                  !user.dynamicProperties.containsKey(element))
                              .map((e) => Action(
                                  onPressed: () {
                                    user.dynamicProperties[e] = "";
                                    controller.add(user);
                                  },
                                  icon: Options.map[e]!.icon))
                              .toList(),
                        )
                ],
              );
            }));
  }
}

class SelfReplacingButton extends StatelessWidget {
  final Icon icon;
  final List<Action> actions;
  final ValueNotifier<bool> _drawerOpen = ValueNotifier(false);

  SelfReplacingButton({required this.icon, required this.actions, super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return ValueListenableBuilder(
          valueListenable: _drawerOpen,
          builder: (context, open, child) {
            if (!open) {
              return Ink(
                decoration: ShapeDecoration(
                  shape: const CircleBorder(),
                  color: Theme.of(context).primaryColor,
                ),
                child: IconButton(
                  iconSize: 30,
                  onPressed: () => _drawerOpen.value = true,
                  icon: icon,
                ),
              );
            }

            // TODO: use stack instead of row and animate transation to the sides
            // maybe https://docs.flutter.dev/cookbook/effects/expandable-fab can help
            return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: actions
                    .map((a) => IconButton(
                          iconSize: 30,
                          onPressed: () {
                            a.onPressed();
                            _drawerOpen.value = false;
                          },
                          icon: Icon(a.icon),
                        ))
                    .toList());
          });
    });
  }
}

class Action {
  final IconData icon;
  final void Function() onPressed;

  Action({required this.icon, required this.onPressed});
}
