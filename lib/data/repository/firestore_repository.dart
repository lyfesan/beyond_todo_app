import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../models/task.dart';

class FirestoreRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // USERS
  Future<void> createUser(User user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<User?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return User.fromDocument(doc);
    }
    return null;
  }

  // TASKS (Subcollection of /users/{userId}/tasks)

  Future<void> addTask(Task task) async {
    await _firestore
        .collection('users')
        .doc(task.userId)
        .collection('tasks')
        .doc(task.id)
        .set(task.toMap());
  }

  Stream<List<Task>> getUserTasks(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Task.fromDocument(doc)).toList());
  }

  Future<void> updateTask(Task task) async {
    await _firestore
        .collection('users')
        .doc(task.userId)
        .collection('tasks')
        .doc(task.id)
        .update(task.toMap());
  }

  Future<void> deleteTask(String userId, String taskId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }
}
