import 'package:flutter/material.dart';
import 'package:sveikuoliai/models/goal_task_model.dart';
import 'package:sveikuoliai/widgets/custom_dialogs.dart';

class GoalTaskCard extends StatefulWidget {
  final GoalTask task;
  final int length;
  final int doneLength;
  final int type;
  final int Function(bool isCompleted)
      calculatePoints; // Grąžina int, priima bool
  final void Function(String taskId)? onDelete; // Priima task.id
  final VoidCallback? onUpdate; // Papildomas callback būsenos atnaujinimui

  const GoalTaskCard({
    Key? key,
    required this.task,
    required this.type,
    required this.length,
    required this.doneLength,
    required this.calculatePoints,
    this.onDelete,
    this.onUpdate,
  }) : super(key: key);

  @override
  _GoalTaskCardState createState() => _GoalTaskCardState();
}

class _GoalTaskCardState extends State<GoalTaskCard> {
  @override
  Widget build(BuildContext context) {
    // Pasirenkame, kurį metodą naudoti pagal task.isCompleted
    return widget.task.isCompleted
        ? buildGoalItemTrue(widget.task)
        : buildGoalItemFalse(widget.task, widget.length, widget.doneLength);
  }

  // Tikslų kortelių kūrimo funkcija užbaigtoms užduotims
  Widget buildGoalItemTrue(GoalTask task) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: widget.type == 0
            ? const Color(0xFF72ddf7).withOpacity(0.1)
            : widget.type == 1
                ? const Color(0xFFbcd979).withOpacity(0.1)
                : const Color(0xFF72ddf7).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                task.title,
                style: TextStyle(color: Colors.grey[300]),
              ),
              subtitle: Text(
                task.description,
                style: TextStyle(color: Colors.grey[300]),
              ),
              leading: Checkbox(
                value: task.isCompleted,
                onChanged: (bool? value) {
                  // setState(() {
                  //   final newValue = value ?? false;
                  //   task.isCompleted = newValue;
                  //   task.points = widget.calculatePoints(newValue);
                  //   widget.onUpdate?.call();
                  // });
                },
                activeColor: widget.type == 0
                    ? Colors.blue
                    : widget.type == 1
                        ? Colors.lightGreen
                        : const Color(0xFF72ddf7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tikslų kortelių kūrimo funkcija neužbaigtoms užduotims
  Widget buildGoalItemFalse(GoalTask task, int length, int doneLength) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: widget.type == 0
            ? const Color(0xFF72ddf7).withOpacity(0.2)
            : widget.type == 1
                ? const Color(0xFFbcd979).withOpacity(0.2)
                : const Color(0xFF72ddf7).withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(task.title),
              subtitle: Text(task.description),
              leading: Checkbox(
                value: task.isCompleted,
                onChanged: (bool? value) {
                  setState(() {
                    final newValue = value ?? false;
                    task.isCompleted = newValue;
                    task.points = widget.calculatePoints(newValue);
                    widget.onUpdate?.call();
                  });
                },
                activeColor: widget.type == 0
                    ? Colors.blue
                    : widget.type == 1
                        ? Colors.lightGreen
                        : const Color(0xFF72ddf7),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              CustomDialogs.showEditDialog(
                context: context,
                entityType: EntityType.task,
                entity: task,
                accentColor: widget.type == 0
                    ? Colors.lightBlueAccent
                    : widget.type == 1
                        ? (Colors.lightGreen[400] ?? Colors.lightGreen)
                        : const Color(0xFF72ddf7),
                onSave: () {
                  setState(() {});
                  widget.onUpdate?.call();
                },
              );
            },
            icon: Icon(Icons.edit_outlined,
                color: widget.type == 0
                    ? Colors.blue[600]
                    : widget.type == 1
                        ? Colors.lightGreen[600]
                        : const Color(0xFF72ddf7)),
          ),
          if (length > 1 && length - doneLength > 1)
            IconButton(
              onPressed: () {
                CustomDialogs.showDeleteDialog(
                  context: context,
                  entityType: EntityType.task,
                  entity: task,
                  accentColor: widget.type == 0
                      ? Colors.lightBlueAccent
                      : widget.type == 1
                          ? Colors.lightGreen
                          : const Color(0xFF72ddf7),
                  onDelete: () {
                    widget.onDelete?.call(task.id);
                  },
                );
              },
              icon: Icon(Icons.remove_circle_outline,
                  color: widget.type == 0
                      ? Colors.blue[600]
                      : widget.type == 1
                          ? Colors.lightGreen[600]
                          : const Color(0xFF72ddf7)),
            ),
        ],
      ),
    );
  }
}
