import 'package:flutter/material.dart';
import 'package:sveikuoliai/screens/friend_profile.dart';
import 'package:sveikuoliai/widgets/bottom_navigation.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy draugų sąrašas
    final friends = [
      'Draugas 1',
      'Draugas 2',
      'Draugas 3',
      'Draugas 4',
    ];

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
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Draugai',
                    style: TextStyle(
                      fontSize: 35,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Pridėti draugą:',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Įveskite draugo vardą',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Turimi draugai:',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  // Draugų sąrašas su pilkais stačiakampiais ir piktogramomis
                  Expanded(
                    child: ListView.builder(
                      itemCount: friends.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            // Pereiti į draugo profilį
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FriendProfileScreen(
                                  name: friends[index],
                                  username: 'USERNAME',
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Color(0xFFD9D9D9), // Pilkas fonas
                              borderRadius:
                                  BorderRadius.circular(15), // Apvalūs kampai
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.account_circle,
                                        size: 40), // Piktograma
                                    SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          friends[index],
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        Text(
                                          'USERNAME',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF8093F1),
                                            letterSpacing:
                                                1, // Nedidelis tarpų pritaikymas
                                            fontWeight: FontWeight
                                                .w400, // Plonesnė raidė
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: Icon(Icons.remove_circle_outline,
                                      color: Color(
                                          0xFFB388EB)), // Pašalinimo piktograma
                                  onPressed: () {
                                    // Veiksmai, kai paspaudžiamas ištrynimo mygtukas
                                  },
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
            const BottomNavigation(),
          ],
        ),
      ),
    );
  }
}
