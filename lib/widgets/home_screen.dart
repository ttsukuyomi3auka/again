// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _titleController = TextEditingController();
  bool isCompleted = true;

  final CollectionReference _tasks =
      FirebaseFirestore.instance.collection("tasks");

  void _addTask() {
    _tasks.add({
      'title': _titleController.text,
      'completed': false,
    });
    isCompleted = false;
    _titleController.clear();
  }

  void _deleteTask(String taskId) {
    _tasks.doc(taskId).delete();
  }

  void _updateTask(String taskId) {
    _tasks.doc(taskId).update({
      'title': _titleController.text,
      'completed': isCompleted,
    });
    isCompleted = false;
    _titleController.clear();
  }

  void _editTask(DocumentSnapshot task) {
    _titleController.text = task['title'];
    bool isCompleted = task['completed'];

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Внести изменения'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: "Задача"),
                ),
                SizedBox(
                  height: 20,
                ),
                DropdownButton<String>(
                  value: isCompleted ? 'Выполнено' : 'Не выполнено',
                  onChanged: (String? newValue) {
                    setState(() {
                      isCompleted = newValue == 'Выполнено';
                    });
                  },
                  items: <String>['Не выполнено', 'Выполнено']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                SizedBox(
                  height: 20,
                ),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Назад")),
                SizedBox(
                  height: 5,
                ),
                ElevatedButton(
                    onPressed: () {
                      _updateTask(task.id);
                    },
                    child: Text("Обновить")),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CRUD"),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: "Введите задачу"),
            ),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              height: 20,
            ),
            Center(
              child: ElevatedButton(
                  onPressed: () {
                    _addTask();
                  },
                  child: Text("Добавить задачу")),
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
                child: StreamBuilder(
              stream: _tasks.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var task = snapshot.data!.docs[index];
                    return Dismissible(
                      key: Key(task.id),
                      background: Container(
                        color: Color.fromARGB(255, 127, 37, 30),
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(left: 20),
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: Icon(Icons.delete),
                      ),
                      onDismissed: (direction) {
                        _deleteTask(task.id);
                      },
                      direction: DismissDirection.startToEnd,
                      child: Card(
                        elevation: 4,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(task['title']),
                          subtitle: task['completed'] == true
                              ? Icon(Icons.check)
                              : Icon(Icons.close),
                          trailing: Column(
                            children: [
                              IconButton(
                                  onPressed: () {
                                    _editTask(task);
                                  },
                                  icon: Icon(Icons.edit)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ))
          ],
        ),
      ),
    );
  }
}
