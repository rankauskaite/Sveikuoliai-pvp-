import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sveikuoliai/models/goal_model.dart';
import 'package:sveikuoliai/models/goal_task_model.dart';
import 'package:sveikuoliai/models/habit_model.dart';
import 'package:sveikuoliai/models/habit_progress_model.dart';
import 'package:sveikuoliai/models/shared_goal_model.dart';
import 'package:sveikuoliai/screens/goal.dart';
import 'package:sveikuoliai/screens/habit.dart';
import 'package:sveikuoliai/screens/shared_goal.dart';
import 'package:sveikuoliai/services/auth_services.dart';
import 'package:sveikuoliai/services/goal_task_services.dart';
import 'package:sveikuoliai/services/goal_type_services.dart';
import 'package:sveikuoliai/services/habit_progress_services.dart';
import 'package:sveikuoliai/services/habit_services.dart';
import 'package:sveikuoliai/services/habit_type_services.dart';
import 'package:sveikuoliai/services/plant_image_services.dart';
import 'package:sveikuoliai/widgets/custom_snack_bar.dart';

// Enum dialogo tipui
enum EntityType { habit, goal, sharedGoal, task }

// Pavyzdinis AuthService, kuris grąžina prisijungusio vartotojo username
class CatchUserService {
  static Future<String?> getCurrentUserUsername() async {
    final AuthService authService = AuthService();
    Map<String, String?> sessionData = await authService.getSessionUser();
    if (sessionData.isNotEmpty) {
      return sessionData['username'];
    } else {
      return null; // Jei vartotojas neprisijungęs
    }
  }
}

