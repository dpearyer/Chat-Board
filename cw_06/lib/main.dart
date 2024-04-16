import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'task.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TaskListScreen(),
    );
  }
}


class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final List<Task> _tasks = [];
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() async {
    final user = _auth.currentUser;
    if (user != null) {
      var snapshot = await _db.collection('tasklist').where('userId', isEqualTo: user.uid).get();
      setState(() {
        _tasks.clear();
        for (var doc in snapshot.docs) {
          _tasks.add(Task.fromMap(doc.data()));
        }
      });
    }
  }

  void _addTask(String name) async {
    final user = _auth.currentUser;
    if (user != null) {
      var task = Task(id: '', name: name, isCompleted: false);
      var docRef = await _db.collection('tasklist').add({
        ...task.toMap(),
        'userId': user.uid,
      });
      setState(() {
        _tasks.add(task..id = docRef.id);
      });
    }
  }

  void _toggleCompletion(Task task) async {
    await _db.collection('tasklist').doc(task.id).update({
      'isCompleted': !task.isCompleted,
    });
    setState(() {
      task.isCompleted = !task.isCompleted;
    });
  }

  void _deleteTask(Task task) async {
    await _db.collection('tasklist').doc(task.id).delete();
    setState(() {
      _tasks.remove(task);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task List'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return ListTile(
            title: Text(task.name),
            leading: Checkbox(
              value: task.isCompleted,
              onChanged: (_) => _toggleCompletion(task),
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _deleteTask(task),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add logic to show a dialog or another screen to input the task name
          _addTask('New Task'); // Placeholder for task addition
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

