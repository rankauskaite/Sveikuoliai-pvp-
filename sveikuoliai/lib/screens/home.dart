import 'package:flutter/material.dart';
import 'package:sveikuoliai/widgets/bottom_navigation.dart';
import 'package:sveikuoliai/widgets/profile_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showNotifications = false; // Ar rodyti pranešimų panelę?
  final List<String> messages = [
    'Naujas iššūkis!',
    'Tavo draugas pasiekė tikslą!',
    'Nepamiršk palaistyti augalo!',
    'Šiandien gera diena pradėti naują iššūkį!',
  ]; // Pranešimų sąrašas

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8093F1),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 20,
        backgroundColor: const Color(0xFF8093F1),
      ),
      body: Stack(
        children: [
          Center(
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
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ProfileButton(),
                          Container(
                            height: 50,
                            alignment: Alignment.bottomLeft,
                            child: const Text(
                              'VARDAS',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                showNotifications = true;
                              });
                            },
                            icon: const Icon(Icons.notifications_outlined,
                                size: 35),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: const [
                          Text(
                            'Mano augalai',
                            style: TextStyle(fontSize: 17),
                          ),
                        ],
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildPlantColumn('Orchidėja'),
                            _buildPlantColumn('Dobilas'),
                            _buildPlantColumn('Žibuoklės'),
                            _buildPlantColumn('Ramunė'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 250,
                            height: 150,
                            color: const Color(0xFFB388EB),
                            child: const Center(
                              child: Text(
                                'PREMIUM VERSIJOS REKLAMA',
                                style: TextStyle(
                                    fontSize: 30, color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 250,
                            height: 100,
                            color: const Color(0xFFD9D9D9),
                            child: const Center(
                              child: Text(
                                'Reklamos plotas',
                                style: TextStyle(
                                    fontSize: 30, color: Colors.black),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const BottomNavigation(),
              ],
            ),
          ),
          // Išslenkanti pranešimų panelė
          if (showNotifications)
            GestureDetector(
              onTap: () {
                setState(() {
                  showNotifications = false;
                });
              },
              child: Container(
                color: Colors.black.withOpacity(0.3), // Permatomas fonas
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 300,
                    height: double.infinity,
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppBar(
                          title: const Text('Pranešimai'),
                          backgroundColor: const Color(0xFF8093F1),
                          automaticallyImplyLeading: false,
                          actions: [
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  showNotifications = false;
                                });
                              },
                            ),
                          ],
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              bool isUnread = index ==
                                  0; // Tik pirmas pranešimas yra neperskaitytas

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    // Žymime, kad pranešimas perskaitytas
                                    if (isUnread) {
                                      messages[0] =
                                          '✔ ${messages[0]}'; // Žymime kaip skaitytą
                                    }
                                  });
                                  _showMessageDialog(messages[index]);
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isUnread
                                        ? const Color(
                                            0xFFFFC0CB) // Šviesiai oranžinė fonui
                                        : const Color(0xFF8093F1)
                                            .withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(15),
                                    border: isUnread
                                        ? Border.all(
                                            color: Colors.pink,
                                            width: 2) // Rėmelis neperskaitytam
                                        : null,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.notifications,
                                          color: isUnread
                                              ? Colors.pink
                                              : Colors.deepPurple,
                                          size: 24),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          messages[index],
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlantColumn(String plantName) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.circle, size: 90, color: Color(0xFFD9D9D9)),
        Text(plantName, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  void _showMessageDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          title: const Text(
            'Pranešimas',
            style: TextStyle(color: Colors.black, fontSize: 20),
          ),
          content: Text(
            message,
            style: const TextStyle(color: Colors.black, fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Uždaryti',
                style: TextStyle(color: Colors.deepPurple),
              ),
            ),
          ],
        );
      },
    );
  }
}
