import 'package:flutter/material.dart';
import 'package:sveikuoliai/widgets/bottom_navigation.dart';

class GoalPage extends StatelessWidget {
  const GoalPage({super.key});

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
                    'Naujas tikslas',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
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
                        GoalCard(
                          goalName: 'Tikslas 1',
                          goalDescription: 'Aprašymas 1...',
                          goalIcon: Icons.sports_tennis,
                        ),
                        GoalCard(
                          goalName: 'Tikslas 2',
                          goalDescription: 'Aprašymas 2...',
                          goalIcon: Icons.local_drink,
                        ),
                        GoalCard(
                          goalName: 'Tikslas 3',
                          goalDescription: 'Aprašymas 3...',
                          goalIcon: Icons.single_bed,
                        ),
                        GoalCard(
                          goalName: 'Tikslas 4',
                          goalDescription: 'Aprašymas 4...',
                          goalIcon: Icons.self_improvement,
                        ),
                        GoalCard(
                          goalName: 'Pridėti savo tikslą',
                          goalDescription: 'Sukurk ir pridėk savo tikslą',
                          goalIcon: Icons.add_circle,
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

// Atkuriama tikslo kortelė su piktograma, pavadinimu ir aprašymu
class GoalCard extends StatefulWidget {
  final String goalName;
  final String goalDescription;
  final IconData goalIcon;
  final bool
      isLast; // Naujas parametras, kad žinotume, ar tai paskutinė kortelė

  const GoalCard({
    super.key,
    required this.goalName,
    required this.goalDescription,
    required this.goalIcon,
    this.isLast = false, // Jei neapibrėžta, laikome, kad kortelė nėra paskutinė
  });

  @override
  _GoalCardState createState() => _GoalCardState();
}

class _GoalCardState extends State<GoalCard> {
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
        color: Color(0xFF72ddf7), // Kortelės fonas
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
}
