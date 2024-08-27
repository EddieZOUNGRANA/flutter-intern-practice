import 'package:cloud_firestore/cloud_firestore.dart';

class Tasks {
  int id;
  String userId;
  String title;
  String description;
  int taskColor;
  bool archive;
  int? index;
  List<Todos> todos;

  Tasks({
    required this.id,
    required this.userId,
    required this.title,
    this.description = '',
    this.archive = false,
    required this.taskColor,
    this.index,
    this.todos = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'taskColor': taskColor,
      'archive': archive,
      'index': index,
      'todos': todos.map((todo) => todo.toMap()).toList(),
    };
  }

  factory Tasks.fromDocument(DocumentSnapshot doc) {
    return Tasks(
      id: doc ['id'],
      userId: doc['userId'],
      title: doc['title'] ?? '',
      description: doc['description'] ?? '',
      taskColor: doc['taskColor'] ?? 0,
      archive: doc['archive'] ?? false,
      index: doc['index'],
    );
  }
}

class Todos {
  int id;
  String userId;
  String name;
  String description;
  DateTime? todoCompletedTime;
  String taskstitle;
  bool done;
  bool fix;
  int taskId;

  Todos({
    required this.id,
    required this.userId,
    required this.name,
    this.description = '',
    this.todoCompletedTime,
    required this.taskstitle,
    this.done = false,
    this.fix = false,
    required this.taskId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'todoCompletedTime': todoCompletedTime,
      'taskstitle': taskstitle,
      'done': done,
      'fix': fix,
      'taskId': taskId,
    };
  }

  factory Todos.fromDocument(DocumentSnapshot doc) {
    return Todos(
      id: doc['id'],
      userId: doc['userId'],
      name: doc['name'],
      description: doc['description'] ?? '',
      todoCompletedTime: doc['todoCompletedTime'] != null
          ? (doc['todoCompletedTime'] as Timestamp).toDate()
          : null,
      taskstitle: doc['taskstitle'],
      done: doc['done'] ?? false,
      fix: doc['fix'] ?? false,
      taskId: doc['taskId'],
    );
  }
}
