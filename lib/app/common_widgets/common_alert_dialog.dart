import 'package:flutter/material.dart';

class CommonAlertDialog extends StatelessWidget {
  const CommonAlertDialog({
    super.key,
    required this.notNow,
    required this.login,
  });

  final VoidCallback notNow;
  final VoidCallback login;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text(
        "Login",
        style: TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: const Text(
        "Please, Login before continue.",
        style: TextStyle(
          color: Colors.blueGrey,
          fontSize: 16,
        ),
      ),
      actions: [
        TextButton(
          onPressed: notNow,
          child: const Text(
            "Not Now",
            style: TextStyle(
              color: Colors.deepPurple,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextButton(
          onPressed: login,
          child: const Text(
            "Login",
            style: TextStyle(
              color: Colors.deepPurple,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
