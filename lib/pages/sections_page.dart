import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../model/todo_entry.dart';
import '../redux/core.dart';
import '../redux/actions.dart';
import 'todo_list_page.dart';

@immutable
class SectionsViewModel {
  final List<SectionModel> sections;
  final List<TodoEntryModel> todos;
  final Function(SectionModel) addSectionCallback;
  final Function(SectionModel) updateSectionCallback;
  final Function(SectionModel) deleteSectionCallback;

  SectionsViewModel({this.sections, this.todos, this.addSectionCallback, this.updateSectionCallback, this.deleteSectionCallback});
}

class SectionsPage extends StatelessWidget {
  final _listViewScrollController = new ScrollController();

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<ReduxState, SectionsViewModel>(
      converter: (store) => new SectionsViewModel(
          sections: store.state.sections,
          todos: store.state.todos,
          addSectionCallback: (section) =>
              store.dispatch(new AddSectionAction(section)),
          updateSectionCallback: (section) =>
              store.dispatch(new UpdateSectionAction(section)),
          deleteSectionCallback: (section) =>
              store.dispatch(new DeleteSectionAction(section))
      ),                      
      builder: (context, viewModel) {
        return new Scaffold(
          appBar: new AppBar(
            title: new Text("Sections"),
          ),
          body: _buildSectionsList(context, viewModel),
          floatingActionButton: new FloatingActionButton(
            onPressed: () => _addNewSection(context, viewModel),
            tooltip: 'Add new section',
            child: new Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildSectionsList(BuildContext context, SectionsViewModel viewModel) {
    final ThemeData theme = Theme.of(context);
    final TextStyle textStyle = theme.textTheme.subhead.copyWith(color: theme.textTheme.caption.color);

    var list = viewModel.sections.map((entry) {
      var todosInSection = viewModel.todos.where((todo) => todo.section == entry.id);
      var doneTodosInSection = todosInSection.where((todo) => todo.done);

      return new InkWell(
        onTap: () => Navigator.of(context).push(new MaterialPageRoute(
          builder: (context) => new TodoListPage(entry))),
        onLongPress: () => _showActionsMenu(context, viewModel, entry),
        child: new ListTile(
          title: new Text('${entry.title} (${doneTodosInSection.length}/${todosInSection.length})'),
          trailing: new Icon(Icons.arrow_right),
        ),
      );
    });

    return list.length > 0
        ? new ListView(
            shrinkWrap: true,
            reverse: false,
            controller: _listViewScrollController,
            children:
                ListTile.divideTiles(context: context, tiles: list).toList())
        : new Center(child: new Text("No sections", style: textStyle));
  }

  void _showActionsMenu(BuildContext context, SectionsViewModel viewModel, SectionModel section) async {
    var isEditOrDelete = await showDialog<bool>(
      context: context,
      builder: (context) => new SimpleDialog(
        children: <Widget>[
          new ListTile(
            leading: new Icon(Icons.edit),
            title: new Text("Edit"),
            onTap: () => Navigator.of(context).pop(true)
          ),
          new ListTile(
            leading: new Icon(Icons.delete),
            title: new Text("Delete"),
            onTap: () => Navigator.of(context).pop(false),
          )
        ],          
      )
    );

    if (isEditOrDelete != null) {
      if (isEditOrDelete) {
        _editSection(context, viewModel, section);
      } else {
        _deleteSection(context, viewModel, section);
      }
    }
  }

  void _addNewSection(BuildContext context, SectionsViewModel viewModel) async {
    var section = await showDialog<SectionModel>(
      context: context, 
      builder: (context) => new SectionDialog.add()
    );

    if (section != null) {
      viewModel.addSectionCallback(section);
    }
  }

  void _editSection(BuildContext context, SectionsViewModel viewModel, SectionModel section) async {
    var updated = await showDialog<SectionModel>(
      context: context, 
      builder: (context) => new SectionDialog.edit(section)
    );
      
    if (updated != null) {
      viewModel.updateSectionCallback(updated);
    }
  }

  void _deleteSection(BuildContext context, SectionsViewModel viewModel, SectionModel section) async {
    var confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return new AlertDialog(
          title: new Text("Are you sure you want to delete?"),
          content: new Text("Section `${section.title}` and all associated entries will be deleted."),
          actions: <Widget>[
            new FlatButton(
              child: new Text("CANCEL"),
              onPressed: () => Navigator.of(context).pop(false)
            ),
            new FlatButton(
              child: new Text("DELETE"),
              onPressed: () => Navigator.of(context).pop(true)
            )
          ],
        );
      }
    ) ?? false;

    if (confirmed) {      
      viewModel.deleteSectionCallback(section);
    }
  }
}

class SectionDialog extends StatefulWidget {
  final SectionModel sectionToEdit;

  SectionDialog.add() : sectionToEdit = null;

  SectionDialog.edit(this.sectionToEdit);

  @override
  SectionDialogState createState() => new SectionDialogState();
}

class SectionDialogState extends State<SectionDialog> {
  SectionModel section;
  final _formKey = new GlobalKey<FormState>();
  bool _autovalidate = false;

  bool get isEditing => widget.sectionToEdit != null;

  @override
  void initState() {
    section = isEditing ? widget.sectionToEdit : new SectionModel(id: 0, title: "");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Form(
    key: _formKey,
    autovalidate: _autovalidate,      
    child: new AlertDialog(
      title: new Text(isEditing ? "Edit section" : "Add section"),
      content:  new TextFormField(
        initialValue: isEditing ? widget.sectionToEdit.title : '',
        validator: (str) => str.isEmpty ? "Required" : null,
        onSaved: (str) => section.title = str,
      ),
      actions: <Widget>[
        new FlatButton(
          child: new Text("CANCEL"),
          onPressed: () => Navigator.of(context).pop(null)
        ),
        new FlatButton(
          child: new Text(isEditing ? "SAVE" : "ADD"),
          onPressed: _save
        )
      ],
    ));
  }

  void _save() {
    var form = _formKey.currentState;
    if (!form.validate()) {
      _autovalidate = true;
    } else {      
      form.save();
      Navigator.of(context).pop(section);
    }
  }
}