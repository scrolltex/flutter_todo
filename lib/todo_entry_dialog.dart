import 'package:flutter/material.dart';

import 'model/todo_entry.dart';

class TodoEntryDialog extends StatefulWidget {
  final TodoEntryModel entryToEdit;

  TodoEntryDialog.add() : entryToEdit = null;
  TodoEntryDialog.edit(this.entryToEdit);

  @override
  TodoEntryDialogState createState() {
    if (entryToEdit != null)
      return new TodoEntryDialogState(
          entryToEdit.title, "", entryToEdit.importance);
    else
      return new TodoEntryDialogState("", "", TodoImportance.Low);
  }
}

class TodoEntryDialogState extends State<TodoEntryDialog> {
  TextEditingController _titleTextEditingController;
  TextEditingController _noteTextEditingController;

  String _title;
  String _note;
  TodoImportance _importance;

  TodoEntryDialogState(this._title, this._note, this._importance);

  @override
  void initState() {
    _titleTextEditingController = new TextEditingController(text: _title);
    _noteTextEditingController = new TextEditingController(text: _note);
    super.initState();
  }

  Widget _createAppBar(BuildContext context) {
    return new AppBar(
      title: widget.entryToEdit == null
          ? const Text("New TODO")
          : const Text("Edit TODO"),
      actions: [
        new IconButton(
            icon: new Icon(Icons.delete, color: Colors.white),
            tooltip: "Delete",
            onPressed: () {
              //TODO: Delete todo entry
            },
          ),
        new IconButton(
          icon: new Icon(Icons.save, color: Colors.white,),
          tooltip: "Save",
          onPressed: () {
            Navigator
                .of(context)
                .pop(new TodoEntryModel(_title, _importance, widget.entryToEdit?.done ?? false));
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: _createAppBar(context),
        body: new Column(children: <Widget>[
          new ListTile(
            leading: new Icon(Icons.title, color: Colors.grey[500]),
            title: new TextField(
              decoration: new InputDecoration(
                hintText: 'Title',
              ),
              controller: _titleTextEditingController,
              onChanged: (value) => _title = value,
            ),
          ),
          new ListTile(
            leading: new Icon(Icons.speaker_notes, color: Colors.grey[500]),
            title: new TextField(
              decoration: new InputDecoration(
                hintText: 'Optional note',
              ),
              maxLines: 4,
              controller: _noteTextEditingController,
              onChanged: (value) => _note = value,
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
                    onPressed: () {
                      setState(() {
                        _importance = TodoImportance.Low;
                      });
                    },
                  ),
                  new IconButton(
                    icon: new Icon(Icons.warning,
                        color: _importance == TodoImportance.Middle
                            ? Colors.yellow
                            : Colors.grey[600]),
                    onPressed: () {
                      setState(() {
                        _importance = TodoImportance.Middle;
                      });
                    },
                  ),
                  new IconButton(
                    icon: new Icon(Icons.error,
                        color: _importance == TodoImportance.High
                            ? Colors.red
                            : Colors.grey[600]),
                    onPressed: () {
                      setState(() {
                        _importance = TodoImportance.High;
                      });
                    },
                  ),
                ],
              )),
        ]));
  }
}
