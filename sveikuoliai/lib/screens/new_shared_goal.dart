import 'package:flutter/material.dart';
import 'package:sveikuoliai/enums/category_enum.dart';
import 'package:sveikuoliai/models/friendship_model.dart';
import 'package:sveikuoliai/models/goal_task_model.dart';
import 'package:sveikuoliai/models/goal_type_model.dart';
import 'package:sveikuoliai/models/notification_model.dart';
import 'package:sveikuoliai/models/shared_goal_model.dart';
import 'package:sveikuoliai/screens/habits_goals.dart';
import 'package:sveikuoliai/services/auth_services.dart';
import 'package:sveikuoliai/services/friendship_services.dart';
import 'package:sveikuoliai/services/goal_task_services.dart';
import 'package:sveikuoliai/services/goal_type_services.dart';
import 'package:sveikuoliai/services/notification_services.dart';
import 'package:sveikuoliai/services/shared_goal_services.dart';
import 'package:sveikuoliai/widgets/bottom_navigation.dart';
import 'package:sveikuoliai/widgets/custom_snack_bar.dart';

class NewSharedGoalScreen extends StatefulWidget {
  final String username;
  const NewSharedGoalScreen({Key? key, required this.username})
      : super(key: key);

  @override
  _NewSharedGoalScreenState createState() => _NewSharedGoalScreenState();
}

class _NewSharedGoalScreenState extends State<NewSharedGoalScreen> {
  static List<GoalType> defaultGoalTypes = GoalType.defaultGoalTypes;
  static Map<String, IconData> goalIcons = GoalType.goalIcons;
  final AuthService _authService = AuthService();
  bool isDarkMode = false; // Temos būsena
  late String username;

  @override
  void initState() {
    super.initState();
    username = widget.username;
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      Map<String, String?> sessionData = await _authService.getSessionUser();
      if (!mounted) return; // Apsauga prieš setState
      setState(() {
        isDarkMode =
            sessionData['darkMode'] == 'true'; // Gauname darkMode iš sesijos
      });
    } catch (e) {
      if (mounted) {
        String message = 'Klaida gaunant duomenis ❌';
        showCustomSnackBar(context, message, false);
      }
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
      resizeToAvoidBottomInset: false,
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
                      ],
                    ),
                    const SizedBox(height: 50),
                    Text(
                      'Naujas tikslas tarp draugų',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 350,
                      child: PageView(
                        scrollDirection: Axis.horizontal,
                        controller: PageController(viewportFraction: 0.9),
                        children: [
                          ...defaultGoalTypes
                              .where((goal) => goal.tikFriends == true)
                              .map((goal) {
                            return GoalCard(
                              goalId: goal.id,
                              goalName: goal.title,
                              goalDescription: goal.description,
                              isCountable: goal.isCountable,
                              username: username,
                              goalIcon: goalIcons[goal.id] ?? Icons.help,
                              isDarkMode: isDarkMode, // Perduodame isDarkMode
                            );
                          }).toList(),
                          GoalCard(
                            goalId: '',
                            goalName: 'Pridėti savo tikslą',
                            goalDescription: 'Sukurk ir pridėk savo tikslą',
                            goalIcon: Icons.add_circle,
                            isCountable: true,
                            username: username,
                            isCustom: true,
                            isDarkMode: isDarkMode, // Perduodame isDarkMode
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const BottomNavigation(),
            const SizedBox(height: bottomPadding),
          ],
        ),
      ),
    );
  }
}

class GoalCard extends StatefulWidget {
  final String goalId;
  final String goalName;
  final String goalDescription;
  final IconData goalIcon;
  final bool isCountable;
  final bool isCustom;
  final String username;
  final bool isDarkMode; // Pridėtas isDarkMode parametras

  const GoalCard({
    super.key,
    required this.goalId,
    required this.goalName,
    required this.goalDescription,
    required this.goalIcon,
    required this.isCountable,
    required this.username,
    this.isCustom = false,
    required this.isDarkMode, // Pridėtas parametras
  });

  @override
  _GoalCardState createState() => _GoalCardState();
}

