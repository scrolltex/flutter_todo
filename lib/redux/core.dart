import 'package:flutter/foundation.dart';

import '../model/todo_entry.dart';
import 'actions.dart';

@immutable
class ReduxState {
  final List<TodoEntryModel> todos;
  final List<SectionModel> sections;

  const ReduxState({
    @required this.todos,
    @required this.sections
  });

  ReduxState.initialState()
      : todos = <TodoEntryModel>[],
        sections = <SectionModel>[];

  ReduxState copyWith({
    List<TodoEntryModel> todos, 
    List<SectionModel> sections
  }) => new ReduxState(
      todos: todos ?? this.todos,
      sections: sections ?? this.sections
  );
}

ReduxState stateReducer(ReduxState state, action) {
  if (action is AddSectionAction) {    
    int maxId = 0;
    for (var section in state.sections) {
      if (section.id > maxId) {
        maxId = section.id;
      }
    }

    return state.copyWith(
      sections: <SectionModel>[]
        ..addAll(state.sections)
        ..add(action.section.copyWith(id: maxId + 1)));
  }

  if (action is AddTodoAction) {
    int maxId = 0;
    for (var todo in state.todos) {
      if (todo.id > maxId) {
        maxId = todo.id;
      }
    }

    return state.copyWith(
      todos: <TodoEntryModel>[]
        ..addAll(state.todos)
        ..add(action.todo.copyWith(id: maxId + 1)));
  }

  return state;
}
