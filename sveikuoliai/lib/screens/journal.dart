import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:sveikuoliai/screens/meditation.dart';
import 'package:sveikuoliai/services/auth_services.dart';
import 'package:sveikuoliai/services/journal_services.dart';
import 'package:sveikuoliai/widgets/custom_snack_bar.dart';
import 'package:sveikuoliai/widgets/profile_button.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:sveikuoliai/screens/journal_day.dart';
import 'package:sveikuoliai/widgets/bottom_navigation.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  _JournalScreenState createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  AuthService _authService = AuthService();
  JournalService _journalService = JournalService();
  String userUsername = '';
  Set<DateTime> _markedDays = {};

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    initializeDateFormatting(
        'lt_LT', null); // Inicijuojame lietuvišką datų formatą
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
      await _loadMarkedDays(userUsername);
    } catch (e) {
      String message = 'Klaida gaunant duomenis ❌';
      showCustomSnackBar(context, message, false);
    }
  }

  Future<void> _loadMarkedDays(String username) async {
    // Čia gautųsi duomenys iš Firestore ar kito šaltinio
    List<DateTime> savedDates =
        await _journalService.getSavedJournalEntries(username);

    setState(() {
      _markedDays = savedDates.toSet();
    });
  }

  // Future<List<DateTime>> getSavedJournalEntries() async {
  //   // Simuliacija, bet čia turėtum iš DB paimti realias dienas, kai buvo užpildyta
  //   return [
  //     DateTime.utc(2025, 03, 28),
  //     DateTime.utc(2025, 03, 30),
  //     DateTime.utc(2025, 04, 01),
  //   ];
  // }

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
            _buildCalendarContainer(context),
            const BottomNavigation(), // Apatinė navigacija
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarContainer(BuildContext context) {
    return Container(
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
            children: [
              ProfileButton(),
              const Expanded(child: SizedBox()),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MeditationScreen()),
                  );
                },
                icon: const Icon(
                  Icons.self_improvement,
                  color: Color(0xFFD9D9D5),
                  size: 50,
                ),
              ),
              // IconButton(
              //   onPressed: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (context) => LoadingScreen()),
              //     );
              //   },
              //   icon: Icon(
              //     Icons.create,
              //     size: 30,
              //   ),
              // ),
            ],
          ),
          _buildBanner(),
          SizedBox(
            height: 30,
          ),
          _buildCalendar(context),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 250,
          height: 100,
          color: const Color(0xFFD9D9D9),
          child: const Center(
            child: Text(
              'Vizualas su užrašu dienoraštis (?) Jei ką - papildomas reklamos plotas',
              style: TextStyle(fontSize: 20, color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFFCE5FC), // Šviesiai rožinis fonas visam kalendoriui
        borderRadius: BorderRadius.circular(15), // Užapvalinti kampai
      ),
      padding: EdgeInsets.all(5), // Kad būtų tarpai nuo kraštų
      child: TableCalendar(
        locale: 'lt_LT', // Kalendorius lietuviškai
        firstDay: DateTime.utc(2020, 01, 01),
        lastDay: DateTime.utc(2025, 12, 31),
        focusedDay: DateTime.now(),
        startingDayOfWeek:
            StartingDayOfWeek.monday, // Pirmadienis kaip savaitės pradžia
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextFormatter: (date, locale) =>
              DateFormat.yMMMM('lt_LT').format(date), // Lietuviški mėnesiai
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(color: Colors.black),
          weekendStyle: TextStyle(color: Colors.purple),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false, // Paslepia kitų mėnesių dienas
          tablePadding: EdgeInsets.all(10), // Papildomi tarpai lentelės viduje
          defaultTextStyle:
              TextStyle(color: Colors.black), // Dienų skaičių spalva
          weekendTextStyle:
              TextStyle(color: Colors.purple), // Savaitgalių spalva
        ),
        rowHeight: 40, // Nustatykite mažesnį aukštį tarp savaičių
        enabledDayPredicate: (day) {
          return day.isBefore(DateTime.now());
        },
        onDaySelected: (selectedDay, focusedDay) {
          if (selectedDay.isBefore(DateTime.now())) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    JournalDayScreen(selectedDay: selectedDay),
              ),
            );
          }
        },
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (_markedDays.any((markedDay) =>
                markedDay.year == date.year &&
                markedDay.month == date.month &&
                markedDay.day == date.day)) {
              return Positioned(
                bottom: 5,
                child: Text(
                  '✓',
                  style: TextStyle(
                    color: Colors.deepPurple.withOpacity(0.6),
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }
            return SizedBox();
          },
        ),
      ),
    );
  }
}
