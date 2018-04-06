import 'package:flutter/material.dart';
import 'todo_list_page.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'ToDo list',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new TodoListPage(),
    );
  }
}
