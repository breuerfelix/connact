import 'package:flutter/material.dart';

class SelfReplacingButton extends StatelessWidget {
  final Icon icon;
  final List<ActionButton> actions;
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
                  color: Theme.of(context).colorScheme.primary,
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

class ActionButton {
  final IconData icon;
  final void Function() onPressed;

  ActionButton({required this.icon, required this.onPressed});
}
