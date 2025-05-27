import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sveikuoliai/enums/mood_enum.dart';
import 'package:sveikuoliai/models/journal_model.dart';
import 'package:sveikuoliai/models/menstrual_cycle_model.dart';
import 'package:sveikuoliai/models/user_model.dart';
import 'package:sveikuoliai/screens/journal.dart';
import 'package:sveikuoliai/services/auth_services.dart';
import 'package:sveikuoliai/services/backblaze_service.dart';
import 'package:sveikuoliai/services/journal_services.dart';
import 'package:sveikuoliai/services/menstrual_cycle_services.dart';
import 'package:sveikuoliai/services/user_services.dart';
import 'package:sveikuoliai/widgets/bottom_navigation.dart';
import 'package:sveikuoliai/widgets/custom_snack_bar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:sveikuoliai/services/journal_upload_service.dart';

class JournalDayScreen extends StatefulWidget {
  final DateTime selectedDay;

  const JournalDayScreen({super.key, required this.selectedDay});

  @override
  _JournalDayScreenState createState() => _JournalDayScreenState();
}

class _JournalDayScreenState extends State<JournalDayScreen> {
  final JournalService _journalService = JournalService();
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final MenstrualCycleService _menstrualCycleService = MenstrualCycleService();
  final BackblazeService _backblazeService = BackblazeService();
  late DateTime selectedDay;
  MoodType selectedMood = MoodType.neutrali;
  String journalText = '';
  late DateTime menstruationStart;
  DateTime? _tempMenstruationStart;
  int periodLength = 7;
  late DateTime selectedTempDay = selectedDay;
  String userUsername = "";
  File? _selectedImage;
  String? _photoUrl;
  bool isDarkMode = false; // Temos būsena

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    selectedDay = widget.selectedDay;
    menstruationStart = DateTime(2000, 1, 1);
    _fetchUserData();
  }

  @override
  void dispose() {
    _selectedImage = null; // Išvalykite nuotrauką
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    try {
      Map<String, String?> sessionData = await _authService.getSessionUser();
      setState(() {
        userUsername = sessionData['username'] ?? "Nežinomas";
        isDarkMode = sessionData['darkMode'] == 'true'; // Gauname darkMode
      });
      await _fetchJournalEntry(selectedDay);
      UserModel? userModel = await _userService.getUserEntry(userUsername);
      if (userModel != null) {
        setState(() {
          periodLength = userModel.menstrualLength;
        });
      }
      await _fetchMenstrualCycleEntry();
      print("Menstruacijų pradžia: $menstruationStart");
    } catch (e) {
      String message = 'Klaida gaunant duomenis ❌';
      showCustomSnackBar(context, message, false);
    }
  }

  Future<void> _fetchJournalEntry(DateTime date) async {
    try {
      // Gauname visus žurnalo įrašus iš sesijos
      List<JournalModel> journalEntries =
          await _authService.getJournalEntriesFromSession();
      if (journalEntries.isEmpty) {
        // Jei sesija tuščia, rodome pranešimą ir nustatome numatytas reikšmes
        setState(() {
          journalText = '';
          selectedMood = MoodType.neutrali;
          _photoUrl = null;
        });
        showCustomSnackBar(context,
            'Nėra žurnalo įrašų sesijoje, klaida gaunant duomenis ❌', false);
        return;
      }

      // Filtruojame įrašą pagal datą (ignoruojame laiką)
      DateTime targetDate = DateTime.utc(date.year, date.month, date.day);
      JournalModel? entry = journalEntries.firstWhere(
        (e) =>
            DateTime.utc(e.date.year, e.date.month, e.date.day) == targetDate,
        orElse: () => JournalModel(
          id: '',
          userId: userUsername,
          note: '',
          mood: MoodType.neutrali,
          date: targetDate,
        ),
      );

      // Apdorojame photoUrl, jei jis egzistuoja
      String? photoUrl =
          entry.photoUrl?.isNotEmpty == true ? entry.photoUrl : null;
      if (photoUrl != null) {
        final uri = Uri.parse(photoUrl);
        final filePath = uri.pathSegments.skip(2).join('/');
        photoUrl = await _backblazeService.getAuthorizedDownloadUrl(filePath);
        if (photoUrl == null) {
          print('Nepavyko gauti autorizuoto URL nuotraukai: $filePath');
        }
      }

      // Atnaujiname būsena
      setState(() {
        journalText = entry.note;
        selectedMood = entry.mood;
        _photoUrl = photoUrl;
      });
      print('Nuotraukos URL: $_photoUrl');
    } catch (e) {
      showCustomSnackBar(context, 'Klaida gaunant įrašą ❌', false);
      setState(() {
        journalText = '';
        selectedMood = MoodType.neutrali;
        _photoUrl = null;
      });
      print('Klaida _fetchJournalEntry: $e');
    }
  }

  Future<void> _fetchMenstrualCycleEntry() async {
    try {
      List<MenstrualCycle> menstrualCycles =
          await _menstrualCycleService.getUserMenstrualCycles(userUsername);

      if (menstrualCycles.isNotEmpty) {
        menstrualCycles.sort((a, b) => b.startDate.compareTo(a.startDate));
        MenstrualCycle mostRecentCycle = menstrualCycles.first;
        setState(() {
          menstruationStart = mostRecentCycle.startDate;
        });
      } else {
        setState(() {
          menstruationStart = DateTime(2000, 1, 1);
        });
      }
    } catch (e) {}
  }

  Future<void> _saveJournalEntry() async {
    if (journalText.isNotEmpty) {
      String? photoUrl;
      if (_selectedImage != null) {
        photoUrl = await uploadJournalEntry(
          id: "${userUsername}_${selectedDay.year}-${selectedDay.month}-${selectedDay.day}",
          username: userUsername,
          date: selectedDay,
          note: journalText,
          mood: selectedMood,
          photoFile: _selectedImage,
        );
        if (photoUrl == null) {
          if (mounted) {
            showCustomSnackBar(context, 'Nepavyko įkelti nuotraukos ❌', false);
          }
          return;
        }
      }

      JournalModel journalModel = JournalModel(
        id: "${userUsername}_${selectedDay.year}-${selectedDay.month}-${selectedDay.day}",
        userId: userUsername,
        note: journalText,
        photoUrl: photoUrl ?? _photoUrl ?? '',
        mood: selectedMood,
        date: selectedDay,
      );

      await _journalService.createJournalEntry(journalModel);
      await _authService.addJournalentryToSession(journalModel);

      if (_tempMenstruationStart != null) {
        MenstrualCycle menstrualCycle = MenstrualCycle(
          id: "${userUsername}_${widget.selectedDay.year}-${widget.selectedDay.month}-${widget.selectedDay.day}",
          userId: userUsername,
          startDate: _tempMenstruationStart!,
          endDate:
              _tempMenstruationStart!.add(Duration(days: periodLength - 1)),
        );
        await _menstrualCycleService.createMenstrualCycleEntry(menstrualCycle);
        setState(() {
          menstruationStart = _tempMenstruationStart!;
          _tempMenstruationStart = null;
        });
      }

      setState(() {
        _selectedImage = null;
        if (photoUrl != null) _photoUrl = photoUrl;
      });

      if (mounted) {
        String message = 'Įrašas išsaugotas! 🎉';
        showCustomSnackBar(context, message, true);
      }
    } else {
      if (mounted) {
        String message = 'Užpildyk visus laukus!';
        showCustomSnackBar(context, message, false);
      }
    }

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => JournalScreen()));
  }

  Future<void> _selectDate(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        int rowCount = _getRowCountForMonth(selectedDay);
        return Container(
          height: 170 + rowCount * 40.0,
          color: isDarkMode ? Colors.grey[900] : null,
          child: Column(
            children: [
              Expanded(
                child: TableCalendar(
                  firstDay: DateTime(2000),
                  lastDay: DateTime.now(),
                  locale: 'lt_LT',
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  rowHeight: 40,
                  focusedDay: selectedTempDay,
                  selectedDayPredicate: (day) {
                    return day.year == selectedTempDay.year &&
                        day.month == selectedTempDay.month &&
                        day.day == selectedTempDay.day;
                  },
                  onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
                    setState(() {
                      selectedTempDay = selectedDay;
                    });
                    Navigator.pop(context);
                    Future.delayed(Duration(milliseconds: 1), () {
                      _selectDate(context);
                    });
                  },
                  calendarFormat: CalendarFormat.month,
                  availableCalendarFormats: const {
                    CalendarFormat.month: 'Month',
                  },
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    leftChevronIcon: Icon(Icons.arrow_back,
                        color: isDarkMode ? Colors.white : null),
                    rightChevronIcon: Icon(Icons.arrow_forward,
                        color: isDarkMode ? Colors.white : null),
                  ),
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color:
                          isDarkMode ? Colors.purple[300] : Colors.deepPurple,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.purple[400]
                          : Colors.deepPurple[400],
                      shape: BoxShape.circle,
                    ),
                    defaultTextStyle:
                        TextStyle(color: isDarkMode ? Colors.white70 : null),
                    weekendTextStyle:
                        TextStyle(color: isDarkMode ? Colors.white70 : null),
                    holidayTextStyle:
                        TextStyle(color: isDarkMode ? Colors.white70 : null),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Atšaukti',
                        style:
                            TextStyle(color: isDarkMode ? Colors.white : null)),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _tempMenstruationStart = selectedTempDay;
                      });
                      Navigator.pop(context);
                    },
                    child: Text('Gerai',
                        style:
                            TextStyle(color: isDarkMode ? Colors.white : null)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  int _getRowCountForMonth(DateTime date) {
    final lastDayOfMonth = DateTime(date.year, date.month + 1, 0);
    int totalDaysInMonth = lastDayOfMonth.day;
    return (totalDaysInMonth / 7).ceil();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      if (mounted) {
        showCustomSnackBar(
            context, 'Nuotrauka pasirinkta! Išsaugokite ją. 📸', true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime currentDay = DateTime.now();
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double bottomNavigationHeight = 60.0;
          final double availableHeight = constraints.maxHeight -
              topPadding -
              bottomPadding -
              bottomNavigationHeight;

          return Center(
            child: Column(
              children: [
                SizedBox(height: topPadding),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: horizontalPadding),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[900] : Color(0xFFFCE5FC),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color:
                            isDarkMode ? Colors.grey[800]! : Color(0xFFFCE5FC),
                        width: 10,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_left,
                                  color: isDarkMode ? Colors.white : null),
                              onPressed: () {
                                setState(() {
                                  selectedDay =
                                      selectedDay.subtract(Duration(days: 1));
                                });
                                _fetchJournalEntry(selectedDay);
                              },
                            ),
                            Text(
                              _formatDay(selectedDay.day),
                              style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white : null),
                            ),
                            if (!isToday(selectedDay, currentDay))
                              IconButton(
                                icon: Icon(Icons.arrow_right,
                                    color: isDarkMode ? Colors.white : null),
                                onPressed: () {
                                  setState(() {
                                    selectedDay =
                                        selectedDay.add(Duration(days: 1));
                                  });
                                  _fetchJournalEntry(selectedDay);
                                },
                              )
                            else
                              SizedBox(width: 48),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _capitalizeMonth(
                                  DateFormat.MMMM('lt_LT').format(selectedDay)),
                              style: TextStyle(
                                  fontSize: 20,
                                  color: isDarkMode ? Colors.white70 : null),
                            ),
                          ],
                        ),
                        const Divider(thickness: 1, color: Colors.grey),
                        SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 80,
                              height: availableHeight - 140.0,
                              child: ListView(
                                scrollDirection: Axis.vertical,
                                children: [
                                  Text('Šiandien jaučiuosi:',
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: isDarkMode
                                              ? Colors.white70
                                              : null)),
                                  SizedBox(height: 10),
                                  _buildMoodCircle(MoodType.laiminga,
                                      'assets/images/nuotaikos/laiminga.png'),
                                  _buildMoodCircle(MoodType.liudna,
                                      'assets/images/nuotaikos/liudna.png'),
                                  _buildMoodCircle(MoodType.pikta,
                                      'assets/images/nuotaikos/pikta.png'),
                                  _buildMoodCircle(MoodType.pavargusi,
                                      'assets/images/nuotaikos/pavargusi.png'),
                                  _buildMoodCircle(MoodType.motyvuota,
                                      'assets/images/nuotaikos/motyvuota.png'),
                                  _buildMoodCircle(MoodType.ryztinga,
                                      'assets/images/nuotaikos/ryztinga.png'),
                                  _buildMoodCircle(MoodType.suglumusi,
                                      'assets/images/nuotaikos/suglumusi.png'),
                                  _buildMoodCircle(MoodType.kuribinga,
                                      'assets/images/nuotaikos/kurybinga.png'),
                                  _buildMoodCircle(MoodType.patenkinta,
                                      'assets/images/nuotaikos/patenkinta.png'),
                                  _buildMoodCircle(MoodType.sunerimusi,
                                      'assets/images/nuotaikos/stresuojanti.png'),
                                  _buildMoodCircle(MoodType.zaisminga,
                                      'assets/images/nuotaikos/zaisminga.png'),
                                ],
                              ),
                            ),
                            Container(
                              height: availableHeight - 140.0,
                              width: 1,
                              color:
                                  isDarkMode ? Colors.grey[700]! : Colors.grey,
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  SizedBox(height: 10),
                                  Container(
                                    width: 200,
                                    height: 110,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.asset(
                                        'assets/images/dienorascio_vizualas.png',
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: GestureDetector(
                                      onTap: () {
                                        String tempText = journalText;
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: isDarkMode
                                              ? Colors.grey[900]
                                              : null,
                                          builder: (BuildContext context) {
                                            return Padding(
                                              padding: EdgeInsets.only(
                                                bottom: MediaQuery.of(context)
                                                    .viewInsets
                                                    .bottom,
                                                left: 20,
                                                right: 20,
                                                top: 20,
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  TextField(
                                                    maxLines: null,
                                                    autofocus: true,
                                                    onChanged: (value) {
                                                      tempText = value;
                                                    },
                                                    style: TextStyle(
                                                        color: isDarkMode
                                                            ? Colors.white
                                                            : null),
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          'Rašykite čia...',
                                                      hintStyle: TextStyle(
                                                          color: isDarkMode
                                                              ? Colors.grey[500]
                                                              : null),
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      filled: true,
                                                      fillColor: isDarkMode
                                                          ? Colors.grey[800]
                                                          : Colors.white,
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          isDarkMode
                                                              ? Colors.grey[700]
                                                              : null,
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        journalText = tempText;
                                                      });
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text('Išsaugoti',
                                                        style: TextStyle(
                                                            color: isDarkMode
                                                                ? Colors.white
                                                                : null)),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      child: Container(
                                        height: 115,
                                        decoration: BoxDecoration(
                                          color: isDarkMode
                                              ? Colors.grey[800]
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: isDarkMode
                                                  ? Colors.grey[700]!
                                                  : Colors.transparent,
                                              width: 1),
                                        ),
                                        child: Center(
                                          child: Text(
                                            journalText.isEmpty
                                                ? 'Įrašyk savo mintis\n································\n································\n································'
                                                : journalText,
                                            style: TextStyle(
                                                color: isDarkMode
                                                    ? Colors.purple[300]
                                                    : Color(0xFFB388EB),
                                                fontSize: 18),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  (_photoUrl != null || _selectedImage != null)
                                      ? Container(
                                          width: 200,
                                          height: 150,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                                color: isDarkMode
                                                    ? Colors.purple[700]!
                                                    : Colors
                                                        .deepPurple.shade200),
                                            boxShadow: [
                                              BoxShadow(
                                                color: isDarkMode
                                                    ? Colors.black
                                                        .withOpacity(0.3)
                                                    : Colors.black
                                                        .withOpacity(0.05),
                                                spreadRadius: 2,
                                                blurRadius: 8,
                                                offset: Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            child: _selectedImage != null
                                                ? Image.file(
                                                    _selectedImage!,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return Center(
                                                        child: Text(
                                                          'Klaida įkeliant nuotrauką',
                                                          style: TextStyle(
                                                              color: isDarkMode
                                                                  ? Colors
                                                                      .red[300]
                                                                  : Colors.red),
                                                        ),
                                                      );
                                                    },
                                                  )
                                                : CachedNetworkImage(
                                                    imageUrl: _photoUrl!,
                                                    fit: BoxFit.cover,
                                                    placeholder:
                                                        (context, url) =>
                                                            Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        color: isDarkMode
                                                            ? Colors.purple[300]
                                                            : null,
                                                      ),
                                                    ),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Center(
                                                      child: Text(
                                                        'Klaida įkeliant nuotrauką',
                                                        style: TextStyle(
                                                            color: isDarkMode
                                                                ? Colors
                                                                    .red[300]
                                                                : Colors.red),
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                        )
                                      : GestureDetector(
                                          onTap: _pickImage,
                                          child: Container(
                                            width: 200,
                                            height: (_photoUrl != null ||
                                                    _selectedImage != null)
                                                ? 250
                                                : 150,
                                            decoration: BoxDecoration(
                                              color: isDarkMode
                                                  ? Colors.grey[800]
                                                  : Colors.deepPurple.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                  color: isDarkMode
                                                      ? Colors.purple[700]!
                                                      : Colors
                                                          .deepPurple.shade200),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: isDarkMode
                                                      ? Colors.black
                                                          .withOpacity(0.3)
                                                      : Colors.black
                                                          .withOpacity(0.05),
                                                  spreadRadius: 2,
                                                  blurRadius: 8,
                                                  offset: Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.add_a_photo,
                                                    size: 50,
                                                    color: isDarkMode
                                                        ? Colors.purple[300]
                                                        : Colors
                                                            .deepPurple[300]),
                                                SizedBox(height: 10),
                                                Text(
                                                  'Įkelti nuotrauką',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      color: isDarkMode
                                                          ? Colors.purple[300]
                                                          : Colors
                                                              .deepPurple[300]),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                  SizedBox(height: 10),
                                  if ((_tempMenstruationStart != null &&
                                          !selectedDay.isBefore(
                                              _tempMenstruationStart!) &&
                                          selectedDay.isBefore(
                                              _tempMenstruationStart!.add(
                                                  Duration(
                                                      days: periodLength)))) ||
                                      (_tempMenstruationStart != null &&
                                          selectedDay ==
                                              _tempMenstruationStart!.add(Duration(
                                                  days: periodLength - 1))) ||
                                      (menstruationStart.year > 2000 &&
                                          !selectedDay
                                              .isBefore(menstruationStart) &&
                                          selectedDay.isBefore(menstruationStart.add(
                                              Duration(days: periodLength)))) ||
                                      (menstruationStart.year > 2000 &&
                                          selectedDay ==
                                              menstruationStart.add(Duration(
                                                  days: periodLength - 1))))
                                    Text(
                                      'Šiandien yra ${selectedDay.difference(_tempMenstruationStart ?? menstruationStart).inDays + 1} mėnesinių diena',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode
                                            ? Colors.purple[300]
                                            : Colors.deepPurple,
                                      ),
                                    )
                                  else
                                    GestureDetector(
                                      onTap: () => _selectDate(context),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isDarkMode
                                              ? Colors.grey[800]
                                              : Colors.deepPurple.shade50,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                              color: isDarkMode
                                                  ? Colors.purple[700]!
                                                  : Colors.deepPurple.shade200),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.calendar_today,
                                                color: isDarkMode
                                                    ? Colors.purple[300]
                                                    : Colors.deepPurple,
                                                size: 16),
                                            SizedBox(width: 8),
                                            Text(
                                              'Pažymėti mėnesines',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: isDarkMode
                                                    ? Colors.purple[300]
                                                    : Colors.deepPurple,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  SizedBox(height: 5),
                                  SizedBox(
                                    width: 150,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isDarkMode
                                            ? Colors.grey[700]
                                            : null,
                                      ),
                                      onPressed: () {
                                        setState(() {});
                                        _saveJournalEntry();
                                      },
                                      child: Text(
                                        'Išsaugoti',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: isDarkMode
                                                ? Colors.white
                                                : null),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const BottomNavigation(),
                SizedBox(height: bottomPadding),
              ],
            ),
          );
        },
      ),
    );
  }

  bool isToday(DateTime selectedDay, DateTime currentDay) {
    return selectedDay.year == currentDay.year &&
        selectedDay.month == currentDay.month &&
        selectedDay.day == currentDay.day;
  }

  String _capitalizeMonth(String month) {
    return month[0].toUpperCase() + month.substring(1);
  }

  String _formatDay(int day) {
    return day.toString().padLeft(2, "0");
  }

  Widget _buildMoodCircle(MoodType mood, String imageUrl) {
    bool isSelected = selectedMood == mood;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMood = mood;
        });
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 37,
            backgroundColor: isSelected
                ? (isDarkMode ? Colors.purple[400] : Colors.deepPurple)
                : (isDarkMode ? Colors.grey[800] : Color(0xFFFCE5FC)),
            child: Image.asset(imageUrl, width: 70, height: 70),
          ),
          Text(mood.toDisplayName(),
              style: TextStyle(
                  fontSize: 16, color: isDarkMode ? Colors.white70 : null),
              textAlign: TextAlign.center),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
