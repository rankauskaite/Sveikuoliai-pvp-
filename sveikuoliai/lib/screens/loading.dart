import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF8093F1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
                        Image.asset(
              'assets/logo.png', // Naudojamas asset kelias
              width: 150,
              height: 150,
            ),
          ],
        ),
      ),
    );
  }
}
