import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
              future: search(value.text),
              builder: (context, snapshot) {
                // print("connection state");
                // print(snapshot.connectionState == ConnectionState.waiting);
                // print("data");
                // print(snapshot.hasData);
                final loading = !snapshot.hasData ||
                    snapshot.connectionState == ConnectionState.waiting;
                // TODO: error handling

                if (!loading && snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                            "https://media.tenor.com/lx2WSGRk8bcAAAAC/pulp-fiction-john-travolta.gif"),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Where is everyone?",
                          style: Theme.of(context).textTheme.headline5,
                        )
                      ],
                    ),
                  );
                }

                final results = snapshot.data;
                return Column(
                  children: [
                    loading
                        ? const LinearProgressIndicator(
                            backgroundColor: Colors.transparent,
                            minHeight: 5,
                          )
                        : const SizedBox(
                            height: 5,
                          ),
                    Expanded(
                      child: ListView(
                          children: (results ?? [])
                              .map((username) => _userCard(context, username))
                              .toList()),
                    )
                  ],
                );
              });
        },
      ),
    );
  }

  Widget _userCard(BuildContext context, String username) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.transparent,
            backgroundImage: NetworkImage(
                "https://avatars.dicebear.com/api/personas/$username.png"),
          ),
          title: Text(
            username,
            style: Theme.of(context).textTheme.headline5,
          ),
          trailing: IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("Added user $username"),
              ));
              // TODO: actually add the user
              // TODO: turn the add icon to a tick on click to indicate success
            },
            icon: const FaIcon(FontAwesomeIcons.plus),
          ),
        ),
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
  "ahfuawh"
];
