import 'package:flutter/material.dart';
import 'package:sveikuoliai/screens/settings.dart';
import 'package:sveikuoliai/widgets/bottom_navigation.dart';
import 'dart:ui';

class UpdateProfileScreen extends StatelessWidget {
  const UpdateProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8093F1),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 20,
        backgroundColor: const Color(0xFF8093F1),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 320,
              height: 600,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white, width: 20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.arrow_back_ios,
                          size: 30,
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                      ElevatedButton(
                        onPressed: () {
                          // setState(() {
                          //   journalText = tempText; // Išsaugome tekstą
                          // });
                          Navigator.pop(context); // Uždaro modalą
                        },
                        child: Text('Išsaugoti'),
                      ),
                    ],
                  ),
                  Stack(
                    children: [
                      // Centrinė account_circle ikona
                      Stack(
                        alignment:
                            Alignment.center, // Centruoja tekstą ant ikonos
                        children: [
                          ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              Color(
                                  0xFFD9D9D9), // Naudojame skaidrų filtrą su blur efektu
                              BlendMode
                                  .srcIn, // Blend mode, kad būtų matomas tik blur efektas
                            ),
                            child: ImageFiltered(
                              imageFilter: ImageFilter.blur(
                                  sigmaX: 5.0, sigmaY: 5.0), // Blur stiprumas
                              child: Icon(
                                Icons.account_circle,
                                size: 200,
                                color: Color(0xFFD9D9D9),
                              ),
                            ),
                          ),
                          const Text(
                            'Keisti profilio\nnuotrauką', // Čia įrašyk norimą tekstą
                            style: TextStyle(
                              fontSize: 24,
                              color:
                                  Colors.black, // Pakeisk spalvą pagal poreikį
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ],
                  ),
                  IntrinsicWidth(
                    child: TextField(
                      controller: TextEditingController(text: 'VARDAS'),
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        border:
                            OutlineInputBorder(), // Pridedame rėmelį aplink lauką
                        labelText:
                            'Vardas', // Label tekstas, kuris pasirodo viršuje
                      ),
                    ),
                  ),
                  const Text(
                    'USERNAME',
                    style: TextStyle(fontSize: 15, color: Color(0xFF8093F1)),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Mano duomenys',
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IntrinsicWidth(
                        child: TextField(
                          controller: TextEditingController(
                              text: 'asesumergaite@gmail.com'),
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFFB388EB),
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFFB388EB),
                          ),
                          decoration: InputDecoration(
                            border:
                                OutlineInputBorder(), // Pridedame rėmelį aplink lauką
                            labelText:
                                'el. paštas', // Label tekstas, kuris pasirodo viršuje
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IntrinsicWidth(
                        child: TextField(
                          controller: TextEditingController(text: '2009-05-16'),
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFFB388EB),
                            decorationColor: Color(0xFFB388EB),
                          ),
                          decoration: InputDecoration(
                            border:
                                OutlineInputBorder(), // Pridedame rėmelį aplink lauką
                            labelText:
                                'kita', // Label tekstas, kuris pasirodo viršuje
                          ),
                        ),
                      ),
                    ],
                  ),
                  // const SizedBox(height: 20),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.start,
                  //   children: [
                  //     Text(
                  //       'Versija: ',
                  //       style: TextStyle(fontSize: 15),
                  //     ),
                  //     Text(
                  //       'nemokama',
                  //       style:
                  //           TextStyle(fontSize: 15, color: Color(0xFF8093F1)),
                  //     )
                  //   ],
                  // ),
                ],
              ),
            ),
            const BottomNavigation(), // Įterpiama navigacija
          ],
        ),
      ),
    );
  }
}
