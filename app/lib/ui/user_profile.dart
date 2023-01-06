import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/users.dart';
import '../util/options.dart';
import 'self_replacing_button.dart';

class UserProfile extends StatelessWidget {
  final User user;
  final bool inEditMode;

  const UserProfile({super.key, required this.user, this.inEditMode = false});

  @override
  Widget build(BuildContext context) {
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
              ...orderedProperties(user).map((prop) {
                final option = Options.map[prop.key]!;
                return _buildInfoCard(
                  context,
                  inEditMode,
                  icon: option.icon,
                  text: prop.value,
                  url: option.urlFormatter(prop.value),
                  validator: option.validator,
                  onSave: (value) {
                    user.dynamicProperties[prop.key] = value;
                  },
                  onRemove: () {
                    user.dynamicProperties.remove(prop.key);
                    changeListener.notifyListeners();
                  },
                );
              }),
              !inEditMode
                  ? const SizedBox.shrink()
                  : SelfReplacingButton(
                      icon: const Icon(Icons.add),
                      actions: Options.map.keys
                          .where((element) =>
                              !user.dynamicProperties.containsKey(element))
                          .map((e) => ActionButton(
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
}

List<MapEntry> orderedProperties(User user) {
  return user.dynamicProperties.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));
}

Widget _buildInfoCard(
  BuildContext context,
  bool inEditMode, {
  required IconData icon,
  required String text,
  required String url,
  required void Function(String) onSave,
  required void Function() onRemove,
  String? Function(String?)? validator,
}) {
  return Card(
    child: InkWell(
      onTap: inEditMode ? null : () => launchUrl(Uri.parse(url)),
      mouseCursor: MouseCursor.defer,
      child: ListTile(
        leading: FaIcon(
          icon,
          size: 35,
          color: Colors.black,
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
    ),
  );
}
