import 'package:flutter/material.dart';
import 'package:sveikuoliai/main.dart';
import 'package:sveikuoliai/screens/login.dart';

class SignupScreen extends StatelessWidget {
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
                  'Registruotis',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Slapyvardis',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Slaptažodis',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Pakartoti slaptažodį',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MainScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(300, 50),
                          iconColor:
                              const Color(0xFF8093F1), // Violetinė spalva
                        ),
                        child: const Text(
                          'Registruotis',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Jau turi paskyrą?'),
                          SizedBox(
                            width: 10,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen()),
                              );
                            },
                            child: Text(
                              'Prisijungti',
                              style: TextStyle(
                                color: Colors.deepPurple,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
