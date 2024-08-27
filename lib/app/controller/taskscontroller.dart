import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager/app/data/schema.dart';
import 'package:task_manager/app/services/notification.dart';
import 'package:task_manager/main.dart';

class TasksController extends GetxController {
  final tasks = <Tasks>[].obs;
  final todos = <Todos>[].obs;

  final selectedTask = <Tasks>[].obs;
  final isMultiSelectionTask = false.obs;

  final selectedTodo = <Todos>[].obs;
  final isMultiSelectionTodo = false.obs;

  final user = FirebaseAuth.instance.currentUser;

  RxBool isPop = true.obs;

  final duration = const Duration(milliseconds: 500);
  var now = DateTime.now();
  int counterTasksid = 0;
  int counterTasksTodoid = 0;

  TextEditingController titleCategoryEdit = TextEditingController();
  TextEditingController descCategoryEdit = TextEditingController();

  TextEditingController textTodoConroller = TextEditingController();
  TextEditingController transferTodoConroller = TextEditingController();
  TextEditingController titleTodoEdit = TextEditingController();
  TextEditingController descTodoEdit = TextEditingController();
  TextEditingController timeTodoEdit = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadTasks();
    loadTodos();
    loadCounterTasksid();
  }

  Future<void> loadTasks() async {
    try {
      if (user != null) {
        final tasksSnapshot = await FirebaseFirestore.instance
            .collection('tasks')
            .where('userId', isEqualTo: user!.uid)
            .get();

        final todosSnapshot = await FirebaseFirestore.instance
            .collectionGroup('todos')
            .where('userId', isEqualTo: user!.uid)
            .get();

        tasks.clear();

        for (var taskDoc in tasksSnapshot.docs) {
          final task = Tasks.fromDocument(taskDoc);
          task.todos = todosSnapshot.docs
              .map((doc) => Todos.fromDocument(doc))
              .where((doc) => doc.taskId == task.id)
              .toList();
          tasks.add(task);
          for (var todo in task.todos) {
            todos.add(todo);
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading tasks: $e');
    }
  }

  Future<void> loadTodos() async {
    try {} catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> loadCounterTasksid() async {
    final prefs = await SharedPreferences.getInstance();
    counterTasksid = prefs.getInt('counter') ?? 0;
    counterTasksTodoid = prefs.getInt('counterTodo') ?? 0;
  }

  Future<void> incrementTasksid() async {
    final prefs = await SharedPreferences.getInstance();
    counterTasksid = (prefs.getInt('counter') ?? 0) + 1;
    prefs.setInt('counter', counterTasksid);
  }

  Future<void> incrementTasksTodoid() async {
    final prefs = await SharedPreferences.getInstance();
    counterTasksTodoid = (prefs.getInt('counterTodo') ?? 0) + 1;
    prefs.setInt('counterTodo', counterTasksTodoid);
  }

  Future<void> addTask(String title, String desc, Color myColor) async {
    if (title.isNotEmpty && desc.isNotEmpty) {
      if (user != null) {
        // Check for existing Task with the same name and userId
        final existingTask = await FirebaseFirestore.instance
            .collection('tasks')
            .where('title', isEqualTo: title)
            .where('userId', isEqualTo: user!.uid)
            .get();

        if (existingTask.docs.isEmpty) {
          incrementTasksid();
          final newTaskRef =
              FirebaseFirestore.instance.collection('tasks').doc();
          final newTask = Tasks(
            id: counterTasksid,
            title: title,
            description: desc,
            taskColor: myColor.value,
            userId: user!.uid,
            archive: false,
            index: tasks.length,
          );
          await newTaskRef.set(newTask.toMap());

          tasks.add(newTask); // Assuming you have a tasks list

          EasyLoading.showSuccess('createTasks'.tr, duration: duration);
        } else {
          EasyLoading.showError('duplicateTasks'.tr, duration: duration);
        }
      }
    }
  }

  Future<void> updateTask(
      Tasks task, String title, String desc, Color myColor) async {
    await FirebaseFirestore.instance
        .collection('tasks')
        .doc(task.id as String?)
        .update({
      'title': title,
      'description': desc,
      'taskColor': myColor.value,
    });
    var newTask = task;
    int oldIdx = tasks.indexOf(task);
    tasks[oldIdx] = newTask;
    tasks.refresh();
    todos.refresh();
    EasyLoading.showSuccess('editTasks'.tr, duration: duration);
  }

  //todo

  Future<void> addTodo(
      Tasks task, String title, String desc, String time) async {
    DateTime? date;
    if (time.isNotEmpty) {
      date = timeformat == '12'
          ? DateFormat.yMMMEd(locale.languageCode).add_jm().parse(time)
          : DateFormat.yMMMEd(locale.languageCode).add_Hm().parse(time);
    }

    final query = await FirebaseFirestore.instance
        .collectionGroup('todos')
        .where('name', isEqualTo: title)
        .where('taskId', isEqualTo: task.id)
        .where('todoCompletedTime', isEqualTo: date)
        .where('userId', isEqualTo: user!.uid)
        .get();

    if (query.docs.isEmpty) {
      incrementTasksTodoid();
      final newTodoRef = FirebaseFirestore.instance
          .collection('tasks')
          .doc(task.id.toString())
          .collection('todos')
          .doc();
      final newTodo = Todos(
        id: counterTasksTodoid,
        name: title,
        description: desc,
        todoCompletedTime: date,
        taskstitle: task.title,
        done: false,
        fix: false,
        taskId: task.id,
        userId: user!.uid,
      );
      await newTodoRef.set(newTodo.toMap());

      int taskIndex = tasks.indexWhere((t) => t.id == task.id);
      if (taskIndex != -1) {
        tasks[taskIndex].todos.add(newTodo);
      }

      todos.add(newTodo);

      if (date != null && now.isBefore(date)) {
        NotificationShow().showNotification(
          newTodo.id,
          newTodo.name,
          newTodo.description,
          date,
        );
      }
      EasyLoading.showSuccess('todoCreate'.tr, duration: duration);
    } else {
      EasyLoading.showError('duplicateTodo'.tr, duration: duration);
    }
  }

  Future<void> updateTodo(
      Todos todo, Tasks task, String title, String desc, String time) async {
    DateTime? date;
    if (time.isNotEmpty) {
      date = timeformat == '12'
          ? DateFormat.yMMMEd(locale.languageCode).add_jm().parse(time)
          : DateFormat.yMMMEd(locale.languageCode).add_Hm().parse(time);
    }

    await FirebaseFirestore.instance.collection('todos').doc(todo.name).update({
      'name': title,
      'description': desc,
      'todoCompletedTime': date,
    });

    int oldIdx = todos.indexOf(todo);
    if (oldIdx != -1) {
      todos[oldIdx] = Todos(
        id: todo.id,
        userId: todo.userId,
        name: title,
        description: desc,
        todoCompletedTime: date,
        taskstitle: task.title,
        taskId: task.id,
      );
    }

    if (date != null && now.isBefore(date)) {
      await flutterLocalNotificationsPlugin.cancel(todo.id);
      NotificationShow().showNotification(
        todo.id,
        title,
        desc,
        date,
      );
    } else {
      await flutterLocalNotificationsPlugin.cancel(todo.id);
    }
    EasyLoading.showSuccess('updateTodo'.tr, duration: duration);
  }

  //other
  Future<void> updateTodoFix(Todos todo) async {
    // 1. Find the task containing the todo
    Tasks? parentTask = tasks.firstWhere((task) => task.todos.contains(todo));

    // 2. Update the todo in the task's todos list
    int todoIndexInTask = parentTask.todos.indexOf(todo);
    parentTask.todos[todoIndexInTask].fix =
        !parentTask.todos[todoIndexInTask].fix;

    // 3. Update the todo in Firestore
    await FirebaseFirestore.instance
        .collection('tasks')
        .doc(parentTask.id as String?)
        .collection('todos')
        .doc(todo.id as String?)
        .update({'fix': parentTask.todos[todoIndexInTask].fix});

    // 4. Update the todo in the main todos list (if you're maintaining one)
    int todoIndexInMainList = todos.indexOf(todo);
    todos[todoIndexInMainList] = parentTask.todos[todoIndexInTask];
    tasks.refresh();
    todos.refresh();
  }

  Future<void> updateTodoCheck(Todos todo) async {
    tasks.refresh();
    todos.refresh();
  }

  int createdTasks() {
    return todos
        .where((todo) =>
            !tasks.any((task) => task.id == todo.taskId && task.archive))
        .length;
  }

  int completedTasks() {
    return todos
        .where((todo) =>
            !tasks.any((task) => task.id == todo.taskId && task.archive) &&
            todo.done)
        .length;
  }

  int createdTodosTask(Tasks task) {
    return todos.where((todo) => todo.taskId == task.id).length;
  }

  int completedTodosTask(Tasks task) {
    return todos
        .where((todo) => todo.taskId == task.id && todo.done == true)
        .length;
  }

  int countTotalTodosCalendar(DateTime date) {
    int count = 0;
    for (var task in tasks) {
      if (!task.archive) {
        count += task.todos
            .where((todo) =>
                !todo.done &&
                todo.todoCompletedTime != null &&
                DateTime(date.year, date.month, date.day, 0, -1)
                    .isBefore(todo.todoCompletedTime!) &&
                DateTime(date.year, date.month, date.day, 23, 60)
                    .isAfter(todo.todoCompletedTime!))
            .length;
      }
    }
    return count;
  }

  void doMultiSelectionTask(Tasks task) {
    if (isMultiSelectionTask.isTrue) {
      isPop.value = false;
      if (selectedTask.contains(task)) {
        selectedTask.remove(task);
      } else {
        selectedTask.add(task);
      }

      if (selectedTask.isEmpty) {
        isMultiSelectionTask.value = false;
        isPop.value = true;
      }
    }
    tasks.refresh();
  }

  void doMultiSelectionTaskClear() {
    selectedTask.clear();
    isMultiSelectionTask.value = false;
    isPop.value = true;
    tasks.refresh();
  }

  void doMultiSelectionTodoClear() {
    selectedTodo.clear();
    isMultiSelectionTodo.value = false;
    isPop.value = true;
  }

  void doMultiSelectionTodo(Todos todos) {
    if (isMultiSelectionTodo.isTrue) {
      isPop.value = false;
      if (selectedTodo.contains(todos)) {
        selectedTodo.remove(todos);
      } else {
        selectedTodo.add(todos);
      }

      if (selectedTodo.isEmpty) {
        isMultiSelectionTodo.value = false;
        isPop.value = true;
      }
    }
  }
}
