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
  final Function(SectionModel) addSectionCallback;

  SectionsViewModel({this.sections, this.addSectionCallback});
}

class SectionsPage extends StatelessWidget {
  final _listViewScrollController = new ScrollController();

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<ReduxState, SectionsViewModel>(
      converter: (store) => new SectionsViewModel(
          sections: store.state.sections,
          addSectionCallback: (section) =>
              store.dispatch(new AddSectionAction(section))),
      builder: (context, viewModel) {
        return new Scaffold(
          appBar: new AppBar(
            title: const Text("Sections"),
          ),
          body: _buildSectionsList(context, viewModel),
          floatingActionButton: new FloatingActionButton(
            onPressed: () => _addNewSection(
                context, (section) => viewModel.addSectionCallback(section)),
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

    var list = viewModel.sections.map((entry) => new InkWell(
          onTap: () => Navigator.of(context).push(new MaterialPageRoute(
              builder: (context) => new TodoListPage(entry))),
          child: new ListTile(
            title: new Text(entry.title),
            trailing: new Icon(Icons.arrow_right),
          ),
        ));

    return list.length > 0
        ? new ListView(
            shrinkWrap: true,
            reverse: false,
            controller: _listViewScrollController,
            children:
                ListTile.divideTiles(context: context, tiles: list).toList())
        : new Center(child: new Text("No sections", style: textStyle));
  }

  void _addNewSection(BuildContext context, Function(SectionModel) addSectionCallback) async {
    var title = await showDialog<String>(
        context: context, builder: (context) => new AddSectionDialog());

    if (title != null && title.isNotEmpty)
      addSectionCallback(new SectionModel(id: 0, title: title));
  }
}

class AddSectionDialog extends StatelessWidget {
  final _textEditingController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new AlertDialog(
      title: new Text("Add new section"),
      content: new TextField(controller: _textEditingController),
      actions: <Widget>[
        new FlatButton(
            child: new Text("CANCEL"),
            onPressed: () => Navigator.of(context).pop(null)),
        new FlatButton(
          child: new Text("ADD"),
          onPressed: () =>
              Navigator.of(context).pop(_textEditingController.text),
        )
      ],
    );
  }
}
