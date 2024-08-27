import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_manager/app/appwidgets/tasks/widgets/task_card.dart';
import 'package:task_manager/app/appwidgets/todos/view/taks_todos.dart';
import 'package:task_manager/app/controller/taskscontroller.dart';

class TasksList extends StatefulWidget {
  const TasksList({
    super.key,
    required this.archived,
  });
  final bool archived;

  @override
  State<TasksList> createState() => _TasksListState();
}

class _TasksListState extends State<TasksList> {
  final tasksController = Get.put(TasksController());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 50),
      child: Obx(
        () {
          var tasks = tasksController.tasks
              .where((task) => task.archive == widget.archived)
              .toList()
              .obs;
          return tasks.isEmpty
              ? Center(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          widget.archived ? 'add Archive'.tr : 'add Taks'.tr,
                          textAlign: TextAlign.center,
                          style: context.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView(
                  children: [
                    ...tasks.map(
                      (task) {
                        var createdTodos =
                            tasksController.createdTodosTask(task);
                        var completedTodos =
                            tasksController.completedTodosTask(task);
                        var precent = (completedTodos / createdTodos * 100)
                            .toStringAsFixed(0);

                        return TaskCard(
                          key: ValueKey(task),
                          task: task,
                          createdTodos: createdTodos,
                          completedTodos: completedTodos,
                          precent: precent,
                          onTap: () {
                            tasksController.isMultiSelectionTask.isTrue
                                ? tasksController.doMultiSelectionTask(task)
                                : Get.to(
                                    () => TodosTask(task: task),
                                    transition: Transition.downToUp,
                                  );
                          },
                          onLongPress: () {
                            tasksController.isMultiSelectionTask.value = true;
                            tasksController.doMultiSelectionTask(task);
                          },
                        );
                      },
                    ),
                  ],
                );
        },
      ),
    );
  }
}
