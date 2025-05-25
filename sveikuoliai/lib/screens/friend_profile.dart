import 'package:flutter/material.dart';
import 'package:sveikuoliai/models/friendship_model.dart';
import 'package:sveikuoliai/models/shared_goal_model.dart';
import 'package:sveikuoliai/models/user_model.dart';
import 'package:sveikuoliai/screens/friends.dart';
import 'package:sveikuoliai/screens/garden.dart';
import 'package:sveikuoliai/services/friendship_services.dart';
import 'package:sveikuoliai/services/shared_goal_services.dart';
import 'package:sveikuoliai/services/user_services.dart';
import 'package:sveikuoliai/widgets/bottom_navigation.dart';
import 'package:sveikuoliai/widgets/custom_snack_bar.dart';
import 'package:sveikuoliai/services/auth_services.dart';

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
  final FriendshipService _friendshipService = FriendshipService();
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
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
  bool isDarkMode = false; // Temos būsena
  String userUsername = '';

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    try {
      Map<String, String?> sessionData = await _authService.getSessionUser();
      setState(() {
        userUsername = sessionData['username'] ?? "Nežinoma";
        isDarkMode =
            sessionData['darkMode'] == 'true'; // Gauname darkMode iš sesijos
      });
      UserModel? model = await _userService.getUserEntry(widget.username);
      setState(() {
        userModel = model!;
      });
    } catch (e) {}
  }

  Future<void> _deleteFriend(String friendshipID) async {
    try {
      Friendship? friendship =
          await _friendshipService.getFriendship(friendshipID);
      String? otherUserId = friendship?.user1 == userUsername
          ? friendship?.user2
          : friendship?.user1;
      await _friendshipService.deleteFriendship(friendship!.id);

      final SharedGoalService _sharedGoalService = SharedGoalService();
      List<SharedGoal> goals = await _sharedGoalService.getSharedGoalsForUsers(
          userUsername, otherUserId!);

      for (var goal in goals) {
        await _sharedGoalService.deleteSharedGoalEntry(goal.id);
      }

      setState(() {
        FocusScope.of(context).unfocus();
      });

      showCustomSnackBar(
          context, "Draugas ir bendros užduotys pašalinti ✅", true);
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
    const double topPadding = 25.0;
    const double horizontalPadding = 20.0;
    const double bottomPadding = 20.0;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : const Color(0xFF8093F1),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
        backgroundColor: isDarkMode ? Colors.black : const Color(0xFF8093F1),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: topPadding),
            Expanded(
              child: Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: horizontalPadding),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[900] : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isDarkMode ? Colors.grey[800]! : Colors.white,
                    width: 20,
                  ),
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
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        const Expanded(child: SizedBox()),
                        ElevatedButton(
                          onPressed: () {
                            _deleteCustomSnackBar(userModel);
                          },
                          child: Text(
                            'Ištrinti',
                          ),
                        ),
                      ],
                    ),
                    Stack(
                      children: [
                        Center(
                          child: (userModel.iconUrl == '' ||
                                  userModel.iconUrl == null)
                              ? Icon(
                                  Icons.account_circle,
                                  size: 250,
                                  color: isDarkMode
                                      ? Colors.grey[400]
                                      : const Color(0xFFD9D9D9),
                                )
                              : Image.asset(
                                  userModel.iconUrl!,
                                  width: 250,
                                  height: 250,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        widget.name,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        widget.username,
                        style: TextStyle(
                          fontSize: 18,
                          color: isDarkMode
                              ? Colors.white70
                              : const Color(0xFF8093F1),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      GardenScreen(user: userModel)),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 270,
                            height: 160,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isDarkMode
                                    ? Colors.green.shade600
                                    : Colors.green.shade700,
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: isDarkMode
                                      ? Colors.black54
                                      : Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(9),
                              child: Image.asset(
                                'assets/images/draugo_sodas.png',
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const BottomNavigation(),
            SizedBox(height: bottomPadding),
          ],
        ),
      ),
    );
  }

  void _deleteCustomSnackBar(UserModel friend) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text.rich(
            TextSpan(
              text: "${friend.name}\n",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: isDarkMode ? Colors.purple[200] : Colors.deepPurple,
              ),
              children: [
                TextSpan(
                  text: "Ar tikrai norite pašalinti šį draugą?",
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: isDarkMode ? Colors.white70 : Colors.black,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
          content: Text(
            "Draugo pašalinimas bus negrįžtamas.\nBus pašalinta ir bendrų užduočių istorija.",
            style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      FocusScope.of(context).unfocus();
                    });
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: isDarkMode
                        ? Colors.purple[500]!.withOpacity(0.2)
                        : Colors.deepPurple.withOpacity(0.2),
                  ),
                  child: Text(
                    "Ne",
                    style: TextStyle(
                      fontSize: 18,
                      color: isDarkMode ? Colors.white70 : Colors.black,
                    ),
                  ),
                ),
                SizedBox(width: 20),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _deleteFriend(widget.friendshipId);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: isDarkMode
                        ? Colors.red[500]!.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                  ),
                  child: Text(
                    "Taip",
                    style: TextStyle(
                      color: isDarkMode ? Colors.red[300] : Colors.red,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
