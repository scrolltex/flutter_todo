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

class UpdateSectionAction extends ReduxAction {
  final SectionModel section;

  UpdateSectionAction(this.section);
}

class DeleteSectionAction extends ReduxAction {
  final SectionModel section;

  DeleteSectionAction(this.section);
}

class AddTodoAction extends ReduxAction {
  final TodoEntryModel todo;

  AddTodoAction(this.todo);
}

class UpdateTodoAction extends ReduxAction {
  final TodoEntryModel todo;

  UpdateTodoAction(this.todo);
}

class DeleteTodoAction extends ReduxAction {
  final TodoEntryModel todo;

  DeleteTodoAction(this.todo);
}
