import '../model/todo_entry.dart';

abstract class ReduxAction {
  String toString() {
    return '$runtimeType';
  }
}

class AddSectionAction extends ReduxAction {
  final SectionModel section;

  AddSectionAction(this.section);
}

class AddTodoAction extends ReduxAction {
  final TodoEntryModel todo;

  AddTodoAction(this.todo);
}