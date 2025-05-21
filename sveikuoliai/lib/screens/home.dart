import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sveikuoliai/models/notification_model.dart';
import 'package:sveikuoliai/models/user_model.dart';
import 'package:sveikuoliai/screens/friends.dart';
import 'package:sveikuoliai/screens/garden.dart';
import 'package:sveikuoliai/screens/habits_goals.dart';
import 'package:sveikuoliai/screens/version.dart';
import 'package:sveikuoliai/services/auth_services.dart';
import 'package:sveikuoliai/services/notification_services.dart';
import 'package:sveikuoliai/services/user_services.dart';
import 'package:sveikuoliai/widgets/bottom_navigation.dart';
import 'package:sveikuoliai/widgets/profile_button.dart';
import 'package:sveikuoliai/services/notification_helper.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final AppNotificationService _notificationService = AppNotificationService();
  bool showNotifications = false;
  List<AppNotification> notifications = [];
  String userName = "";
  String userUsername = "";
  String userVersion = "";
  final UserService _userService = UserService();
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
    version: "free",
  );
  final PageController _adController = PageController();
  final List<String> _reklamos = [
    'assets/images/reklamos/drouglas.png',
    'assets/images/reklamos/ebatelis.png',
    'assets/images/reklamos/vienaragis.png',
  ];
  int _reklamosIndex = 0;
  Timer? _adTimer;

  // Skaičiuojame neperskaitytus pranešimus
  int get unreadNotificationsCount =>
      notifications.where((n) => !n.isRead).length;

  @override
  void initState() {
    // super.initState();
    // _fetchSessionUser(); // Kviečiame užkrauti sesijos duomenis
    // final now = DateTime.now();
    // final trigger = now.add(const Duration(seconds: 10));
    // NotificationHelper.scheduleDailyNotification(
    //   id: 999,
    //   title: 'Primename!',
    //   body: 'Nenusimink – tikslai formuojasi kasdien 🌱',
    //   hour: trigger.hour,
    //   minute: trigger.minute,
    // );
    // print("🔔 Notification planned for ${trigger.hour}:${trigger.minute}");

    // _adTimer = Timer.periodic(
    //   const Duration(seconds: 3),
    //   (timer) {
    //     _reklamosIndex++;
    //     if (_reklamosIndex >= _reklamos.length) _reklamosIndex = 0;
    //     if (_adController.hasClients) {
    //       _adController.animateToPage(
    //         _reklamosIndex,
    //         duration: const Duration(milliseconds: 500),
    //         curve: Curves.easeInOut,
    //       );
    //     }
    //   },
    // );
    super.initState();
    _fetchSessionUser();
    //final now = DateTime.now();
    //final trigger = now.add(const Duration(seconds: 10));
    // NotificationHelper.scheduleDailyNotification(
    //   id: 999,
    //   title: 'Primename!',
    //   body: 'Nenusimink – tikslai formuojasi kasdien 🌱',
    //   hour: trigger.hour,
    //   minute: trigger.minute,
    // );
    // print("🔔 Notification planned for ${trigger.hour}:${trigger.minute}");
    _setupDailyNotifications();

    _adTimer = Timer.periodic(
      const Duration(seconds: 3),
      (timer) {
        _reklamosIndex++;
        if (_reklamosIndex >= _reklamos.length) _reklamosIndex = 0;
        if (_adController.hasClients) {
          _adController.animateToPage(
            _reklamosIndex,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      },
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _adTimer?.cancel();
    _adController.dispose();
    super.dispose();
  }

  Future<void> _setupDailyNotifications() async {
    // Tik testavimui – gali ištrinti šią eilutę vėliau
    //await FlutterLocalNotificationsPlugin().cancelAll();

    await NotificationHelper.scheduleTwoMotivationsPerDay();
    print("📅 Du pranešimai suplanuoti kasdien 9:00 ir 21:00");
  }

  // Funkcija, kad gauti prisijungusio vartotojo duomenis
  Future<void> _fetchSessionUser() async {
    if (userName.isEmpty || userUsername.isEmpty) {
      try {
        Map<String, String?> sessionData = await _authService.getSessionUser();
        setState(() {
          userName = sessionData['name'] ?? "Nežinomas";
          userUsername = sessionData['username'] ?? "Nežinomas";
          userVersion = sessionData['version'] ?? "Nežinoma";
        });
        UserModel? model = await _userService.getUserEntry(userUsername);
        setState(() {
          userModel = model!;
        });
        _fetchUserNotifications(userUsername);
      } catch (e) {
        setState(() {
          userName = "Klaida gaunant duomenis";
        });
      }
    }
  }

  Future<void> _fetchUserNotifications(String username) async {
    try {
      List<AppNotification> userNotifications =
          await _notificationService.getUserNotifications(username);
      setState(() {
        notifications = userNotifications;
      });
    } catch (e) {
      print("Klaida gaunant pranešimus: $e");
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
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF8093F1),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
        backgroundColor: const Color(0xFF8093F1),
      ),
      body: Stack(
        children: [
          Column(
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
                    // Pakeista iš Column į ListView, kad turinys būtų slenkamas
                    // padding: const EdgeInsets.symmetric(
                    //     vertical: 16), // Vidinis tarpas
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ProfileButton(),
                          Container(
                            height: 50,
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              userName.length > 12
                                  ? '${userName.substring(0, 12)}...'
                                  : userName,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                showNotifications = true;
                              });
                            },
                            child: Stack(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(4.0),
                                  child: Icon(Icons.notifications_outlined,
                                      size: 35),
                                ),
                                if (unreadNotificationsCount > 0)
                                  Positioned(
                                    right: 4,
                                    top: 4,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.pink.shade400,
                                        shape: BoxShape.circle,
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 20,
                                        minHeight: 20,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '$unreadNotificationsCount',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      // Slenkama nuotraukų sritis
                      Expanded(
                        child: ListView(
                          //padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
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
                                    width: (screenSize.width -
                                            2 * horizontalPadding) *
                                        0.8,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.green.shade700,
                                          width: 3),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 8,
                                          offset: Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.asset(
                                        'assets/images/mano_sodas.png',
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            if (userVersion == "free") ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => VersionScreen(
                                                username: userUsername)),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      width: (screenSize.width -
                                              2 * horizontalPadding) *
                                          0.8,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.deepPurple.shade700,
                                            width: 3),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 8,
                                            offset: Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(9),
                                        child: Image.asset(
                                          'assets/gif/premium.gif',
                                          fit: BoxFit.cover,
                                        ),
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
                                    width: (screenSize.width -
                                            2 * horizontalPadding) *
                                        0.8,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD9D9D9),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: PageView.builder(
                                      controller: _adController,
                                      itemCount: _reklamos.length,
                                      itemBuilder: (context, index) {
                                        return ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.asset(
                                            _reklamos[index],
                                            fit: BoxFit.cover,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ] else ...[
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => FriendsScreen()),
                                  );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: (screenSize.width -
                                          2 * horizontalPadding) *
                                      0.8,
                                  height: 300,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Color(0xFF833EBD), width: 3),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 8,
                                        offset: Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(9),
                                    child: Image.asset(
                                      'assets/images/premium_vizualas.png',
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            // const SizedBox(
                            //     height: 20), // Papildomas tarpas apačioje
                          ],
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
          if (showNotifications)
            GestureDetector(
              onTap: () {
                setState(() {
                  showNotifications = false;
                });
              },
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: screenSize.width * 0.75,
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
                            itemCount: notifications.length,
                            itemBuilder: (context, index) {
                              bool isUnread = !notifications[index].isRead;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isUnread) {
                                      _notificationService
                                          .markNotificationAsRead(
                                              notifications[index].id);
                                      notifications[index].isRead =
                                          true; // Atnaujiname lokaliai
                                    }
                                  });
                                  _showMessageDialog(notifications[index]);
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isUnread
                                        ? const Color(0xFFFFC0CB)
                                        : const Color(0xFF8093F1)
                                            .withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(15),
                                    border: isUnread
                                        ? Border.all(
                                            color: Colors.pink, width: 2)
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
                                          notifications[index].text,
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

  void _showMessageDialog(AppNotification notification) {
    showDialog(
      context: context,
      builder: (context) {
        Widget title;
        Widget content;
        List<Widget> actions;

        switch (notification.type) {
          case 'friend_request':
            title = const Text(
              'Nori draugauti?',
              style: TextStyle(
                color: Colors.deepPurple,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            );
            content = Text(
              notification.text,
              style: const TextStyle(color: Colors.black, fontSize: 16),
            );
            actions = [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FriendsScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Peržiūrėti',
                  style: TextStyle(
                      color: Colors.deepPurple, fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Reject friend request logic
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Uždaryti',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ];
            break;
          case 'shared_goal':
            title = const Text(
              'Nori auginti augaliuką kartu?',
              style: TextStyle(
                color: Colors.purple,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            );
            content = Text(
              notification.text,
              style: const TextStyle(color: Colors.black, fontSize: 16),
            );
            actions = [
              TextButton(
                onPressed: () {
                  // View shared goal logic
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HabitsGoalsScreen(selectedIndex: 2),
                    ),
                  );
                },
                child: const Text(
                  'Peržiūrėti',
                  style: TextStyle(color: Colors.purple),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Uždaryti',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ];
            break;
          default: // Handles "generic" or any unrecognized type
            title = const Text(
              'Pranešimas',
              style: TextStyle(color: Colors.deepPurple, fontSize: 20),
            );
            content = Text(
              notification.text,
              style: const TextStyle(color: Colors.black, fontSize: 16),
            );
            actions = [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Uždaryti',
                  style: TextStyle(color: Colors.deepPurple),
                ),
              ),
            ];
            break;
        }

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          titlePadding: const EdgeInsets.only(left: 16, top: 16, right: 16),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: title),
            ],
          ),
          content: content,
          actions: actions,
        );
      },
    );
  }
}
