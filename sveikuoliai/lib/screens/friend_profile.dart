import 'package:flutter/material.dart';
import 'package:sveikuoliai/models/friendship_model.dart';
import 'package:sveikuoliai/models/shared_goal_model.dart';
import 'package:sveikuoliai/models/user_model.dart';
import 'package:sveikuoliai/screens/friends.dart';
import 'package:sveikuoliai/screens/garden.dart';
import 'package:sveikuoliai/services/auth_services.dart';
import 'package:sveikuoliai/services/friendship_services.dart';
import 'package:sveikuoliai/services/shared_goal_services.dart';
import 'package:sveikuoliai/widgets/bottom_navigation.dart';
import 'package:sveikuoliai/widgets/custom_snack_bar.dart';

class FriendProfileScreen extends StatefulWidget {
  final FriendshipModel friendship;
  final bool isDarkMode;
  const FriendProfileScreen(
      {super.key,
      required this.friendship,
      required this.isDarkMode});

  @override
  _FriendProfileScreenState createState() => _FriendProfileScreenState();
}

class _FriendProfileScreenState extends State<FriendProfileScreen> {
  final FriendshipService _friendshipService = FriendshipService();
  final SharedGoalService _sharedGoalService = SharedGoalService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _deleteFriend(FriendshipModel friendship) async {
    try {
      await _friendshipService.deleteFriendship(friendship.friendship.id);
      await _authService.removeFriendsFromSession(widget.friendship);

      List<SharedGoalInformation> goals =
          await _authService.getSharedGoalsFromSession();

      List<String> goalsToDelete = goals
          .where((goal) {
            return (goal.sharedGoalModel.user1Id ==
                        friendship.friendship.user1 &&
                    goal.sharedGoalModel.user2Id ==
                        friendship.friendship.user2) ||
                (goal.sharedGoalModel.user1Id == friendship.friendship.user2 &&
                    goal.sharedGoalModel.user2Id ==
                        friendship.friendship.user1);
          })
          .map((goal) => goal.sharedGoalModel.id)
          .toList();

      // Šaliname bendrus tikslus iš Firestore
      for (var goalId in goalsToDelete) {
        await _sharedGoalService.deleteSharedGoalEntry(goalId);
      }

      setState(() {
        goals.removeWhere(
            (goal) => goalsToDelete.contains(goal.sharedGoalModel.id));
      });

      await _authService.saveSharedGoalsToSession(goals);

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
      print('Klaida šalinant draugą: $e');
      showCustomSnackBar(context, "Nepavyko pašalinti draugo ❌", false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const double topPadding = 25.0;
    const double horizontalPadding = 20.0;
    const double bottomPadding = 20.0;

    return Scaffold(
      backgroundColor:
          widget.isDarkMode ? Colors.black : const Color(0xFF8093F1),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
        backgroundColor:
            widget.isDarkMode ? Colors.black : const Color(0xFF8093F1),
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
                  color: widget.isDarkMode ? Colors.grey[900] : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: widget.isDarkMode ? Colors.grey[800]! : Colors.white,
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
                            color:
                                widget.isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        const Expanded(child: SizedBox()),
                        ElevatedButton(
                          onPressed: () {
                            _deleteCustomSnackBar(widget.friendship.friend);
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
                          child: (widget.friendship.friend.iconUrl == '' ||
                                  widget.friendship.friend.iconUrl == null)
                              ? Icon(
                                  Icons.account_circle,
                                  size: 250,
                                  color: widget.isDarkMode
                                      ? Colors.grey[400]
                                      : const Color(0xFFD9D9D9),
                                )
                              : Image.asset(
                                  widget.friendship.friend.iconUrl!,
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
                        widget.friendship.friend.name,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color:
                              widget.isDarkMode ? Colors.white : Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        widget.friendship.friend.username,
                        style: TextStyle(
                          fontSize: 18,
                          color: widget.isDarkMode
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
                                  builder: (context) => GardenScreen(
                                      user: widget.friendship.friend)),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 270,
                            height: 160,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: widget.isDarkMode
                                    ? Colors.green.shade600
                                    : Colors.green.shade700,
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.isDarkMode
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
          contentPadding: EdgeInsets.all(16.0), // Standartinis padding
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              (friend.iconUrl == null || friend.iconUrl!.isEmpty)
                  ? Icon(
                      Icons.account_circle,
                      size: 100,
                      color:
                          widget.isDarkMode ? Colors.white70 : Colors.grey[800],
                    )
                  : Image.asset(
                      friend.iconUrl!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                    ),
              SizedBox(height: 10),
              Text.rich(
                TextSpan(
                  text: "${friend.name}\n",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: widget.isDarkMode
                        ? Colors.purple[200]
                        : Colors.deepPurple,
                  ),
                  children: [
                    TextSpan(
                      text: "Ar tikrai norite pašalinti šį draugą?",
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color:
                            widget.isDarkMode ? Colors.white70 : Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Draugo pašalinimas bus negrįžtamas.\nBus pašalinta ir bendrų užduočių istorija.",
                style: TextStyle(
                    color: widget.isDarkMode ? Colors.white70 : Colors.black),
              ),
            ],
          ),
          backgroundColor: widget.isDarkMode ? Colors.grey[800] : Colors.white,
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
                    backgroundColor: widget.isDarkMode
                        ? Colors.purple[500]!.withOpacity(0.2)
                        : Colors.deepPurple.withOpacity(0.2),
                  ),
                  child: Text(
                    "Ne",
                    style: TextStyle(
                      fontSize: 18,
                      color: widget.isDarkMode
                          ? Colors.white70
                          : Colors.deepPurple,
                    ),
                  ),
                ),
                SizedBox(width: 20),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _deleteFriend(widget.friendship);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: widget.isDarkMode
                        ? Colors.red[500]!.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                  ),
                  child: Text(
                    "Taip",
                    style: TextStyle(
                      color: widget.isDarkMode ? Colors.red[300] : Colors.red,
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
