// lib/services/auth_service.dart
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sveikuoliai/models/friendship_model.dart';
import 'package:sveikuoliai/models/goal_model.dart';
import 'package:sveikuoliai/models/goal_task_model.dart';
import 'package:sveikuoliai/models/habit_model.dart';
import 'package:sveikuoliai/models/habit_progress_model.dart';
import 'package:sveikuoliai/models/journal_model.dart';
import 'package:sveikuoliai/models/plant_model.dart';
import 'package:sveikuoliai/models/shared_goal_model.dart';
import 'package:sveikuoliai/services/friendship_services.dart';
import 'package:sveikuoliai/services/goal_services.dart';
//import 'package:sveikuoliai/services/goal_task_services.dart';
import 'package:sveikuoliai/services/habit_progress_services.dart';
import 'package:sveikuoliai/services/habit_services.dart';
import 'package:sveikuoliai/services/journal_services.dart';
import 'package:sveikuoliai/services/plant_services.dart';
import 'package:sveikuoliai/services/shared_goal_services.dart';
import '../models/user_model.dart';
import 'user_services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();
  final HabitService _habitService = HabitService();
  final GoalService _goalService = GoalService();
  final SharedGoalService _sharedGoalService = SharedGoalService();
  final FriendshipService _friendshipService = FriendshipService();
  final JournalService _journalService = JournalService();
  final HabitProgressService _habitProgressService = HabitProgressService();
  final PlantService _plantService = PlantService();
  //final GoalTaskService _goalTaskService = GoalTaskService();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Check if username or email already exists
  Future<void> checkUserExists(String username, String email) async {
    try {
      // Check if username exists
      UserModel? existingUserByUsername =
          await _userService.getUserEntry(username);
      if (existingUserByUsername != null) {
        throw Exception('Šis slapyvardis jau užimtas');
      }

      // Check if email exists
      UserModel? existingUserByEmail =
          await _userService.getUserEntryByEmail(email);
      if (existingUserByEmail != null) {
        throw Exception(
            'Šis el. pašto adresas jau užregistruotas, bandykite prisijungti');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<User?> registerWithEmail(
      String email, String password, String username, String name) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      if (user != null) {
        UserModel newUser = UserModel(
          username: username,
          name: name,
          password: password,
          email: email,
          role: "user",
          notifications: true,
          darkMode: false,
          menstrualLength: 7,
          version: "free",
          createdAt: DateTime.now(),
          iconUrl: "", // Default icon URL
        );
        await _userService.createUserEntry(newUser);
        await _saveUserToSession(newUser);
        // Pasirinktinai: Sukurti tuščias sesijas naujam vartotojui
        await _initializeEmptySessions(username);
        return user;
      }
    } catch (e) {
      print("Klaida registruojant: $e");
    }
    return null;
  }

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = userCredential.user;
      if (user != null) {
        UserModel? userData = await _userService.getUserEntryByEmail(email);
        if (userData != null) {
          await _saveUserToSession(userData);
          // Pasirinktinai: Įkelti sesijos duomenis iš Firestore
          await _loadSessionData(userData.username);
        }
      }
      return user;
    } catch (e) {
      print("Klaida prisijungiant: $e");
    }
    return null;
  }

  Future<User?> registerWithGoogle(String username) async {
    try {
      await checkUserExists(username, '');
      // Pirmiausia atlikime prisijungimą su Google
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null)
        return null; // Jei vartotojas atsisako prisijungimo

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Pabandykite prisijungti su Google ir sukurti vartotoją
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      User? user = userCredential.user;
      if (user != null) {
        UserModel newUser = UserModel(
          username: username,
          name: '${user.displayName}',
          password: '',
          email: '${user.email}',
          role: "user",
          notifications: true,
          darkMode: false,
          menstrualLength: 7,
          version: "free",
          createdAt: DateTime.now(),
          iconUrl: "", // Default icon URL
        );
        await _userService.createUserEntry(newUser);
        await _saveUserToSession(newUser);
        // Pasirinktinai: Sukurti tuščias sesijas naujam vartotojui
        await _initializeEmptySessions(username);
        return user;
      }
    } catch (e) {
      print("Klaida registruojant su Google: $e");
    }
    return null;
  }

  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    User? user = userCredential.user;
    if (user != null) {
      UserModel? userData = await _userService.getUserEntryByEmail(user.email!);
      if (userData != null) {
        await _saveUserToSession(userData);
        // Pasirinktinai: Įkelti sesijos duomenis iš Firestore
        await _loadSessionData(userData.username);
      }
    }
    return userCredential;
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    await _storage.deleteAll();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      print("Slaptažodžio priminimo laiškas išsiųstas: $email");
    } catch (e) {
      print("Klaida siunčiant priminimo laišką: $e");
      rethrow;
    }
  }

  Future<void> _saveUserToSession(UserModel user) async {
    await _storage.write(key: "username", value: user.username);
    await _storage.write(key: "name", value: user.name);
    await _storage.write(key: "email", value: user.email);
    await _storage.write(key: "version", value: user.version);
    await _storage.write(
        key: "date", value: DateTime.now().toIso8601String().split('T').first);
    await _storage.write(key: "icon", value: user.iconUrl);
    await _storage.write(key: 'darkMode', value: user.darkMode.toString());
  }

  Future<void> updateUserSession(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<Map<String, String?>> getSessionUser() async {
    return {
      "username": await _storage.read(key: "username"),
      "name": await _storage.read(key: "name"),
      "email": await _storage.read(key: "email"),
      "version": await _storage.read(key: "version"),
      "date": await _storage.read(key: "date"),
      "icon": await _storage.read(key: "icon"),
      "darkMode": await _storage.read(key: "darkMode")
    };
  }

  // Saugome plants sesijoje
  Future<void> savePlantsToSession(List<PlantModel> plants) async {
    final plantsJson = plants.map((plant) => plant.toJson()).toList();
    await _storage.write(key: 'plants', value: jsonEncode(plantsJson));
  }

  Future<List<PlantModel>> getPlantsFromSession() async {
    final plantsJson = await _storage.read(key: 'plants');
    if (plantsJson != null) {
      final List<dynamic> decoded = jsonDecode(plantsJson);
      return decoded.map((json) => PlantModel.fromJson(json)).toList();
    }
    return [];
  }

  // Saugome userHabits sesijoje
  Future<void> saveHabitsToSession(List<HabitInformation> habits) async {
    final habitsJson = habits.map((habit) => habit.toJson()).toList();
    await _storage.write(key: 'userHabits', value: jsonEncode(habitsJson));
  }

  Future<List<HabitInformation>> getHabitsFromSession() async {
    final habitsJson = await _storage.read(key: 'userHabits');
    if (habitsJson != null) {
      final List<dynamic> decoded = jsonDecode(habitsJson);
      return decoded.map((json) => HabitInformation.fromJson(json)).toList();
    }
    return [];
  }

  Future<void> addHabitToSession(HabitInformation habit) async {
    List<HabitInformation> habits = await getHabitsFromSession();
    habits.add(habit);
    final habitsJson = habits.map((habit) => habit.toJson()).toList();
    await _storage.write(key: 'userHabits', value: jsonEncode(habitsJson));
  }

  Future<void> removeHabitFromSession(HabitInformation habit) async {
    List<HabitInformation> habits = await getHabitsFromSession();
    habits.removeWhere((f) => f.habitModel.id == habit.habitModel.id);
    final habitsJson = habits.map((habit) => habit.toJson()).toList();
    await _storage.write(key: 'userHabits', value: jsonEncode(habitsJson));
  }

// Saugome userGoals sesijoje
  Future<void> saveGoalsToSession(List<GoalInformation> goals) async {
    final goalsJson = goals.map((goal) => goal.toJson()).toList();
    await _storage.write(key: 'userGoals', value: jsonEncode(goalsJson));
  }

  Future<List<GoalInformation>> getGoalsFromSession() async {
    final goalsJson = await _storage.read(key: 'userGoals');
    if (goalsJson != null) {
      final List<dynamic> decoded = jsonDecode(goalsJson);
      return decoded.map((json) => GoalInformation.fromJson(json)).toList();
    }
    return [];
  }

  Future<void> addGoalToSession(GoalInformation goal) async {
    List<GoalInformation> goals = await getGoalsFromSession();
    goals.add(goal);
    final goalsJson = goals.map((goal) => goal.toJson()).toList();
    await _storage.write(key: 'userGoals', value: jsonEncode(goalsJson));
  }

  Future<void> removeGoalFromSession(GoalInformation goal) async {
    List<GoalInformation> goals = await getGoalsFromSession();
    goals.removeWhere((f) => f.goalModel.id == goal.goalModel.id);
    final goalsJson = goals.map((goal) => goal.toJson()).toList();
    await _storage.write(key: 'userGoals', value: jsonEncode(goalsJson));
  }

// Saugome userSharedGoals sesijoje
  Future<void> saveSharedGoalsToSession(
      List<SharedGoalInformation> sharedGoals) async {
    final sharedGoalsJson = sharedGoals.map((goal) => goal.toJson()).toList();
    await _storage.write(
        key: 'userSharedGoals', value: jsonEncode(sharedGoalsJson));
  }

  Future<void> addSharedGoalToSession(SharedGoalInformation goal) async {
    List<SharedGoalInformation> goals = await getSharedGoalsFromSession();
    goals.add(goal);
    final goalsJson = goals.map((goal) => goal.toJson()).toList();
    await _storage.write(key: 'userSharedGoals', value: jsonEncode(goalsJson));
  }

  Future<void> removeSharedGoalFromSession(SharedGoalInformation goal) async {
    List<SharedGoalInformation> goals = await getSharedGoalsFromSession();
    goals.removeWhere((f) => f.sharedGoalModel.id == goal.sharedGoalModel.id);
    final goalsJson = goals.map((goal) => goal.toJson()).toList();
    await _storage.write(key: 'userSharedGoals', value: jsonEncode(goalsJson));
  }

  Future<List<SharedGoalInformation>> getSharedGoalsFromSession() async {
    final sharedGoalsJson = await _storage.read(key: 'userSharedGoals');
    if (sharedGoalsJson != null) {
      final List<dynamic> decoded = jsonDecode(sharedGoalsJson);
      return decoded
          .map((json) => SharedGoalInformation.fromJson(json))
          .toList();
    }
    return [];
  }

// Saugome userFriends sesijoje
  Future<void> saveFriendsToSession(List<FriendshipModel> friends) async {
    final friendsJson = friends.map((friend) => friend.toJson()).toList();
    await _storage.write(key: 'userFriends', value: jsonEncode(friendsJson));
  }

  Future<void> removeFriendsFromSession(FriendshipModel user) async {
    List<FriendshipModel> friends = await getFriendsFromSession();
    friends.removeWhere((f) => f.friendship.id == user.friendship.id);
    final friendsJson = friends.map((friend) => friend.toJson()).toList();
    await _storage.write(key: 'userFriends', value: jsonEncode(friendsJson));
  }

  Future<List<FriendshipModel>> getFriendsFromSession() async {
    final friendsJson = await _storage.read(key: 'userFriends');
    if (friendsJson != null) {
      final List<dynamic> decoded = jsonDecode(friendsJson);
      return decoded.map((json) => FriendshipModel.fromJson(json)).toList();
    }
    return [];
  }

  Future<void> saveJournalEntriesToSession(
      List<JournalModel> journalEntries) async {
    try {
      final journalEntriesJson =
          journalEntries.map((entry) => entry.toJson()).toList();
      await _storage.write(
          key: 'userJournalEntries', value: jsonEncode(journalEntriesJson));
    } catch (e) {
      print("Klaida saugant žurnalo įrašus sesijoje: $e");
    }
  }

  Future<List<JournalModel>> getJournalEntriesFromSession() async {
    try {
      final journalEntriesJson = await _storage.read(key: 'userJournalEntries');
      if (journalEntriesJson != null) {
        final List<dynamic> decoded = jsonDecode(journalEntriesJson);
        return decoded.map((json) => JournalModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Klaida gaunant žurnalo įrašus iš sesijos: $e");
      return [];
    }
  }

  Future<void> addJournalentryToSession(JournalModel journal) async {
    List<JournalModel> entries = await getJournalEntriesFromSession();
    // Jei jau yra įrašas su tokiu id, jį pašaliname
    entries.removeWhere((entry) => entry.id == journal.id);
    entries.add(journal);
    final entriesJson = entries.map((entry) => entry.toJson()).toList();
    await _storage.write(
        key: 'userJournalEntries', value: jsonEncode(entriesJson));
  }

  Future<void> saveHabitProgressToSession(
      Map<String, List<HabitProgress>> progressByHabit) async {
    try {
      // Konvertuojame Map į JSON struktūrą
      final progressJson = progressByHabit.map((habitId, progressList) =>
          MapEntry(habitId, progressList.map((p) => p.toJson()).toList()));
      await _storage.write(
          key: 'userHabitProgress', value: jsonEncode(progressJson));
    } catch (e) {
      print("Klaida saugant įpročių progresą sesijoje: $e");
      rethrow;
    }
  }

  Future<void> addHabitProgressToSession(
      String habitId, HabitProgress progress) async {
    try {
      // Gauname esamą progresą iš sesijos
      Map<String, List<HabitProgress>> allProgress =
          await getHabitProgressFromSession();

      // Jei habitId jau egzistuoja, pridedame prie esamo sąrašo
      if (allProgress.containsKey(habitId)) {
        allProgress[habitId]!.add(progress);
      } else {
        // Jei habitId dar nėra, sukuriame naują sąrašą su šiuo progresu
        allProgress[habitId] = [progress];
      }

      // Išsaugome atnaujintą progresą sesijoje
      await saveHabitProgressToSession(allProgress);
    } catch (e) {
      print("Klaida pridedant įpročio progresą sesijoje: $e");
      rethrow;
    }
  }

  Future<Map<String, List<HabitProgress>>> getHabitProgressFromSession() async {
    try {
      final habitProgressJson = await _storage.read(key: 'userHabitProgress');
      if (habitProgressJson != null) {
        final Map<String, dynamic> decoded = jsonDecode(habitProgressJson);
        final Map<String, List<HabitProgress>> progressByHabit = decoded.map(
          (habitId, progressList) => MapEntry(
            habitId,
            (progressList as List)
                .map((json) => HabitProgress.fromJson(json))
                .toList(),
          ),
        );
        return progressByHabit;
      }
      return {};
    } catch (e) {
      print("Klaida gaunant įpročių progresą iš sesijos: $e");
      return {};
    }
  }

  // NAUJA: Saugome userGoalTasks sesijoje
  Future<void> saveGoalTasksToSession(List<GoalTask> goalTasks) async {
    try {
      final goalTasksJson = goalTasks.map((task) => task.toJson()).toList();
      await _storage.write(
          key: 'userGoalTasks', value: jsonEncode(goalTasksJson));
    } catch (e) {
      print("Klaida saugant tikslų užduotis sesijoje: $e");
    }
  }

  Future<List<GoalTask>> getGoalTasksFromSession() async {
    try {
      final goalTasksJson = await _storage.read(key: 'userGoalTasks');
      if (goalTasksJson != null) {
        final List<dynamic> decoded = jsonDecode(goalTasksJson);
        return decoded.map((json) => GoalTask.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Klaida gaunant tikslų užduotis iš sesijos: $e");
      return [];
    }
  }

  // Pasirinktinė funkcija: Sukuria tuščias sesijas naujam vartotojui
  Future<void> _initializeEmptySessions(String username) async {
    try {
      await savePlantsToSession([]);
      await saveHabitsToSession([]);
      await saveGoalsToSession([]);
      await saveSharedGoalsToSession([]);
      await saveFriendsToSession([]);
      await saveJournalEntriesToSession([]);
      await saveHabitProgressToSession({});
      //await saveGoalTasksToSession([]);
    } catch (e) {
      print("Klaida inicializuojant tuščias sesijas: $e");
    }
  }

  // Pasirinktinė funkcija: Įkelia sesijos duomenis iš Firestore
  Future<void> _loadSessionData(String username) async {
    try {
      print("Loading session data for username: $username");

      List<PlantModel> plants = await _plantService.getAllPlants();
      print("Plants loaded: ${plants.length}");
      await savePlantsToSession(plants);

      List<HabitInformation> habits =
          await _habitService.getUserHabits(username);
      print("Habits loaded: ${habits.length}");
      await saveHabitsToSession(habits);

      List<GoalInformation> goals = await _goalService.getUserGoals(username);
      print("Goals loaded: ${goals.length}");
      await saveGoalsToSession(goals);

      List<SharedGoalInformation> sharedGoals =
          await _sharedGoalService.getSharedUserGoals(username);
      print("Shared goals loaded: ${sharedGoals.length}");
      await saveSharedGoalsToSession(sharedGoals);

      List<FriendshipModel> friends =
          await _friendshipService.getUserFriendshipModels(username);
      print("Friends loaded: ${friends.length}");
      await saveFriendsToSession(friends);

      List<JournalModel> journalEntries =
          await _journalService.getAllUsersJournalEntries(username);
      print("Journal entries loaded: ${journalEntries.length}");
      await saveJournalEntriesToSession(journalEntries);

      Map<String, List<HabitProgress>> habitProgress =
          await _habitProgressService.getAllHabitProgress(habits);
      print(
          "Habit progress loaded: ${habitProgress.length} habits (not journal entries)");
      await saveHabitProgressToSession(habitProgress);
      // List<GoalTask> goalTasks =
      //     await _goalTaskService.getGoalTasks(username); // NAUJA

      // NAUJA
      //await saveGoalTasksToSession(goalTasks); // NAUJA
    } catch (e) {
      print("Klaida įkeliant sesijos duomenis: $e");
    }
  }
}
