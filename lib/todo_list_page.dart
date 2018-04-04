import 'dart:async';

import 'package:flutter/material.dart';

import 'model/todo_entry.dart';
import 'todo_entry_dialog.dart';

Icon getImportanceIcon(TodoImportance importance) {
  switch (importance) {
    case TodoImportance.Low:
      return new Icon(Icons.info_outline, color: Colors.lightBlue);
    case TodoImportance.Middle:
      return new Icon(Icons.warning, color: Colors.yellow);
    case TodoImportance.High:
      return new Icon(Icons.error, color: Colors.red);
    default:
      return null;
  }
}

class TodoListPage extends StatefulWidget {
  @override
  _TodoListPageState createState() => new _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List<TodoEntryModel> _todoList = new List();
  ScrollController _listViewScrollController = new ScrollController();

  @override
  Widget build(BuildContext context) {
    var drawer = new Drawer();

    return new Scaffold(
      drawer: drawer,
      appBar: new AppBar(
        title: new Text("TODO list"),
      ),
      body: _buildTodoList(),
      floatingActionButton: new FloatingActionButton(
        onPressed: _openAddEntryDialog,
        tooltip: 'Add new todo entry',
        child: new Icon(Icons.add),
      ),
    );
  }

  Widget _buildTodoList() {
    return new ListView.builder(
      shrinkWrap: true,
      reverse: true,
      controller: _listViewScrollController,
      itemCount: _todoList.length,
      itemBuilder: (context, index) {
        return new InkWell(
          onTap: () =>
              setState(() => _todoList[index].done = !_todoList[index].done),
          onLongPress: () => _editTodoEntry(_todoList[index]),
          child: new TodoListItem(entry: _todoList[index]),
        );
      },
    );
  }

  Future _openAddEntryDialog() async {
    var entry =
        await Navigator.of(context).push(new MaterialPageRoute<TodoEntryModel>(
            builder: (BuildContext context) {
              return new TodoEntryDialog.add();
            },
            fullscreenDialog: true));

    if (entry != null) _addTodoListEntry(entry);
  }

  void _addTodoListEntry(TodoEntryModel entry) {
    setState(() => _todoList.add(entry));
  }

  void _editTodoEntry(TodoEntryModel entry) {
    Navigator
        .of(context)
        .push(new MaterialPageRoute<TodoEntryModel>(
            builder: (BuildContext context) {
              return new TodoEntryDialog.edit(entry);
            },
            fullscreenDialog: true))
        .then((newEntry) => setState(() {
              if (newEntry != null)
                _todoList[_todoList.indexOf(entry)] = (newEntry as TodoEntryModel);
            }));
  }
}

class TodoListItem extends StatefulWidget {
  TodoListItem({Key key, this.entry}) : super(key: key);

  final TodoEntryModel entry;

  @override
  TodoListItemState createState() => new TodoListItemState();
}

class TodoListItemState extends State<TodoListItem> {
  @override
  Widget build(BuildContext context) {
    return new Padding(
        padding: new EdgeInsets.all(8.0),
        child: new Row(children: [
          new Checkbox(
            value: widget.entry.done,
            onChanged: (newValue) => setState(() {
                  widget.entry.done = newValue;
                }),
          ),
          getImportanceIcon(widget.entry.importance),
          new Text(
            widget.entry.title,
            style: new TextStyle(fontSize: 18.0),
          )
        ]));
  }
}
