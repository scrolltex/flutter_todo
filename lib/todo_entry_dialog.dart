import 'dart:async';

import 'package:flutter/material.dart';
import 'model/todo_entry.dart';

import 'data_manager.dart';

class TodoEntryDialog extends StatefulWidget {
  final TodoEntryModel entryToEdit;
  final int id;
  final int sectionId;

  TodoEntryDialog.add(this.sectionId) 
    : id = new DataManager().getTodoNextId(), 
      entryToEdit = null;

  TodoEntryDialog.edit(this.entryToEdit) 
    : id = entryToEdit.id,
      sectionId = entryToEdit.section;

  @override
  TodoEntryDialogState createState() => new TodoEntryDialogState();
}

class TodoEntryDialogState extends State<TodoEntryDialog> {
  TextEditingController _titleTextEditingController;
  TextEditingController _noteTextEditingController;

  String _title;
  TodoImportance _importance;
  String _note;
  bool _saveNeeded = false;

  VoidCallback _saveCallback;

  @override
  void initState() {
    _title = widget.entryToEdit?.title ?? "";
    _importance = widget.entryToEdit?.importance ?? TodoImportance.Low;
    _note = widget.entryToEdit?.note ?? "";

    _titleTextEditingController = new TextEditingController(text: _title);
    _noteTextEditingController = new TextEditingController(text: _note);

    _saveCallback = null;

    super.initState();
  }

  Widget _createAppBar(BuildContext context) {
    return new AppBar(
      title: widget.entryToEdit == null
          ? const Text("New TODO")
          : const Text("Edit TODO"),
      actions: [
        widget.entryToEdit != null
        ? new IconButton(
            icon: new Icon(Icons.delete, color: Colors.white),
            tooltip: "Delete",
            onPressed: _deleteTodo,
          )
        : new Container(),
        new IconButton(
          icon: new Icon(Icons.save, color: Colors.white),
          tooltip: "Save",
          onPressed: _saveCallback,
        ),
      ],
    );
  }

  void _saveEntry() {
    Navigator
      .of(context)
      .pop(new TodoEntryModel(
        widget.id, 
        widget.sectionId, 
        _title,
        _note, 
        _importance, 
        widget.entryToEdit?.done ?? false));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: _createAppBar(context),
        body: new Form(
          onWillPop: _onWillPop, 
          child: new ListView(children: <Widget>[
            new ListTile(
              leading: new Icon(Icons.title, color: Colors.grey[500]),
              title: new TextField(
                decoration: new InputDecoration(
                  labelText: "Title",
                  hintText: 'What you want to do?',
                ),
                controller: _titleTextEditingController,
                onChanged: (value) {
                  _title = value;
                  _saveNeeded = true;
                }
              ),
            ),
            new ListTile(
                leading: new Icon(Icons.info_outline, color: Colors.grey[500]),
                title: new Row(
                  children: <Widget>[
                    new IconButton(
                      icon: new Icon(Icons.info_outline,
                          color: _importance == TodoImportance.Low
                              ? Colors.lightBlue
                              : Colors.grey[600]),
                      onPressed: () => setState(() {
                        _importance = TodoImportance.Low;
                        _saveNeeded = true;
                      }),
                    ),
                    new IconButton(
                      icon: new Icon(Icons.warning,
                          color: _importance == TodoImportance.Middle
                              ? Colors.yellow
                              : Colors.grey[600]),
                      onPressed: () => setState(() {
                        _importance = TodoImportance.Middle;
                        _saveNeeded = true;
                      }),
                    ),
                    new IconButton(
                      icon: new Icon(Icons.error,
                          color: _importance == TodoImportance.High
                              ? Colors.red
                              : Colors.grey[600]),
                      onPressed: () => setState(() {
                        _importance = TodoImportance.High;
                        _saveNeeded = true;
                      }),
                    ),
                  ],
                )),
            new ListTile(
              leading: new Icon(Icons.note),
              title: new TextField(
                controller: _noteTextEditingController,
                decoration: new InputDecoration(                  
                  labelText: "Note",
                  hintText: "Additional notes",
                ),
                maxLines: 5,
                onChanged: (value) {
                  _note = value;
                  _saveNeeded = true;
                },
              )
            ),    
          ]
        )
      )
    );
  }

  Future<bool> _onWillPop() async {
    if (!_saveNeeded)
      return true;
      
    final ThemeData theme = Theme.of(context);
    final TextStyle dialogTextStyle = theme.textTheme.subhead.copyWith(color: theme.textTheme.caption.color);

    return await showDialog<bool>(
      context: context,
      child: new AlertDialog(
          content: new Text(
            'Discard new event?',
            style: dialogTextStyle
          ),
          actions: <Widget>[
            new FlatButton(
              child: const Text('CANCEL'),
              onPressed: () =>  Navigator.of(context).pop(false)
            ),
            new FlatButton(
              child: const Text('DISCARD'),
              onPressed: () =>  Navigator.of(context).pop(true)
            )
          ],
        )
    ) ?? false;
  }

  void _deleteTodo() async {    
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

    setState(() => new DataManager().deleteTodo(widget.entryToEdit.id));
    Navigator.pop(context);
  }
}
