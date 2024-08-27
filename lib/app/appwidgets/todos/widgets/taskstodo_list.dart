import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_manager/app/appwidgets/todos/widgets/taskstodo_action.dart';
import 'package:task_manager/app/appwidgets/todos/widgets/taskstodo_cart.dart';
import 'package:task_manager/app/controller/taskscontroller.dart';
import 'package:task_manager/app/data/schema.dart';

class TaskstodosList extends StatefulWidget {
  const TaskstodosList({
    super.key,
    required this.done,
    this.task,
    required this.allTodos,
    required this.calendare,
    this.selectedDay,
  });
  final bool done;
  final Tasks? task;
  final bool allTodos;
  final bool calendare;
  final DateTime? selectedDay;

  @override
  State<TaskstodosList> createState() => _TaskstodosListState();
}

class _TaskstodosListState extends State<TaskstodosList> {
  final todoController = Get.put(TasksController());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 50),
      child: Obx(
        () {
          RxList<Todos> todos = <Todos>[].obs;
          List<Todos> filteredList = widget.task != null
              ? todoController.todos
                  .where((todo) =>
                      todo.taskId == widget.task?.id &&
                      todo.done == widget.done 
                    )
                  .toList()
              : widget.allTodos
                  ? todoController.todos
                      .where((todo) =>
                        todo.done == widget.done 
                      )
                      .toList()
                  : widget.calendare
                      ? todoController.todos
                          .where((todo) =>
                              todo.todoCompletedTime != null &&
                              todo.todoCompletedTime!.isAfter(
                                DateTime(
                                    widget.selectedDay!.year,
                                    widget.selectedDay!.month,
                                    widget.selectedDay!.day,
                                    0,
                                    0),
                              ) &&
                              todo.todoCompletedTime!.isBefore(
                                DateTime(
                                    widget.selectedDay!.year,
                                    widget.selectedDay!.month,
                                    widget.selectedDay!.day,
                                    23,
                                    59),
                              ) &&
                              todo.done == widget.done)
                          .toList()
                      : todoController.todos;

          if (widget.calendare) {
            filteredList.sort(
                (a, b) => a.todoCompletedTime!.compareTo(b.todoCompletedTime!));
          } else {
            filteredList.sort((a, b) {
              if (a.fix && !b.fix) {
                return -1;
              } else if (!a.fix && b.fix) {
                return 1;
              } else {
                return 0;
              }
            });
          }

          todos.value = filteredList.obs;

          return todos.isEmpty
              ? Center(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          widget.done ? 'completed Todo'.tr : 'add Todo'.tr,
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
                    ...todos.map(
                      (todo) => TaskstodoCard(
                        key: ValueKey(todo),
                        todo: todo,
                        allTodos: widget.allTodos,
                        calendare: widget.calendare,
                        onTap: () {
                          todoController.isMultiSelectionTodo.isTrue
                              ? todoController.doMultiSelectionTodo(todo)
                              : showModalBottomSheet(
                                  enableDrag: false,
                                  isDismissible: false,
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (BuildContext context) {
                                    return TakstodosAction(
                                      text: 'editing'.tr,
                                      edit: true,
                                      todo: todo,
                                      category: true,
                                    );
                                  },
                                );
                        },
                        onLongPress: () {
                          todoController.isMultiSelectionTodo.value = true;
                          todoController.doMultiSelectionTodo(todo);
                        },
                      ),
                    ),
                  ],
                );
        },
      ),
    );
  }
}