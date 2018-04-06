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
  TodoEntryDialogState createState() {
    if (entryToEdit != null) {
      return new TodoEntryDialogState(entryToEdit.title, entryToEdit.importance);
    } else {
      return new TodoEntryDialogState("", TodoImportance.Low);
    }
  }
}

class TodoEntryDialogState extends State<TodoEntryDialog> {
  TextEditingController _titleTextEditingController;

  String _title;
  TodoImportance _importance;

  TodoEntryDialogState(this._title, this._importance);

  @override
  void initState() {
    _titleTextEditingController = new TextEditingController(text: _title);
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
          onPressed: () {
            Navigator
                .of(context)
                .pop(new TodoEntryModel(widget.id, widget.sectionId, _title, _importance, widget.entryToEdit?.done ?? false));
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

  void _deleteTodo() async {    
    var confirmDelete = await showDialog<bool>(
      context: context,
      child: new AlertDialog(
        title: const Text("Are you sure you want to delete this?"),
        actions: [
          new FlatButton(
            child: const Text("Yes"),
            onPressed: () => Navigator.of(context).pop(true),
          ),
          new FlatButton(
            child: const Text("No"),
            onPressed: () => Navigator.of(context).pop(false),
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
