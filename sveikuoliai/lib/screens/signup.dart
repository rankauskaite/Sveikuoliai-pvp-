import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sveikuoliai/screens/login.dart';
import 'package:sveikuoliai/screens/version.dart';
import 'package:sveikuoliai/services/auth_services.dart';
import 'package:sveikuoliai/widgets/custom_snack_bar.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final AuthService _authService = AuthService();
  bool _obscurePassword = true; // Track password visibility
  bool _obscurePasswordConfirm = true; // Track password visibility

  bool _isEmailSignup = false;
  bool _showButtons = true;

  @override
  void dispose() {
    usernameController.dispose(); // Atlaisvinkite usernameController išteklius
    nameController.dispose(); // Atlaisvinkite nameController išteklius
    emailController.dispose(); // Atlaisvinkite emailController išteklius
    passwordController.dispose(); // Atlaisvinkite passwordController išteklius
    confirmPasswordController
        .dispose(); // Atlaisvinkite confirmPasswordController išteklius
    super.dispose();
  }

  void _signupWithEmail(BuildContext context) async {
    String username = usernameController.text.trim();
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    _authService.checkUserExists(username, email).then((_) async {
      var user =
          await _authService.registerWithEmail(email, password, username, name);

      if (user != null) {
        print("✅ Registracija sėkminga: ${user.email}");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => VersionScreen(
                    username: username,
                    screenName: "Signup",
                  )),
        );
      } else {
        print("❌ Registracija nepavyko!");
        String message = '❌ Registracija nepavyko!';
        showCustomSnackBar(context, message, false);
      }
    }).catchError((error) {
      // Extract clean error message
      String message =
          error.toString().replaceAll('Exception: Exception: ', '').trim();
      if (message.isEmpty) {
        message = '❌ Registracija nepavyko!';
      }
      print(message);
      showCustomSnackBar(context, message, false);
    });
  }

  void _signupWithGoogle(BuildContext context) async {
    String username = usernameController.text.trim();

    _authService.checkUserExists(username, "").then((_) async {
      var user = await _authService.registerWithGoogle(username);
      if (user != null) {
        print("✅ Google registracija sėkminga: ${user.email}");
        showCustomSnackBar(context, '✅ Google registracija sėkminga!', true);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => VersionScreen(
                    username: username,
                    screenName: "Signup",
                  )),
        );
      } else {
        print("❌ Google registracija nepavyko!");
        showCustomSnackBar(
            context, 'Nepavyko užsiregistruoti su Google ❌', false);
      }
    }).catchError((error) {
      // Extract clean error message
      String message =
          error.toString().replaceAll('Exception: Exception: ', '').trim();
      if (message.isEmpty) {
        message = '❌ Registracija nepavyko!';
      }
      print(message);
      showCustomSnackBar(context, message, false);
    });
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
                      Text('Registruotis',
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold)),
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
                                  child: Text('Registruotis su el. paštu'),
                                ),
                                SizedBox(height: 10),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _showButtons = false;
                                      _isEmailSignup = false;
                                    });
                                  },
                                  icon: SvgPicture.asset(
                                    'assets/icons/google_logo.svg',
                                    height: 22,
                                    width: 22,
                                  ),
                                  label: Text('Registruotis su Google'),
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
                                        controller: usernameController,
                                        decoration: InputDecoration(
                                          labelText: 'Slapyvardis',
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
                                            return 'Įveskite slapyvardį';
                                          }
                                          return null;
                                        },
                                      ),
                                      SizedBox(height: 5),
                                      TextFormField(
                                        controller: nameController,
                                        decoration: InputDecoration(
                                          labelText: 'Vardas',
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
                                            return 'Įveskite vardą';
                                          }
                                          return null;
                                        },
                                      ),
                                      SizedBox(height: 5),
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
                                      SizedBox(height: 5),
                                      TextFormField(
                                        controller: passwordController,
                                        obscureText: true,
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
                                      SizedBox(height: 5),
                                      TextFormField(
                                        controller: confirmPasswordController,
                                        obscureText: true,
                                        decoration: InputDecoration(
                                          labelText: 'Patvirtinkite slaptažodį',
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
                                              _obscurePasswordConfirm
                                                  ? Icons.visibility_off
                                                  : Icons.visibility,
                                              size: 20,
                                              color: Color(0xFF8093F1),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _obscurePasswordConfirm =
                                                    !_obscurePasswordConfirm;
                                              });
                                            },
                                          ),
                                        ),
                                        style: TextStyle(fontSize: 14),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Patvirtinkite slaptažodį';
                                          }
                                          if (value !=
                                              passwordController.text) {
                                            return 'Slaptažodžiai nesutampa';
                                          }
                                          return null;
                                        },
                                      ),
                                      SizedBox(height: 10),
                                      ElevatedButton(
                                        onPressed: () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            _signupWithEmail(context);
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: Size(300, 50),
                                          iconColor: const Color(0xFF8093F1),
                                        ),
                                        child: const Text(
                                          'Registruotis',
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      TextFormField(
                                        controller: usernameController,
                                        decoration: InputDecoration(
                                          labelText: 'Slapyvardis',
                                          border: OutlineInputBorder(),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Įveskite slapyvardį';
                                          }
                                          return null;
                                        },
                                      ),
                                      SizedBox(height: 10),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            _signupWithGoogle(context);
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: Size(300, 50),
                                          iconColor: const Color(0xFF8093F1),
                                        ),
                                        label: const Text(
                                          'Registruotis',
                                          style: TextStyle(fontSize: 20),
                                        ),
                                        icon: SvgPicture.asset(
                                          'assets/icons/google_logo.svg',
                                          height: 25,
                                          width: 25,
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
                              ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Jau turi paskyrą?'),
                          SizedBox(width: 10),
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
