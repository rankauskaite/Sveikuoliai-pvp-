import 'package:flutter/material.dart';
import 'package:sveikuoliai/screens/home.dart';
import 'package:sveikuoliai/screens/login.dart';
import 'package:sveikuoliai/services/auth_services.dart';

class SignupScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>(); //formos raktas validacijai

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  void _signup(BuildContext context) async {
    String username = usernameController.text.trim();
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    var user =
        await _authService.registerWithEmail(email, password, username, name);

    if (user != null) {
      print("✅ Registracija sėkminga: ${user.email}");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      print("❌ Registracija nepavyko!");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Neteisingi registracijos duomenys")),
      );
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
                  padding: const EdgeInsets.all(
                      20.0), // Užtikrina, kad turinys nebūtų per arti krašto
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Centruoja viską vertikaliai
                    crossAxisAlignment: CrossAxisAlignment
                        .center, // Centruoja viską horizontaliai
                    children: [
                      Image.asset('assets/logo.png', width: 150, height: 150),
                      SizedBox(height: 20),
                      Text(
                        'Registruotis',
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Form(
                          // form widget aplink visus laukuis
                          key: _formKey,
                          child: Column(
                            children: [
                              // slapyvardžio validacija
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

                              // Vardas
                              TextFormField(
                                controller: nameController,
                                decoration: InputDecoration(
                                  labelText: 'Vardas',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Įveskite vardą';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10),

                              // El. paštas
                              TextFormField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  labelText: 'El. paštas',
                                  border: OutlineInputBorder(),
                                ),
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

                              // slaptažodis
                              TextFormField(
                                controller: passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: 'Slaptažodis',
                                  border: OutlineInputBorder(),
                                ),
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
                              // TextField(
                              //   obscureText: true,
                              //   decoration: InputDecoration(
                              //     labelText: 'Pakartoti slaptažodį',
                              //     border: OutlineInputBorder(),
                              //   ),
                              // ),
                              // SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    _signup(context);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size(300, 50),
                                  iconColor: const Color(
                                      0xFF8093F1), // Violetinė spalva
                                ),
                                child: const Text(
                                  'Registruotis',
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
                                  Text('Jau turi paskyrą?'),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                LoginScreen()),
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
