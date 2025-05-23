import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:sveikuoliai/screens/relax_menu.dart';
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
  PageController _pageController = PageController();
  final List<String> images = [
    'assets/images/virsKalendoriaus/eziukai.png',
    'assets/images/virsKalendoriaus/katukas.png',
    'assets/images/virsKalendoriaus/kiaules.png',
    'assets/images/virsKalendoriaus/suniuks.png',
    'assets/images/virsKalendoriaus/zuikuciai.png',
  ];
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    initializeDateFormatting(
        'lt_LT', null); // Inicijuojame lietuvišką datų formatą
    _startAutoSwitch();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer to prevent memory leaks
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSwitch() {
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      if (mounted) {
        setState(() {
          _currentPage = (_currentPage + 1) % images.length;
        });
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 900),
          curve: Curves.easeInOut,
        );
      }
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

  @override
  Widget build(BuildContext context) {
    // Fiksuoti tarpai
    const double topPadding = 25.0; // Tarpas nuo viršaus
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
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: topPadding,
            ),
            _buildCalendarContainer(context),
            const BottomNavigation(), // Apatinė navigacija
            SizedBox(
              height: bottomPadding,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarContainer(BuildContext context) {
    const double horizontalPadding = 20.0; // Tarpai iš šonų

    return Expanded(
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
              children: [
                ProfileButton(),
                const Expanded(child: SizedBox()),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RelaxMenuScreen()),
                    );
                  },
                  icon: Icon(
                    Icons.self_improvement,
                    color: Colors.grey.shade500, //Color(0xFFD9D9D5),
                    size: 50,
                  ),
                ),
              ],
            ),
            _buildBanner(),
            SizedBox(
              height: 20,
            ),
            _buildCalendar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return Column(
      children: [
        SizedBox(height: 10),
        Container(
          height: 120,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: PageView.builder(
              controller: _pageController,
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Image.asset(
                  images[index],
                  fit: BoxFit.fill,
                  width: 250,
                );
              },
              scrollDirection: Axis.horizontal,
              pageSnapping: true,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
            ),
          ),
        ),
        SizedBox(height: 5),
        SmoothPageIndicator(
          controller: _pageController,
          count: images.length,
          effect: const WormEffect(
            dotColor: Colors.grey,
            activeDotColor: Colors.deepPurple,
            dotHeight: 6,
            dotWidth: 6,
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
