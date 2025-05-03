import 'package:sveikuoliai/models/goal_task_model.dart';

List<GoalTask> generateDefaultTasksForGoal({
  required String goalId,
  required String goalType,
  required String username,
  required String? isFriend,
}) {
  switch (goalType) {
    case 'read_books':
      return List.generate(
        10,
        (index) {
          final baseTitle = 'Perskaityti ${index + 1}-ąją knygą';
          final baseDescription = 'Išsirinkti ir perskaityti knygą';
          final now = DateTime.now();

          final tasks = <GoalTask>[];

          // Vartotojo užduotis (jei username nenurodytas kaip draugas)
          tasks.add(
            GoalTask(
              title: baseTitle,
              id: '${index}_$goalType${username[0].toUpperCase()}${username.substring(1)}$now',
              goalId: goalId,
              description: baseDescription,
              date: now,
              userId: isFriend == null ? null : username,
            ),
          );

          // Draugo užduotis, jei yra draugas
          if (isFriend != null) {
            tasks.add(
              GoalTask(
                title: baseTitle,
                id: '${index}_$goalType${isFriend[0].toUpperCase()}${isFriend.substring(1)}$now',
                goalId: goalId,
                description: baseDescription,
                date: now,
                userId: isFriend,
              ),
            );
          }

          return tasks;
        },
      ).expand((tasks) => tasks).toList();
    case 'save_money':
      int index = 0;
      return [
        'Sutaupyti pirmus 50€',
        'Sutaupyti 100€',
        'Sutaupyti 150€',
        'Sutaupyti 200€',
        'Sutaupyti 250€',
        'Sutaupyti 300€',
        'Sutaupyti 350€',
        'Sutaupyti 400€',
        'Sutaupyti 450€',
        'Sutaupyti 500€',
      ]
          .map((title) => GoalTask(
                title: title,
                goalId: goalId,
                id: '${++index}_$goalType${username[0].toUpperCase() + username.substring(1)}${DateTime.now()}',
                description: 'Pasistengti sutaupyti pinigų',
                date: DateTime.now(),
              ))
          .toList();
    case 'run_marathon':
      int index = 0;
      final now = DateTime.now();
      return [
        'Pasiruošti treniruočių planą',
        'Prabėgti pirmą 1 km',
        'Prabėgti 3 km',
        'Prabėgti 5 km',
        'Prabėgti 10 km',
        'Prabėgti 15 km',
        'Prabėgti pusmaratonį (21 km)',
        'Prabėgti 25 km',
        'Prabėgti 30 km',
        'Prabėgti 35 km',
        'Prabėgti 40 km',
        'Prabėgti pilną maratoną (42 km)',
      ].expand((title) {
        final tasks = <GoalTask>[];

        tasks.add(
          GoalTask(
            title: title,
            goalId: goalId,
            id: '${++index}_$goalType${username[0].toUpperCase()}${username.substring(1)}$now',
            description: 'Pasiruošti maratonui',
            date: now,
            userId: isFriend == null ? null : username,
          ),
        );

        if (isFriend != null) {
          tasks.add(
            GoalTask(
              title: title,
              goalId: goalId,
              id: '${index}_$goalType${isFriend[0].toUpperCase()}${isFriend.substring(1)}$now',
              description: 'Pasiruošti maratonui',
              date: now,
              userId: isFriend,
            ),
          );
        }

        return tasks;
      }).toList();
    case 'meditate_30_days':
      return List.generate(
        30,
        (index) => GoalTask(
          title: 'Meditacija ${index + 1}-ą dieną',
          goalId: goalId,
          id: '${index}_$goalType${username[0].toUpperCase() + username.substring(1)}${DateTime.now()}',
          description: 'Ugdyti emocijas ir ramybę',
          date: DateTime.now(),
        ),
      );
    case 'plant_trees':
      return List.generate(
        20,
        (index) => GoalTask(
          title: 'Pasodinti medį #${index + 1}',
          goalId: goalId,
          id: '${index}_$goalType${username[0].toUpperCase() + username.substring(1)}${DateTime.now()}',
          description: 'Prisidėti prie gamtos išsaugojimo',
          date: DateTime.now(),
        ),
      );
    case 'run_100km':
      int index = 0;
      final now = DateTime.now();
      return [
        'Prabėgti pirmą 1 km',
        'Prabėgti 5 km',
        'Prabėgti 10 km',
        'Prabėgti 15 km',
        'Prabėgti 20 km',
        'Prabėgti 25 km',
        'Prabėgti 30 km',
        'Prabėgti 35 km',
        'Prabėgti 40 km',
        'Prabėgti 45 km',
        'Prabėgti 50 km',
        'Prabėgti 55 km',
        'Prabėgti 60 km',
        'Prabėgti 65 km',
        'Prabėgti 70 km',
        'Prabėgti 75 km',
        'Prabėgti 80 km',
        'Prabėgti 85 km',
        'Prabėgti 90 km',
        'Prabėgti 95 km',
        'Prabėgti 100 km',
      ].expand((title) {
        final tasks = <GoalTask>[];

        tasks.add(
          GoalTask(
            title: title,
            goalId: goalId,
            id: '${++index}_$goalType${username[0].toUpperCase()}${username.substring(1)}$now',
            description: 'Tobulinti bėgimo įgūdžius',
            date: now,
            userId: isFriend == null ? null : username,
          ),
        );

        if (isFriend != null) {
          tasks.add(
            GoalTask(
              title: title,
              goalId: goalId,
              id: '${index}_$goalType${isFriend[0].toUpperCase()}${isFriend.substring(1)}$now',
              description: 'Tobulinti bėgimo įgūdžius',
              date: now,
              userId: isFriend,
            ),
          );
        }

        return tasks;
      }).toList();
    case 'group_challenge_steps':
      int index = 0;
      final now = DateTime.now();
      return [
        'Nueiti 5 000 žingsnių',
        'Nueiti 10 000 žingsnių',
        'Nueiti 15 000 žingsnių',
        'Nueiti 20 000 žingsnių',
        'Nueiti 25 000 žingsnių',
        'Nueiti 30 000 žingsnių',
        'Nueiti 35 000 žingsnių',
        'Nueiti 40 000 žingsnių',
        'Nueiti 45 000 žingsnių',
        'Nueiti 50 000 žingsnių',
      ].expand((title) {
        final tasks = <GoalTask>[];

        tasks.add(
          GoalTask(
            title: title,
            goalId: goalId,
            id: '${++index}_$goalType${username[0].toUpperCase()}${username.substring(1)}$now',
            description: 'Vaikščioti ir būti aktyviam',
            date: now,
            userId: isFriend == null ? null : username,
          ),
        );

        if (isFriend != null) {
          tasks.add(
            GoalTask(
              title: title,
              goalId: goalId,
              id: '${index}_$goalType${isFriend[0].toUpperCase()}${isFriend.substring(1)}$now',
              description: 'Vaikščioti ir būti aktyviam',
              date: now,
              userId: isFriend,
            ),
          );
        }

        return tasks;
      }).toList();
    case 'hydrate_together':
      final now = DateTime.now();
      return List.generate(
        5,
        (i) {
          final tasks = <GoalTask>[];

          tasks.add(
            GoalTask(
              title: 'Išgerti 2 litrus vandens #${i + 1}',
              goalId: goalId,
              id: '${i}_$goalType${username[0].toUpperCase()}${username.substring(1)}$now',
              description: 'Gerti pakankamai vandens',
              date: now,
              userId: isFriend == null ? null : username,
            ),
          );

          if (isFriend != null) {
            tasks.add(
              GoalTask(
                title: 'Išgerti 2 litrus vandens #${i + 1}',
                goalId: goalId,
                id: '${i}_$goalType${isFriend[0].toUpperCase()}${isFriend.substring(1)}$now',
                description: 'Gerti pakankamai vandens',
                date: now,
                userId: isFriend,
              ),
            );
          }

          return tasks;
        },
      ).expand((tasks) => tasks).toList();
    default:
      return [];
  }
}
