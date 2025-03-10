import 'package:flutter/material.dart';
import 'package:sveikuoliai/screens/login.dart';
import 'package:sveikuoliai/screens/signup.dart';

class HelloScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7AEF8),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Labas, tai',
              style: TextStyle(
                fontSize: 24,
                color: Colors.black,
              ),
            ),
            Text(
              '[APPSO PAVADINIMAS]',
              style: TextStyle(
                fontSize: 35,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 20,
            ),
            Image.asset(
              'assets/logo.png', // Naudojamas asset kelias
              width: 150,
              height: 150,
            ),
            SizedBox(
              height: 40,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(300, 50),
                iconColor: const Color(0xFF8093F1), // Violetinė spalva
              ),
              child: const Text(
                'Prisijungti',
                style: TextStyle(fontSize: 20),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignupScreen()),
                );
              },
              style: OutlinedButton.styleFrom(
                minimumSize: Size(300, 50),
                side: BorderSide(
                    color: Colors.deepPurple, width: 2), // Juodas kraštas
                foregroundColor: Colors.black, // Teksto spalva
              ),
              child: const Text(
                'Registruotis',
                style: TextStyle(fontSize: 20, color: Colors.deepPurple),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
