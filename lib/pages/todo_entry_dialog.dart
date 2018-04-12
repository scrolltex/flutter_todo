import 'dart:async';

import 'package:flutter/material.dart';

import '../model/todo_entry.dart';

class TodoEntryDialog extends StatefulWidget {
  final TodoEntryModel entryToEdit;
  final int sectionId;

  TodoEntryDialog.add(this.sectionId) : entryToEdit = null;

  TodoEntryDialog.edit(this.entryToEdit) : sectionId = entryToEdit.section;

  @override
  TodoEntryDialogState createState() => new TodoEntryDialogState();
}

class TodoEntryDialogState extends State<TodoEntryDialog> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  TodoEntryModel model;
  bool _saveNeeded = false;

  @override
  void initState() {
    model = widget.entryToEdit ??
        new TodoEntryModel(id: 0, section: widget.sectionId, title: "");
    super.initState();
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
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
          onPressed: _saveEntry,
        ),
      ],
    );
  }

  void _saveEntry() {
    final FormState form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      Navigator.of(context).pop(model);
    } else {
      showInSnackBar('Please fix the errors in red before saving.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        appBar: _createAppBar(context),
        body: new Form(
            key: _formKey,
            autovalidate: true,
            onWillPop: _onWillPop,
            child: new ListView(children: <Widget>[
              new ListTile(
                leading: new Icon(Icons.title, color: Colors.grey[500]),
                title: new TextFormField(
                  initialValue: model.title,
                  decoration: new InputDecoration(
                    labelText: "Title *",
                    hintText: 'What do you want to do?',
                  ),
                  onSaved: (String value) => model.title = value,
                  validator: (String value) {
                    _saveNeeded = true;

                    if (value.isEmpty) return "Title is required.";
                  },
                ),
              ),
              new ListTile(
                  leading:
                      new Icon(Icons.info_outline, color: Colors.grey[500]),
                  title: new Row(
                    children: <Widget>[
                      new IconButton(
                        icon: new Icon(Icons.info_outline,
                            color: model.importance == TodoImportance.Low
                                ? Colors.lightBlue
                                : Colors.grey[600]),
                        onPressed: () => setState(() {
                              model.importance = TodoImportance.Low;
                              _saveNeeded = true;
                            }),
                      ),
                      new IconButton(
                        icon: new Icon(Icons.warning,
                            color: model.importance == TodoImportance.Middle
                                ? Colors.yellow
                                : Colors.grey[600]),
                        onPressed: () => setState(() {
                              model.importance = TodoImportance.Middle;
                              _saveNeeded = true;
                            }),
                      ),
                      new IconButton(
                        icon: new Icon(Icons.error,
                            color: model.importance == TodoImportance.High
                                ? Colors.red
                                : Colors.grey[600]),
                        onPressed: () => setState(() {
                              model.importance = TodoImportance.High;
                              _saveNeeded = true;
                            }),
                      ),
                    ],
                  )),
              new ListTile(
                  leading: new Icon(Icons.note),
                  title: new TextFormField(
                    initialValue: model.note,
                    decoration: new InputDecoration(
                      labelText: "Note",
                      hintText: "Additional notes",
                    ),
                    maxLines: 5,
                    onSaved: (String value) => model.note = value,
                    validator: (String value) {
                      _saveNeeded = true;
                      return null;
                    },
                  )),
            ])));
  }

  Future<bool> _onWillPop() async {
    if (!_saveNeeded) return true;

    final ThemeData theme = Theme.of(context);
    final TextStyle dialogTextStyle =
        theme.textTheme.subhead.copyWith(color: theme.textTheme.caption.color);

    return await showDialog<bool>(
            context: context,
            builder: (context) {
              return new AlertDialog(
                content: new Text('Discard changes?', style: dialogTextStyle),
                actions: <Widget>[
                  new FlatButton(
                      child: const Text('CANCEL'),
                      onPressed: () => Navigator.of(context).pop(false)),
                  new FlatButton(
                      child: const Text('DISCARD'),
                      onPressed: () => Navigator.of(context).pop(true))
                ],
              );
            }) ??
        false;
  }

  void _deleteTodo() async {
    final ThemeData theme = Theme.of(context);
    final TextStyle dialogTextStyle =
        theme.textTheme.subhead.copyWith(color: theme.textTheme.caption.color);

    var confirmDelete = await showDialog<bool>(
        context: context,
        builder: (context) {
          return new AlertDialog(
            title: new Text("Delete this todo?", style: dialogTextStyle),
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
          );
        });

    if (confirmDelete != null && confirmDelete) {
      //TODO: Implement deleting
      Navigator.pop(context);
    }
  }
}
