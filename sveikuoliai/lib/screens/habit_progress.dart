import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sveikuoliai/widgets/bottom_navigation.dart';

class HabitProgressScreen extends StatefulWidget {
  const HabitProgressScreen({super.key});

  @override
  _HabitProgressScreenState createState() => _HabitProgressScreenState();
}

class _HabitProgressScreenState extends State<HabitProgressScreen> {
  bool _isChecked = false; // Pradinis checkbox būsenos nustatymas

  @override
  Widget build(BuildContext context) {
    // Gauti dabartinę datą ir laiką
    String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

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
                color: Color(0xFFCF9CFF),
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
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Atnaujink savo progresą',
                    style: TextStyle(fontSize: 18),
                  ),
                  const Text(
                    'Įpročio pavadinimas',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Rodyti šios dienos datą
                  Text(
                    'Data: $formattedDate',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Įvedimo lauko pavadinimas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 10),
                      Text(
                        'Informacija:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Įvedimo laukas
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Įveskite informaciją',
                        labelStyle: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.transparent,
                      ),
                    ),
                  ),

                  // Checkbox su tekstu šalia
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: CheckboxListTile(
                      title: Text(
                        'Patvirtinti informaciją',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      value: _isChecked,
                      onChanged: (bool? value) {
                        setState(() {
                          _isChecked = value ?? false;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: Colors.deepPurple,
                    ),
                  ),
                  SizedBox(
                    height: 100,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(200, 50),
                      iconColor: const Color(0xFFB388EB), // Violetinė spalva
                    ),
                    child: const Text(
                      'Išsaugoti',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
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
