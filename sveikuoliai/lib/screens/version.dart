import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pay/pay.dart';
import 'package:sveikuoliai/screens/home.dart';
import 'package:sveikuoliai/services/auth_services.dart';
import 'package:sveikuoliai/services/user_services.dart';
import 'package:sveikuoliai/widgets/custom_snack_bar.dart';

class VersionScreen extends StatefulWidget {
  final String username;
  final String? screenName;
  const VersionScreen({Key? key, required this.username, this.screenName})
      : super(key: key);

  @override
  _VersionScreenState createState() => _VersionScreenState();
}

class _VersionScreenState extends State<VersionScreen> {
  String? selectedPlan;
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
  int currentPage = 0;
  PaymentConfiguration? _paymentConfiguration; // Store the loaded configuration

  final List<double> cardHeights = [
    400, // Gija NULIS
    480, // Gija PLIUS
  ];

  // Google Pay payment items
  final _paymentItems = [
    const PaymentItem(
      label: 'Gija PLIUS',
      amount: '5.00',
      status: PaymentItemStatus.final_price,
    )
  ];

  @override
  void initState() {
    super.initState();
    // Load PaymentConfiguration asynchronously
    _loadPaymentConfiguration();
  }

  Future<void> _loadPaymentConfiguration() async {
    try {
      final config = await PaymentConfiguration.fromAsset('gpay_config.json');
      setState(() {
        _paymentConfiguration = config;
      });
    } catch (e) {
      print('Error loading payment configuration: $e');
      showCustomSnackBar(
          context, '❌ Nepavyko įkelti mokėjimo konfigūracijos', false);
    }
  }

  Future<void> saveSelectedPlan(String plan,
      {Map<String, dynamic>? paymentResult}) async {
    try {
      if (plan == 'premium' && paymentResult != null) {
        // Save payment information to Firestore
        await FirebaseFirestore.instance.collection('payments').add({
          'userId': widget.username,
          'planId': plan,
          'status': 'succeeded',
          'amount': 5.00,
          'timestamp': FieldValue.serverTimestamp(),
          'paymentData': paymentResult,
        });
      }
      await _userService.updateUserVersion(widget.username, plan);
      _authService.updateUserSession('version', plan);
      String message = widget.screenName == 'Signup'
          ? '✅ Registracija sėkminga!'
          : '✅ Planas pasirinktas sėkmingai!';
      showCustomSnackBar(context, message, true);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } catch (e) {
      String message = 'Klaida renkantis planą ❌';
      showCustomSnackBar(context, message, false);
    }
    print("Pasirinktas planas: $plan");
  }

  Widget buildDynamicCard(int index) {
    switch (index) {
      case 0:
        return buildPlanCard(
          planId: 'free',
          color: const Color(0xFFEEEEEE),
          borderColor: const Color(0xFFF7AEF8),
          title: 'Gija NULIS',
          price: '0',
          description: '''
Stebėk
  - 3 tikslus
  - 3 įpročius
Naudokis
  - Virtualiu dienoraščiu
  - Meditacijos kampeliu
        ''',
          buttonColor: const Color(0xFFEF3BF1),
          fixedHeight: cardHeights[0],
        );
      case 1:
        return buildPlanCard(
          planId: 'premium',
          color: const Color(0xFFF7AEF8),
          borderColor: const Color(0xFFF7AEF8),
          title: 'Gija PLIUS',
          price: '5',
          description: '''
Stebėk
  - neribotus tikslus
  - neribotus įpročius
Naudokis
  - Virtualiu dienoraščiu
  - Meditacijos kampeliu
Bendrauk
  - Kviesk draugus
  - Kelk bendrus tikslus
  - Stebėk draugų sodą
        ''',
          buttonColor: const Color(0xFFEF3BF1),
          fixedHeight: cardHeights[1],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8093F1),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Image.asset('assets/logo.png', width: 100, height: 100),
            const Text(
              'Pasirink savo',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('GIJA',
                    style: TextStyle(
                        fontSize: 35,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
                Text(' planą',
                    style: TextStyle(fontSize: 24, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.85),
                itemCount: 2,
                itemBuilder: (context, index) {
                  return Align(
                    child: buildDynamicCard(index),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
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
    double? fixedHeight,
  }) {
    List<Widget> buildDescription(String description) {
      List<Widget> descriptionWidgets = [];
      final sections = description.split('\n');
      String? currentHeading;

      for (var line in sections) {
        if (line.trim().isEmpty) continue;

        if (line.startsWith('Stebėk') ||
            line.startsWith('Naudokis') ||
            line.startsWith('Bendrauk')) {
          if (currentHeading != null) {
            descriptionWidgets.add(const SizedBox(height: 10));
          }
          currentHeading = line;
          descriptionWidgets.add(Text(
            currentHeading,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ));
        } else {
          descriptionWidgets.add(Text(
            '  $line',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
          ));
        }
      }
      return descriptionWidgets;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10),
      child: Container(
        height: fixedHeight,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 10),
                      Column(
                        children: [
                          Text(
                            title.split(" ").first,
                            style: const TextStyle(
                                fontSize: 28,
                                color: Colors.black,
                                fontWeight: FontWeight.w300),
                          ),
                          Text(
                            title.split(" ").last,
                            style: const TextStyle(
                                fontSize: 40,
                                color: Colors.black,
                                fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0xFFEF3BF1), width: 3),
                            color: Colors.white,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const SizedBox(height: 5),
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                      fontStyle: FontStyle.italic),
                                  children: [
                                    TextSpan(
                                      text: price,
                                      style: const TextStyle(
                                          fontSize: 40, color: Colors.black),
                                    ),
                                    const TextSpan(
                                      text: '€',
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                              const Text(
                                '/ mėn.',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                    fontStyle: FontStyle.italic),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(
                            left: 35, right: 35, top: 16, bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...buildDescription(description),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (planId == 'free')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: buttonColor,
                          shape: const StadiumBorder(),
                          elevation: 3,
                        ),
                        onPressed: () async {
                          setState(() {
                            selectedPlan = planId;
                          });
                          await saveSelectedPlan(planId);
                        },
                        child: const Text(
                          "Gauti",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  if (planId == 'premium')
                    _paymentConfiguration == null
                        ? const Center(child: CircularProgressIndicator())
                        : SizedBox(
                            width: double.infinity,
                            child: GooglePayButton(
                              paymentConfiguration: _paymentConfiguration!,
                              paymentItems: _paymentItems,
                              type: GooglePayButtonType.buy,
                              onPaymentResult:
                                  (Map<String, dynamic> result) async {
                                if (result['paymentMethodData'] != null) {
                                  setState(() {
                                    selectedPlan = planId;
                                  });
                                  await saveSelectedPlan(planId,
                                      paymentResult: result);
                                } else {
                                  showCustomSnackBar(
                                      context, '❌ Mokėjimas nepavyko', false);
                                }
                              },
                              loadingIndicator: const Center(
                                child: CircularProgressIndicator(),
                              ),
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
