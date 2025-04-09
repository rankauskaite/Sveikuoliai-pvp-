import 'package:flutter/material.dart';
import 'package:sveikuoliai/enums/category_enum.dart';
import 'package:sveikuoliai/models/friendship_model.dart';
import 'package:sveikuoliai/models/goal_type_model.dart';
import 'package:sveikuoliai/models/shared_goal_model.dart';
import 'package:sveikuoliai/screens/habits_goals.dart';
import 'package:sveikuoliai/services/auth_services.dart';
import 'package:sveikuoliai/services/friendship_services.dart';
import 'package:sveikuoliai/services/goal_type_services.dart';
import 'package:sveikuoliai/services/shared_goal_services.dart';
import 'package:sveikuoliai/widgets/bottom_navigation.dart';
import 'package:sveikuoliai/widgets/custom_snack_bar.dart';

class NewSharedGoalScreen extends StatelessWidget {
  final String username;
  const NewSharedGoalScreen({Key? key, required this.username})
      : super(key: key);

  static List<GoalType> defaultGoalTypes = GoalType.defaultGoalTypes;
  static Map<String, IconData> goalIcons = GoalType.goalIcons;

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
                    ],
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  const Text(
                    'Naujas tikslas tarp draugų',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // Karuselė su tikslais
                  SizedBox(
                    height: 300, // Aukštis karuselei
                    child: PageView(
                      scrollDirection:
                          Axis.horizontal, // Horizontalus slinkimas
                      controller: PageController(
                          viewportFraction: 0.9), // Pagerins sklandumą
                      children: [
                        ...defaultGoalTypes.map((goal) {
                          return GoalCard(
                            goalId: goal.id,
                            goalName: goal.title,
                            goalDescription: goal.description,
                            isCountable: goal.isCountable,
                            username: username,
                            goalIcon: goalIcons[goal.id] ??
                                Icons
                                    .help, // Galite naudoti specifinį piktogramą pagal tipą
                          );
                        }).toList(),
                        // Paskutinė kortelė su tikslu
                        GoalCard(
                          goalId: '',
                          goalName: 'Pridėti savo tikslą',
                          goalDescription: 'Sukurk ir pridėk savo tikslą',
                          goalIcon: Icons.add_circle,
                          isCountable: true,
                          username: username,
                          isCustom:
                              true, // Nurodoma, kad ši kortelė yra paskutinė
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const BottomNavigation(), // Įterpiama navigacija
          ],
        ),
      ),
    );
  }
}

// Atkuriama tikslo kortelė su piktograma, pavadinimu ir aprašymu
class GoalCard extends StatefulWidget {
  final String goalId;
  final String goalName;
  final String goalDescription;
  final IconData goalIcon;
  final bool isCountable;
  final bool
      isCustom; // Naujas parametras, kad žinotume, ar tai paskutinė kortelė
  final String username;

  const GoalCard({
    super.key,
    required this.goalId,
    required this.goalName,
    required this.goalDescription,
    required this.goalIcon,
    required this.isCountable,
    required this.username,
    this.isCustom =
        false, // Jei neapibrėžta, laikome, kad kortelė nėra paskutinė
  });

  @override
  _GoalCardState createState() => _GoalCardState();
}

class _GoalCardState extends State<GoalCard> {
  late String userUsername;
  final GoalTypeService _goalTypeService = GoalTypeService();
  final SharedGoalService _sharedGoalService = SharedGoalService();
  final FriendshipService _friendshipService = FriendshipService();
  List<FriendshipModel> friends = [];
  String? _selectedDuration = '1 mėnuo'; // Pasirinkta trukmė
  DateTime _startDate = DateTime.now(); // Pradžios data
  String _selectedFriend = "";

