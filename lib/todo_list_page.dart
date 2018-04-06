import 'dart:async';

import 'package:flutter/material.dart';

import 'model/todo_entry.dart';
import 'todo_entry_dialog.dart';
import 'data_manager.dart';

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
  TodoListPageState createState() => new TodoListPageState();
}

class TodoListPageState extends State<TodoListPage> {
  int _selectedSection = 0;
  List<TodoEntryModel> _todoList = new List();
  ScrollController _listViewScrollController = new ScrollController();
  TextEditingController _titleEditingController;

  DataManager data = new DataManager();

  bool _editSectionTitle = false;

  @override
  void initState() {
    _selectSection(0);
    _titleEditingController = new TextEditingController(text: data.getSection(_selectedSection));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      drawer: _buildDrawer(context),
      appBar: new AppBar(
        title: _editSectionTitle
            ? new TextField(
                controller: _titleEditingController,
                decoration: new InputDecoration(hintText: "Section title"),
                style: new TextStyle(color: Colors.white))
            : new Text("${data.getSection(_selectedSection)}"),
        actions: [
          _editSectionTitle
              ? new IconButton(
                  icon: new Icon(Icons.delete),
                  onPressed: () => _deleteSection(_selectedSection))
              : new Container(),
          new IconButton(
            icon: new Icon(_editSectionTitle ? Icons.save : Icons.edit),
            onPressed: () => setState(() {
              if (_editSectionTitle)
                data.updateSection(_selectedSection, _titleEditingController.text);

              _editSectionTitle = !_editSectionTitle;
            }),
          )
        ],
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

  Widget _buildDrawer(BuildContext context) {
    var drawerItems = <Widget>[];

    drawerItems.add(new DecoratedBox(
      child: new Padding(
        padding: const EdgeInsets.all(16.0),
        child: new Text(
          'ToDo list',
          //textAlign: TextAlign.center,
          style: new TextStyle(
            fontSize: 28.0, 
            color: Colors.white),
        )),
      decoration: new BoxDecoration(
        color: Colors.blue
      ),
    ));

    // Sections
    drawerItems.add(new Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
        child: new Row(children: [
          new Expanded(
              child:
                  new Text("Sections", style: new TextStyle(fontSize: 22.0))),
          new IconButton(
            icon: new Icon(Icons.add),
            alignment: Alignment.centerRight,
            onPressed: _addSection,
          ),
        ])));

    for (var idx in data.getSections().keys) {
      drawerItems.add(new FlatButton(
          child: new Text(data.getSection(idx),
              style: new TextStyle(fontSize: 16.0)),
          onPressed: () {
            _selectSection(idx);
            Navigator.pop(context);
          }));
    }

    drawerItems.add(new Divider());

    return new Drawer(child: new ListView(primary: false, children: drawerItems));
  }

  void _addSection() {
    setState(() => data.addSection(data.getSectionNextId(), "New Section"));
  }

  void _deleteSection(int sectionId) {
    setState(() {
      data.deleteSection(sectionId);
      _editSectionTitle = false;
      if (_selectedSection == sectionId)
        _selectSection(data.getSections().keys.elementAt(0));
    });
  }

  void _selectSection(int sectionId) {
    setState(() {
      _editSectionTitle = false;
      _todoList = data.getTodo(sectionId).toList();
      _selectedSection = sectionId;
    });
  }

  Future _openAddEntryDialog() async {
    var entry =
        await Navigator.of(context).push(new MaterialPageRoute<TodoEntryModel>(
            builder: (BuildContext context) {
              return new TodoEntryDialog.add(_selectedSection);
            },
            fullscreenDialog: true));

    if (entry != null) _addTodoListEntry(entry);
  }

  void _addTodoListEntry(TodoEntryModel entry) {
    setState(() {
      data.addTodo(entry);
      _selectSection(entry.section);
    });
  }

  void _editTodoEntry(TodoEntryModel entry) async {
    _editSectionTitle = false;

    var newEntry = await Navigator.of(context).push(
        new MaterialPageRoute<TodoEntryModel>(
            builder: (BuildContext context) => new TodoEntryDialog.edit(entry),
            fullscreenDialog: true));

    setState(() {
      if (newEntry != null)
        data.updateTodo(entry.id, (newEntry as TodoEntryModel));
      _selectSection(_selectedSection);
    });
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
            style: new TextStyle(
              fontSize: 18.0, 
              decoration: widget.entry.done ? TextDecoration.lineThrough : null),
          )
        ]));
  }
}
