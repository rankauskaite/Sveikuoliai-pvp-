import 'package:flutter/material.dart';
import 'package:sveikuoliai/screens/forgot_password.dart';
import 'package:sveikuoliai/screens/home.dart';
import 'package:sveikuoliai/screens/signup.dart';
import 'package:sveikuoliai/services/auth_services.dart';
import 'package:sveikuoliai/widgets/custom_snack_bar.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  void _login(BuildContext context) async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    var user = await _authService.signInWithEmail(email, password);

    if (user != null) {
      print("✅ Prisijungimas sėkmingas: ${user.email}");
      String message = '✅ Prisijungimas sėkmingas!';
      showCustomSnackBar(context, message, true);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      print("❌ Prisijungimas nepavyko!");
      String message = '❌ Prisijungimas nepavyko!';
      showCustomSnackBar(context, message, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF7AEF8),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints:
                BoxConstraints(minHeight: MediaQuery.of(context).size.height),
            child: IntrinsicHeight(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Color(0xFFF7AEF8), width: 20),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset('assets/logo.png', width: 150, height: 150),
                      SizedBox(height: 20),
                      Text(
                        'Prisijungti',
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          children: [
                            TextField(
                              controller: emailController,
                              decoration: InputDecoration(
                                labelText: 'El. paštas',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 20),
                            TextField(
                              controller: passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Slaptažodis',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 10),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ForgotPasswordScreen()),
                                );
                              },
                              child: Text(
                                'Pamiršai slaptažodį?',
                                style: TextStyle(
                                  color: Colors.deepPurple,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () => _login(context),
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(300, 50),
                                iconColor:
                                    const Color(0xFF8093F1), // Violetinė spalva
                              ),
                              child: const Text(
                                'Prisijungti',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                            // ElevatedButton(
                            //   onPressed: () => _login(context),
                            //   style: ElevatedButton.styleFrom(
                            //     minimumSize: Size(300, 50),
                            //     backgroundColor: Color(0xFF8093F1),
                            //   ),
                            //   child: const Text(
                            //     'Prisijungti',
                            //     style: TextStyle(fontSize: 20),
                            //   ),
                            // ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Neturi paskyros?'),
                                SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SignupScreen()),
                                    );
                                  },
                                  child: Text(
                                    'Registruotis',
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
          ),
        ),
      ),
    );
  }
}
