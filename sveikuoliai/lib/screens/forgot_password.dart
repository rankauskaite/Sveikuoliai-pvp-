import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7AEF8),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Color(0xFFF7AEF8), width: 20),
            borderRadius: BorderRadius.circular(40),
          ),
          child: Padding(
            padding: const EdgeInsets.all(
                20.0), // Užtikrina, kad turinys nebūtų per arti krašto
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Centruoja viską vertikaliai
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Centruoja viską horizontaliai
              children: [
                Image.asset('assets/logo.png', width: 150, height: 150),
                SizedBox(height: 20),
                Text(
                  'Pamiršai slaptažodį?',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
