import 'package:flutter/material.dart';

class MenuItem extends StatelessWidget {
  final IconData? icon;
  final String label;
  final bool isImportantAction;
  final void Function() onPressed;

  const MenuItem(
      {super.key,
      this.icon,
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
          spacing: 10,
          children: [
            if (icon != null)
              Icon(
                icon,
                color: isImportantAction ? theme.colorScheme.error : null,
              ),
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
