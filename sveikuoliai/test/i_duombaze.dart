import 'package:firebase_core/firebase_core.dart';
import 'package:sveikuoliai/models/shared_goal_model.dart';
import 'package:sveikuoliai/services/shared_goal_services.dart';
import 'package:sveikuoliai/enums/category_enum.dart';
import 'package:flutter/widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Android konfigūracija pakanka

  final sharedGoalService = SharedGoalService();

  final goal = SharedGoal(
    id: '',
    startDate: DateTime.now(),
    endDate: DateTime.now().add(const Duration(days: 21)),
    points: 0,
    isCompletedUser1: false,
    isCompletedUser2: false,
    category: CategoryType.bekategorijos, // naudok tinkamą enum reikšmę
    endPoints: 21,
    user1Id: 'test2',
    user2Id: 'test3',
    plantId: 'plant_rose',
    goalTypeId: 'focus21',
    isApproved: false, // Pridėta nauja savybė
    isPlantDeadUser1: false,
    isPlantDeadUser2: false,
  );

  await sharedGoalService.createSharedGoalEntry(goal);
  print('✅ Įrašas sukurtas Firestore!');
}
