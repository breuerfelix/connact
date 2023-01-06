import 'package:app/services/users.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatelessWidget {
  static String route = "/search";
  final _controller = TextEditingController();

  SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: TextField(
            controller: _controller,
            cursorColor: Colors.white,
            maxLines: 1,
            decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(10),
                icon: const FaIcon(
                  FontAwesomeIcons.magnifyingGlass,
                  color: Colors.white,
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Theme.of(context).primaryColorDark,
                hintText: 'Search...',
                hintStyle: const TextStyle(color: Colors.white),
                suffixIcon: ValueListenableBuilder(
                  valueListenable: _controller,
                  builder: (_, value, __) => value.text == ""
                      ? const SizedBox.shrink()
                      : IconButton(
                          onPressed: () => _controller.clear(),
                          icon: const Icon(Icons.clear),
                          color: Colors.white,
                        ),
                )),
            autofocus: true,
            textInputAction: TextInputAction.search,
            textCapitalization: TextCapitalization.none,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: _controller,
        builder: (_, value, __) {
          if (value.text == "") {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const FaIcon(
                    FontAwesomeIcons.binoculars,
                    size: 60,
                  ),
                  Text(
                    "Start looking for your friends.",
                    style: Theme.of(context).textTheme.headline5,
                  )
                ],
              ),
            );
          }

          return FutureBuilder(
              future: Future.wait([
                search(value.text),
                Provider.of<UsersService>(context, listen: false).currentUser
              ]),
              builder: (context, snapshot) {
                // print("connection state");
                // print(snapshot.connectionState == ConnectionState.waiting);
                // print("data");
                // print(snapshot.hasData);
                final loading = !snapshot.hasData ||
                    snapshot.connectionState == ConnectionState.waiting;
                // TODO: error handling

                final searchResults = snapshot.data?[0] as List<String>?;
                final currentUser = snapshot.data?[1] as User?;

                // if (!loading && searchResults!.isEmpty) {
                //   return Center(
                //     child: Image.network(
                //         "https://media.tenor.com/lx2WSGRk8bcAAAAC/pulp-fiction-john-travolta.gif"),
                //   );
                // }

                return Column(
                  children: [
                    loading
                        ? const LinearProgressIndicator(
                            backgroundColor: Colors.transparent,
                            minHeight: 5,
                          )
                        :
                        // to not jump when loading indicator is gone
                        const SizedBox(
                            height: 5,
                          ),
                    if (currentUser != null) ...[
                      const Text("Hit or miss:"),
                      _userCard(context, currentUser, value.text,
                          icon: const FaIcon(FontAwesomeIcons.question)),
                    ],
                    if ((searchResults ?? []).isNotEmpty) ...[
                      const Divider(),
                      const Text("Search results:"),
                    ],
                    Expanded(
                        child: ListView(
                            children: (searchResults ?? [])
                                .map((username) =>
                                    _userCard(context, currentUser!, username))
                                .toList()))
                  ],
                );
              });
        },
      ),
    );
  }

  Widget _userCard(BuildContext context, User currentUser, String username,
      {Widget? icon}) {
    final isInContacts =
        currentUser.contacts?.contains("user:$username") ?? false;
    final isUserItself = currentUser.username == username;
    final isAdded = ValueNotifier(isInContacts || isUserItself);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey[200],
              backgroundImage: icon == null
                  ? NetworkImage(
                      "https://avatars.dicebear.com/api/personas/$username.png")
                  : null,
              child: icon,
            ),
            title: Text(
              username,
              style: Theme.of(context).textTheme.headline5,
            ),
            trailing: ValueListenableBuilder(
              valueListenable: isAdded,
              builder: (context, added, _) => IconButton(
                onPressed: added
                    ? null
                    : () async {
                        currentUser.contacts!.add("user:$username");
                        await Provider.of<UsersService>(context, listen: false)
                            .update(currentUser);

                        isAdded.value = true;
                      },
                icon: added
                    ? const FaIcon(FontAwesomeIcons.check)
                    : const FaIcon(FontAwesomeIcons.plus),
              ),
            )),
      ),
    );
  }
}

// TODO: fetch from user service
Future<List<String>> search(String filter) async {
  return Future.delayed(
    const Duration(milliseconds: 500),
    () => TEST_VALUES.where((element) => element.contains(filter)).toList(),
  );
}

final TEST_VALUES = [
  "test123",
  "tes345",
  "awdawd",
  "löijafe",
  "löjiawd",
  "vgaw",
  "ahfuawh",
  "brumhard"
];
