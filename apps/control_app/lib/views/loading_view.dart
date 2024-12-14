import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  final String message;
  const LoadingView({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 20,
        children: [
          CircularProgressIndicator(),
          Text(
            message,
            style: theme.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
