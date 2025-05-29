import 'package:flutter/material.dart';
import 'package:sveikuoliai/models/habit_model.dart';
import 'package:sveikuoliai/models/habit_type_model.dart';
import 'package:sveikuoliai/screens/habits_goals.dart';
import 'package:sveikuoliai/services/auth_services.dart';
import 'package:sveikuoliai/services/habit_services.dart';
import 'package:sveikuoliai/services/habit_type_services.dart';
import 'package:sveikuoliai/widgets/bottom_navigation.dart';
import 'package:sveikuoliai/widgets/custom_snack_bar.dart';

class NewHabitScreen extends StatefulWidget {
  const NewHabitScreen({super.key});

  @override
  _NewHabitScreenState createState() => _NewHabitScreenState();
}

class _NewHabitScreenState extends State<NewHabitScreen> {
  static List<HabitType> defaultHabitTypes = HabitType.defaultHabitTypes;
  static Map<String, IconData> habitIcons = HabitType.habitIcons;
  final AuthService _authService = AuthService();
  bool isDarkMode = false; // Temos būsena
  String userUsername = "";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      Map<String, String?> sessionData = await _authService.getSessionUser();
      setState(() {
        userUsername = sessionData['username'] ?? "";
        isDarkMode =
            sessionData['darkMode'] == 'true'; // Gauname darkMode iš sesijos
      });
    } catch (e) {
      String message = 'Klaida gaunant duomenis ❌';
      showCustomSnackBar(context, message, false);
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
                margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
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
                      'Naujas įprotis',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 350,
                      child: PageView(
                        scrollDirection: Axis.horizontal,
                        controller: PageController(viewportFraction: 0.9),
                        children: [
                          ...defaultHabitTypes.map((habit) {
                            return HabitCard(
                              habitId: habit.id,
                              habitName: habit.title,
                              habitDescription: habit.description,
                              habitIcon: habitIcons[habit.id] ?? Icons.help,
                              isDarkMode: isDarkMode, // Perduodame isDarkMode
                              userUsername: userUsername,
                            );
                          }).toList(),
                          HabitCard(
                            habitId: '',
                            habitName: 'Pridėti savo įprotį',
                            habitDescription: 'Sukurk ir pridėk savo įprotį',
                            habitIcon: Icons.add_circle,
                            isCustom: true,
                            isDarkMode: isDarkMode, // Perduodame isDarkMode
                            userUsername: userUsername,
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

class HabitCard extends StatefulWidget {
  final String habitId;
  final String habitName;
  final String habitDescription;
  final IconData habitIcon;
  final bool isCustom;
  final bool isDarkMode; // Pridėtas isDarkMode parametras
  final String userUsername;

  const HabitCard({
    super.key,
    required this.userUsername,
    required this.habitId,
    required this.habitName,
    required this.habitDescription,
    required this.habitIcon,
    this.isCustom = false,
    required this.isDarkMode, // Pridėtas parametras
  });

  @override
  _HabitCardState createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard> {
  final HabitTypeService _habitTypeService = HabitTypeService();
  final HabitService _habitService = HabitService();
  String? _selectedDuration = '1 mėnuo';
  DateTime _startDate = DateTime.now();
  final TextEditingController _habitNameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _habitDescriptionController =
      TextEditingController();
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _dateController.text = DateTime.now().toString().substring(0, 10);
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
                    'Užpildykite įprotį:\n${widget.habitName}',
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
                        widget.habitDescription,
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
                              controller: _habitNameController,
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
                              controller: _habitDescriptionController,
                              decoration: InputDecoration(
                                labelText: 'Aprašymas',
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10),
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
                              maxLines: null,
                              minLines: 1,
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
                          labelText: 'Įpročio trukmė',
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
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            HabitModel? result = await _submitHabit();
                            if (result != null) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        HabitsGoalsScreen(selectedIndex: 0)),
                              );
                            }
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
        color: widget.isDarkMode ? Colors.purple[300] : Color(0xFFB388EB),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.habitIcon,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            Text(
              widget.habitName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.habitDescription,
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

  Future<HabitModel?> _submitHabit() async {
    String habitId = widget.isCustom
        ? _habitNameController.text
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
        : widget.habitId;

    if (widget.isCustom) {
      HabitType habitData = HabitType(
        id: _habitNameController.text
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
        title: _habitNameController.text,
        description: _habitDescriptionController.text,
        type: "custom",
      );

      try {
        await _habitTypeService.createHabitTypeEntry(habitData);
        print('Įprotis pridėtas! 🎉');
      } catch (e) {
        print("Klaida pridedant įprotį: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Įvyko klaida!')),
        );
      }
    }

    String habitID =
        '${habitId}${widget.userUsername[0].toUpperCase() + widget.userUsername.substring(1)}$_startDate';

    HabitModel habitModel = HabitModel(
      id: habitID,
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
      isCompleted: false,
      userId: widget.userUsername,
      habitTypeId: habitId.trim(),
      isPlantDead: false,
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
    );

    try {
      await _habitService.createHabitEntry(habitModel);
      HabitType? habitType =
          await _habitTypeService.getHabitTypeById(habitModel.habitTypeId);
      if (habitType == null) {
        throw Exception(
            'HabitType not found for id: ${habitModel.habitTypeId}');
      }
      HabitInformation habitInformation =
          HabitInformation(habitModel: habitModel, habitType: habitType);
      await _authService.addHabitToSession(habitInformation);
      String message = 'Įprotis pridėtas! 🎉';
      showCustomSnackBar(context, message, true);
      return habitModel;
    } catch (e) {
      print("Klaida pridedant įprotį: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Įvyko klaida!')),
      );
    }
    return null;
  }
}
