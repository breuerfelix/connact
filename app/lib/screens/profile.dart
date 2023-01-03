import 'package:app/services/users.dart';
import 'package:app/util/options.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

// TODO: open link on tab
// TODO: add option to remove dynamicProperties

class ProfilePage extends StatelessWidget {
  static String route = "/profile";

  final _formKey = GlobalKey<FormState>();
  final ValueNotifier<bool> editing = ValueNotifier(false);

  ProfilePage({super.key});

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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("Welcome back @${user.username}!",
                              style: Theme.of(context).textTheme.headline4),
                          _buildUserProfile(context, user, inEditMode),
                        ],
                      ),
                    ),
                  ),
                );
              });
        });
  }

  Widget _buildUserProfile(BuildContext context, User user, bool inEditMode) {
    final changeListener =
        ChangeNotifier(); // TODO: there's probably a cleaner approach

    return AnimatedBuilder(
        animation: changeListener,
        builder: (context, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                maxRadius: 100,
                backgroundColor: Colors.transparent,
                backgroundImage: NetworkImage(
                    "https://avatars.dicebear.com/api/personas/${user.username}.png"),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: TextFormField(
                  initialValue: user.fullname,
                  onSaved: (value) => user.fullname = value!,
                  validator: (value) =>
                      value != "" ? null : "Full Name is required",
                  enabled: inEditMode,
                  style: Theme.of(context)
                      .textTheme
                      .headline4!
                      .copyWith(color: Colors.black),
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                      hintText: "<Your full name>",
                      disabledBorder: InputBorder.none),
                ),
              ),
              ...user.dynamicProperties.entries.map((prop) => _buildInfoCard(
                    context,
                    inEditMode,
                    icon: Options.map[prop.key]!.icon,
                    text: prop.value,
                    onSave: (value) {
                      user.dynamicProperties[prop.key] = value;
                    },
                    onRemove: () {
                      user.dynamicProperties.remove(prop.key);
                      changeListener.notifyListeners();
                    },
                    validator: Options.map[prop.key]!.validator,
                  )),
              !inEditMode
                  ? const SizedBox.shrink()
                  : SelfReplacingButton(
                      icon: const Icon(Icons.add),
                      actions: Options.map.keys
                          .where((element) =>
                              !user.dynamicProperties.containsKey(element))
                          .map((e) => Action(
                              onPressed: () {
                                user.dynamicProperties[e] = "";
                                changeListener.notifyListeners();
                              },
                              icon: Options.map[e]!.icon))
                          .toList(),
                    )
            ],
          );
        });
  }

  Widget _buildInfoCard(
    BuildContext context,
    bool inEditMode, {
    required IconData icon,
    required String text,
    required void Function(String) onSave,
    required void Function() onRemove,
    String? Function(String?)? validator,
  }) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          maxRadius: 40,
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).iconTheme.color,
          child: FaIcon(
            icon,
            size: 35,
          ),
        ),
        title: TextFormField(
          key: Key(icon.toString()), // to keep the text in the right fields
          initialValue: text,
          onSaved: (value) => onSave(value!),
          validator: (value) {
            if (value == "") {
              return "Field is required";
            }
            if (validator != null) {
              return validator(value);
            }
            return null;
          },
          enabled: inEditMode,
          style: Theme.of(context).textTheme.headline5,
          decoration: const InputDecoration(disabledBorder: InputBorder.none),
        ),
        trailing: inEditMode
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: onRemove,
              )
            : null,
      ),
    );
  }
}

class SelfReplacingButton extends StatelessWidget {
  final Icon icon;
  final List<Action> actions;
  final ValueNotifier<bool> _drawerOpen = ValueNotifier(false);

  SelfReplacingButton({required this.icon, required this.actions, super.key});

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

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
                  color: Colors.white,
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
