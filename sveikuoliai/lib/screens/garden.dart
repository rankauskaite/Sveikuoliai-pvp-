import 'dart:math';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:sveikuoliai/models/goal_model.dart';
import 'package:sveikuoliai/models/habit_model.dart';
import 'package:sveikuoliai/models/shared_goal_model.dart';
import 'package:sveikuoliai/models/user_model.dart';
import 'package:sveikuoliai/services/auth_services.dart';
import 'package:sveikuoliai/services/goal_services.dart';
import 'package:sveikuoliai/services/habit_services.dart';
import 'package:sveikuoliai/services/plant_image_services.dart';
import 'package:sveikuoliai/services/shared_goal_services.dart';
import 'package:sveikuoliai/widgets/bottom_navigation.dart';
import 'package:sveikuoliai/widgets/custom_snack_bar.dart';

class GardenScreen extends StatefulWidget {
  final UserModel user;
  const GardenScreen({Key? key, required this.user}) : super(key: key);

  @override
  _GardenScreenState createState() => _GardenScreenState();
}

class _GardenScreenState extends State<GardenScreen> {
  final AuthService _authService = AuthService();
  bool friendFlag = false;
  List<Map<String, dynamic>> userHabits = [];
  List<Map<String, dynamic>> userGoals = [];
  List<Map<String, dynamic>> userSharedGoals = [];
  final HabitService _habitService = HabitService();
  final GoalService _goalService = GoalService();
  final SharedGoalService _sharedGoalService = SharedGoalService();
  final PageController _pageController = PageController();
  final Random _random = Random();
  int _currentPage = 0;
  final int plantCount = 5;
  List<String> count = ['0', '0', '0'];

  final List<String> titlesTop = ['Įpročių', 'Tikslų', 'Draugų'];
  final List<String> titlesBottom = ['sodas', 'sodas', 'sodas'];
  List<String> subtitles = [
    'Tavo įpročių sodą puošia\naugaliukai',
    'Tavo tikslų sodą puošia\naugaliukai',
    'Bendrame sode su\ndraugais augini\ntikslų augaliukus'
  ];
  final List<String> images = [
    'assets/images/salos/sala_iprociu.png',
    'assets/images/salos/sala_tikslu.png',
    'assets/images/salos/sala_draugu.png',
  ];
  final List<Color> backgroundColors = [
    Color(0xFFB388EB), // Spalva pirmam puslapiui
    Color(0xFF27B1D2), // Spalva antram puslapiui
    Color(0xFF5A741E), // Spalva trečiam puslapiui
  ];

