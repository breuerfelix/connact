import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

abstract class Editable<T> extends StatelessWidget {
  late final ValueNotifier<bool> _inEditMode;
  final void Function(T value) onChange;

  Editable({required this.onChange, bool editState = false, super.key}) {
    _inEditMode = ValueNotifier(editState);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: _inEditMode,
        builder: ((context, value, child) {
          return value ? buildEdit(context) : buildShow(context);
        }));
  }

  Widget buildEdit(BuildContext context);
  Widget buildShow(BuildContext context);
}

class ContactCard extends Editable<String> {
  final IconData icon;
  final String identity;
  late final TextEditingController _textController;

  ContactCard(
      {required this.icon,
      required this.identity,
      required super.onChange,
      super.key,
      super.editState}) {
    _textController = TextEditingController(text: identity);
    _textController.addListener(() => onChange(_textController.text));
  }

  void dispose() {
    _textController.dispose();
  }

  @override
  Widget buildShow(BuildContext context) {
    return Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
            maxRadius: 40,
            backgroundColor: Colors.transparent,
            foregroundColor: Theme.of(context).iconTheme.color,
            child: FaIcon(
              icon,
              size: 35,
            ),
          ),
          Text(
            _textController.text,
            style: Theme.of(context).textTheme.headline5,
          )
        ],
      ),
    );
  }

  @override
  Widget buildEdit(BuildContext context) {
    return Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
            maxRadius: 40,
            backgroundColor: Colors.transparent,
            foregroundColor: Theme.of(context).iconTheme.color,
            child: FaIcon(
              icon,
              size: 35,
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: _textController,
              style: Theme.of(context).textTheme.headline5,
            ),
          )
        ],
      ),
    );
  }
}
