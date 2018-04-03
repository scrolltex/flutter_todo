import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: new TodoListPage(),
    );
  }
}

enum TodoImportance {
  Low,
  Middle,
  High,
}

class TodoEntry {
  TodoEntry([this.title, this.importance = TodoImportance.Low, this.isComplete = false]);

  TodoImportance importance;
  bool isComplete;
  String title;

  final TextEditingController _controller = new TextEditingController();

  Icon getImportanceIcon() {
    switch(importance)
    {
      case TodoImportance.Low: return new Icon(Icons.info_outline);
      case TodoImportance.Middle: return new Icon(Icons.warning, color: Colors.yellow);
      case TodoImportance.High: return new Icon(Icons.error, color: Colors.red);
      default: return null;
    }
  }
}

class TodoListPage extends StatefulWidget {
  @override
  _TodoListPageState createState() => new _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final _categories = <TodoEntry>[];
  bool _editMode = false;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("TODO list"),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(_editMode ? Icons.save : Icons.edit),
            onPressed: () { 
              setState(() { 
                if (!_editMode)
                  _editMode = true;
                else 
                  _saveEdited();
              }); 
            },
          ),
        ],
      ),
      body:_buildTodoList(),
      floatingActionButton: new FloatingActionButton(
        onPressed: _createNewItem,
        tooltip: 'Create new todo',
        child: new Icon(Icons.add),
      ),
    );
  }

  Widget _buildTodoList() {
     return new ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, i) {
        if (i.isOdd) return new Divider();

        final index = i ~/ 2;
        if (index < _categories.length)
          return _buildRow(_categories[index]);
      },
    );
  }

  Widget _buildRow(TodoEntry item) {
    return new ListTile(
      leading: !_editMode ? 
        item.getImportanceIcon() : 
        new IconButton(
          icon: item.getImportanceIcon(), 
          onPressed: () { setState(() { 
            var idx = item.importance.index + 1;
            if (idx >= TodoImportance.values.length) idx = 0;
            item.importance = TodoImportance.values[idx]; 
            }); },
        ),

      title: !_editMode ? 
        new Text(
          item.title,
          style: new TextStyle(fontSize: 18.0),
        ) : 
        new TextField(
            controller: item._controller,
            decoration: new InputDecoration(
              hintText: item.title,
            ),
        ),

      trailing: !_editMode ? 
        new Checkbox(
          value: item.isComplete,
          onChanged: (newValue) { setState(() { item.isComplete = newValue; }); },
        ) : 
        new IconButton(
          icon: new Icon(Icons.delete), 
          onPressed: () { setState(() { _categories.remove(item); }); },
        ),

      onTap: () { setState(() { item.isComplete = !item.isComplete; }); },
    );
  }

  void _createNewItem() {
      setState(() {
          _categories.add(new TodoEntry(new WordPair.random().asPascalCase));
      });
  }

  void _saveEdited() {
    setState(() {
      for(var item in _categories) {
        if (item._controller.text.isNotEmpty)
          item.title = item._controller.text;
      }
      _editMode = false;
    });
  }
}