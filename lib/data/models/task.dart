import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final bool isDone;
  final DateTime createdAt;
  final DateTime? dueDate;

  Task({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.isDone,
    required this.createdAt,
    this.dueDate,
  });

  factory Task.fromMap(Map<String, dynamic> map, String id) {
    return Task(
      id: id,
      userId: map['userId'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      isDone: map['isDone'] as bool? ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      dueDate: map['dueDate'] != null
          ? (map['dueDate'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'isDone': isDone,
      'createdAt': Timestamp.fromDate(createdAt),
      if (dueDate != null) 'dueDate': Timestamp.fromDate(dueDate!),
    };
  }

  factory Task.fromDocument(DocumentSnapshot doc) {
    return Task.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }
}