class _GoalCardState extends State<GoalCard> {
  late String userUsername;
  String userName = "";
  final GoalTypeService _goalTypeService = GoalTypeService();
  final GoalTaskService _goalTaskService = GoalTaskService();
  final SharedGoalService _sharedGoalService = SharedGoalService();
  final FriendshipService _friendshipService = FriendshipService();
  final AppNotificationService _notificationService = AppNotificationService();
  List<FriendshipModel> friends = [];
  String? _selectedDuration = '1 mėnuo';
  DateTime _startDate = DateTime.now();
  String _selectedFriend = "";

  final TextEditingController _goalNameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _goalDescriptionController =
      TextEditingController();
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _dateController.text = DateTime.now().toString().substring(0, 10);
    userUsername = widget.username;
    _fetchUserFriends(userUsername);
  }

  Future<void> _fetchUserData() async {
    try {
      Map<String, String?> sessionData = await _authService.getSessionUser();
      if (!mounted) return; // Apsauga prieš setState
      setState(() {
        userUsername = sessionData['username'] ?? "Nežinomas";
        userName = sessionData['name'] ?? "Nežinomas";
      });
    } catch (e) {
      if (mounted) {
        String message = 'Klaida gaunant duomenis ❌';
        showCustomSnackBar(context, message, false);
      }
    }
  }

  Future<void> _fetchUserFriends(String username) async {
    try {
      List<FriendshipModel> friendsList =
          await _friendshipService.getUserFriendshipModels(username);
      List<FriendshipModel> friendsListFiltered = friendsList
          .where((friendship) => friendship.friendship.status == 'accepted')
          .toList();
      setState(() {
        friends = friendsListFiltered;
        _selectedFriend = friends.isNotEmpty ? friends[0].friend.username : "";
      });
      print("Draugai: $friends");
    } catch (e) {
      String message = 'Klaida gaunant draugų duomenis ❌';
      if (mounted) {
        showCustomSnackBar(context, message, false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor:
                  widget.isDarkMode ? Colors.grey[800] : Colors.white,
              title: Stack(
                children: [
                  Text(
                    'Užpildykite tikslą:\n${widget.goalName}',
                    style: TextStyle(
                      color: widget.isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: Icon(
                        Icons.close,
                        color:
                            widget.isDarkMode ? Colors.white70 : Colors.black,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        widget.goalDescription,
                        style: TextStyle(
                          color:
                              widget.isDarkMode ? Colors.white70 : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (widget.isCustom)
                        Column(
                          children: [
                            TextFormField(
                              controller: _goalNameController,
                              decoration: InputDecoration(
                                labelText: 'Pavadinimas',
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 10),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: widget.isDarkMode
                                          ? Colors.grey[700]!
                                          : Colors.transparent),
                                ),
                                labelStyle: TextStyle(
                                  color: widget.isDarkMode
                                      ? Colors.white70
                                      : Colors.black,
                                ),
                                errorStyle: TextStyle(fontSize: 11),
                              ),
                              style: TextStyle(
                                color: widget.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Įveskite pavadinimą';
                                }
                                return null;
                              },
                              onChanged: (String newValue) {},
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _goalDescriptionController,
                              decoration: InputDecoration(
                                labelText: 'Aprašymas',
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 10),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: widget.isDarkMode
                                          ? Colors.grey[700]!
                                          : Colors.transparent),
                                ),
                                labelStyle: TextStyle(
                                  color: widget.isDarkMode
                                      ? Colors.white70
                                      : Colors.black,
                                ),
                                errorStyle: TextStyle(fontSize: 11),
                              ),
                              style: TextStyle(
                                color: widget.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Įveskite aprašymą';
                                }
                                return null;
                              },
                              onChanged: (String newValue) {},
                            ),
                          ],
                        ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedDuration,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedDuration = newValue;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Tikslo trukmė',
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: widget.isDarkMode
                                      ? Colors.grey[700]!
                                      : Colors.transparent)),
                          labelStyle: TextStyle(
                            color: widget.isDarkMode
                                ? Colors.white70
                                : Colors.black,
                          ),
                        ),
                        style: TextStyle(
                          color:
                              widget.isDarkMode ? Colors.white : Colors.black,
                        ),
                        dropdownColor:
                            widget.isDarkMode ? Colors.grey[800] : Colors.white,
                        isExpanded: true,
                        items: <String>[
                          '1 savaitė',
                          '2 savaitės',
                          '1 mėnuo',
                          '1,5 menesio',
                          '2 mėnesiai',
                          '3 mėnesiai',
                          '6 mėnesiai'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: Text(
                                value,
                                style: TextStyle(
                                  color: widget.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _dateController,
                        decoration: InputDecoration(
                          labelText: 'Pradžios data',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: widget.isDarkMode
                                  ? Colors.grey[700]!
                                  : Colors.black,
                            ),
                          ),
                          labelStyle: TextStyle(
                            color: widget.isDarkMode
                                ? Colors.white70
                                : Colors.black,
                          ),
                        ),
                        style: TextStyle(
                          color:
                              widget.isDarkMode ? Colors.white : Colors.black,
                        ),
                        readOnly: true,
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: _startDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2101),
                            locale: const Locale('lt', 'LT'),
                          );
                          if (pickedDate != null && pickedDate != _startDate) {
                            setState(() {
                              _startDate = pickedDate;
                              _dateController.text =
                                  _startDate.toString().substring(0, 10);
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedFriend,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedFriend = newValue!;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Pasirink draugą',
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: widget.isDarkMode
                                    ? Colors.grey[700]!
                                    : Colors.transparent),
                          ),
                          labelStyle: TextStyle(
                            color: widget.isDarkMode
                                ? Colors.white70
                                : Colors.black,
                          ),
                        ),
                        style: TextStyle(
                          color:
                              widget.isDarkMode ? Colors.white : Colors.black,
                        ),
                        dropdownColor:
                            widget.isDarkMode ? Colors.grey[800] : Colors.white,
                        isExpanded: true,
                        items:
                            friends.map<DropdownMenuItem<String>>((friendship) {
                          final friendUsername = friendship.friend.username;
                          final friendName = friendship.friend.name;
                          return DropdownMenuItem<String>(
                            value: friendUsername,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: Text(
                                '$friendName (@$friendUsername)',
                                style: TextStyle(
                                  color: widget.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Pasirinkite draugą';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _submitGoal().then((result) {
                              if (result != null) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          HabitsGoalsScreen(selectedIndex: 2)),
                                );
                              }
                            });
                          }
                        },
                        child: Text(
                          'Išsaugoti',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      child: Card(
        color: widget.isDarkMode ? Colors.lightGreen[400] : Color(0xFFbcd979),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.goalIcon,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            Text(
              widget.goalName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.goalDescription,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> createTask(GoalTask task) async {
    try {
      task.userId = userUsername;
      task.id = '${task.id.splitMapJoin(
        RegExp(r'[A-Z]'),
        onMatch: (match) => '',
        onNonMatch: (nonMatch) => nonMatch,
      )}${userUsername[0].toUpperCase() + userUsername.substring(1)}${DateTime.now()}';
      await _goalTaskService.createGoalTaskEntry(task);
      task.userId = _selectedFriend;
      task.id = '${task.title.splitMapJoin(
        RegExp(r'[A-Z]'),
        onMatch: (match) => '',
        onNonMatch: (nonMatch) => nonMatch,
      )}${_selectedFriend[0].toUpperCase() + _selectedFriend.substring(1)}${DateTime.now()}';
      await _goalTaskService.createGoalTaskEntry(task);
      showCustomSnackBar(context, "Tikslo užduotis sėkmingai pridėta ✅", true);
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HabitsGoalsScreen(selectedIndex: 2)),
      );
    } catch (e) {
      showCustomSnackBar(context, "Klaida pridedant tikslo užduotį ❌", false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HabitsGoalsScreen(selectedIndex: 2)),
      );
    }
  }

  Future<SharedGoal?> _submitGoal() async {
    String goalId = widget.isCustom
        ? _goalNameController.text
            .toLowerCase()
            .replaceFirstMapped(
                RegExp(r'(\s[a-z])'), (match) => match.group(0)!.toUpperCase())
            .replaceAll(' ', '')
            .replaceAllMapped(RegExp(r'[ąčęėįšųūž]'), (match) {
            switch (match.group(0)) {
              case 'ą':
                return 'a';
              case 'č':
                return 'c';
              case 'ę':
                return 'e';
              case 'ė':
                return 'e';
              case 'į':
                return 'i';
              case 'š':
                return 's';
              case 'ų':
                return 'u';
              case 'ū':
                return 'u';
              case 'ž':
                return 'z';
              default:
                return match.group(0)!;
            }
          })
        : widget.goalId;

    if (widget.isCustom) {
      GoalType goalData = GoalType(
        id: _goalNameController.text
            .toLowerCase()
            .replaceFirstMapped(
                RegExp(r'(\s[a-z])'), (match) => match.group(0)!.toUpperCase())
            .replaceAll(' ', '')
            .replaceAllMapped(RegExp(r'[ąčęėįšųūž]'), (match) {
          switch (match.group(0)) {
            case 'ą':
              return 'a';
            case 'č':
              return 'c';
            case 'ę':
              return 'e';
            case 'ė':
              return 'e';
            case 'į':
              return 'i';
            case 'š':
              return 's';
            case 'ų':
              return 'u';
            case 'ū':
              return 'u';
            case 'ž':
              return 'z';
            default:
              return match.group(0)!;
          }
        }),
        title: _goalNameController.text,
        description: _goalDescriptionController.text,
        type: "custom",
        isCountable: false,
      );

      try {
        await _goalTypeService.createGoalTypeEntry(goalData);
        print('Tikslas pridėtas! 🎉');
      } catch (e) {
        print("Klaida pridedant tikslą: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Įvyko klaida!')),
        );
      }
    }

    if (userUsername.isEmpty) {
      await _fetchUserData();
    }
    String goalID =
        '${goalId}${userUsername[0].toUpperCase() + userUsername.substring(1)}_friendship$_startDate';

    SharedGoal goalModel = SharedGoal(
      id: goalID,
      startDate: _startDate,
      endDate: _startDate.add(
        Duration(
          days: _selectedDuration == '1 savaitė'
              ? 7
              : _selectedDuration == '2 savaitės'
                  ? 14
                  : _selectedDuration == '1 mėnuo'
                      ? 30
                      : _selectedDuration == '1,5 menesio'
                          ? 45
                          : _selectedDuration == '2 mėnesiai'
                              ? 60
                              : _selectedDuration == '3 mėnesiai'
                                  ? 90
                                  : 180,
        ),
      ),
      points: 0,
      category: CategoryType.bekategorijos,
      endPoints: _selectedDuration == '1 savaitė'
          ? 7
          : _selectedDuration == '2 savaitės'
              ? 14
              : _selectedDuration == '1 mėnuo'
                  ? 30
                  : _selectedDuration == '1,5 menesio'
                      ? 45
                      : _selectedDuration == '2 mėnesiai'
                          ? 60
                          : _selectedDuration == '3 mėnesiai'
                              ? 90
                              : 180,
      user1Id: userUsername,
      user2Id: _selectedFriend,
      isPlantDeadUser1: false,
      isPlantDeadUser2: false,
      goalTypeId: goalId.trim(),
      plantId: _selectedDuration == '1 savaitė'
          ? 'dobiliukas'
          : _selectedDuration == '2 savaitės'
              ? 'ramuneles'
              : _selectedDuration == '1 mėnuo'
                  ? 'zibuokle'
                  : _selectedDuration == '1,5 menesio'
                      ? 'saulegraza'
                      : _selectedDuration == '2 mėnesiai'
                          ? 'orchideja'
                          : _selectedDuration == '3 mėnesiai'
                              ? 'gervuoge'
                              : 'vysnia',
      isCompletedUser1: false,
      isCompletedUser2: false,
      isApproved: false,
    );

    try {
      await _sharedGoalService.createSharedGoalEntry(goalModel);
      if (widget.isCountable) {
        await _goalTaskService.createDefaultTasksForGoal(
          goalId: goalID,
          goalType: goalId,
          username: userUsername,
          isFriend: goalModel.user2Id,
        );
      }
      String message = 'Bendras tikslas pridėtas! 🎉';
      showCustomSnackBar(context, message, true);
      DateTime now = DateTime.now();
      AppNotification notification = AppNotification(
        id: "${_selectedFriend}_$now",
        userId: goalModel.user2Id,
        text:
            'Draugas $userName (@${userUsername}) sukūrė bendrą tikslą! Prisijungsi? 🪁',
        isRead: false,
        date: DateTime.now(),
        type: 'shared_goal',
      );
      await _notificationService.createNotification(notification);
      return goalModel;
    } catch (e) {
      print("Klaida pridedant tikslą: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Įvyko klaida!')),
      );
      return null;
    }
  }
}
