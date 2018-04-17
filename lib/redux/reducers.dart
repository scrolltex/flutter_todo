import 'package:redux/redux.dart';
import 'package:redux_persist/redux_persist.dart';

import 'core.dart';
import 'actions.dart';
import '../model/todo_entry.dart';

ReduxState addSectionReducer(ReduxState state, AddSectionAction action) {
  int maxId = 0;
  for (var section in state.sections) {
    if (section.id > maxId) {
      maxId = section.id;
    }
  }

  return state.copyWith(
    sections: <SectionModel>[]
      ..addAll(state.sections)
      ..add(action.section.copyWith(id: maxId + 1))
  );
}

ReduxState updateSectionReducer(ReduxState state, UpdateSectionAction action) {
  var newSections = <SectionModel>[]..addAll(state.sections);
  newSections[newSections.indexWhere((section) => section.id == action.section.id)] = action.section;
    
  return state.copyWith(sections: newSections);
}

ReduxState deleteSectionReducer(ReduxState state, DeleteSectionAction action) {
  return state.copyWith(
    sections: <SectionModel>[]
      ..addAll(state.sections)
      ..remove(action.section),
    todos: <TodoEntryModel>[]
      ..addAll(state.todos.where((x) => x.section != action.section.id)),
    hasEntryBeenDeleted: true,
    lastRemovedSection: action.section,
    lastRemovedTodos: <TodoEntryModel>[]
      ..addAll(state.todos.where((x) => x.section == action.section.id))
  );
}

ReduxState undoDeletionSectionReducer(ReduxState state, UndoDeletionSectionAction action) {
  return state.copyWith(
    todos: <TodoEntryModel>[]
      ..addAll(state.todos)
      ..addAll(state.lastRemovedTodos),
    sections: <SectionModel>[]
      ..addAll(state.sections)
      ..add(state.lastRemovedSection)
      ..sort((x, y) => x.id.compareTo(y.id))
  );
}

ReduxState addTodoReducer(ReduxState state, AddTodoAction action) {
  int maxId = 0;
  for (var todo in state.todos) {
    if (todo.id > maxId) {
      maxId = todo.id;
    }
  }

  return state.copyWith(
    todos: <TodoEntryModel>[]
      ..addAll(state.todos)
      ..add(action.todo.copyWith(id: maxId + 1))
  );
}

ReduxState updateTodoReducer(ReduxState state, UpdateTodoAction action) {
  var newTodos = <TodoEntryModel>[]..addAll(state.todos);
  newTodos[newTodos.indexWhere((todo) => todo.id == action.todo.id)] = action.todo;
    
  return state.copyWith(todos: newTodos);
}

ReduxState deleteTodoReducer(ReduxState state, DeleteTodoAction action) {
  return state.copyWith(
    todos: <TodoEntryModel>[]
      ..addAll(state.todos)
      ..remove(action.todo),
    hasEntryBeenDeleted: true,
    lastRemovedTodos: <TodoEntryModel>[]
      ..add(action.todo)
  );
}

ReduxState undoDeletionTodoAction(ReduxState state, UndoDeletionTodoAction action) {
  return state.copyWith(
    todos: <TodoEntryModel>[]
      ..addAll(state.todos)
      ..addAll(state.lastRemovedTodos)
      ..sort((x, y) => x.id.compareTo(y.id))
  );
}

/// Main reducer
Reducer<ReduxState> stateReducer = combineReducers([
  // Misc reducers
  new TypedReducer<ReduxState, PersistLoadedAction<ReduxState>>((state, action) => action.state ?? state),
  new TypedReducer<ReduxState, AcceptDeletionAction>((state, action) => state.copyWith(hasEntryBeenDeleted: false)),

  // Section reducers
  new TypedReducer<ReduxState, AddSectionAction>(addSectionReducer),
  new TypedReducer<ReduxState, UpdateSectionAction>(updateSectionReducer),
  new TypedReducer<ReduxState, DeleteSectionAction>(deleteSectionReducer),
  new TypedReducer<ReduxState, UndoDeletionSectionAction>(undoDeletionSectionReducer),

  // Todo reducers
  new TypedReducer<ReduxState, AddTodoAction>(addTodoReducer),
  new TypedReducer<ReduxState, UpdateTodoAction>(updateTodoReducer),
  new TypedReducer<ReduxState, DeleteTodoAction>(deleteTodoReducer),
  new TypedReducer<ReduxState, UndoDeletionTodoAction>(undoDeletionTodoAction),
]);
