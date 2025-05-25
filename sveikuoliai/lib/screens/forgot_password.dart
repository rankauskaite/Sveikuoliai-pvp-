import 'package:flutter/material.dart';
import 'package:sveikuoliai/services/auth_services.dart';
import 'package:sveikuoliai/widgets/custom_snack_bar.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final AuthService _auth = AuthService();

  void _sendPasswordResetEmail() async {
    String email = _emailController.text.trim();

    if (email.isEmpty) {
      showCustomSnackBar(context, 'Įveskite el. paštą!', false);
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email);
      showCustomSnackBar(context,
          'Slaptažodžio atstatymo nuoroda\nišsiųsta į jūsų el. paštą!', true);
      Navigator.pop(context); // Grįžta į prisijungimo ekraną
    } catch (e) {
      showCustomSnackBar(context,
          'Nepavyko išsiųsti nuorodos! Patikrinkite el. paštą.', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        'Pamiršai slaptažodį?',
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Įveskite savo el. pašto adresą ir mes išsiųsime nuorodą slaptažodžiui atstatyti.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 20),
                      // TextField(
                      //   controller: _emailController,
                      //   decoration: InputDecoration(
                      //     labelText: 'El. paštas',
                      //     border: OutlineInputBorder(),
                      //     prefixIcon: Icon(Icons.email),
                      //   ),
                      //   keyboardType: TextInputType.emailAddress,
                      // ),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'El. paštas',
                          labelStyle: TextStyle(fontSize: 14),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.email),
                          errorStyle: TextStyle(fontSize: 11),
                        ),
                        style: TextStyle(fontSize: 14),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Įveskite el. paštą';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$')
                              .hasMatch(value)) {
                            return 'Netinkamas el. pašto formatas';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _sendPasswordResetEmail,
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(300, 50),
                          iconColor: const Color(0xFF8093F1),
                        ),
                        child: const Text(
                          'Siųsti nuorodą',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(
                              context); // Grįžta į prisijungimo ekraną
                        },
                        child: Text('Atšaukti'),
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
