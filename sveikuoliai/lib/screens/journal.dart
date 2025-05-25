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
  bool isDarkMode = false; // Temos būsena

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
      setState(() {
        userUsername = sessionData['username'] ?? "Nežinomas";
        isDarkMode =
            sessionData['darkMode'] == 'true'; // Gauname darkMode iš sesijos
      });
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
    const double topPadding = 25.0;
    const double bottomPadding = 20.0;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : const Color(0xFF8093F1),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
        backgroundColor: isDarkMode ? Colors.black : const Color(0xFF8093F1),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: topPadding),
            _buildCalendarContainer(context),
            const BottomNavigation(),
            SizedBox(height: bottomPadding),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarContainer(BuildContext context) {
    const double horizontalPadding = 20.0;

    return Expanded(
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
                    color: isDarkMode ? Colors.white : Colors.grey.shade500,
                    size: 50,
                  ),
                ),
              ],
            ),
            _buildBanner(),
            SizedBox(height: 20),
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
          effect: WormEffect(
            dotColor: isDarkMode ? Colors.grey[700]! : Colors.grey,
            activeDotColor: isDarkMode ? Colors.white : Colors.deepPurple,
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
        color: isDarkMode ? Colors.grey[700] : Color(0xFFFCE5FC),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: EdgeInsets.all(5),
      child: TableCalendar(
        locale: 'lt_LT',
        firstDay: DateTime.utc(2020, 01, 01),
        lastDay: DateTime.utc(2025, 12, 31),
        focusedDay: DateTime.now(),
        startingDayOfWeek: StartingDayOfWeek.monday,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextFormatter: (date, locale) =>
              DateFormat.yMMMM('lt_LT').format(date),
          titleTextStyle: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          formatButtonTextStyle: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          leftChevronIcon: Icon(
            Icons.chevron_left,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle:
              TextStyle(color: isDarkMode ? Colors.white70 : Colors.black),
          weekendStyle: TextStyle(
              color: isDarkMode ? Colors.purple[200]! : Colors.purple),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          tablePadding: EdgeInsets.all(10),
          defaultTextStyle:
              TextStyle(color: isDarkMode ? Colors.white70 : Colors.black),
          weekendTextStyle: TextStyle(
              color: isDarkMode ? Colors.purple[200]! : Colors.purple),
          todayDecoration: BoxDecoration(
            color: isDarkMode
                ? Colors.grey[500]
                : Colors.deepPurple.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color:
                isDarkMode ? Colors.white.withOpacity(0.3) : Colors.deepPurple,
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: isDarkMode
                ? Colors.white.withOpacity(0.6)
                : Colors.deepPurple.withOpacity(0.6),
            shape: BoxShape.circle,
          ),
        ),
        rowHeight: 40,
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
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.6)
                        : Colors.deepPurple.withOpacity(0.6),
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