  final TextEditingController _goalNameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dateController.text = DateTime.now().toString().substring(0, 10);
    userUsername = widget.username;
    _fetchUserFriends(userUsername);
  }

  final TextEditingController _goalDescriptionController =
      TextEditingController();

  final AuthService _authService = AuthService();

  // Funkcija, kad gauti prisijungusio vartotojo duomenis
  Future<void> _fetchUserData() async {
    try {
      Map<String, String?> sessionData = await _authService.getSessionUser();

      if (!mounted) return; // <- Apsauga prieš setState
      setState(() {
        userUsername = sessionData['username'] ?? "Nežinomas";
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
      setState(() {
        friends = friendsList;
        _selectedFriend = friends.isNotEmpty ? friends[0].friend.username : "";
      });
      print("Draugai: $friends");
    } catch (e) {
      String message = 'Klaida gaunant draugų duomenis ❌';
      showCustomSnackBar(context, message, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Paspaudus ant kortelės, atidarome formą
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Stack(
                children: [
                  Text('Užpildykite tikslą:\n${widget.goalName}'),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.pop(context); // Uždaryti dialogą
                      },
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(widget.goalDescription),
                    const SizedBox(height: 20),
                    // Jei tai paskutinė kortelė, naudoti kitus laukus
                    if (widget.isCustom)
                      Column(
                        children: [
                          TextFormField(
                            controller: _goalNameController,
                            decoration: InputDecoration(
                              labelText: 'Pavadinimas',
                              floatingLabelBehavior: FloatingLabelBehavior
                                  .always, // Label tekstas visada ant lauko
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 0,
                                  horizontal:
                                      10), // Lygiavimas su kitais laukais
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.transparent), // Nematoma riba
                              ),
                            ),
                            onChanged: (String newValue) {
                              // Veiksmas, kai tekstas pasikeičia
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _goalDescriptionController,
                            decoration: InputDecoration(
                              labelText: 'Aprašymas',
                              floatingLabelBehavior: FloatingLabelBehavior
                                  .always, // Label tekstas visada ant lauko
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 10),
                              border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent),
                              ),
                            ),
                            onChanged: (String newValue) {
                              // Veiksmas, kai tekstas pasikeičia
                            },
                          ),
                        ],
                      ),
                    const SizedBox(height: 10),
                    // Trukmės pasirinkimas su dekoracija
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
                            borderSide: BorderSide(color: Colors.transparent)),
                      ),
                      isExpanded: true, // Užima visą plotį
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
                            child: Text(value),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    // Pradžios datos pasirinkimas
                    TextFormField(
                      controller: _dateController,
                      decoration: const InputDecoration(
                        labelText: 'Pradžios data',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _startDate,
                          firstDate: DateTime
                              .now(), // Neleidžia pasirinkti ankstesnių datų
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
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                      ),
                      isExpanded: true,
                      items:
                          friends.map<DropdownMenuItem<String>>((friendship) {
                        final friendUsername = friendship.friend.username;
                        final friendName = friendship.friend.name;
                        return DropdownMenuItem<String>(
                          value: friendUsername,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Text('$friendName (@$friendUsername)'),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        _submitGoal();
                        _dateController.text =
                            _startDate.toString().substring(0, 10);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HabitsGoalsScreen()),
                        );
                      },
                      child: const Text('Išsaugoti'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: Card(
        color: Color(0xFFbcd979), // Kortelės fonas
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.goalIcon,
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            Text(
              widget.goalName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              widget.goalDescription,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  // Funkcija įrašyti duomenis į duomenų bazę
  Future<void> _submitGoal() async {
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

    // Sukurkite objektą su įpročio duomenimis
    if (widget.isCustom) {
      // Sukurkite objektą su įpročio duomenimis
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
        type: "custom", // Jei tai yra vartotojo sukurtas įprotis
        isCountable: true,
      );

      try {
        await _goalTypeService.createGoalTypeEntry(goalData);
        print('Tikslas pridėtas! 🎉');
        //showCustomSnackBar(context, message, true); // Naudokite funkciją
      } catch (e) {
        print("Klaida pridedant tikslą: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Įvyko klaida!')),
        );
      }
    }

    if (userUsername.isEmpty) {
      await _fetchUserData(); // Palauk, kol gaus vartotojo vardą
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
                  : _selectedDuration == '3 mėnesiai'
                      ? 90
                      : 180,
      user1Id: userUsername,
      user2Id: _selectedFriend,
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
      isCountable: widget.isCountable,
    );

    try {
      await _sharedGoalService.createSharedGoalEntry(goalModel);
      String message = 'Bendras tikslas pridėtas! 🎉';
      showCustomSnackBar(context, message, true); // Naudokite funkciją
    } catch (e) {
      print("Klaida pridedant tikslą: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Įvyko klaida!')),
      );
    }

    // Čia įrašykite kodą, kuris įrašo duomenis į duomenų bazę
    // Pavyzdžiui, naudojant Firebase, SQLite, ar kitą metodą
    //print('Įrašyti į duomenų bazę: $habitData');
  }
}
