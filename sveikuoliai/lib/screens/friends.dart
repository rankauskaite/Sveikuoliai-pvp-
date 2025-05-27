import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sveikuoliai/models/friendship_model.dart';
import 'package:sveikuoliai/models/notification_model.dart';
import 'package:sveikuoliai/models/shared_goal_model.dart';
import 'package:sveikuoliai/models/user_model.dart';
import 'package:sveikuoliai/screens/friend_profile.dart';
import 'package:sveikuoliai/services/auth_services.dart';
import 'package:sveikuoliai/services/friendship_services.dart';
import 'package:sveikuoliai/services/notification_services.dart';
import 'package:sveikuoliai/services/shared_goal_services.dart';
import 'package:sveikuoliai/widgets/bottom_navigation.dart';
import 'package:sveikuoliai/widgets/custom_snack_bar.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final AuthService _authService = AuthService();
  final FriendshipService _friendshipService = FriendshipService();
  final AppNotificationService _notificationService = AppNotificationService();
  final SharedGoalService _sharedGoalService = SharedGoalService();
  String userUsername = "";
  String userName = "";
  String userIcon = "account_circle";
  List<FriendshipModel> friends = [];
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> searchResults = [];
  bool isSearching = false;
  bool isDarkMode = false; // Temos būsena

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _searchController.addListener(() {
      setState(() {}); // atnaujina suffixIcon matomumą
    });
  }

  // Funkcija, kad gauti prisijungusio vartotojo duomenis
  Future<void> _fetchUserData() async {
    try {
      Map<String, String?> sessionData = await _authService.getSessionUser();
      setState(
        () {
          userUsername = sessionData['username'] ?? "Nežinomas";
          userName = sessionData['name'] ?? "Nežinomas";
          userIcon = sessionData['icon'] ?? "account_circle";
          isDarkMode =
              sessionData['darkMode'] == 'true'; // Gauname darkMode iš sesijos
        },
      );
      await _fetchUserFriends(userUsername);
    } catch (e) {
      String message = 'Klaida gaunant duomenis ❌';
      showCustomSnackBar(context, message, false);
    }
  }

  Future<void> _fetchUserFriends(String username) async {
    try {
      List<FriendshipModel> friendsList =
          await _authService.getFriendsFromSession();
      setState(() {
        friends = friendsList;
      });
    } catch (e) {
      String message = 'Klaida gaunant draugų duomenis ❌';
      showCustomSnackBar(context, message, false);
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
        isSearching = false;
      });
      return;
    }

    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').get();

    List<UserModel> allUsers = snapshot.docs
        .map((doc) =>
            UserModel.fromJson(doc.id, doc.data() as Map<String, dynamic>))
        .toList();

    List<UserModel> premiumUsers =
        allUsers.where((user) => user.version == 'premium').toList();

    setState(() {
      searchResults = premiumUsers.where((user) {
        final nameLower = user.name.toLowerCase();
        final usernameLower = user.username.toLowerCase();
        final queryLower = query.toLowerCase();

        final isSelf = user.username == userUsername;
        final isFriend =
            friends.any((friend) => friend.friend.username == user.username);

        return !isSelf &&
            !isFriend &&
            (nameLower.contains(queryLower) ||
                usernameLower.contains(queryLower));
      }).toList();

      isSearching = true;
    });
  }

  Future<void> _addFriend(UserModel user) async {
    try {
      Friendship friendship = Friendship(
        id: Friendship.generateFriendshipId(userUsername, user.username),
        user1: userUsername,
        user2: user.username,
        status: "pending",
        createdAt: DateTime.now(),
      );
      FriendshipModel friendshipModel =
          FriendshipModel(friendship: friendship, friend: user);
      await _friendshipService.createFriendship(friendship);
      friends.add(friendshipModel);
      await _authService.saveFriendsToSession(friends);

      showCustomSnackBar(context, "Draugas pridėtas ✅", true);
      setState(() {
        _searchController.clear();
        searchResults = [];
        isSearching = false;
        FocusScope.of(context).unfocus();
      });
      DateTime now = DateTime.now();
      AppNotification notification = AppNotification(
          id: "${user.username}_$now",
          userId: user.username,
          text:
              "${userName} (@${userUsername}) išsiuntė jums pakvietimą draugauti! Ar sutiksi? 👯‍♀️",
          type: "friend_request",
          date: now);
      await _notificationService.createNotification(notification);
    } catch (e) {
      showCustomSnackBar(context, "Nepavyko pridėti draugo ❌", false);
    }
  }

  void _showAddFriendDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor:
                    isDarkMode ? Colors.grey[700] : Colors.grey[200],
                backgroundImage:
                    (user.iconUrl != null && user.iconUrl!.isNotEmpty)
                        ? AssetImage(user.iconUrl!)
                        : null,
                child: (user.iconUrl == null || user.iconUrl!.isEmpty)
                    ? Icon(
                        Icons.account_circle,
                        size: 60,
                        color: isDarkMode ? Colors.white70 : Colors.grey[600],
                      )
                    : null,
              ),
              SizedBox(height: 10),
              Text(
                "Pridėti draugą",
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 16,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              Text(
                user.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: isDarkMode ? Colors.purple[200] : Colors.deepPurple,
                ),
              ),
            ],
          ),
          backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
          content: Text.rich(
            TextSpan(
              text: "Ar tikrai norite pridėti ",
              style: TextStyle(
                fontWeight: FontWeight.normal,
                color: isDarkMode ? Colors.white70 : Colors.black,
                fontSize: 15,
              ),
              children: [
                TextSpan(
                  text: "${user.name}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.purple[200] : Colors.deepPurple,
                    fontSize: 15,
                  ),
                ),
                TextSpan(
                  text: " (${user.username})",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.pink[200] : Colors.pink[300],
                    fontSize: 15,
                  ),
                ),
                TextSpan(
                  text: " kaip draugą?",
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: isDarkMode ? Colors.white70 : Colors.black,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: isDarkMode
                    ? Colors.purple[400]!.withOpacity(0.2)
                    : Colors.deepPurple.withOpacity(0.2),
              ),
              child: Text(
                "Ne",
                style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: isDarkMode
                    ? Colors.purple[400]!.withOpacity(0.2)
                    : Colors.deepPurple.withOpacity(0.2),
              ),
              child: Text(
                "Taip",
                style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await _addFriend(user);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmFriendship(FriendshipModel friendship) async {
    try {
      setState(() {
        friendship.friendship.status = "accepted";
      });
      await _friendshipService.updateFriendship(friendship.friendship);
      setState(() {
        friends.removeWhere((f) => f.friendship.id == friendship.friendship.id);
        friends.add(friendship);
      });
      await _authService.saveFriendsToSession(friends);

      showCustomSnackBar(context, "Draugystė patvirtinta ✅", true);
      setState(() {
        FocusScope.of(context).unfocus();
      });
    } catch (e) {
      showCustomSnackBar(context, "Nepavyko patvirtinti draugystės ❌", false);
    }
  }

  Future<void> _deleteFriend(FriendshipModel friendship) async {
    try {
      await _friendshipService.deleteFriendship(friendship.friendship.id);

      setState(() {
        friends.removeWhere((f) => f.friendship.id == friendship.friendship.id);
      });

      await _authService.saveFriendsToSession(friends);

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

    List<FriendshipModel> pendingFriends = friends
        .where((friend) => friend.friendship.status == "pending")
        .toList();
    List<FriendshipModel> acceptedFriends = friends
        .where((friend) => friend.friendship.status == "accepted")
        .toList();

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : const Color(0xFF8093F1),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
        backgroundColor: isDarkMode ? Colors.black : const Color(0xFF8093F1),
      ),
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                      ],
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Draugai',
                      style: TextStyle(
                        fontSize: 35,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Pridėti draugą:',
                          style: TextStyle(
                            fontSize: 20,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _searchController,
                      onChanged: _searchUsers,
                      style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Įveskite draugo slapyvardį',
                        hintStyle: TextStyle(
                            color: isDarkMode ? Colors.grey[500] : Colors.grey),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: isDarkMode ? Colors.white70 : Colors.black,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: isDarkMode
                                      ? Colors.white70
                                      : Colors.black,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    searchResults = [];
                                    isSearching = false;
                                  });
                                  FocusScope.of(context).unfocus();
                                },
                              )
                            : null,
                      ),
                    ),
                    SizedBox(height: 20),
                    if (isSearching && searchResults.isNotEmpty)
                      Expanded(
                        child: ListView.builder(
                          itemCount: searchResults.length,
                          itemBuilder: (context, index) {
                            final user = searchResults[index];
                            return ListTile(
                              leading: (user.iconUrl == null ||
                                      user.iconUrl!.isEmpty)
                                  ? Icon(
                                      Icons.account_circle,
                                      size: 40,
                                      color: isDarkMode
                                          ? Colors.white70
                                          : Colors.black,
                                    )
                                  : CircleAvatar(
                                      backgroundImage:
                                          AssetImage(user.iconUrl!),
                                    ),
                              title: Text(
                                user.name.length > 10
                                    ? user.name.substring(0, 10) + '…'
                                    : user.name,
                                style: TextStyle(
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                              subtitle: Text(
                                user.username,
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.white70
                                      : const Color(0xFF8093F1),
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.person_add_alt_1,
                                  color: isDarkMode
                                      ? Colors.purple[200]
                                      : const Color(0xFFB388EB),
                                ),
                                onPressed: () {
                                  _showAddFriendDialog(user);
                                },
                              ),
                              onTap: () {},
                            );
                          },
                        ),
                      ),
                    if (pendingFriends.isNotEmpty) ...[
                      Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.grey[700]
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Nepatvirtintos draugystės:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode
                                    ? Colors.white70
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      if (pendingFriends.isEmpty && !isSearching)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Nėra nepatvirtintų draugysčių",
                            style: TextStyle(
                              fontSize: 18,
                              color:
                                  isDarkMode ? Colors.grey[500] : Colors.grey,
                            ),
                          ),
                        ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: pendingFriends.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {},
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? Colors.grey[800]
                                      : const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: isDarkMode
                                        ? Colors.grey[600]!
                                        : Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        if (pendingFriends[index]
                                                    .friend
                                                    .iconUrl ==
                                                null ||
                                            pendingFriends[index]
                                                .friend
                                                .iconUrl!
                                                .isEmpty)
                                          Icon(
                                            Icons.account_circle,
                                            size: 40,
                                            color: isDarkMode
                                                ? Colors.white70
                                                : Colors.black,
                                          )
                                        else
                                          CircleAvatar(
                                            backgroundImage: AssetImage(
                                                pendingFriends[index]
                                                    .friend
                                                    .iconUrl!),
                                          ),
                                        SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              pendingFriends[index]
                                                          .friend
                                                          .name
                                                          .length >
                                                      10
                                                  ? pendingFriends[index]
                                                          .friend
                                                          .name
                                                          .substring(0, 10) +
                                                      '…'
                                                  : pendingFriends[index]
                                                      .friend
                                                      .name,
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: isDarkMode
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                            ),
                                            Text(
                                              pendingFriends[index]
                                                  .friend
                                                  .username,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: isDarkMode
                                                    ? Colors.white70
                                                    : const Color(0xFF8093F1),
                                                letterSpacing: 1,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    if (pendingFriends[index]
                                            .friendship
                                            .user2 ==
                                        userUsername)
                                      Row(
                                        children: [
                                          Transform.translate(
                                            offset: Offset(10, 0),
                                            child: IconButton(
                                              icon: Icon(
                                                Icons.cancel_outlined,
                                                color: isDarkMode
                                                    ? Colors.red[300]
                                                    : Colors.red.shade300,
                                              ),
                                              onPressed: () {
                                                _showDeclineFriendshipDialog(
                                                    pendingFriends[index]);
                                              },
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.check_circle,
                                              color: isDarkMode
                                                  ? Colors.green[300]
                                                  : Colors.green.shade400,
                                            ),
                                            onPressed: () {
                                              _showConfirmFriendshipDialog(
                                                  pendingFriends[index]);
                                            },
                                          ),
                                        ],
                                      )
                                    else
                                      Column(
                                        children: [
                                          Text(
                                            "Draugas dar",
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: isDarkMode
                                                  ? Colors.grey[500]
                                                  : Colors.grey.shade700,
                                              fontStyle: FontStyle.italic,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            "nepatvirtino",
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: isDarkMode
                                                  ? Colors.grey[500]
                                                  : Colors.grey.shade700,
                                              fontStyle: FontStyle.italic,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: Divider(
                          color: isDarkMode
                              ? Colors.grey[600]
                              : Colors.grey.shade300,
                          thickness: 1,
                        ),
                      ),
                    ],
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.purple[900]!.withOpacity(0.2)
                            : Color(0xFFE9E3FB).withOpacity(0.7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Turimi draugai:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode
                                  ? Colors.purple[200]
                                  : const Color(0xFFB388EB),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    if (acceptedFriends.isEmpty && !isSearching)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Draugų sąrašas tuščias",
                          style: TextStyle(
                            fontSize: 18,
                            color: isDarkMode ? Colors.grey[500] : Colors.grey,
                          ),
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: acceptedFriends.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FriendProfileScreen(
                                    friendship: acceptedFriends[index],
                                    isDarkMode: isDarkMode,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Colors.purple[900]!.withOpacity(0.1)
                                    : const Color(0xFFE9E3FB),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: isDarkMode
                                      ? Colors.purple[700]!
                                      : const Color(0xFFB388EB),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      if (acceptedFriends[index]
                                                  .friend
                                                  .iconUrl ==
                                              null ||
                                          acceptedFriends[index]
                                              .friend
                                              .iconUrl!
                                              .isEmpty)
                                        Icon(
                                          Icons.account_circle,
                                          size: 40,
                                          color: isDarkMode
                                              ? Colors.white70
                                              : Colors.black,
                                        )
                                      else
                                        CircleAvatar(
                                          backgroundImage: AssetImage(
                                              acceptedFriends[index]
                                                  .friend
                                                  .iconUrl!),
                                        ),
                                      SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            acceptedFriends[index]
                                                        .friend
                                                        .name
                                                        .length >
                                                    10
                                                ? '${acceptedFriends[index].friend.name.substring(0, 10)}…'
                                                : acceptedFriends[index]
                                                    .friend
                                                    .name,
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: isDarkMode
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                          Text(
                                            acceptedFriends[index]
                                                .friend
                                                .username,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isDarkMode
                                                  ? Colors.white70
                                                  : const Color(0xFF8093F1),
                                              letterSpacing: 1,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.remove_circle_outline,
                                      color: isDarkMode
                                          ? Colors.purple[200]
                                          : const Color(0xFFB388EB),
                                    ),
                                    onPressed: () {
                                      _deleteCustomSnackBar(
                                          index, acceptedFriends);
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
            ),
            const BottomNavigation(),
            SizedBox(height: bottomPadding),
          ],
        ),
      ),
    );
  }

  void _showDeclineFriendshipDialog(FriendshipModel friendship) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(16.0), // Standartinis padding
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              (friendship.friend.iconUrl == null ||
                      friendship.friend.iconUrl!.isEmpty)
                  ? Icon(
                      Icons.account_circle,
                      size: 100,
                      color: isDarkMode ? Colors.white70 : Colors.grey[800],
                    )
                  : Image.asset(
                      friendship.friend.iconUrl!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                    ),
              SizedBox(height: 10),
              Text.rich(
                TextSpan(
                  text: "${friendship.friend.name}\n",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: isDarkMode ? Colors.purple[200] : Colors.deepPurple,
                  ),
                  children: [
                    TextSpan(
                      text: "Draugystės atsisakymas",
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: isDarkMode ? Colors.white70 : Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Ar tikrai norite atsisakyti šios draugystės?",
                style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black),
              ),
            ],
          ),
          backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
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
                    "Grįžti",
                    style: TextStyle(
                      fontSize: 18,
                      color: isDarkMode ? Colors.white70 : Colors.deepPurple,
                    ),
                  ),
                ),
                SizedBox(width: 20),
                TextButton(
                  onPressed: () async {
                    await _friendshipService
                        .deleteFriendship(friendship.friendship.id);
                    Navigator.of(context).pop();
                    showCustomSnackBar(
                        context, "Draugystės atsisakyta ✅", true);
                    setState(() {
                      FocusScope.of(context).unfocus();
                    });
                    await _fetchUserFriends(userUsername);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: isDarkMode
                        ? Colors.red[500]!.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                  ),
                  child: Text(
                    "Atsisakyti",
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

  void _showConfirmFriendshipDialog(FriendshipModel friendship) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(16.0), // Standartinis padding
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              (friendship.friend.iconUrl == null ||
                      friendship.friend.iconUrl!.isEmpty)
                  ? Icon(
                      Icons.account_circle,
                      size: 100,
                      color: isDarkMode ? Colors.white70 : Colors.grey[800],
                    )
                  : Image.asset(
                      friendship.friend.iconUrl!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                    ),
              SizedBox(height: 10),
              Text.rich(
                TextSpan(
                  text: "${friendship.friend.name}\n",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: isDarkMode ? Colors.purple[200] : Colors.deepPurple,
                  ),
                  children: [
                    TextSpan(
                      text: "Draugystės patvirtinimas",
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: isDarkMode ? Colors.white70 : Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Ar norite patvirtinti šią draugystę?",
                style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black),
              ),
            ],
          ),
          backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
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
                    "Grįžti",
                    style: TextStyle(
                      fontSize: 18,
                      color: isDarkMode ? Colors.white70 : Colors.deepPurple,
                    ),
                  ),
                ),
                SizedBox(width: 20),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _confirmFriendship(friendship);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: isDarkMode
                        ? Colors.green[500]!.withOpacity(0.2)
                        : Colors.green.withOpacity(0.2),
                  ),
                  child: Text(
                    "Patvirtinti",
                    style: TextStyle(
                      color: isDarkMode ? Colors.green[300] : Colors.green,
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

  void _deleteCustomSnackBar(
      int index, List<FriendshipModel> friendsList) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(16.0), // Standartinis padding
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              (friendsList[index].friend.iconUrl == null ||
                      friendsList[index].friend.iconUrl!.isEmpty)
                  ? Icon(
                      Icons.account_circle,
                      size: 100,
                      color: isDarkMode ? Colors.white70 : Colors.grey[800],
                    )
                  : Image.asset(
                      friendsList[index].friend.iconUrl!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                    ),
              SizedBox(height: 10),
              Text.rich(
                TextSpan(
                  text: "${friendsList[index].friend.name}\n",
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
              SizedBox(height: 10),
              Text(
                "Draugo pašalinimas bus negrįžtamas.\nBus pašalinta ir bendrų užduočių istorija.",
                style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black),
              ),
            ],
          ),
          backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
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
                      color: isDarkMode ? Colors.white70 : Colors.deepPurple,
                    ),
                  ),
                ),
                SizedBox(width: 20),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _deleteFriend(friendsList[index]);
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
