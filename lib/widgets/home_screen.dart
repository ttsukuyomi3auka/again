// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:again/models/task.dart';
import 'package:again/crud.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _titleController = TextEditingController();
  bool isCompleted = true;

  CollectionReference _tasks = FirebaseFirestore.instance.collection("tasks");
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
            Checkbox(
                value: isCompleted,
                onChanged: (value) {
                  setState(() {
                    isCompleted = value ?? false;
                  });
                }),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(onPressed: () {}, child: Text("Добавить задачу")),
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
                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(task['title']),
                        subtitle: task['completed'] == 'true'
                            ? Icon(Icons.check)
                            : Icon(Icons.close),
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