// Bendras dialogų valdymo klasė
class CustomDialogs {
  // 1. Redagavimo dialogas (Custom Goal, Custom Task, Habit)
  static void showEditDialog({
    required BuildContext context,
    required EntityType entityType,
    required dynamic entity, // GoalModel, HabitModel arba GoalTask
    required Color accentColor,
    required VoidCallback onSave,
  }) {
    final titleController = TextEditingController(
      text: () {
        if (entityType == EntityType.task) {
          return (entity as GoalTask).title;
        } else if (entityType == EntityType.habit) {
          return (entity as HabitInformation).habitType.title;
        } else if (entityType == EntityType.goal) {
          return (entity as GoalInformation).goalType.title;
        } else {
          return (entity as SharedGoalInformation).goalType.title;
        }
      }(),
    );
    final descriptionController = TextEditingController(
      text: () {
        if (entityType == EntityType.task) {
          return (entity as GoalTask).description;
        } else if (entityType == EntityType.habit) {
          return (entity as HabitInformation).habitType.description;
        } else if (entityType == EntityType.goal) {
          return (entity as GoalInformation).goalType.description;
        } else {
          return (entity as SharedGoalInformation).goalType.description;
        }
      }(),
    );

    String dialogTitle;
    String successMessage;
    String errorMessage;

    switch (entityType) {
      case EntityType.habit:
        dialogTitle = "Redaguoti įprotį";
        successMessage = "Įprotis sėkmingai atnaujintas ✅";
        errorMessage = "Klaida atnaujinant įprotį ❌";
        break;
      case EntityType.goal:
        dialogTitle = "Redaguoti tikslą";
        successMessage = "Tikslas sėkmingai atnaujintas ✅";
        errorMessage = "Klaida atnaujinant tikslą ❌";
        break;
      case EntityType.task:
        dialogTitle = "Redaguoti užduotį";
        successMessage = "Užduotis sėkmingai atnaujinta ✅";
        errorMessage = "Klaida atnaujinant užduotį ❌";
        break;
      case EntityType.sharedGoal:
        dialogTitle = "Redaguoti bendrą tikslą";
        successMessage = "Bendras tikslas sėkmingai atnaujintas ✅";
        errorMessage = "Klaida atnaujinant bendrą tikslą ❌";
        break;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(dialogTitle, style: TextStyle(color: accentColor)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: "Pavadinimas",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Aprašymas",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Atšaukti", style: TextStyle(color: accentColor)),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  if (entityType == EntityType.habit) {
                    final habitTypeService = HabitTypeService();
                    entity.habitType.title = titleController.text;
                    entity.habitType.description = descriptionController.text;
                    await habitTypeService
                        .updateHabitTypeEntry(entity.habitType);
                  } else if (entityType == EntityType.goal ||
                      entityType == EntityType.sharedGoal) {
                    final goalTypeService = GoalTypeService();
                    entity.goalType.title = titleController.text;
                    entity.goalType.description = descriptionController.text;
                    await goalTypeService.updateGoalTypeEntry(entity.goalType);
                  } else if (entityType == EntityType.task) {
                    final goalTaskService = GoalTaskService();
                    entity.title = titleController.text;
                    entity.description = descriptionController.text;
                    await goalTaskService.updateGoalTaskEntry(entity);
                  }

                  onSave(); // Callback po sėkmingo išsaugojimo
                  showCustomSnackBar(context, successMessage, true);
                } catch (e) {
                  showCustomSnackBar(context, errorMessage, false);
                }
                Navigator.pop(context);
                if (entityType == EntityType.habit) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HabitScreen(
                        habit: entity as HabitInformation,
                      ),
                    ),
                  );
                } else if (entityType == EntityType.goal) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GoalScreen(
                        goal: entity as GoalInformation,
                      ),
                    ),
                  );
                } else if (entityType == EntityType.sharedGoal) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SharedGoalScreen(
                        goal: entity as SharedGoalInformation,
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: accentColor),
              child: const Text("Išsaugoti",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // 2. Trynimo dialogas (Habit, Goal, Shared Goal)
  static void showDeleteDialog({
    required BuildContext context,
    required EntityType entityType,
    required dynamic entity, // GoalModel arba HabitModel
    required Color accentColor,
    required VoidCallback onDelete,
  }) {
    String title = () {
      if (entityType == EntityType.task) {
        return (entity as GoalTask).title;
      } else if (entityType == EntityType.habit) {
        return (entity as HabitInformation).habitType.title;
      } else if (entityType == EntityType.goal) {
        return (entity as GoalInformation).goalType.title;
      } else {
        return (entity as SharedGoalInformation).goalType.title;
      }
    }();

    String dialogText = () {
      switch (entityType) {
        case EntityType.habit:
          return 'šį įprotį';
        case EntityType.task:
          return 'šią užduotį';
        case EntityType.goal:
          return 'šį tikslą';
        case EntityType.sharedGoal:
          return 'šį bendrą tikslą';
      }
    }();

    String dialogText2 = () {
      switch (entityType) {
        case EntityType.habit:
          return 'Šio įpročio';
        case EntityType.task:
          return 'Šios užduoties';
        case EntityType.goal:
          return 'Šio tikslo';
        case EntityType.sharedGoal:
          return 'Šio bendro tikslo';
      }
    }();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text.rich(
            TextSpan(
              text: "$title\n",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
                color: accentColor,
              ),
              children: [
                TextSpan(
                  text: "Ar tikrai norite ištrinti $dialogText?",
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          content: Text("$dialogText2 ištrynimas bus negrįžtamas."),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    backgroundColor: accentColor.withOpacity(0.2),
                  ),
                  child: Text(
                    "Ne",
                    style: TextStyle(fontSize: 18, color: accentColor),
                  ),
                ),
                const SizedBox(width: 20),
                TextButton(
                  onPressed: () {
                    onDelete();
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.2),
                  ),
                  child: const Text(
                    "Taip",
                    style: TextStyle(color: Colors.red, fontSize: 18),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // 3. Progreso dialogas (Habit)
  static void showProgressDialog({
    required BuildContext context,
    required HabitInformation habit,
    required Color accentColor,
    required VoidCallback onSave,
    String? currentProgressId,
    required TextEditingController progressController,
    required int points,
    required int streak,
  }) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Atnaujink savo progresą',
                  style: TextStyle(fontSize: 18)),
              Text(
                habit.habitType.title,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Data: $formattedDate',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: progressController,
                  maxLines: null,
                  decoration: const InputDecoration(
                    labelText: 'Įveskite informaciją',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Atšaukti', style: TextStyle(color: accentColor)),
            ),
            ElevatedButton(
              onPressed: () async {
                final habitProgressService = HabitProgressService();
                final habitService = HabitService();

                HabitProgress newProgress = HabitProgress(
                  id: currentProgressId ??
                      '${habit.habitModel.habitTypeId}${habit.habitModel.userId[0].toUpperCase() + habit.habitModel.userId.substring(1)}${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}',
                  habitId: habit.habitModel.id,
                  description: progressController.text,
                  points: currentProgressId != null ? points : points + 1,
                  streak: currentProgressId != null ? streak : streak + 1,
                  plantUrl: PlantImageService.getPlantImage(
                      habit.habitModel.plantId, habit.habitModel.points + 1),
                  date: DateTime.now(),
                  isCompleted: true,
                );

                await habitProgressService
                    .createHabitProgressEntry(newProgress);

                HabitModel updatedHabit = HabitModel(
                  id: habit.habitModel.id,
                  startDate: habit.habitModel.startDate,
                  endDate: habit.habitModel.endDate,
                  points: newProgress.points,
                  category: habit.habitModel.category,
                  endPoints: habit.habitModel.endPoints,
                  isCompleted: habit.habitModel.isCompleted,
                  userId: habit.habitModel.userId,
                  habitTypeId: habit.habitModel.habitTypeId,
                  plantId: habit.habitModel.plantId,
                  isPlantDead: habit.habitModel.isPlantDead,
                );

                await habitService.updateHabitEntry(updatedHabit);

                habit.habitModel = updatedHabit; // Atstatome atnaujintą įprotį

                onSave();
                showCustomSnackBar(context, 'Progresas išsaugotas! 🎉', true);
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HabitScreen(
                      habit: habit,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: accentColor),
              child: const Text('Išsaugoti'),
            ),
          ],
        );
      },
    );
  }

  // Naujas metodas naujos užduoties dialogui
  static Future<void> showNewTaskDialog({
    required BuildContext context,
    required dynamic goal, // Priima GoalInformation arba SharedGoalInformation
    required Color accentColor,
    required Function(GoalTask) onSave, // Callback naujai užduočiai išsaugoti
  }) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final String? currentUserUsername =
        await CatchUserService.getCurrentUserUsername();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pridėti užduotį', style: TextStyle(color: accentColor)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Pavadinimas',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Aprašymas',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Atšaukti', style: TextStyle(color: accentColor)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty) {
                  // Sukuriame naują užduotį
                  final task = GoalTask(
                    id: goal is GoalInformation
                        ? '${goal.goalModel.goalTypeId}${goal.goalModel.userId[0].toUpperCase() + goal.goalModel.userId.substring(1)}${DateTime.now()}'
                        : '${goal.sharedGoalModel.goalTypeId}${currentUserUsername![0].toUpperCase() + currentUserUsername.substring(1)}${DateTime.now()}',
                    title: titleController.text,
                    description: descriptionController.text,
                    goalId: goal is GoalInformation
                        ? goal.goalModel.id
                        : goal.sharedGoalModel.id,
                    date: DateTime.now(),
                    userId:
                        goal is GoalInformation ? null : currentUserUsername,
                  );

                  try {
                    final goalTaskService = GoalTaskService();
                    await goalTaskService.createGoalTaskEntry(task);
                    onSave(task); // Išsaugome naują užduotį
                    showCustomSnackBar(
                        context, 'Užduotis sėkmingai pridėta ✅', true);
                  } catch (e) {
                    showCustomSnackBar(
                        context, 'Klaida pridedant užduotį ❌', false);
                  }

                  Navigator.pop(context);
                } else {
                  showCustomSnackBar(
                      context, 'Pavadinimas negali būti tuščias ❌', false);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: accentColor),
              child: const Text(
                'Pridėti',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

// Naujas metodas naujos užduoties dialogui
  static void showNewFirstTaskDialog({
    required BuildContext context,
    required dynamic goal, // Priima GoalInformation arba SharedGoalInformation
    required int type,
    required Color accentColor,
    required Function(GoalTask) onSave, // Callback naujai užduočiai išsaugoti
  }) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false, // Neleidžia uždaryti paspaudus šalia
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false, // Neleidžia uždaryti „back“ mygtuku
          child: AlertDialog(
            title:
                Text('Pridėti užduotį', style: TextStyle(color: accentColor)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Pavadinimas',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Aprašymas',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  if (titleController.text.isNotEmpty) {
                    final task = GoalTask(
                      id: type == 1
                          ? '${goal.goalModel.goalTypeId}${goal.goalModel.userId[0].toUpperCase() + goal.goalModel.userId.substring(1)}${DateTime.now()}'
                          : type == 2
                              ? '${goal.goalTypeId}${goal.user1Id[0].toUpperCase() + goal.user1Id.substring(1)}${DateTime.now()}'
                              : '${goal.goalTypeId}${goal.userId[0].toUpperCase() + goal.userId.substring(1)}${DateTime.now()}',
                      title: titleController.text,
                      description: descriptionController.text,
                      goalId: type == 1 ? goal.goalModel.id : goal.id,
                      date: DateTime.now(),
                    );

                    try {
                      final goalTaskService = GoalTaskService();
                      if (type != 2) {
                        await goalTaskService.createGoalTaskEntry(task);
                      }
                      onSave(task);
                      showCustomSnackBar(
                          context, 'Užduotis sėkmingai pridėta ✅', true);
                      Navigator.pop(
                          context); // Leidžiam uždaryti tik po išsaugojimo
                    } catch (e) {
                      showCustomSnackBar(
                          context, 'Klaida pridedant užduotį ❌', false);
                    }
                  } else {
                    showCustomSnackBar(
                        context, 'Pavadinimas negali būti tuščias ❌', false);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: accentColor),
                child: const Text('Pridėti',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }
}
