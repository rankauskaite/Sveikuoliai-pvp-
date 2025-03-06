import 'package:flutter/material.dart';
import 'package:sveikuoliai/widgets/bottom_navigation.dart';

class HabitPage extends StatelessWidget {
  const HabitPage({super.key});

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
                    'Naujas įprotis',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Karuselė su įpročiais
                  SizedBox(
                    height: 300, // Aukštis karuselei
                    child: PageView(
                      scrollDirection:
                          Axis.horizontal, // Horizontalus slinkimas
                      controller: PageController(
                          viewportFraction: 0.9), // Pagerins sklandumą
                      children: [
                        HabitCard(
                          habitName: 'Įprotis 1',
                          habitDescription: 'Aprašymas 1...',
                          habitIcon: Icons.fitness_center,
                        ),
                        HabitCard(
                          habitName: 'Įprotis 2',
                          habitDescription: 'Aprašymas 2...',
                          habitIcon: Icons.local_drink,
                        ),
                        HabitCard(
                          habitName: 'Įprotis 3',
                          habitDescription: 'Aprašymas 3...',
                          habitIcon: Icons.run_circle,
                        ),
                        HabitCard(
                          habitName: 'Įprotis 4',
                          habitDescription: 'Aprašymas 4...',
                          habitIcon: Icons.self_improvement,
                        ),
                        HabitCard(
                          habitName: 'Pridėti savo įprotį',
                          habitDescription: 'Sukurk ir pridėk savo įprotį',
                          habitIcon: Icons.add_circle,
                          isLast:
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

// Atkuriama įpročio kortelė su piktograma, pavadinimu ir aprašymu
class HabitCard extends StatefulWidget {
  final String habitName;
  final String habitDescription;
  final IconData habitIcon;
  final bool
      isLast; // Naujas parametras, kad žinotume, ar tai paskutinė kortelė

  const HabitCard({
    super.key,
    required this.habitName,
    required this.habitDescription,
    required this.habitIcon,
    this.isLast = false, // Jei neapibrėžta, laikome, kad kortelė nėra paskutinė
  });

  @override
  _HabitCardState createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard> {
  String? _selectedDuration = '1 mėnesį'; // Pasirinkta trukmė
  DateTime _startDate = DateTime.now(); // Pradžios data

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
                    if (widget.isLast)
                      Column(
                        children: [
                          TextFormField(
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
                        '1 mėnesį',
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
                      controller: TextEditingController(
                          text: '${_startDate.toLocal()}'.split(' ')[0]),
                      decoration: const InputDecoration(
                        labelText: 'Pradžios data',
                        border: OutlineInputBorder(),
                      ),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _startDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2101),
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
                        // Veiksmas, kai paspaudžiama 'Pateikti'
                        Navigator.pop(context);
                      },
                      child: const Text('Pateikti'),
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
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            Text(
              widget.habitName,
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
}
