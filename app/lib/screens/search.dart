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
      body: const Center(child: Text("search")),
    );
  }
}
