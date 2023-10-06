import 'package:app/screens/search.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../services/users.dart';

class ContactsPage extends StatelessWidget {
  static String route = "/contacts";

  const ContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contacts"),
        actions: [
          IconButton(
              onPressed: () => context.go(SearchPage.route),
              icon: const FaIcon(FontAwesomeIcons.magnifyingGlass))
        ],
      ),
      body: Center(
          child: FutureBuilder(
        future: _fetchContacts(context),
        builder: (context, snapshot) {
          if (!snapshot.hasData ||
              snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          final contacts = snapshot.data!;

          if (contacts.isEmpty) {
            return const Text("No contacts found. Go to search to add some.");
          }

          return ListView(
            children: sortedUserEntries(contacts)
                .map((entry) => _userCard(context, entry.key, entry.value))
                .toList(),
          );
        },
      )),
    );
  }

  // sortedUserEntries puts users first in the list that are not pending
  // (not null when fetching).
  List<MapEntry<String, User?>> sortedUserEntries(Map<String, User?> contacts) {
    return contacts.entries.toList()
      ..sort((a, b) {
        if (a.value == null) return 1;
        if (b.value == null) return -1;
        return 0;
      });
  }

  Widget _userCard(BuildContext context, String username, User? user) {
    final pending = user == null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          // TODO: adapt colorscheme
          leading: CircleAvatar(
            backgroundColor: Colors.grey[200],
            backgroundImage: pending
                ? null
                : NetworkImage(
                    "https://avatars.dicebear.com/api/personas/$username.png"),
            child: pending ? const FaIcon(FontAwesomeIcons.question) : null,
          ),
          title: Text(
            pending ? username : user.fullname!,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          trailing: IconButton(
            onPressed:
                pending ? null : () => context.push("/profiles/$username"),
            icon: Tooltip(
              message: pending ? "pending invite" : "see profile",
              child: FaIcon(pending
                  ? FontAwesomeIcons.hourglassHalf
                  : FontAwesomeIcons.angleRight),
            ),
          ),
        ),
      ),
    );
  }

  Future<Map<String, User?>> _fetchContacts(BuildContext context) async {
    final usersService = Provider.of<UsersService>(context, listen: false);

    final Map<String, User?> users = {};
    final currentUser = await usersService.currentUser;
    for (String contact in (currentUser.contacts ?? {})) {
      contact = contact.replaceFirst("user:", "");
      users[contact] = await usersService.get(contact);
    }

    // push null for requested users to indicate pending status
    for (String contact in (currentUser.requested ?? {})) {
      contact = contact.replaceFirst("user:", "");
      users[contact] = null;
    }

    return users;
  }
}
