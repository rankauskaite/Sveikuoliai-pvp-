import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sveikuoliai/screens/hello.dart';
import 'package:sveikuoliai/screens/home.dart';
import 'package:sveikuoliai/services/auth_services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // await pushTestSharedGoal(); 
  runApp(const MyApp());
}

// Future<void> pushTestSharedGoal() async {
//   final sharedGoalService = SharedGoalService();

//   final goal = SharedGoal(
//     id: '',
//     startDate: DateTime.now(),
//     endDate: DateTime.now().add(const Duration(days: 21)),
//     points: 0,
//     isCountable: true,
//     category: CategoryType.sveikata,
//     endPoints: 21,
//     user1Id: 'test2',
//     user2Id: 'test3',
//     plantId: 'zibuokle',
//     goalTypeId: 'meditate_30_days',
//   );

//   await sharedGoalService.createSharedGoalEntry(goal);
//   print('✅ SharedGoal sėkmingai išsiųstas į Firestore');
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('lt'), // Nustatome numatytąją kalbą į lietuvių
      supportedLocales: const [
        Locale('lt'), // Lietuvių kalba
        Locale('en'), // Anglų kalba, jei reikėtų ateityje
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      title: 'Pagrindinis ekranas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthCheckScreen(), // Tikriname prisijungimo būseną
    );
  }
}

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  _AuthCheckScreenState createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkIfLoggedIn();
  }

  // Patikrinti, ar vartotojas yra prisijungęs
  Future<void> _checkIfLoggedIn() async {
    try {
      // Patikrinkite, ar užrašyti vartotojo duomenys yra sesijoje
      var sessionUser = await AuthService().getSessionUser();
      if (sessionUser["username"] != null) {
        setState(() {
          isLoggedIn = true; // Jei vartotojas prisijungęs
        });
      } else {
        setState(() {
          isLoggedIn = false; // Jei vartotojas nėra prisijungęs
        });
      }
    } catch (e) {
      print("Klaida tikrinant prisijungimo būseną: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Kol tikrinama prisijungimo būsena, rodomas laukimo ekranas
    return isLoggedIn
        ? const HomeScreen() // Jei prisijungęs, rodomas pagrindinis ekranas
        : HelloScreen(); // Jei neprisijungęs, rodomas pasisveikinimo ekranas
  }
}