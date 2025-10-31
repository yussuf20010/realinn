import 'package:flutter/material.dart';

class ThemedScaffold extends StatelessWidget {
  final Widget body;
  final bool isDarkMode;

  const ThemedScaffold({Key? key, required this.body, this.isDarkMode = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            isDarkMode
                ? 'assets/images/dark.png'
                : 'assets/images/light.png',
          ),
          fit: BoxFit.cover, // Covers the entire screen
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Ensure transparency
        body: body,
      ),
    );
  }
}
