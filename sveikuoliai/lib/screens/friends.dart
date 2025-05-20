import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sveikuoliai/models/friendship_model.dart';
import 'package:sveikuoliai/models/shared_goal_model.dart';
import 'package:sveikuoliai/models/user_model.dart';
import 'package:sveikuoliai/screens/friend_profile.dart';
import 'package:sveikuoliai/services/auth_services.dart';
import 'package:sveikuoliai/services/friendship_services.dart';
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
  //final UserService _userService = UserService();
  String userUsername = "";
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
      await _fetchUserFriends(userUsername); // Atnaujina draugų sąrašą
      // if (mounted) {
      //   Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => FriendProfileScreen(
      //         name: user.name,
      //         username: user.username,
      //         friendshipId:
      //             Friendship.generateFriendshipId(userUsername, user.username),
      //       ),
      //     ),
      //   );
      // }
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

    // Gauname ekrano matmenis
    //final Size screenSize = MediaQuery.of(context).size;

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
                    SizedBox(
                      height: 20,
                    ),
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
                    if (friends.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Draugų sąrašas tuščias",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
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
                                    name: friends[index].friend.name,
                                    username: friends[index].friend.username,
                                    friendshipId: friends[index].friendship.id,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                            friends[index].friend.name,
                                            style: TextStyle(fontSize: 18),
                                          ),
                                          Text(
                                            friends[index].friend.username,
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
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text.rich(
                                              TextSpan(
                                                text:
                                                    "${friends[index].friend.name}\n",
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
                                                      fontWeight:
                                                          FontWeight.normal,
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
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(
                                                          context); // Uždaro dialogą
                                                    },
                                                    style: TextButton.styleFrom(
                                                      backgroundColor: Colors
                                                          .deepPurple
                                                          .withOpacity(0.2),
                                                    ),
                                                    child: Text("Ne",
                                                        style: TextStyle(
                                                            fontSize: 18)),
                                                  ),
                                                  SizedBox(width: 20),
                                                  TextButton(
                                                    onPressed: () async {
                                                      Navigator.pop(context);
                                                      await _deleteFriend(
                                                          friends[index]);
                                                    },
                                                    style: TextButton.styleFrom(
                                                      backgroundColor: Colors
                                                          .red
                                                          .withOpacity(0.2),
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
            SizedBox(
              height: bottomPadding,
            ), // Fiksuotas tarpas nuo apačios
          ],
        ),
      ),
    );
  }
}
