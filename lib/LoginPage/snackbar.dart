import 'package:flutter/material.dart';

class ErrorSnackbar extends StatelessWidget {
  const ErrorSnackbar({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return SnackBar(
      content: Text(text),
      behavior: SnackBarBehavior.floating,
      elevation: 6,
      dismissDirection: DismissDirection.vertical,
    );
  }
}
