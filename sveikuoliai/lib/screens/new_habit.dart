import 'package:flutter/material.dart';
import 'package:sveikuoliai/enums/category_enum.dart';
import 'package:sveikuoliai/models/habit_model.dart';
import 'package:sveikuoliai/models/habit_type_model.dart';
import 'package:sveikuoliai/screens/habits_goals.dart';
import 'package:sveikuoliai/services/auth_services.dart';
import 'package:sveikuoliai/services/habit_services.dart';
import 'package:sveikuoliai/services/habit_type_services.dart';
import 'package:sveikuoliai/widgets/bottom_navigation.dart';
import 'package:sveikuoliai/widgets/custom_snack_bar.dart';

class NewHabitScreen extends StatelessWidget {
  const NewHabitScreen({super.key});

  static List<HabitType> defaultHabitTypes = HabitType.defaultHabitTypes;
  static Map<String, IconData> habitIcons = HabitType.habitIcons;

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
          children: [
            SizedBox(
              height: topPadding,
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                ),
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
                      'Naujas įprotis',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Karuselė su įpročiais
                    SizedBox(
                      height: 350, // Aukštis karuselei
                      child: PageView(
                        scrollDirection:
                            Axis.horizontal, // Horizontalus slinkimas
                        controller: PageController(
                            viewportFraction: 0.9), // Pagerins sklandumą
                        children: [
                          ...defaultHabitTypes.map((habit) {
                            return HabitCard(
                              habitId: habit.id,
                              habitName: habit.title,
                              habitDescription: habit.description,
                              habitIcon: habitIcons[habit.id] ??
                                  Icons
                                      .help, // Galite naudoti specifinį piktogramą pagal tipą
                            );
                          }).toList(),
                          // Paskutinė kortelė su tikslu
                          HabitCard(
                            habitId: '',
                            habitName: 'Pridėti savo įprotį',
                            habitDescription: 'Sukurk ir pridėk savo įprotį',
                            habitIcon: Icons.add_circle,
                            isCustom:
                                true, // Nurodoma, kad ši kortelė yra paskutinė
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const BottomNavigation(), // Įterpiama navigacija
            const SizedBox(
              height: bottomPadding,
            ),
          ],
        ),
      ),
    );
  }
}

// Atkuriama įpročio kortelė su piktograma, pavadinimu ir aprašymu
class HabitCard extends StatefulWidget {
  final String habitId;
  final String habitName;
  final String habitDescription;
  final IconData habitIcon;
  final bool
      isCustom; // Naujas parametras, kad žinotume, ar tai paskutinė kortelė

  const HabitCard({
    super.key,
    required this.habitId,
    required this.habitName,
    required this.habitDescription,
    required this.habitIcon,
    this.isCustom =
        false, // Jei neapibrėžta, laikome, kad kortelė nėra paskutinė
  });

  @override
  _HabitCardState createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard> {
  String userUsername = "";
  final HabitTypeService _habitTypeService = HabitTypeService();
  final HabitService _habitService = HabitService();
  String? _selectedDuration = '1 mėnuo'; // Pasirinkta trukmė
  DateTime _startDate = DateTime.now(); // Pradžios data

  final TextEditingController _habitNameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dateController.text = DateTime.now().toString().substring(0, 10);
  }

  final TextEditingController _habitDescriptionController =
      TextEditingController();

  final AuthService _authService = AuthService();

  // Funkcija, kad gauti prisijungusio vartotojo duomenis
  Future<void> _fetchUserData() async {
    try {
      Map<String, String?> sessionData = await _authService.getSessionUser();
      setState(
        () {
          userUsername = sessionData['username'] ?? "Nežinomas";
        },
      );
    } catch (e) {
      String message = 'Klaida gaunant duomenis ❌';
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
                  Text('Užpildykite įprotį:\n${widget.habitName}'),
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
                    Text(widget.habitDescription),
                    const SizedBox(height: 20),
                    // Jei tai paskutinė kortelė, naudoti kitus laukus
                    if (widget.isCustom)
                      Column(
                        children: [
                          TextFormField(
                            controller: _habitNameController,
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
                            onChanged: (String newValue) {},
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _habitDescriptionController,
                            decoration: InputDecoration(
                              labelText: 'Aprašymas',
                              floatingLabelBehavior: FloatingLabelBehavior
                                  .always, // Label tekstas visada ant lauko
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent),
                              ),
                            ),
                            maxLines: null, // Leidžia laukui augti pagal turinį
                            minLines: 2,
                            onChanged: (String newValue) {},
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
                        labelText: 'Įpročio trukmė',
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
                      readOnly: true, // Neleidžia redaguoti lauko
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
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        _submitHabit();
                        _dateController.text =
                            _startDate.toString().substring(0, 10);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HabitsGoalsScreen(selectedIndex: 0)),
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
        color: Color(0xFFB388EB), // Kortelės fonas
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
                  color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              widget.habitDescription,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  // Funkcija įrašyti duomenis į duomenų bazę
  Future<void> _submitHabit() async {
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

    // Sukurkite objektą su įpročio duomenimis
    if (widget.isCustom) {
      // Sukurkite objektą su įpročio duomenimis
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
        type: "custom", // Jei tai yra vartotojo sukurtas įprotis
      );

      try {
        await _habitTypeService.createHabitTypeEntry(habitData);
        print('Įprotis pridėtas! 🎉');
        //showCustomSnackBar(context, message, true); // Naudokite funkciją
      } catch (e) {
        print("Klaida pridedant įprotį: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Įvyko klaida!')),
        );
      }
    }

    if (userUsername.isEmpty) {
      await _fetchUserData(); // Palauk, kol gaus vartotojo vardą
    }
    String habitID =
        '${habitId}${userUsername[0].toUpperCase() + userUsername.substring(1)}$_startDate';

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
      isCompleted: false,
      userId: userUsername,
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
      String message = 'Įprotis pridėtas! 🎉';
      showCustomSnackBar(context, message, true); // Naudokite funkciją
    } catch (e) {
      print("Klaida pridedant įprotį: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Įvyko klaida!')),
      );
    }

    // Čia įrašykite kodą, kuris įrašo duomenis į duomenų bazę
    // Pavyzdžiui, naudojant Firebase, SQLite, ar kitą metodą
    //print('Įrašyti į duomenų bazę: $habitData');
  }
}
