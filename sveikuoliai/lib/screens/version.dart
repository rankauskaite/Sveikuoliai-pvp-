import 'package:flutter/material.dart';
import 'package:sveikuoliai/screens/home.dart';
import 'package:sveikuoliai/services/user_services.dart';
import 'package:sveikuoliai/widgets/custom_snack_bar.dart';

import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VersionScreen extends StatefulWidget {
  final String username;
  const VersionScreen({Key? key, required this.username}) : super(key: key);
  @override
  _VersionScreenState createState() => _VersionScreenState();
}

class _VersionScreenState extends State<VersionScreen> {
  String? selectedPlan;
  final UserService _userService = UserService();
  int currentPage = 0;

  final List<double> cardHeights = [
    400, // Gija NULIS
    480, // Gija PLIUS
    350, // Gija KARTU
  ];

  Future<void> saveSelectedPlan(String plan) async {
    try {
      await _userService.updateUserVersion(widget.username, selectedPlan!);
      String message = '✅ Registracija sėkminga!';
      showCustomSnackBar(context, message, true);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } catch (e) {
      String message = 'Klaida renkantis planą ❌';
      showCustomSnackBar(context, message, false);
    }
    print("Pasirinktas planas: $plan"); // Kol kas tiesiog atspausdinsime
  }

  Future<void> payWithStripe(String planId) async {
  try {
    final response = await http.post(
      Uri.parse('https://stripe-server-thr2.onrender.com:10000/create-payment-intent'),
      headers: {'Content-Type': 'application/json'},
    );
    
    print('SERVERIO ATSAKYMAS: ${response.body}');
    print('STATUSAS: ${response.statusCode}');

    final jsonResponse = json.decode(response.body);
    final clientSecret = jsonResponse['clientSecret'];

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'Sveikuoliai App',
        style: ThemeMode.light,
        //testEnv: true,
      ),
    );

    await Stripe.instance.presentPaymentSheet();

    // Jei sėkminga — išsaugom planą
    setState(() {
      selectedPlan = planId;
    });
    await saveSelectedPlan(planId);

  } catch (e) {
    print('KLAIDA: $e');
    showCustomSnackBar(context, '❌ Mokėjimas nepavyko: $e', false);
  }
}


  Widget buildDynamicCard(int index) {
    switch (index) {
      case 0:
        return buildPlanCard(
          planId: 'free',
          color: Color(0xFFEEEEEEEE),
          borderColor: Color(0xFFF7AEF8),
          title: 'Gija NULIS',
          price: '0',
          description: '''
Stebėk
  - ? iššūkius
  - ? įpročius
Naudokis
  - Virtualiu dienoraščiu
  - Meditacijos kampeliu
        ''',
          buttonColor: Color(0xFFEF3BF1),
          fixedHeight: cardHeights[0], // Priskiriame aukštį
        );
      case 1:
        return buildPlanCard(
          planId: 'premium',
          color: Color(0xFFF7AEF8),
          borderColor: Color(0xFFF7AEF8),
          title: 'Gija PLIUS',
          price: '5',
          description: '''
Stebėk
  - neribotus iššūkius
  - neribotus įpročius
Naudokis
  - Virtualiu dienoraščiu
  - Meditacijos kampeliu
Bendrauk
  - Kviešk draugus
  - Kelk bendrus iššūkius
  - Stebėk draugų sodą
        ''',
          buttonColor: Color(0xFFEF3BF1),
          fixedHeight: cardHeights[1], // Priskiriame aukštį
        );
      case 2:
        return buildPlanCard(
          planId: 'together',
          color: Color(0xFFFDA6B8),
          borderColor: Color(0xFFFDA6B8),
          title: 'Gija KARTU',
          price: '30',
          description: '''
Stebėk
  - kaip tau ir tavo 
    bendruomenei sekasi
    vykdyti iššūkius
        ''',
          buttonColor: Colors.black,
          fixedHeight: cardHeights[2], // Priskiriame aukštį
        );
      default:
        return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF8093F1),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),
            Image.asset('assets/logo.png', width: 100, height: 100),
            Text(
              'Pasirink savo',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('GIJA',
                    style: TextStyle(
                        fontSize: 35,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
                Text(' planą',
                    style: TextStyle(fontSize: 24, color: Colors.white)),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.85),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Align(
                    alignment: Alignment.center,
                    child: buildDynamicCard(index),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget buildPlanCard({
    required String planId,
    required Color color,
    required Color borderColor,
    required String title,
    required String price,
    required String description,
    required Color buttonColor,
    double? fixedHeight, // <-- naujas parametras
  }) {
    // Funkcija, kuri suskaido aprašymą į pavadinimus ir punktus
    List<Widget> buildDescription(String description) {
      List<Widget> descriptionWidgets = [];
      final sections = description.split('\n');
      String? currentHeading;

      for (var line in sections) {
        if (line.trim().isEmpty) continue;

        // Jei eilutė prasideda su pavadinimu (pvz., Stebėk, Naudokis), padarome ją didesnę
        if (line.startsWith('Stebėk') ||
            line.startsWith('Naudokis') ||
            line.startsWith('Bendrauk')) {
          if (currentHeading != null) {
            //descriptionWidgets.add(SizedBox(height: 10));
          }
          currentHeading = line;
          descriptionWidgets.add(Text(
            currentHeading,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ));
        } else {
          // Pridedame punktus po pavadinimo
          descriptionWidgets.add(Text(
            '  $line',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
          ));
        }
      }
      return descriptionWidgets;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10),
      child: Container(
        height: fixedHeight, // <-- čia priskiriam
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  //SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: 10),
                      Column(
                        children: [
                          Text(
                            title.split(" ").first,
                            style: TextStyle(
                                fontSize: 28,
                                color: Colors.black,
                                fontWeight: FontWeight.w300),
                          ),
                          Text(
                            title.split(" ").last,
                            style: TextStyle(
                                fontSize: 40,
                                color: Colors.black,
                                fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          padding: EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: Color(0xFFEF3BF1), width: 3),
                            color: Colors.white,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SizedBox(height: 5),
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(fontStyle: FontStyle.italic),
                                  children: [
                                    TextSpan(
                                      text: price,
                                      style: TextStyle(
                                          fontSize: 40, color: Colors.black),
                                    ),
                                    TextSpan(
                                      text: '€',
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '/ mėn.',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                    fontStyle: FontStyle.italic),
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Pavadinimai ir punktai su fonu
                      Container(
                        padding: EdgeInsets.only(
                            left: 35, right: 35, top: 16, bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white, // Fono spalva
                          borderRadius:
                              BorderRadius.circular(10), // Kampų suapvalinimas
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment
                              .start, // Užtikrina, kad tekstas bus kairėje
                          children: [
                            // Pavadinimai ir punktai, suformatuoti pagal anksčiau sukurtą funkciją
                            ...buildDescription(description),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: buttonColor,
                        shape: StadiumBorder(),
                        elevation: 3,
                      ),
                      // onPressed: () async {
                      //   setState(() {
                      //     selectedPlan = planId;
                      //   });
                      //   await saveSelectedPlan(planId);
                      //   // Gali naviguoti į kitą ekraną arba rodyti pranešimą
                      // },
                      onPressed: () async {
                          if (planId == 'free') {
                            setState(() {
                              selectedPlan = planId;
                            });
                            await saveSelectedPlan(planId);
                          } else {
                            await payWithStripe(planId); // Stripe mokėjimas
                          }
                        },
                      child: Text("Gauti",
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
