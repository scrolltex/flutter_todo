import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:redux_persist/redux_persist.dart';

import '../model/todo_entry.dart';
import 'actions.dart';

@immutable
class ReduxState {
  final List<TodoEntryModel> todos;
  final List<SectionModel> sections;

  final bool hasEntryBeenDeleted;
  final SectionModel lastRemovedSection;
  final List<TodoEntryModel> lastRemovedTodos;

  const ReduxState({
    @required this.todos,
    @required this.sections,
    this.hasEntryBeenDeleted = false,
    this.lastRemovedSection,
    this.lastRemovedTodos
  });

  ReduxState.initialState()
      : todos = <TodoEntryModel>[],
        sections = <SectionModel>[],
        hasEntryBeenDeleted = false,
        lastRemovedSection = null,
        lastRemovedTodos = null;

  ReduxState copyWith({
    List<TodoEntryModel> todos, 
    List<SectionModel> sections,
    bool hasEntryBeenDeleted,
    SectionModel lastRemovedSection,
    List<TodoEntryModel> lastRemovedTodos
  }) => new ReduxState(
      todos: todos ?? this.todos,
      sections: sections ?? this.sections,
      hasEntryBeenDeleted: hasEntryBeenDeleted ?? this.hasEntryBeenDeleted,
      lastRemovedSection: lastRemovedSection ?? this.lastRemovedSection,
      lastRemovedTodos: lastRemovedTodos ?? this.lastRemovedTodos,
  );

  static ReduxState fromJson(dynamic jsonObj) {
    // Parsing sections
    var loadedSectionsList = new List<SectionModel>();
    var loadedSections = json.decode(jsonObj['sections']);
    for (var item in loadedSections) {
      loadedSectionsList.add(new SectionModel.fromJson(item));
    }

    // Parsing todos
    var loadedTodosList = new List<TodoEntryModel>();
    var loadedTodos = json.decode(jsonObj['todos']);
    for (var item in loadedTodos) {
      loadedTodosList.add(new TodoEntryModel.fromJson(item));
    }

    // Return state
    return new ReduxState(
      todos: loadedTodosList,
      sections: loadedSectionsList
    );
  }

  Map toJson() => {
    'todos': json.encode(todos),
    'sections': json.encode(sections)
  };
}

ReduxState stateReducer(ReduxState state, action) {
  if (action is PersistLoadedAction<ReduxState>) {
    return action.state ?? state;
  }
  
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

  if (action is UpdateSectionAction) {
    var newSections = <SectionModel>[]..addAll(state.sections);
    newSections[newSections.indexWhere((section) => section.id == action.section.id)] = action.section;
    
    return state.copyWith(sections: newSections);
  }

  if (action is DeleteSectionAction) {  
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

  if (action is UndoDeletionSectionAction) {
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

  if (action is UpdateTodoAction) {
    var newTodos = <TodoEntryModel>[]..addAll(state.todos);
    newTodos[newTodos.indexWhere((todo) => todo.id == action.todo.id)] = action.todo;
    
    return state.copyWith(todos: newTodos);
  }

  if (action is DeleteTodoAction) {    
    return state.copyWith(
      todos: <TodoEntryModel>[]
        ..addAll(state.todos)
        ..remove(action.todo),
      hasEntryBeenDeleted: true,
      lastRemovedTodos: <TodoEntryModel>[]
        ..add(action.todo)
    );
  }

  if (action is UndoDeletionTodoAction) {
    return state.copyWith(
      todos: <TodoEntryModel>[]
        ..addAll(state.todos)
        ..addAll(state.lastRemovedTodos)
        ..sort((x, y) => x.id.compareTo(y.id))
    );
  }

  if (action is AcceptDeletionAction) {
    return state.copyWith(hasEntryBeenDeleted: false);
  }

  return state;
}
