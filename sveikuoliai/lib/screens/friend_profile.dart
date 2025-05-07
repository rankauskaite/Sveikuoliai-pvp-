import 'package:flutter/material.dart';
import 'package:sveikuoliai/models/user_model.dart';
import 'package:sveikuoliai/screens/friends.dart';
import 'package:sveikuoliai/screens/garden.dart';
import 'package:sveikuoliai/services/friendship_services.dart';
import 'package:sveikuoliai/services/user_services.dart';
import 'package:sveikuoliai/widgets/bottom_navigation.dart';
import 'package:sveikuoliai/widgets/custom_snack_bar.dart';

class FriendProfileScreen extends StatefulWidget {
  final String name;
  final String username;
  final String friendshipId;
  const FriendProfileScreen(
      {super.key,
      required this.name,
      required this.username,
      required this.friendshipId});

  @override
  _FriendProfileScreenState createState() => _FriendProfileScreenState();
}

class _FriendProfileScreenState extends State<FriendProfileScreen> {
  FriendshipService _friendshipService = FriendshipService();
  UserService _userService = UserService();
  UserModel userModel = UserModel(
      username: "",
      name: "",
      password: "",
      role: "user",
      notifications: true,
      darkMode: false,
      menstrualLength: 7,
      email: "",
      createdAt: DateTime.now(),
      version: "free");

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    try {
      UserModel? model = await _userService.getUserEntry(widget.username);
      setState(() {
        userModel = model!;
      });
    } catch (e) {}
  }

  Future<void> _deleteFriend(String friendshipID) async {
    try {
      await _friendshipService.deleteFriendship(friendshipID);
      showCustomSnackBar(context, "Draugas pašalintas ✅", true);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => FriendsScreen()),
      );
    } catch (e) {
      showCustomSnackBar(context, "Nepavyko pašalinti draugo ❌", false);
    }
  }

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
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text.rich(
                                  TextSpan(
                                    text: "${widget.name}\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                      color: Colors.deepPurple,
                                    ),
                                    children: [
                                      TextSpan(
                                        text:
                                            "Ar tikrai norite pašalinti šį draugą?",
                                        style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          color: Colors.black,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                content:
                                    Text("Draugo pašalinimas bus negrįžtamas."),
                                actions: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(
                                              context); // Uždaro dialogą
                                        },
                                        style: TextButton.styleFrom(
                                          backgroundColor: Colors.deepPurple
                                              .withOpacity(0.2),
                                        ),
                                        child: Text("Ne",
                                            style: TextStyle(fontSize: 18)),
                                      ),
                                      SizedBox(width: 20),
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          await _deleteFriend(
                                              widget.friendshipId);
                                        },
                                        style: TextButton.styleFrom(
                                          backgroundColor:
                                              Colors.red.withOpacity(0.2),
                                        ),
                                        child: Text("Taip",
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 18)),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          );
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
                      widget.name,
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
                      widget.username,
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
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      GardenScreen(user: userModel)),
                            );
                          },
                          child: Text(
                            "sodas",
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
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
}
