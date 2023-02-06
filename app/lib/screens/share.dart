import 'package:app/services/users.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SharePage extends StatelessWidget {
  static String route = "/share";

  const SharePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Provider.of<UsersService>(context, listen: false).currentUser,
        builder: (context, snapshot) {
          // TODO: copy error handling from other FutureBuilders
          // and define as defaultFutureBuilder somewhere

          if (snapshot.hasData) {
            final username = snapshot.data!.username;
            return Scaffold(
              appBar: AppBar(title: const Text("Share")),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("@$username",
                        style: Theme.of(context).textTheme.headline3),
                    QrImage(
                      data: "https://connact.io/add/$username",
                      size: 0.6 * MediaQuery.of(context).size.width,
                    )
                  ],
                ),
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        });
  }
}
