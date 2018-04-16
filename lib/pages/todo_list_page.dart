import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:share/share.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../model/todo_entry.dart';
import '../redux/core.dart';
import '../redux/actions.dart';
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

@immutable
class TodoListViewModel {
  final List<TodoEntryModel> todos;
  final Function(TodoEntryModel) addEntryCallback;
  final Function(TodoEntryModel) updateEntryCallback;
  final Function(TodoEntryModel) deleteEntryCallback;

  TodoListViewModel({
    this.todos,
    this.addEntryCallback,
    this.updateEntryCallback,
    this.deleteEntryCallback
  });
}

class TodoListPage extends StatefulWidget {
  final SectionModel section;

  TodoListPage(this.section);

  @override
  TodoListPageState createState() => new TodoListPageState();
}

enum TodoVisibility { All, Undone, Done }

class TodoListPageState extends State<TodoListPage> {
  ScrollController _listViewScrollController = new ScrollController();

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<ReduxState, TodoListViewModel>(
      converter: (store) => new TodoListViewModel(
          todos: store.state.todos
              .where((todo) => todo.section == widget.section.id)
              .toList(),
          addEntryCallback: (entry) =>
              store.dispatch(new AddTodoAction(entry)),
          updateEntryCallback: (entry) =>
              store.dispatch(new UpdateTodoAction(entry)),
          deleteEntryCallback: (entry) =>
              store.dispatch(new DeleteTodoAction(entry)),
      ),
      builder: (context, viewModel) {
        return new Scaffold(
          appBar: new AppBar(
              title: new Text(widget.section.title),
              actions: <Widget>[
                new IconButton(
                  icon: new Icon(Icons.share),
                  onPressed: () => _share(viewModel),
                ),
              ]),
          body: _buildTodoList(context, viewModel),
          floatingActionButton: new FloatingActionButton(
            onPressed: () => _openAddEntryDialog(viewModel),
            tooltip: 'Add new ToDo',
            child: new Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildTodoList(BuildContext context, TodoListViewModel viewModel) {
    if (viewModel.todos.length == 0) {
      final ThemeData theme = Theme.of(context);
      final TextStyle textStyle = theme.textTheme.subhead
          .copyWith(color: theme.textTheme.caption.color);
          
      return new Center(child: new Text("No sections", style: textStyle));
    }

    var list = viewModel.todos.map((entry) => new InkWell(
          onTap: () => _showTodoBottomSheet(entry),
          onLongPress: () => _editTodoEntry(viewModel, entry),
          child: new TodoListItem(entry: entry),
        ));

    return new ListView(
        shrinkWrap: true,
        controller: _listViewScrollController,
        children: ListTile.divideTiles(context: context, tiles: list).toList());
  }

  void _showTodoBottomSheet(TodoEntryModel model) {
    assert(model != null);

    final ThemeData theme = Theme.of(context);
    final TextStyle titleTextStyle =
        theme.textTheme.title.copyWith(color: theme.textTheme.title.color);

    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return new ListView(children: <Widget>[
            new ListTile(
                leading: new Icon(Icons.title),
                title: new Text(model.title, style: titleTextStyle),
                trailing: getImportanceIcon(model.importance)),
            new ListTile(
                leading: new Icon(Icons.category),
                title: new Text(widget.section.title)),
            new ListTile(
                leading: new Icon(Icons.note),
                title: new Text(model.note.isNotEmpty ? model.note : "(Empty)",
                    maxLines: 5))
          ]);
        });
  }

  void _share(TodoListViewModel viewModel) {
    var shareString = "${widget.section.title}:\n";

    for (var item in viewModel.todos) {
      var importanceChar = '';
      switch (item.importance) {
        case TodoImportance.Middle:
          importanceChar = '!';
          break;
        case TodoImportance.High:
          importanceChar = '!!';
          break;
        default:
          importanceChar = '';
      }

      shareString +=
          "[${item.done ? 'x' : '  '}] $importanceChar ${item.title}\n";
    }

    share(shareString);
  }

  void _openAddEntryDialog(TodoListViewModel viewModel) async {
    var entry = await Navigator.of(context).push(
        new MaterialPageRoute<TodoEntryModel>(
          builder: (context) => new TodoEntryDialog.add(widget.section.id),
          fullscreenDialog: true
        )
    );

    if (entry != null) {
      setState(() => viewModel.addEntryCallback(entry));
    }
  }

  void _editTodoEntry(TodoListViewModel viewModel, TodoEntryModel entry) async {
    var newEntry = await Navigator.of(context).push<TodoEntryModel>(
        new MaterialPageRoute<TodoEntryModel>(
          builder: (context) => new TodoEntryDialog.edit(entry),
          fullscreenDialog: true
        )
    );

    if (newEntry != null) {
      setState(() => viewModel.updateEntryCallback(newEntry));
    }
  }
}

class TodoListItem extends StatefulWidget {
  TodoListItem({Key key, this.entry}) : super(key: key);

  final TodoEntryModel entry;

  @override
  TodoListItemState createState() => new TodoListItemState();
}

class TodoListItemViewModel {
  final Function(TodoEntryModel) updateEntryCallback;

  TodoListItemViewModel({this.updateEntryCallback});
}

class TodoListItemState extends State<TodoListItem> {
  @override
  Widget build(BuildContext context) {
    return new StoreConnector<ReduxState, TodoListItemViewModel>(
      converter: (store) => new TodoListItemViewModel(
        updateEntryCallback: (entry) => store.dispatch(new UpdateTodoAction(entry))
      ),
      builder: (context, viewModel) {
        return new ListTile(
        leading: new Checkbox(
          value: widget.entry.done,
          onChanged: (newValue) => setState(() {
            viewModel.updateEntryCallback(widget.entry.copyWith(done: newValue));
          })
        ),
        title: new Text(widget.entry.title,
            style: new TextStyle(
                fontSize: 18.0,
                decoration:
                    widget.entry.done ? TextDecoration.lineThrough : null)),
        subtitle: widget.entry.note.isNotEmpty
            ? new Text(
                widget.entry.note,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: getImportanceIcon(widget.entry.importance));
        })
    ;
  }
}
