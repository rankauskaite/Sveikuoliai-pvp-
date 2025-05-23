import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sveikuoliai/screens/forgot_password.dart';
import 'package:sveikuoliai/screens/home.dart';
import 'package:sveikuoliai/screens/signup.dart';
import 'package:sveikuoliai/services/auth_services.dart';
import 'package:sveikuoliai/widgets/custom_snack_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true; // Track password visibility

  bool _isEmailSignup = false;
  bool _showButtons = true;

  void _login(BuildContext context) async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    var user = await _authService.signInWithEmail(email, password);

    if (user != null) {
      print("✅ Prisijungimas sėkmingas: ${user.email}");
      showCustomSnackBar(context, '✅ Prisijungimas sėkmingas!', true);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      print("❌ Prisijungimas nepavyko!");
      showCustomSnackBar(context, '❌ Prisijungimas nepavyko!', false);
    }
  }

  void _signInWithGoogle(BuildContext context) async {
    var user = await _authService.signInWithGoogle();
    if (user != null) {
      print("✅ Google prisijungimas sėkmingas: ${user.user?.email}");
      showCustomSnackBar(context, '✅ Prisijungimas sėkmingas!', true);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      print("❌ Google prisijungimas nepavyko!");
      showCustomSnackBar(context, 'Nepavyko prisijungti su Google ❌', false);
      await GoogleSignIn().signOut();
    }
  }

  void _resetSelection() {
    setState(() {
      _showButtons = true;
      _isEmailSignup = false;
    });
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
                      SizedBox(height: 20),
                      if (_showButtons)
                        Column(
                          children: [
                            Container(
                                height: 1.0,
                                color: Colors.grey[300],
                                width: double.infinity),
                            SizedBox(height: 10),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _showButtons = false;
                                      _isEmailSignup = true;
                                    });
                                  },
                                  child: Text('Prisijungti su el. paštu'),
                                ),
                                SizedBox(height: 10),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _showButtons = false;
                                      _isEmailSignup = false;
                                      _signInWithGoogle(context);
                                    });
                                  },
                                  icon: SvgPicture.asset(
                                    'assets/icons/google_logo.svg',
                                    height: 22,
                                    width: 22,
                                  ),
                                  label: Text('Prisijungti su Google'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      if (!_showButtons)
                        _isEmailSignup
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      TextFormField(
                                        controller: emailController,
                                        decoration: InputDecoration(
                                          labelText: 'El. paštas',
                                          labelStyle: TextStyle(fontSize: 14),
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 12),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          errorStyle: TextStyle(fontSize: 11),
                                        ),
                                        style: TextStyle(fontSize: 14),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Įveskite el. paštą';
                                          }
                                          if (!RegExp(
                                                  r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$')
                                              .hasMatch(value)) {
                                            return 'Netinkamas el. pašto formatas';
                                          }
                                          return null;
                                        },
                                      ),
                                      SizedBox(height: 10),
                                      TextFormField(
                                        controller: passwordController,
                                        obscureText: _obscurePassword,
                                        decoration: InputDecoration(
                                          labelText: 'Slaptažodis',
                                          labelStyle: TextStyle(fontSize: 14),
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 12),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          errorStyle: TextStyle(fontSize: 11),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscurePassword
                                                  ? Icons.visibility_off
                                                  : Icons.visibility,
                                              size: 20,
                                              color: Color(0xFF8093F1),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _obscurePassword =
                                                    !_obscurePassword;
                                              });
                                            },
                                          ),
                                        ),
                                        style: TextStyle(fontSize: 14),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Įveskite slaptažodį';
                                          }
                                          if (value.length < 6) {
                                            return 'Slaptažodis per trumpas (min. 6 simboliai)';
                                          }
                                          return null;
                                        },
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
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      ElevatedButton(
                                        onPressed: () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            _login(context);
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: Size(300, 50),
                                          iconColor: const Color(0xFF8093F1),
                                        ),
                                        child: const Text(
                                          'Prisijungti',
                                          style: TextStyle(fontSize: 20),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      ElevatedButton(
                                        onPressed: _resetSelection,
                                        child: Text('Grįžti prie pasirinkimo'),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/google_logo.svg',
                                      height: 25,
                                      width: 25,
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      'Prisijungimas su Google...',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    ElevatedButton(
                                      onPressed: _resetSelection,
                                      child: Text('Grįžti prie pasirinkimo'),
                                    ),
                                  ],
                                )),
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
                              style: TextStyle(color: Colors.deepPurple),
                            ),
                          ),
                        ],
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
