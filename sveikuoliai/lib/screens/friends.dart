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
  String userUsername = "";
  String userName = "";
  List<FriendshipModel> friends = [];
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> searchResults = [];
  bool isSearching = false;

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
          await _friendshipService.getUserFriendshipModels(username);
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

    // Gauk visus vartotojus ir filtruok (čia galėtum optimizuoti užklausą Firestore, jei didelė duomenų bazė)
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

        // Rodyti tik tuos, kurie nėra pats naudotojas ir nėra draugų sąraše
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
      await _friendshipService.createFriendship(friendship);
      showCustomSnackBar(context, "Draugas pridėtas ✅", true);
      //_searchUsers(_searchController.text); // Atnaujina paiešką
      setState(() {
        _searchController.clear(); // Išvalome paieškos laukelį
        searchResults = [];
        isSearching = false;
        FocusScope.of(context).unfocus(); // Uždaro klaviatūrą
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
      await _fetchUserFriends(userUsername); // Atnaujina draugų sąrašą
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Pridėti draugą "),
              Text(
                user.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.deepPurple,
                ),
              )
            ],
          ),
          content: Text.rich(
            TextSpan(
              text:
                  "Ar tikrai norite pridėti ", // Pirmoji dalis (bendras tekstas)
              style: TextStyle(
                fontWeight: FontWeight.normal,
                color: Colors.black,
                fontSize: 15,
              ),
              children: [
                TextSpan(
                  text: "${user.name}", // Vardas
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple, // Kita spalva vardui
                    fontSize: 15,
                  ),
                ),
                TextSpan(
                  text: " (${user.username})", // Slapyvardis
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.pink[300], // Kita spalva slapyvardžiui
                    fontSize: 15,
                  ),
                ),
                TextSpan(
                  text: " kaip draugą?", // Pabaiga
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.deepPurple.withOpacity(0.2),
              ),
              child: Text("Ne"),
              onPressed: () {
                Navigator.of(context).pop(); // Uždaryti dialogą
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.deepPurple.withOpacity(0.2),
              ),
              child: Text("Taip"),
              onPressed: () async {
                Navigator.of(context).pop(); // Uždaryti dialogą
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
      showCustomSnackBar(context, "Draugystė patvirtinta ✅", true);
      setState(() {
        FocusScope.of(context).unfocus(); // Uždaro klaviatūrą
      });
      await _fetchUserFriends(userUsername); // Atnaujina draugų sąrašą
    } catch (e) {
      showCustomSnackBar(context, "Nepavyko patvirtinti draugystės ❌", false);
    }
  }

  Future<void> _deleteFriend(FriendshipModel friendship) async {
    try {
      // Gauti kito draugo ID iš draugystės
      String otherUserId = friendship.friendship.user1 == userUsername
          ? friendship.friendship.user2
          : friendship.friendship.user1;
      // Pašalinti draugystę
      await _friendshipService.deleteFriendship(friendship.friendship.id);

      // Pašalinti visas bendras užduotis
      final SharedGoalService _sharedGoalService = SharedGoalService();
      List<SharedGoal> goals = await _sharedGoalService.getSharedGoalsForUsers(
          userUsername, otherUserId);

      for (var goal in goals) {
        await _sharedGoalService.deleteSharedGoalEntry(goal.id);
      }

      setState(() {
        FocusScope.of(context).unfocus(); // Uždaro klaviatūrą
      });

      showCustomSnackBar(
          context, "Draugas ir bendros užduotys pašalinti ✅", true);
      await _fetchUserFriends(userUsername); // atnaujinti sąrašą
    } catch (e) {
      showCustomSnackBar(context, "Nepavyko pašalinti draugo ❌", false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fiksuoti tarpai
    const double topPadding = 25.0; // Tarpas nuo viršaus
    const double horizontalPadding = 20.0; // Tarpai iš šonų
    const double bottomPadding =
        20.0; // Tarpas nuo apačios (virš BottomNavigation)

    // Split friends into pending and accepted
    List<FriendshipModel> pendingFriends = friends
        .where((friend) => friend.friendship.status == "pending")
        .toList();
    List<FriendshipModel> acceptedFriends = friends
        .where((friend) => friend.friendship.status == "accepted")
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF8093F1),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
        backgroundColor: const Color(0xFF8093F1),
      ),
      resizeToAvoidBottomInset: false, // Prevent resizing when keyboard appears
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: topPadding), // Fiksuotas tarpas nuo viršaus
            Expanded(
              // Balta sritis užpildo likusį plotą tarp fiksuotų tarpų
              child: Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: horizontalPadding),
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
                    SizedBox(height: 20),
                    Text(
                      'Draugai',
                      style: TextStyle(fontSize: 35),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Pridėti draugą:',
                          style: TextStyle(fontSize: 20),
                        )
                      ],
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _searchController,
                      onChanged: _searchUsers,
                      decoration: InputDecoration(
                        hintText: 'Įveskite draugo slapyvardį',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear),
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
                              leading: Icon(Icons.account_circle, size: 40),
                              title: Text(user.name),
                              subtitle: Text(
                                user.username,
                                style: TextStyle(color: Color(0xFF8093F1)),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.person_add_alt_1,
                                  color: Color(0xFFB388EB),
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
                    // Pending Friendships Section
                    if (pendingFriends.isNotEmpty) ...[
                      Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
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
                                color: Colors.grey.shade700,
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
                            style: TextStyle(fontSize: 18, color: Colors.grey),
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
                                  color: Color(
                                      0xFFF5F5F5), // Light grey background
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.account_circle, size: 40),
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
                                              style: TextStyle(fontSize: 18),
                                            ),
                                            Text(
                                              pendingFriends[index]
                                                  .friend
                                                  .username,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFF8093F1),
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
                                            offset: Offset(10,
                                                0), // Shift the second button 10 pixels to the left
                                            child: IconButton(
                                              icon: Icon(Icons.cancel_outlined,
                                                  color: Colors.red.shade300),
                                              onPressed: () {
                                                _showDeclineFriendshipDialog(
                                                    pendingFriends[index]);
                                              },
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.check_circle,
                                                color: Colors.green.shade400),
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
                                              color: Colors.grey.shade700,
                                              fontStyle: FontStyle.italic,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            "nepatvirtino",
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey.shade700,
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
                      // Divider between sections
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: Divider(
                          color: Colors.grey.shade300,
                          thickness: 1,
                        ),
                      ),
                    ],
                    // Accepted Friendships Section
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      decoration: BoxDecoration(
                        color: Color(0xFFE9E3FB).withOpacity(0.7),
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
                              color: Color(0xFFB388EB),
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
                          style: TextStyle(fontSize: 18, color: Colors.grey),
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
                                    name: acceptedFriends[index].friend.name,
                                    username:
                                        acceptedFriends[index].friend.username,
                                    friendshipId:
                                        acceptedFriends[index].friendship.id,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Color(
                                    0xFFE9E3FB), // Light purple background
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Color(0xFFB388EB),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.account_circle, size: 40),
                                      SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            acceptedFriends[index].friend.name,
                                            style: TextStyle(fontSize: 18),
                                          ),
                                          Text(
                                            acceptedFriends[index]
                                                .friend
                                                .username,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF8093F1),
                                              letterSpacing: 1,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.remove_circle_outline,
                                        color: Color(0xFFB388EB)),
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
            SizedBox(height: bottomPadding), // Fiksuotas tarpas nuo apačios
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
          title: Text.rich(
            TextSpan(
              text: "${friendship.friend.name}\n",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.deepPurple,
              ),
              children: [
                TextSpan(
                  text: "Draugystės atsisakymas",
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          content: Text("Ar tikrai norite atsisakyti šios draugystės?"),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Uždaro dialogą
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.deepPurple.withOpacity(0.2),
                  ),
                  child: Text("Grįžti", style: TextStyle(fontSize: 18)),
                ),
                SizedBox(width: 20),
                TextButton(
                  onPressed: () async {
                    await _friendshipService
                        .deleteFriendship(friendship.friendship.id);
                    Navigator.of(context).pop(); // Uždaryti dialogą
                    showCustomSnackBar(
                        context, "Draugystės atsisakyta ✅", true);
                    setState(() {
                      FocusScope.of(context).unfocus(); // Uždaro klaviatūrą
                    });
                    await _fetchUserFriends(
                        userUsername); // Refresh the friends list
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.2),
                  ),
                  child: Text("Atsisakyti",
                      style: TextStyle(color: Colors.red, fontSize: 18)),
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
          title: Text.rich(
            TextSpan(
              text: "${friendship.friend.name}\n",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.deepPurple,
              ),
              children: [
                TextSpan(
                  text: "Draugystės patvirtinimas",
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          content: Text("Ar norite patvirtinti šią draugystę?"),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Uždaro dialogą
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.deepPurple.withOpacity(0.2),
                  ),
                  child: Text("Grįžti", style: TextStyle(fontSize: 18)),
                ),
                SizedBox(width: 20),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context); // Uždaro dialogą
                    await _confirmFriendship(friendship);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.green.withOpacity(0.2),
                  ),
                  child: Text("Patvirtinti",
                      style: TextStyle(color: Colors.green, fontSize: 18)),
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
          title: Text.rich(
            TextSpan(
              text: "${friendsList[index].friend.name}\n",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.deepPurple,
              ),
              children: [
                TextSpan(
                  text: "Ar tikrai norite pašalinti šį draugą?",
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          content: Text(
              "Draugo pašalinimas bus negrįžtamas.\nBus pašalinta ir bendrų užduočių istorija."),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Uždaro dialogą
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.deepPurple.withOpacity(0.2),
                  ),
                  child: Text("Ne", style: TextStyle(fontSize: 18)),
                ),
                SizedBox(width: 20),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _deleteFriend(friendsList[index]);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.2),
                  ),
                  child: Text("Taip",
                      style: TextStyle(color: Colors.red, fontSize: 18)),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
