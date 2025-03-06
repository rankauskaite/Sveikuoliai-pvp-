import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:sveikuoliai/widgets/profile_button.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:sveikuoliai/screens/journal_day.dart';
import 'package:sveikuoliai/widgets/bottom_navigation.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  _JournalPageState createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  @override
  void initState() {
    super.initState();
    initializeDateFormatting(
        'lt_LT', null); // Inicijuojame lietuvišką datų formatą
  }

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
          ProfileButton(),
          _buildBanner(),
          SizedBox(
            height: 50,
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
    return TableCalendar(
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
      rowHeight: 40, // Nustatykite mažesnį aukštį tarp savaičių
      enabledDayPredicate: (day) {
        return day.isBefore(DateTime.now());
      },
      onDaySelected: (selectedDay, focusedDay) {
        if (selectedDay.isBefore(DateTime.now())) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JournalDayPage(selectedDay: selectedDay),
            ),
          );
        }
      },
    );
  }
}
