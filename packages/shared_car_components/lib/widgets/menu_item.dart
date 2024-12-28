import 'package:flutter/material.dart';

class MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isImportantAction;
  final void Function() onPressed;

  const MenuItem(
      {super.key,
      required this.icon,
      required this.label,
      required this.onPressed,
      this.isImportantAction = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MenuItemButton(
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 10,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isImportantAction ? theme.colorScheme.error : null,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: isImportantAction
                  ? theme.textTheme.labelLarge!
                      .copyWith(color: theme.colorScheme.error)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
