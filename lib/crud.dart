import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/task.dart';

// Create
Future<void> addTask(String title) async {
  await FirebaseFirestore.instance.collection('tasks').add({
    'title': title,
    'completed': false,
  });
}

// Read
Stream<List<Task>> getTasks() {
  return FirebaseFirestore.instance
      .collection('tasks')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return Task(
        id: doc.id,
        title: data['title'] ?? '',
        completed: data['completed'] ?? false,
      );
    }).toList();
  });
}

// Update
Future<void> updateTask(String taskId, bool completed) async {
  await FirebaseFirestore.instance.collection('tasks').doc(taskId).update({
    'completed': completed,
  });
}

// Delete
Future<void> deleteTask(String taskId) async {
  await FirebaseFirestore.instance.collection('tasks').doc(taskId).delete();
}
