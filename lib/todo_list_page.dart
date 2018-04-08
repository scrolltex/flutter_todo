import 'dart:async';

import 'package:flutter/material.dart';
import 'package:share/share.dart';

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
                  tooltip: "Delete section",
                  onPressed: () => _deleteSection(_selectedSection))
              : new Container(),
          new IconButton(
            icon: new Icon(_editSectionTitle ? Icons.save : Icons.edit),
            tooltip: _editSectionTitle 
              ? "Save new title" 
              : "Edit section title",
            onPressed: () => setState(() {
              if (_editSectionTitle)
                data.updateSection(_selectedSection, _titleEditingController.text);

              _editSectionTitle = !_editSectionTitle;
            }),
          ),
          new IconButton(
            icon: new Icon(Icons.share),
            tooltip: "Share section",
            onPressed: () {
              var shareString = "${data.getSection(_selectedSection)}:\n";

              for (var item in data.getTodo(_selectedSection)) {
                var importanceChar = '';
                switch (item.importance) {
                  case TodoImportance.Middle: importanceChar = '!'; break;
                  case TodoImportance.High: importanceChar = '!!'; break;
                  default: importanceChar = '';
                }

                shareString += "[${item.done ? 'x' : '  '}] $importanceChar ${item.title}\n";
              }

              share(shareString);
            })
        ],
      ),
      body: _buildTodoList(),
      floatingActionButton: new FloatingActionButton(
        onPressed: _openAddEntryDialog,
        tooltip: 'Add new ToDo',
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
          onTap: () => _showTodoBottomSheet(_todoList[index]),
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
        padding: const EdgeInsets.all(24.0),
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
        padding: const EdgeInsets.only(left: 16.0),
        child: new Row(children: [
          new Expanded(
              child: new Text(
                "Sections", 
                style: new TextStyle(
                  fontSize: 22.0, 
                  fontWeight: FontWeight.w500))),
          new IconButton(
            icon: new Icon(Icons.add),
            tooltip: "Add new section",
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

  void _showTodoBottomSheet(TodoEntryModel model) {
    assert(model != null);

    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return new ListView(children: <Widget>[
          new ListTile(
            leading: new Icon(Icons.title),
            title: new Text(model.title),
            trailing: getImportanceIcon(model.importance)),
          new ListTile(
            leading: new Icon(Icons.category),
            title: new Text(data.getSection(model.section))),
          new ListTile(
            leading: new Icon(Icons.note),
            title: new Text(
              model.note.isNotEmpty ? model.note : "(Empty)", 
              maxLines: 5)
          )]
        );
      });
  }

  void _addSection() => setState(() => data.addSection(data.getSectionNextId(), "New Section"));

  void _deleteSection(int sectionId) async {
    final ThemeData theme = Theme.of(context);
    final TextStyle dialogTextStyle = theme.textTheme.subhead.copyWith(color: theme.textTheme.caption.color);

    var confirmDelete = await showDialog<bool>(
      context: context,
      child: new AlertDialog(
        title: new Text(
          "Delete this todo?",
          style: dialogTextStyle
        ),
        actions: [
          new FlatButton(
            child: const Text("CANCEL"),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          new FlatButton(
            child: const Text("DELETE"),
            onPressed: () => Navigator.of(context).pop(true),
          )
        ],
      )
    ) ?? false;

    if (!confirmDelete)
      return;

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
    var entry = await Navigator.of(context).push(
        new MaterialPageRoute<TodoEntryModel>(
          builder: (BuildContext context) => new TodoEntryDialog.add(_selectedSection),
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
      if (newEntry != null) data.updateTodo(entry.id, (newEntry as TodoEntryModel));
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
    return new ListTile(
      leading: new Checkbox(
        value: widget.entry.done,
        onChanged: (newValue) => setState(() => widget.entry.done = newValue)),
      title: new Text(
        widget.entry.title,
        style: new TextStyle(
          fontSize: 18.0, 
          decoration: widget.entry.done ? TextDecoration.lineThrough : null)),
      trailing: getImportanceIcon(widget.entry.importance));
  }
}
