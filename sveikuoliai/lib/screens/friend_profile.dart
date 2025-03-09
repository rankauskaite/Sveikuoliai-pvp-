import 'package:flutter/material.dart';
import 'package:sveikuoliai/widgets/bottom_navigation.dart';

class FriendProfileScreen extends StatelessWidget {
  final String name;
  final String username;
  const FriendProfileScreen(
      {super.key, required this.name, required this.username});

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
                        child: Text('Ištrinti'),
                      ),
                    ],
                  ),
                  Stack(
                    children: [
                      // Centrinė account_circle ikona
                      Center(
                        child: const Icon(
                          Icons.account_circle,
                          size: 200,
                          color: Color(0xFFD9D9D9),
                        ),
                      ),
                    ],
                  ),
                  // Vardas su stiliumi
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Username su stiliumi
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      username,
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF8093F1),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Draugo augalai',
                        style: TextStyle(fontSize: 17),
                      ),
                    ],
                  ),
                  // Karuselės efektas draugo augalams
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal, // Horizontali slinktis
                    child: Row(
                      children: [
                        _buildPlantColumn('Orchidėja'),
                        _buildPlantColumn('Dobilas'),
                        _buildPlantColumn('Žibuoklės'),
                        _buildPlantColumn(
                            'Ramunė'), // Galite pridėti daugiau augalų
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const BottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantColumn(String plantName) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.circle,
          size: 90,
          color: Color(0xFFD9D9D9),
        ),
        Text(
          plantName,
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}