  List<Positioned> _generatePlants(List<Map<String, dynamic>> sourceList) {
    List<Map<String, dynamic>> plantData = [];
    List<Offset> usedPositions = [];
    int maxAttempts = 100;

    while (plantData.length < sourceList.length && maxAttempts > 0) {
      double left = -5 + _random.nextDouble() * 200;
      double top = 18 + _random.nextDouble() * 28;
      Offset newPos = Offset(left, top);

      bool tooClose = usedPositions.any(
        (pos) => (pos - newPos).dx.abs() < 40 && (pos - newPos).dy.abs() < 5,
      );

      if (!tooClose) {
        usedPositions.add(newPos);
        plantData.add({'left': left, 'top': top});
      }

      maxAttempts--;
    }

    plantData.sort((a, b) => a['top'].compareTo(b['top']));

    return List.generate(sourceList.length, (index) {
      final plant = sourceList[index];
      final double left = plantData[index]['left'];
      final double top = plantData[index]['top'];
      final String imagePath = plant['isPlantDead']
          ? DeadPlantImageService.getPlantImage(
              plant['plantId'],
              plant['points'],
            )
          : PlantImageService.getPlantImage(
              plant['plantId'],
              plant['points'],
            );

      return Positioned(
        left: left,
        top: top,
        child: Image.asset(
          imagePath,
          width: 100,
          height: 100,
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    try {
      Map<String, String?> sessionData = await _authService.getSessionUser();
      bool flag = false;
      if (sessionData['username'] != widget.user.username) {
        flag = true;
      }
      await _fetchUserHabits(widget.user.username);
      await _fetchUserGoals(widget.user.username);
      if (widget.user.version == 'premium') {
        await _fetchUserSharedGoals(widget.user.username);
      }
      setState(() {
        friendFlag = flag;
        if (flag) {
          subtitles = [
            'Draugo ${widget.user.name}\nįpročių sodą puošia\naugaliukai',
            'Draugo ${widget.user.name}\ntikslų sodą puošia\naugaliukai',
            '${widget.user.name} augina\ntikslų augaliukus su draugais'
          ];
        }
        count = [
          userHabits.length.toString(),
          userGoals.length.toString(),
          userSharedGoals.length.toString(),
        ];
      });
    } catch (e) {}
  }

  Future<void> _fetchUserHabits(String username) async {
    try {
      // Gaukime vartotojo įpročius
      List<HabitInformation> habits =
          await _habitService.getUserHabits(username);

      //List<HabitInformation> activeHabits =
      //habits.where((habit) => !habit.habitModel.isCompleted).toList();

      // Atnaujiname būsena su naujais duomenimis
      setState(() {
        userHabits = habits
            .map((habit) => {
                  'plantId': habit.habitModel.plantId,
                  'points': habit.habitModel.points,
                  'isPlantDead': habit.habitModel.isPlantDead,
                })
            .toList();
      });
    } catch (e) {
      showCustomSnackBar(context, 'Klaida kraunant įpročius ❌', false);
    }
  }

  Future<void> _fetchUserGoals(String username) async {
    try {
      // Gaukime vartotojo įpročius
      List<GoalInformation> goals = await _goalService.getUserGoals(username);
      // List<GoalInformation> activeGoals =
      //     goals.where((goal) => !goal.goalModel.isCompleted).toList();

      // Atnaujiname būsena su naujais duomenimis
      setState(() {
        userGoals = goals
            .map((goal) => {
                  'plantId': goal.goalModel.plantId,
                  'points': goal.goalModel.points,
                  'isPlantDead': goal.goalModel.isPlantDead,
                })
            .toList();
      });
    } catch (e) {
      showCustomSnackBar(context, 'Klaida kraunant tikslus ❌', false);
    }
  }

  Future<void> _fetchUserSharedGoals(String username) async {
    try {
      // Gaukime vartotojo įpročius
      List<SharedGoalInformation> goals =
          await _sharedGoalService.getSharedUserGoals(username);
      List<SharedGoalInformation> activeGoals =
          goals.where((goal) => goal.sharedGoalModel.isApproved).toList();

      // Atnaujiname būsena su naujais duomenimis
      setState(() {
        userSharedGoals = activeGoals
            .map((goal) => {
                  'plantId': goal.sharedGoalModel.plantId,
                  'points': goal.sharedGoalModel.points,
                  'isPlantDead': goal.sharedGoalModel.isPlantDeadUser1 &&
                          goal.sharedGoalModel.isPlantDeadUser2
                      ? true
                      : false,
                })
            .toList();
      });
    } catch (e) {
      showCustomSnackBar(context, 'Klaida kraunant draugų tikslus ❌', false);
    }
  }

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
      body: Stack(
        children: [
          Center(
            child: Column(
              children: [
                SizedBox(height: topPadding),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: horizontalPadding),
                    decoration: BoxDecoration(
                      color: Color(0xFFE7EDD9),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Color(0xFFE7EDD9), width: 20),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.arrow_back_ios, size: 30),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: 250, // fiksuotas plotis
                          height: 120, // fiksuotas aukštis
                          decoration: BoxDecoration(
                            color: const Color(0xFFC2DD84),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${titlesTop[_currentPage]}\n',
                                      style: TextStyle(
                                        fontSize: 45,
                                        fontWeight: FontWeight.bold,
                                        color: backgroundColors[_currentPage],
                                        height:
                                            1.2, // sumažintas tarpas tarp eilučių
                                      ),
                                    ),
                                    TextSpan(
                                      text: titlesBottom[_currentPage],
                                      style: const TextStyle(
                                        fontSize: 45,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        height:
                                            1.0, // dar mažesnis tarpas šiai eilutei, jei norisi
                                      ),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Flexible(
                              child: Text(
                                subtitles[_currentPage],
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFC2DD84),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                count[_currentPage],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 35,
                                  color: backgroundColors[_currentPage],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                        const SizedBox(height: 50),
                        Stack(
                          children: [
                            // Kiti Stack elementai (pvz., fonas)
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: SizedBox(
                                width: 300, // page view plotis
                                height: 250, // page view aukštis
                                child: PageView.builder(
                                  controller: _pageController,
                                  itemCount:
                                      widget.user.version == 'premium' ? 3 : 2,
                                  onPageChanged: (index) {
                                    if (widget.user.version == 'free' &&
                                        index == 2) return; // ignoruok
                                    setState(() {
                                      _currentPage = index;
                                    });
                                  },
                                  itemBuilder: (context, index) {
                                    List<Map<String, dynamic>> currentData;
                                    if (index == 0) {
                                      currentData = userHabits;
                                    } else if (index == 1) {
                                      currentData = userGoals;
                                    } else if (widget.user.version ==
                                        'premium') {
                                      currentData = userSharedGoals;
                                    } else {
                                      return const SizedBox(); // tuščias widget, jei free bando pasiekti 2 puslapį
                                    }

                                    return Stack(
                                      alignment: Alignment.bottomCenter,
                                      children: [
                                        Image.asset(
                                          images[index],
                                          width: 300,
                                          height: 200,
                                        ),
                                        ..._generatePlants(currentData),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        SmoothPageIndicator(
                          controller: _pageController,
                          count: widget.user.version == 'premium' ? 3 : 2,
                          effect: const WormEffect(
                            dotColor: Colors.grey,
                            activeDotColor: Colors.deepPurple,
                            dotHeight: 10,
                            dotWidth: 10,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                const BottomNavigation(),
                SizedBox(height: bottomPadding),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
