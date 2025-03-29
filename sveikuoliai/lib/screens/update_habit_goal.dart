import 'package:flutter/material.dart';
import 'package:sveikuoliai/models/goal_model.dart';
import 'package:sveikuoliai/models/habit_model.dart';
import 'package:sveikuoliai/widgets/bottom_navigation.dart';

class UpdateHabitScreen extends StatefulWidget {
  final HabitInformation habit;
  const UpdateHabitScreen({Key? key, required this.habit}) : super(key: key);

  @override
  _UpdateHabitScreenState createState() => _UpdateHabitScreenState();
}

class _UpdateHabitScreenState extends State<UpdateHabitScreen> {
  String? _selectedDuration;
  DateTime _startDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedDuration = widget.habit.habitModel.endPoints == 7
        ? "1 savaitė"
        : widget.habit.habitModel.endPoints == 14
            ? "2 savaitės"
            : widget.habit.habitModel.endPoints == 30
                ? "1 mėnuo"
                : widget.habit.habitModel.endPoints == 45
                    ? "1,5 mėnesio"
                    : widget.habit.habitModel.endPoints == 60
                        ? "2 mėnesiai"
                        : widget.habit.habitModel.endPoints == 90
                            ? "3 mėnesiai"
                            : "6 mėnesiai";
    _startDate = widget.habit.habitModel.startDate;
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
            Container(
              width: 320,
              height: 600,
              decoration: BoxDecoration(
                color: const Color(0xFFCF9CFF),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white, width: 20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
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
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                    const Text(
                      'Atnaujinti įprotį',
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 40),
                    TextFormField(
                      initialValue: widget.habit.habitType.title,
                      decoration: InputDecoration(
                        labelText: 'Įpročio pavadinimas',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 10),
                        border: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent)),
                      ),
                      onChanged: (String newValue) {
                        // Veiksmas, kai tekstas pasikeičia
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      initialValue: widget.habit.habitType.description,
                      maxLines: null,
                      minLines: 1,
                      decoration: const InputDecoration(
                        labelText: 'Aprašymas',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent)),
                      ),
                      onChanged: (String newValue) {
                        // Veiksmas, kai tekstas pasikeičia
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedDuration,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedDuration = newValue;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Įpročio trukmė',
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent)),
                      ),
                      isExpanded: true,
                      items: <String>[
                        '1 savaitė',
                        '2 savaitės',
                        '1 mėnuo',
                        '1.5 mėnesio',
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
                    TextFormField(
                      controller: TextEditingController(
                          text: '${_startDate.toLocal()}'.split(' ')[0]),
                      decoration: const InputDecoration(
                        labelText: 'Pradžios data',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _startDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _startDate = pickedDate;
                          });
                        }
                      },
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        iconColor: const Color(0xFFCF9CFF), // Violetinė spalva
                      ),
                      child: const Text(
                        'Išsaugoti',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const BottomNavigation(), // Čia reikia įterpti tavo navigaciją
          ],
        ),
      ),
    );
  }
}

class UpdateGoalScreen extends StatefulWidget {
  final GoalInformation goal;
  const UpdateGoalScreen({Key? key, required this.goal}) : super(key: key);

  @override
  _UpdateGoalScreenState createState() => _UpdateGoalScreenState();
}

class _UpdateGoalScreenState extends State<UpdateGoalScreen> {
  String? _selectedDuration;
  DateTime _startDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedDuration = widget.goal.goalModel.endPoints == 7
        ? "1 savaitė"
        : widget.goal.goalModel.endPoints == 14
            ? "2 savaitės"
            : widget.goal.goalModel.endPoints == 30
                ? "1 mėnuo"
                : widget.goal.goalModel.endPoints == 45
                    ? "1,5 mėnesio"
                    : widget.goal.goalModel.endPoints == 60
                        ? "2 mėnesiai"
                        : widget.goal.goalModel.endPoints == 90
                            ? "3 mėnesiai"
                            : "6 mėnesiai";
    _startDate = widget.goal.goalModel.startDate;
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
            Container(
              width: 320,
              height: 600,
              decoration: BoxDecoration(
                color: Color(0xFF72ddf7),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white, width: 20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
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
                      'Atnaujinti tikslą',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),
                    TextFormField(
                      initialValue: widget.goal.goalType.title,
                      decoration: const InputDecoration(
                        labelText: 'Tikslo pavadinimas',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent)),
                      ),
                      onChanged: (String newValue) {
                        // Veiksmas, kai tekstas pasikeičia
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      initialValue: widget.goal.goalType.description,
                      decoration: const InputDecoration(
                        labelText: 'Aprašymas',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent)),
                      ),
                      onChanged: (String newValue) {
                        // Veiksmas, kai tekstas pasikeičia
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedDuration,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedDuration = newValue;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Tikslo trukmė',
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent)),
                      ),
                      isExpanded: true,
                      items: <String>[
                        '1 savaitė',
                        '2 savaitės',
                        '1 mėnuo',
                        '1.5 mėnesio',
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
                    TextFormField(
                      controller: TextEditingController(
                          text: '${_startDate.toLocal()}'.split(' ')[0]),
                      decoration: const InputDecoration(
                        labelText: 'Pradžios data',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _startDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _startDate = pickedDate;
                          });
                        }
                      },
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        iconColor: const Color(0xFF72ddf7), // Violetinė spalva
                      ),
                      child: const Text(
                        'Išsaugoti',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const BottomNavigation(), // Įterpiama navigacija
          ],
        ),
      ),
    );
  }
}
