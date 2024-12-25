import 'package:flutter/material.dart';

class VideoOverlayText extends StatelessWidget {
  final String text;

  const VideoOverlayText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(1000),
        color: theme.colorScheme.primary,
      ),
      child: Text(
        text,
        style: theme.textTheme.titleLarge!.copyWith(
          color: theme.colorScheme.onPrimary,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
